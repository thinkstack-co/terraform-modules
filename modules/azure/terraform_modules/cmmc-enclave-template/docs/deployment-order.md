# Deployment Order

This guide describes the recommended sequence for deploying the CMMC enclave. Modules are numbered to match the SOP sequence.

---

## Prerequisites

- Bootstrap complete (see [bootstrap.md](bootstrap.md))
- Customer repo created with `versions.tf`, `providers.tf`, `backend.tf`, `main.tf`
- TFC workspace created, connected to the repo (VCS-driven), and all variables set:
  - Terraform variables: `customer_name`, `storage_account_name`, `location`, `environment`, `admin_upns`, `admin_source_ips`, `vm_admin_password` (sensitive)
  - Environment variables: `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`, `ARM_ENVIRONMENT` (all sensitive)

---

## Full Deployment Sequence

### Step 1: Initialize

```bash
terraform init
terraform validate
```

### Step 2: Plan Everything

```bash
terraform plan -out=tfplan
```

Review the plan output. Expected resource count: ~90-110 resources depending on session host count.

### Step 3: Deploy in Stages (Recommended for First Deployment)

Deploy stage by stage using `-target` to isolate failures:

```bash
# Stage 1: Identity foundation
terraform apply -target=module.entra

# Stage 2: Management network
terraform apply -target=azurerm_resource_group.mgmt -target=module.mgmt_vnet

# Stage 3: Production network + ZTNA (parallel)
terraform apply \
  -target=azurerm_resource_group.prod \
  -target=azurerm_resource_group.ztna \
  -target=module.prod_vnet \
  -target=module.appgate_sdp

# Stage 4: AVD + Storage + Imaging + Image Builder (parallel)
terraform apply \
  -target=azurerm_resource_group.avd \
  -target=azurerm_resource_group.storage \
  -target=azurerm_resource_group.imaging \
  -target=module.avd \
  -target=module.storage \
  -target=module.vm_imaging \
  -target=module.image_builder

# Stage 5: Trigger image build (manual — ~60-90 min)
az image builder run \
  --name <customer>-aib-win11-m365 \
  --resource-group <customer>-imaging-rg \
  --no-wait

# Monitor until runState = Succeeded
az image builder show \
  --name <customer>-aib-win11-m365 \
  --resource-group <customer>-imaging-rg \
  --query "lastRunStatus" \
  --output table

# Stage 6: Session hosts — deploy AFTER image build completes
#          Must run within 2 hours of Stage 4 (registration token expiry)
terraform apply \
  -target=module.session_hosts_mgmt \
  -target=module.session_hosts_prod

# Stage 7: Intune policies (DISABLED — Azure Gov OIDC not supported)
# Re-enable module "intune" in main.tf when a compatible provider is available
# terraform apply -target=module.intune
```

### Step 4: Full Apply (Subsequent Deployments)

After the initial deployment, use a full apply for changes:

```bash
terraform apply
```

---

## Registration Token Warning

AVD host pool registration tokens (used to join session hosts) expire **2 hours** after `terraform apply`. If deploying session hosts is delayed:

```bash
# Refresh tokens only
terraform apply \
  -target=module.avd.azurerm_virtual_desktop_host_pool_registration_info.mgmt \
  -target=module.avd.azurerm_virtual_desktop_host_pool_registration_info.customer

# Then immediately apply session hosts
terraform apply \
  -target=module.session_hosts_mgmt \
  -target=module.session_hosts_prod
```

---

## Image Build Notes

The image build (Stage 5) is intentionally outside Terraform. The `10-image-builder` module provisions the AIB template; the build must be triggered manually after `terraform apply`. This decouples the ~60-90 minute build from the Terraform apply cycle.

To rebuild the image after the initial build (e.g., for monthly patching):

```bash
az image builder run \
  --name <customer>-aib-win11-m365 \
  --resource-group <customer>-imaging-rg \
  --no-wait
```

A new image version is created in the gallery each time the build runs. Session hosts will use the latest version on next deployment.

---

## Post-Deployment Verification

### Entra ID

- [ ] Security groups visible in Entra ID admin center
- [ ] Conditional access policies active (Require MFA, Block non-US, Block legacy auth)
- [ ] PIM eligible assignments visible in PIM dashboard

### Networking

- [ ] Management VNet and production VNet visible in Azure portal
- [ ] VNet peering status: Connected (bidirectional)
- [ ] Azure Firewall status: Running
- [ ] Bastion host: Succeeded

### AVD

- [ ] Host pools visible in Azure Virtual Desktop admin center
- [ ] Workspaces and application groups associated correctly
- [ ] Session hosts show as Available in host pool (mgmt + prod)

### Storage

- [ ] Storage account accessible from mgmt-avd and prod-avd subnets
- [ ] `fslogixprofiles` share exists
- [ ] Backup policy applied, protection status: Protected

### Image Builder

- [ ] AIB template `<customer>-aib-win11-m365` visible in Azure portal (resource group: `<customer>-imaging-rg`)
- [ ] After build: image version appears in `<customer>Gallery/win11-multisession`

### Intune

- [ ] (Pending Azure Gov provider support) Configuration policies visible in Intune portal (intune.microsoft.us)

---

## Appgate SDP Post-Deployment

If Appgate VMs have been deployed (after completing module 04), run the configuration scripts:

```bash
# From Azure Cloud Shell or a machine with connectivity to the ZTNA subnet

# 1. Provision Appgate on Controller
ssh -i <ctl-private-key> appgate@<ctl-public-ip> < scripts/provision-appgate.sh

# 2. Seed Controller
bash scripts/seed-controller.sh <ctl-private-ip>

# 3. Seed Gateway
bash scripts/seed-gateway.sh <gw-private-ip>

# 4. Configure OIDC identity provider
bash scripts/create-oidc-idp.sh

# 5. Configure client profiles, policies, entitlements
bash scripts/create-client-profile.sh
bash scripts/create-tunnel-policy.sh
bash scripts/create-full-tunnel-entitlement.sh
bash scripts/enable-full-tunnel-default-site.sh
```
