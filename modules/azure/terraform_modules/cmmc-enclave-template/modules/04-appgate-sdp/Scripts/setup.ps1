param (
    [Parameter(Mandatory = $true)]
    [string]$VaultName,

    [Parameter(Mandatory = $true)]
    [string]$CustomerShortName,

    [Parameter(Mandatory = $true)]
    [string]$AdminPass,

    [Parameter(Mandatory = $true)]
    [string]$ControllerDnsName,

    [Parameter(Mandatory = $true)]
    [string]$ControllerIp,

    [Parameter(Mandatory = $true)]
    [string]$GatewayDnsName,

    [Parameter(Mandatory = $true)]
    [string]$TenantId
)

# Step 0: Script file list
$RequiredFiles = @(
    'new-oidcapplication.ps1',
    'seed-controller.sh',
    'seed-gateway.sh',
    'enable-full-tunnel-default-site.sh',
    'create-oidc-idp.sh',
    'create-full-tunnel-entitlement.sh',
    'create-tunnel-policy.sh',
    'create-client-profile.sh',
    'provision-appgate.sh'
)

# Step 1: Download scripts
Write-Host 'Downloading provisioning scripts...'
$ScriptBaseUrl = 'https://raw.githubusercontent.com/NetworkCoverage/azure-resource-manager/refs/heads/main/cmmc-enclave/virtual-machine/ztna/scripts'
$RequiredFiles | ForEach-Object {
    $Url = '{0}/{1}' -f $ScriptBaseUrl, $_
    Write-Host ('Downloading {0}' -f $_)
    Invoke-RestMethod -Uri $Url -OutFile $_
}

# Step 2: Ensure Key Vault role
Write-Host 'Checking Key Vault role assignment...'
$CurrentUser = Get-AzADUser -SignedIn
$Vault = Get-AzKeyVault -VaultName $VaultName
$RoleAssignments = Get-AzRoleAssignment -ObjectId $CurrentUser.Id -Scope $Vault.ResourceId -ErrorAction SilentlyContinue
$HasAccess = $RoleAssignments | Where-Object { $_.RoleDefinitionName -eq 'Key Vault Administrator' }

if (-not $HasAccess) {
    Write-Host "Assigning 'Key Vault Administrator' role..."

    $RoleParams = @{
        ObjectId           = $CurrentUser.Id
        RoleDefinitionName = 'Key Vault Administrator'
        Scope              = $Vault.ResourceId
    }
    New-AzRoleAssignment @RoleParams | Out-Null
    Write-Host 'Role assignment complete. Waiting 30 seconds for the changes to propagate.'
    Start-Sleep -Seconds 30
}

# Step 3: Retrieve SSH keys
Write-Host 'Downloading PEM keys from Key Vault...'
@('ctl', 'gw') | ForEach-Object {
    $Key = $_
    $SecretName = '{0}-{1}-secret' -f $VaultName, $Key
    $PemFile = './{0}.pem' -f $Key

    $SecretParams = @{
        VaultName = $VaultName
        Name      = $SecretName
    }
    $Secret = Get-AzKeyVaultSecret @SecretParams

    $Secret.SecretValue | ConvertFrom-SecureString -AsPlainText | Out-File $PemFile
    chmod 400 $PemFile

    Write-Host ('{0} downloaded and secured.' -f $PemFile)
}

# Step 4: Validate required files
Write-Host 'Validating script and key files...'
$Missing = @()
$RequiredFiles + @('ctl.pem', 'gw.pem') | ForEach-Object {
    if (-not (Test-Path $_)) {
        $Missing += $_
    }
}
if ($Missing.Count -gt 0) {
    Write-Host ('Missing files: {0}' -f ($Missing -join ', '))
    exit 1
}
Write-Host 'All required files are present.'

# Step 5: Run new-oidcapplication.ps1
Write-Host 'Executing new-oidcapplication.ps1...'
.\new-oidcapplication.ps1 -Environment USGov -ControllerDNSName $ControllerDnsName

# Step 6: Parse appgate-iodc-app.json to retrieve Client ID
$AppJsonPath = './appgate-oidc-app.json'
if (-not (Test-Path $AppJsonPath)) {
    Write-Error "The OIDC application metadata file '$AppJsonPath' was not found."
    exit 1
}

$AppMetadata = Get-Content $AppJsonPath | ConvertFrom-Json
$AudienceClientId = $AppMetadata.ClientId

if (-not $AudienceClientId) {
    Write-Error "ClientId is missing or empty in '$AppJsonPath'."
    exit 1
}

# Step 7: Write env.sh for Bash
Write-Host 'Writing environment file for Bash...'

@"
export CUSTOMERSHORTNAME='$CustomerShortName'
export ADMINPASS='$AdminPass'
export CONTROLLERDNS='$ControllerDnsName'
export CONTROLLERIP='$ControllerIp'
export GATEWAYDNS='$GatewayDnsName'
export TENANT_ID='$TenantId'
export AUDIENCE_ID='$AudienceClientId'
"@ | Out-File -Encoding ascii ./env.sh

Write-Host ''
Write-Host 'Next steps:'
Write-Host '1. Type: bash'
Write-Host '2. Then run: . ./env.sh'
Write-Host '3. Then run: ./provision-appgate.sh \$CUSTOMERSHORTNAME \$ADMINPASS \$CONTROLLERDNS \$CONTROLLERIP \$GATEWAYDNS \$TENANT_ID \$AUDIENCE_ID'
