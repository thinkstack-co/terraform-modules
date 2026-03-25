# Appgate SDP: Post-Deployment Configuration

This guide covers all manual configuration steps required after `terraform apply` with `deploy_vms = true` in the `04-appgate-sdp` module.

---

## Architecture Overview

```text
Internet
  │
  ├─ TCP/UDP 443 → Firewall PIP[0] (<customer>-ztna-ag-ctl.<region>.cloudapp.usgovcloudapi.net)
  │                  └─ DNAT → Controller VM (private IP, ZTNA subnet)
  │
  └─ TCP/UDP 443 → Firewall PIP[1] (<customer>-ztna-ag-gw.<region>.cloudapp.usgovcloudapi.net)
                     └─ DNAT → Gateway VM (private IP, ZTNA subnet)
```

**No VM public IPs.** Both VMs are private-only. All client and admin traffic routes through Azure Firewall DNAT. Admin SSH and UI access is via firewall DNAT or Azure Bastion.

**ZTNA subnet UDR** routes all VM egress (0.0.0.0/0) through Azure Firewall. This is required for CMMC compliance but creates a routing constraint: the Gateway must resolve the controller FQDN to the controller's **private IP**, not the firewall public IP. If it resolves to the firewall public IP, traffic hairpins through the firewall and causes asymmetric routing → TCP RST. This is handled in Step 3 below.

---

## Prerequisites

- `terraform apply` completed with `deploy_vms = true`
- Key Vault deployed and SSH key secrets populated
- Azure CLI installed and logged into Azure Government (`az cloud set --name AzureUSGovernment`)
- Azure Bastion deployed (from `02-mgmt-vnet`) for private SSH access

---

## Step 1 — Retrieve SSH Keys

Retrieve the Controller and Gateway SSH private keys from Key Vault:

```bash
KV_NAME="<key-vault-name>"  # e.g., owi-ztna-ag-kv-1 — from terraform output key_vault_name

az keyvault secret show \
  --vault-name $KV_NAME \
  --name ag-ctl-private-key \
  --query value -o tsv > ctl.pem

az keyvault secret show \
  --vault-name $KV_NAME \
  --name ag-gw-private-key \
  --query value -o tsv > gw.pem

chmod 600 ctl.pem gw.pem
```

---

## Step 2 — Seed the Controller

SSH to the controller via Azure Bastion tunnel:

```bash
CTL_PRIVATE_IP="<controller-private-ip>"  # from terraform output controller_private_ip
BASTION_NAME="<bastion-name>"
BASTION_RG="<mgmt-resource-group>"
CTL_VM_ID="<controller-vm-resource-id>"

# Open Bastion tunnel (runs in background)
az network bastion tunnel \
  --name $BASTION_NAME \
  --resource-group $BASTION_RG \
  --target-resource-id $CTL_VM_ID \
  --resource-port 22 \
  --port 2222 &

ssh -i ctl.pem -p 2222 appgate@127.0.0.1
```

On the controller, run `cz-config setup` with the initial seed JSON. The seed requires at minimum:

- Admin password
- Hostname (set to the controller FQDN: `<customer>-ztna-ag-ctl.<region>.cloudapp.usgovcloudapi.net`)

```bash
# On the controller VM
cz-config setup - <<'EOF'
{
  "password": "<admin-password>",
  "controllerHostname": "<customer>-ztna-ag-ctl.<region>.cloudapp.usgovcloudapi.net"
}
EOF
```

Wait for the controller to reach `appliance_ready`:

```bash
watch cz-config status
# Expected: {"state": "appliance_ready", "healthy": true, ...}
```

---

## Step 3 — Configure Gateway `networking.hosts` and Generate Seed

The Gateway must resolve the controller FQDN to the controller's **private IP** so that `cz-coredns` (Appgate's internal DNS resolver) routes gateway-to-controller traffic directly, bypassing the Azure Firewall hairpin.

> **Why this is required:** Appgate's `cz-coredns` does **not** read `/etc/hosts`. The only way to inject custom DNS entries is via the `networking.hosts` array in the appliance config, set through the controller API. Without this, the gateway resolves the controller FQDN to the firewall public IP → hairpin → asymmetric routing → TCP RST during gateway activation.

Use the controller REST API to set the `networking.hosts` entry and export the gateway seed. The following Python script can be run from the gateway VM (which has network access to the controller at its private IP):

```python
#!/usr/bin/env python3
"""
fix_and_seed.py — Set networking.hosts on gateway, then export seed.
Run on the gateway VM: python3 fix_and_seed.py
"""
import json, urllib.request, ssl, sys

CTL_IP   = "<controller-private-ip>"
CTL_FQDN = "<customer>-ztna-ag-ctl.<region>.cloudapp.usgovcloudapi.net"
GW_ID    = "<gateway-appliance-id>"   # visible in controller admin UI → Appliances
ADMIN_PW = "<admin-password>"
SEED_PATH = "/home/cz/seed.json"

BASE = f"https://{CTL_IP}:8443/admin/v20"
ctx = ssl.create_default_context(); ctx.check_hostname = False; ctx.verify_mode = ssl.CERT_NONE

def req(method, path, body=None):
    data = json.dumps(body).encode() if body else None
    r = urllib.request.Request(f"{BASE}{path}", data=data, method=method,
        headers={"Content-Type":"application/json",
                 "Authorization": f"Bearer {token}"})
    with urllib.request.urlopen(r, context=ctx) as resp:
        return json.loads(resp.read()) if resp.length else {}

# Authenticate
auth_req = urllib.request.Request(f"{BASE}/login",
    data=json.dumps({"name":"admin","password":ADMIN_PW,"providerName":"local"}).encode(),
    method="POST", headers={"Content-Type":"application/json"})
with urllib.request.urlopen(auth_req, context=ctx) as r:
    token = json.loads(r.read())["token"]

# Get gateway config
cfg = req("GET", f"/appliances/{GW_ID}")

# Add networking.hosts entry
hosts = cfg.get("networking", {}).get("hosts", [])
if not any(h.get("hostname") == CTL_FQDN for h in hosts):
    hosts.append({"hostname": CTL_FQDN, "address": CTL_IP})
    cfg.setdefault("networking", {})["hosts"] = hosts
    req("PUT", f"/appliances/{GW_ID}", cfg)
    print(f"Set networking.hosts: {CTL_FQDN} → {CTL_IP}")

# Export seed
seed = req("POST", f"/appliances/{GW_ID}/export")
with open(SEED_PATH, "w") as f:
    json.dump(seed, f)
print(f"Seed written to {SEED_PATH} ({len(json.dumps(seed))} bytes)")
```

After writing the seed, activate the gateway:

```bash
# On the gateway VM
cz-config setup /home/cz/seed.json
watch cz-config status
# Expected: {"state": "appliance_ready", "healthy": true, ...}
```

---

## Step 4 — Configure OIDC Identity Provider

In the controller admin UI (`https://<controller-fqdn>:8443`):

1. Navigate to **Identity Providers** → **New**
2. Select **OIDC**
3. Configure:
   - **Name**: `Entra ID`
   - **Issuer**: `https://login.microsoftonline.us/<tenant-id>/v2.0`
   - **Client ID**: value of `terraform output -raw module.appgate_sdp.oidc_client_id`
   - **Scopes**: `openid profile email offline_access`
   - **Redirect URIs**: `appgate://oidccallback`, `http://localhost:29001/oidc`
4. Save

Grant admin consent for the OIDC app in Entra ID:

1. Open `portal.azure.us` → Azure Active Directory → App registrations
2. Find the app named `<customer> - Appgate OIDC`
3. Go to **API permissions** → **Grant admin consent for \<tenant\>**

---

## Step 5 — Create Client Profile

In the controller admin UI:

1. Navigate to **Client Profiles** → **New**
2. Configure:
   - **Name**: `<Customer> Full Tunnel`
   - **SPA Key ID**: (generate or use existing)
   - **Controller Hostname**: `<customer>-ztna-ag-ctl.<region>.cloudapp.usgovcloudapi.net`
   - **Identity Provider**: `Entra ID` (from Step 4)
3. Save

---

## Step 6 — Create Policies and Entitlements

### Policy

1. Navigate to **Policies** → **New**
2. Create a policy that assigns the Full Tunnel entitlement to authenticated users
3. Assign to the OIDC identity provider and target Entra group

### Entitlement

1. Navigate to **Entitlements** → **New**
2. Create a Full Tunnel entitlement:
   - **Type**: Full Tunnel
   - **Default Site**: enabled
3. Associate with the policy

---

## Client Connectivity Verification

1. Open Appgate SDP client
2. **Add Profile** → enter controller FQDN: `<customer>-ztna-ag-ctl.<region>.cloudapp.usgovcloudapi.net`
3. Sign in with Entra credentials
4. Verify tunnel establishes and traffic routes through the gateway

---

## Admin Access Reference

| Access | Method |
|---|---|
| Controller admin UI | `https://<firewall-pip-1>:8443` or `https://<controller-fqdn>:8443` |
| Controller SSH | `ssh -i ctl.pem appgate@<firewall-pip-1>` or via Bastion |
| Gateway SSH | `ssh -i gw.pem appgate@<firewall-pip-2>` or via Bastion |
| SSH keys | Azure Key Vault — `ag-ctl-private-key`, `ag-gw-private-key` |

Firewall PIP addresses and controller/gateway FQDNs are available as Terraform outputs:

```bash
terraform output -raw module.appgate_sdp.controller_fqdn
terraform output -raw module.appgate_sdp.gateway_fqdn
terraform output -raw module.mgmt_vnet.firewall_public_ip
terraform output -raw module.mgmt_vnet.firewall_public_ip_2
```
