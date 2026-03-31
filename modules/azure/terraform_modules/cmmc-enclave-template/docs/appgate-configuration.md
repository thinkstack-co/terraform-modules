# Appgate SDP: Post-Deployment Configuration

Post-deployment steps after `terraform apply` with `deploy_vms = true` in the `04-appgate-sdp` module. Covers both the scripted (primary) and manual (fallback) workflows.

---

## Architecture Overview

```text
Internet
  |
  +- TCP/UDP 443 -> Firewall PIP[0] (<customer>-ztna-ag-ctl.<region>.cloudapp.usgovcloudapi.net)
  |                  +- DNAT -> Controller VM (private IP, ZTNA subnet)
  |
  +- TCP/UDP 443 -> Firewall PIP[1] (<customer>-ztna-ag-gw.<region>.cloudapp.usgovcloudapi.net)
                     +- DNAT -> Gateway VM (private IP, ZTNA subnet)
```

**No VM public IPs.** Both VMs are private-only. All client and admin traffic routes through Azure Firewall DNAT. Admin SSH access is via firewall DNAT or Azure Bastion.

**ZTNA subnet UDR** routes all VM egress (0.0.0.0/0) through Azure Firewall. This creates a routing constraint: the Gateway must resolve the controller FQDN to the controller's **private IP**, not the firewall public IP. If it resolves to the firewall public IP, traffic hairpins through the firewall and causes asymmetric routing (TCP RST). This is handled by populating `networking.hosts` during gateway registration.

---

## What Terraform Creates

Before starting post-deployment configuration, Terraform has already provisioned:

- **Key Vault** (`<prefix>-ag-kv-1`) with SSH key pairs:
  - `ag-ctl-private-key` — controller SSH private key
  - `ag-gw-private-key` — gateway SSH private key
- **Controller and Gateway VMs** (when `deploy_vms = true`), SSH user: `cz`
- **Firewall DNAT rules** — PIP[0] maps to controller, PIP[1] maps to gateway (TCP/UDP 443, SSH 22, admin UI 8443)
- **Entra ID OIDC app registration** (`<customer_name> - Appgate OIDC`) with service principal
  - Redirect URIs: `appgate://oidccallback`, `http://localhost:29001/oidc`
  - Scopes: openid, profile, email, offline_access
  - Group membership claims enabled
- **Marketplace agreement** for `cyxtera:appgatesdp-vm:v6_5_vm`

### Gather Terraform Outputs

```bash
terraform output -raw module.appgate_sdp.key_vault_name       # KV_NAME
terraform output -raw module.appgate_sdp.controller_fqdn      # CTL_FQDN
terraform output -raw module.appgate_sdp.controller_private_ip # CTL_IP
terraform output -raw module.appgate_sdp.gateway_fqdn         # GW_FQDN
terraform output -raw module.appgate_sdp.gateway_private_ip   # GW_IP
terraform output -raw module.appgate_sdp.oidc_client_id       # OIDC_CLIENT_ID
terraform output -raw module.mgmt_vnet.firewall_public_ip     # FW_PIP_1
terraform output -raw module.mgmt_vnet.firewall_public_ip_2   # FW_PIP_2
```

> Module paths depend on how your root module names them. Adjust `module.appgate_sdp` / `module.mgmt_vnet` as needed.

---

## Prerequisites

- `terraform apply` completed with `deploy_vms = true`
- Azure CLI installed and logged into Azure Government (`az cloud set --name AzureUSGovernment`)
- PowerShell 7+ with `Az` module (for scripted workflow)
- `jq` and OpenSSH installed
- An admin password chosen for the Appgate controller
- Network access to controller/gateway FQDNs on port 22 (SSH) — your IP must be in `source_admin_ips`

---

## Scripted Workflow (Primary)

The `Scripts/` directory contains automation that handles the full post-deployment configuration.

### Step 1 — Run setup.ps1

Downloads provisioning scripts, retrieves SSH keys from Key Vault, and generates an environment file.

```powershell
.\setup.ps1 `
  -VaultName "<key-vault-name>" `
  -CustomerShortName "<short-name>" `
  -AdminPass "<admin-password>" `
  -ControllerDnsName "<controller-fqdn>" `
  -ControllerIp "<controller-private-ip>" `
  -GatewayDnsName "<gateway-fqdn>" `
  -TenantId "<tenant-id>" `
  -OidcClientId "<oidc-client-id>"
```

| Parameter | Source |
|-----------|--------|
| VaultName | `terraform output -raw module.appgate_sdp.key_vault_name` |
| CustomerShortName | Short customer identifier (used in appliance names) |
| AdminPass | Your chosen Appgate admin password |
| ControllerDnsName | `terraform output -raw module.appgate_sdp.controller_fqdn` |
| ControllerIp | `terraform output -raw module.appgate_sdp.controller_private_ip` |
| GatewayDnsName | `terraform output -raw module.appgate_sdp.gateway_fqdn` |
| TenantId | Your Entra ID tenant ID |
| OidcClientId | `terraform output -raw module.appgate_sdp.oidc_client_id` |

### Step 2 — Run provision-appgate.sh

Switch to bash, source the environment file, and run the provisioning orchestrator:

```bash
bash
. ./env.sh
./provision-appgate.sh $CUSTOMERSHORTNAME $ADMINPASS $CONTROLLERDNS $CONTROLLERIP $GATEWAYDNS $TENANT_ID $AUDIENCE_ID
```

This executes 8 steps:

1. **Seed controller** — SSHes to controller, runs `sudo cz-seed` with firewall-allowed NTP server IPs to bootstrap the appliance
2. **Register gateway** — Registers gateway via controller API with `networking.hosts` (controller FQDN -> private IP)
3. **Transfer gateway seed** — SCPs the seed from controller to gateway at `/home/cz/seed.json`, waits for gateway to reach `appliance_ready`
4. **Enable full tunnel** — Updates Default Site to enable default gateway routing (IPv4 + IPv6)
5. **Create OIDC identity provider** — Creates "OIDC" identity provider using Entra ID issuer and the Terraform-created app's client ID
6. **Create entitlement** — Creates "Outbound All Protocols - Full Tunnel" (TCP/UDP/ICMP to 0.0.0.0/0)
7. **Create policy** — Creates "Full Tunnel Access - OIDC" linking the entitlement to OIDC-authenticated users
8. **Create client profile** — Creates "Full Tunnel Client Profile" bound to the OIDC identity provider

Logs are written to `provision-log-<timestamp>.log`.

### Step 3 — Grant Admin Consent in Entra ID

This step must be done manually in the Azure portal:

1. Open `portal.azure.us` -> Microsoft Entra ID -> App registrations
2. Find the app named `<customer_name> - Appgate OIDC`
3. Go to **API permissions** -> **Grant admin consent for \<tenant\>**

---

## Manual Workflow (Fallback)

Use these steps if the scripted workflow fails or for troubleshooting individual steps.

### Step 1 — Retrieve SSH Keys

```bash
KV_NAME="<key-vault-name>"  # from terraform output module.appgate_sdp.key_vault_name

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

### Step 2 — Seed the Controller

SSH to the controller (via firewall DNAT or Bastion):

```bash
# Option A: Direct SSH via firewall DNAT (your IP must be in source_admin_ips)
ssh -i ctl.pem -o StrictHostKeyChecking=no cz@<controller-fqdn>

# Option B: Azure Bastion tunnel
az network bastion tunnel \
  --name <bastion-name> \
  --resource-group <mgmt-resource-group> \
  --target-resource-id <controller-vm-resource-id> \
  --resource-port 22 \
  --port 2222 &
ssh -i ctl.pem -p 2222 cz@127.0.0.1
```

On the controller, run `cz-seed` (requires `sudo`):

> **Critical:** The `--ntp-server` flags are required. The Azure Firewall only allows NTP traffic to specific IPs. Without these flags, `cz-configd` configures NTP with pool hostnames that resolve to IPs blocked by the firewall. NTP never syncs, PostgreSQL init fails, and the controller stays stuck at `waiting_config`.

```bash
sudo cz-seed \
  --dhcp-ipv4 eth0 \
  --appliance-name "<customershortname>-controller" \
  --profile-hostname "<controller-fqdn>" \
  --hostname "<controller-fqdn>" \
  --admin-hostname "<controller-fqdn>" \
  --admin-password "<admin-password>" \
  --ntp-server 91.189.91.157 \
  --ntp-server 91.189.89.198 \
  --ntp-server 91.189.94.4 \
  --ntp-server 91.189.91.156 > /home/cz/seed.json
```

Wait for the controller to reach `appliance_ready`:

```bash
watch "sudo cz-config status | jq -r .state"
# Wait until: "appliance_ready"
```

### Step 3 — Register and Seed the Gateway

Register the gateway via the controller REST API. This must be done from a machine that can reach the controller on port 8443 (e.g., from the controller itself via SSH).

**3a. Authenticate:**

```bash
CTL_IP="<controller-private-ip>"

TOKEN=$(curl -sk -X POST "https://$CTL_IP:8443/admin/login" \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.appgate.peer-v19+json" \
  -d '{
    "providerName": "local",
    "username": "admin",
    "password": "<admin-password>",
    "deviceId": "'$(cat /proc/sys/kernel/random/uuid)'"
  }' | jq -r '.token')
```

**3b. Get Default Site ID:**

```bash
SITE_ID=$(curl -sk -X GET "https://$CTL_IP:8443/admin/sites" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/vnd.appgate.peer-v19+json" | jq -r '.data[0].id')
```

**3c. Register gateway appliance:**

> **Critical:** The `networking.hosts` entry maps the controller FQDN to its private IP. Without this, the gateway resolves the controller FQDN to the firewall public IP, causing hairpin routing through the Azure Firewall -> asymmetric routing -> TCP RST during activation. Appgate's `cz-coredns` does **not** read `/etc/hosts` — `networking.hosts` is the only way to inject custom DNS entries.

```bash
CTL_FQDN="<controller-fqdn>"
GW_FQDN="<gateway-fqdn>"

GW_ID=$(curl -sk -X POST "https://$CTL_IP:8443/admin/appliances" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.appgate.peer-v19+json" \
  -d '{
    "name": "<customershortname>-gateway",
    "hostname": "'$GW_FQDN'",
    "site": "'$SITE_ID'",
    "clientInterface": {
      "proxyProtocol": false,
      "hostname": "'$GW_FQDN'",
      "httpsPort": 443,
      "dtlsPort": 443,
      "allowSources": [
        {"address": "0.0.0.0", "netmask": 0},
        {"address": "::", "netmask": 0}
      ]
    },
    "networking": {
      "hosts": [{"hostname": "'$CTL_FQDN'", "address": "'$CTL_IP'"}],
      "nics": [{
        "enabled": true, "name": "eth0",
        "ipv4": {"dhcp": {"enabled": true, "dns": true, "routers": true, "ntp": false, "mtu": false}, "static": []},
        "ipv6": {"dhcp": {"enabled": false, "dns": true, "routers": true, "ntp": false, "mtu": false}, "static": []}
      }],
      "dnsServers": [], "dnsDomains": [], "routes": []
    },
    "ntp": {"servers": [
      {"hostname": "91.189.91.157"}, {"hostname": "91.189.89.198"},
      {"hostname": "91.189.94.4"}, {"hostname": "91.189.91.156"}
    ]},
    "sshServer": {
      "enabled": true, "port": 22,
      "allowSources": [{"address": "0.0.0.0", "netmask": 0}, {"address": "::", "netmask": 0}],
      "passwordAuthentication": true
    },
    "gateway": {
      "enabled": true, "suspended": false,
      "vpn": {"weight": 100, "allowDestinations": [{"address": "0.0.0.0", "netmask": 0, "nic": "eth0"}]}
    }
  }' | jq -r '.id')
```

**3d. Export seed and transfer to gateway:**

```bash
# Export seed from controller
curl -sk -X POST "https://$CTL_IP:8443/admin/appliances/$GW_ID/export" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.appgate.peer-v19+json" \
  -d '{"provideCloudSSHKey": true, "allowCustomization": false, "validityDays": 1}' > /tmp/gw-seed.json

# From your workstation: copy seed to gateway
scp -i ctl.pem cz@<controller-fqdn>:/tmp/gw-seed.json ./gw-seed.json
scp -i gw.pem ./gw-seed.json cz@<gateway-fqdn>:/home/cz/seed.json
```

Wait for the gateway to activate:

```bash
ssh -i gw.pem cz@<gateway-fqdn>
watch "cz-config status | jq -r .state"
# Wait until: "appliance_ready"
```

### Step 4 — Enable Full Tunnel on Default Site

Authenticate to the controller API (same as Step 3a), then:

```bash
# Get Default Site full config
SITE_CONFIG=$(curl -sk -X GET "https://$CTL_IP:8443/admin/sites/$SITE_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/vnd.appgate.peer-v19+json")

# Update defaultGateway
UPDATED=$(echo "$SITE_CONFIG" | jq '.defaultGateway = {
  "enabledV4": true,
  "enabledV6": true,
  "excludedSubnets": []
}')

curl -sk -X PUT "https://$CTL_IP:8443/admin/sites/$SITE_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.appgate.peer-v19+json" \
  -d "$UPDATED"
```

### Step 5 — Create OIDC Identity Provider

```bash
TENANT_ID="<tenant-id>"
OIDC_CLIENT_ID="<oidc-client-id>"  # from terraform output module.appgate_sdp.oidc_client_id

# Get IP pool ID
IPPOOL=$(curl -sk -X GET "https://$CTL_IP:8443/admin/ip-pools" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/vnd.appgate.peer-v19+json" | jq -r '.data[] | select(.name == "default pool v4") | .id')

curl -sk -X POST "https://$CTL_IP:8443/admin/identity-providers" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.appgate.peer-v19+json" \
  -d '{
    "name": "OIDC",
    "type": "Oidc",
    "issuer": "https://login.microsoftonline.us/'$TENANT_ID'/v2.0",
    "audience": "'$OIDC_CLIENT_ID'",
    "scope": "openid profile email offline_access",
    "ipPoolV4": "'$IPPOOL'",
    "deviceLimitPerUser": 100,
    "inactivityTimeoutMinutes": 720,
    "claimMappings": [
      {"attributeName": "groups",             "claimName": "idp_groups", "list": true,  "encrypt": false},
      {"attributeName": "sub",                "claimName": "userId",     "list": false, "encrypt": false},
      {"attributeName": "preferred_username",  "claimName": "username",   "list": false, "encrypt": false},
      {"attributeName": "given_name",          "claimName": "firstName",  "list": false, "encrypt": false},
      {"attributeName": "family_name",         "claimName": "lastName",   "list": false, "encrypt": false},
      {"attributeName": "email",              "claimName": "emails",     "list": true,  "encrypt": false}
    ]
  }'
```

### Step 6 — Grant Admin Consent in Entra ID

1. Open `portal.azure.us` -> Microsoft Entra ID -> App registrations
2. Find `<customer_name> - Appgate OIDC`
3. Go to **API permissions** -> **Grant admin consent for \<tenant\>**

### Step 7 — Create Full Tunnel Entitlement

```bash
# Generate unique action IDs
TCP_ID=$(cat /proc/sys/kernel/random/uuid)
UDP_ID=$(cat /proc/sys/kernel/random/uuid)
ICMP_ID=$(cat /proc/sys/kernel/random/uuid)

curl -sk -X POST "https://$CTL_IP:8443/admin/entitlements" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.appgate.peer-v19+json" \
  -d '{
    "name": "Outbound All Protocols - Full Tunnel",
    "notes": "Allows outbound access to all destinations and ports",
    "site": "'$SITE_ID'",
    "conditionLogic": "and",
    "conditions": ["ee7b7e6f-e904-4b4f-a5ec-b3bef040643e"],
    "actions": [
      {"type": "IpAccess", "action": "allow", "hosts": ["0.0.0.0/0"], "subtype": "tcp_up", "ports": ["1-65535"], "monitor": {"enabled": false, "timeout": 30}, "id": "'$TCP_ID'"},
      {"type": "IpAccess", "action": "allow", "hosts": ["0.0.0.0/0"], "subtype": "udp_up", "ports": ["1-65535"], "monitor": {"enabled": false, "timeout": 30}, "id": "'$UDP_ID'"},
      {"type": "IpAccess", "action": "allow", "hosts": ["0.0.0.0/0"], "subtype": "icmp_up", "types": ["0-255"], "id": "'$ICMP_ID'"}
    ],
    "disabled": false
  }'
```

### Step 8 — Create Full Tunnel Policy

```bash
# Get entitlement ID
ENT_ID=$(curl -sk -X GET "https://$CTL_IP:8443/admin/entitlements" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/vnd.appgate.peer-v19+json" | jq -r '.data[] | select(.name == "Outbound All Protocols - Full Tunnel") | .id')

# Get OIDC IdP ID
IDP_ID=$(curl -sk -X GET "https://$CTL_IP:8443/admin/identity-providers" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/vnd.appgate.peer-v19+json" | jq -r '.data[] | select(.name == "OIDC") | .id')

EXPRESSION="var result = false; if(claims.user.ag.identityProviderId === \"$IDP_ID\") { result = true; } else { return false; } return result;"

curl -sk -X POST "https://$CTL_IP:8443/admin/policies" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.appgate.peer-v19+json" \
  -d "$(jq -n \
    --arg name "Full Tunnel Access - OIDC" \
    --arg expression "$EXPRESSION" \
    --arg entitlement "$ENT_ID" \
    '{name: $name, type: "Access", entitlements: [$entitlement], expression: $expression, disabled: false}')"
```

### Step 9 — Create Client Profile

```bash
curl -sk -X POST "https://$CTL_IP:8443/admin/client-profiles" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.appgate.peer-v19+json" \
  -d '{"name": "Full Tunnel Client Profile", "type": "Profile", "identityProviderName": "OIDC"}'
```

---

## Client Connectivity Verification

1. Open Appgate SDP client
2. **Add Profile** -> enter controller FQDN: `<customer>-ztna-ag-ctl.<region>.cloudapp.usgovcloudapi.net`
3. Sign in with Entra ID credentials
4. Verify tunnel establishes and traffic routes through the gateway

---

## Admin Access Reference

| Access | Method |
| --- | --- |
| Controller admin UI | `https://<firewall-pip-1>:8443` or `https://<controller-fqdn>:8443` |
| Controller SSH | `ssh -i ctl.pem cz@<controller-fqdn>` or via Bastion |
| Gateway SSH | `ssh -i gw.pem cz@<gateway-fqdn>` or via Bastion |
| SSH keys | Azure Key Vault: `ag-ctl-private-key`, `ag-gw-private-key` |

Firewall PIP addresses and FQDNs are available as Terraform outputs:

```bash
terraform output -raw module.appgate_sdp.controller_fqdn
terraform output -raw module.appgate_sdp.gateway_fqdn
terraform output -raw module.mgmt_vnet.firewall_public_ip
terraform output -raw module.mgmt_vnet.firewall_public_ip_2
```
