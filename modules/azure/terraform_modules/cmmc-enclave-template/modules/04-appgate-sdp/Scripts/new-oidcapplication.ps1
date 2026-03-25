# Unify Graph PowerShell and Azure PowerSehll logic 
param (
    [Parameter()]
    [ValidateSet('Global', 'USGov')]
    [System.String]$Environment = 'Global',

    [Parameter(Mandatory = $true)]
    [System.String]$ControllerDNSName,

    [System.Management.Automation.SwitchParameter]$GrantConsent
)

'Microsoft.Graph.Groups', 'Microsoft.Graph.Applications' | ForEach-Object {
    if (-not (Get-Module -ListAvailable -Name $_)) {
        Write-Host 'Installing missing module: $_...'
        Install-Module -Name $_ -Scope CurrentUser -Force
    }
    Import-Module $_ -Force
}

$ConnectMgGraphParams = @{
    NoWelcome = $true        
    Scopes = 'Group.ReadWrite.All', 'Directory.ReadWrite.All', 'Application.ReadWrite.All', 'DelegatedPermissionGrant.ReadWrite.All'
    Environment = $Environment
}
Write-Host 'Connecting to Microsoft Graph using interactive login with required scopes...'
Connect-MgGraph @ConnectMgGraphParams    

$TenantId = (Get-MgContext).TenantId

Write-Host 'Creating OIDC App...'
# Create the OIDC App
$AppParams = @{
    DisplayName = 'Appgate OIDC Identity Provider'
    GroupMembershipClaims = 'SecurityGroup'
    PublicClient = @{
        RedirectUris = @('http://localhost:29001/oidc')
    }
    Spa = @{
        RedirectUris = @(('https://{0}:8443/ui/' -f $ControllerDNSName))
    }
    OptionalClaims = @{
        idToken = @(@{
            name = 'groups'
            essential = $false
            additionalProperties = @('sam_account_name')
        })
        accessToken = @(@{
            name = 'groups'
            essential = $false
        })
    }
    RequiredResourceAccess = @(@{
        ResourceAppId = '00000003-0000-0000-c000-000000000000'  # Microsoft Graph
        ResourceAccess = @(@{
            Id = 'e1fe6dd8-ba31-4d61-89e7-88639da4683d' # openid
            Type = 'Scope'
        })
    })
    PasswordCredentials = @(@{
        DisplayName = 'Created with PowerShell'
        EndDateTime = (Get-Date).AddYears(2)
    })
}
$App = New-MgApplication @AppParams

Write-Host 'Creating service principal...'
# Create the service principal for the app registration
$SpParams = @{
    AccountEnabled = $true
    AppId = $App.AppId
    DisplayName = 'Appgate OIDC Identity Provider'
    NotificationEmailAddresses = 'support@netcov.com'
    Tags = @(
        "WindowsAzureActiveDirectoryIntegratedApp",
        "HideApp"
    )
}
$Sp = New-MgServicePrincipal @SpParams

# Build the consent URL
$ConsentBaseUrl = if ((Get-AzContext).Environment.Name -eq 'AzureUSGovernment') {'https://login.microsoftonline.us'} else {'https://login.microsoftonline.com'}
$ConsentUrl = ('{0}/{1}/adminconsent?client_id={2}' -f $ConsentBaseUrl, $TenantId, $App.AppId)

# Get the Microsoft Graph service principal
# This is needed to grant admin consent for the app to use Microsoft Graph API
$GraphSp = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"

# Admin Consent Logic
if (-not $GrantConsent -or -not $GraphSp) {
    if (-not $GrantConsent -and -not $GraphSp) {
        Write-Host 'Microsoft Graph API service principal not found. Granting admin consent using the URL...'
    }
    if ($env:ACC_CLOUD -or $env:AZUREPS_HOST_ENVIRONMENT -like '*CloudShell*') {
        Write-Host ('To grant admin consent, use a web browser to open the page {0} then sign in with a Global Admin account and accept the prompt to authorize the app.' -f $ConsentUrl)
        Read-Host "`nPress [Enter] once you have completed admin consent"
    }
    else {
        Write-Host 'Opening browser to grant admin consent...'
        Start-Process $ConsentUrl
        Read-Host "`nPress [Enter] once you have completed admin consent"
    }
}
else {
    Write-Host 'Granting admin consent using Microsoft Graph API...'
    $PermissionGrantParams = @{
        ClientId = $sp.Id
        ConsentType = 'AllPrincipals'
        ResourceId = $GraphSp.Id
        Scope = 'openid profile offline_access'
    }
    New-MgOauth2PermissionGrant @PermissionGrantParams
}

# Create dynamic group for Appgate users
Write-Host "Creating dynamic group 'Appgate OIDC Users'..."

$DynamicRule = "((user.companyName -eq `"$CompanyName`") or (user.companyName -eq `"Network Coverage`")) and (user.accountEnabled -eq true)"

$GroupParams = @{
    DisplayName     = 'Appgate OIDC Users'
    Description     = 'Users allowed to authenticate to Appgate via OIDC'
    MailEnabled     = $false
    MailNickname    = (New-Guid).ToString().Substring(0,10)
    SecurityEnabled = $true
    GroupTypes      = @('DynamicMembership')
    MembershipRule  = $DynamicRule
    MembershipRuleProcessingState = 'On'
}

$OidcGroup = New-MgGroup @GroupParams
Write-Host "Group created with Object ID: $($OidcGroup.Id). Waiting 30 seconds for group to be ready..."
Start-Sleep -Seconds 30

Write-Host "Assigning group to the application (service principal)..."

# Assign the group to the service principal
$AssignmentParams = @{
    GroupId = $OidcGroup.Id 
    PrincipalId = $OidcGroup.Id  
    ResourceId = $Sp.Id                    
    AppRoleId = '00000000-0000-0000-0000-000000000000'  # default role assignment
}
New-MgGroupAppRoleAssignment @AssignmentParams | Out-Null

# Output useful data
Write-Host ('App registration complete')
Write-Host ('Display Name           : {0}' -f $App.DisplayName)
Write-Host ('Client ID              : {0}' -f $App.AppId)
Write-Host ('ClientSecret           : {0}' -f $App.PasswordCredentials.SecretText)
Write-Host ('Object ID              : {0}' -f $App.Id)
Write-Host ('Service Principal ID   : {0}' -f $Sp.Id)
Write-Host ('Tenant ID              : {0}' -f $TenantId)
Write-Host ('OIDC metadata URL      : {0}/{1}/v2.0/.well-known/openid-configuration' -f $ConsentBaseUrl, $TenantId)
Write-Host ('OIDC issuer            : {0}/{1}/v2.0' -f $ConsentBaseUrl, $TenantId)

# Save output to JSON for automation
$AppMetadata = @{
    DisplayName        = $App.DisplayName
    ClientId           = $App.AppId
    ClientSecret       = $App.PasswordCredentials.SecretText
    TenantId           = $TenantId
    ObjectId           = $App.Id
    ServicePrincipalId = $Sp.Id
    OidcMetadataUrl    = ('{0}/{1}/v2.0/.well-known/openid-configuration' -f $ConsentBaseUrl, $TenantId)
    OidcIssuer         = ('{0}/{1}/v2.0' -f $ConsentBaseUrl, $TenantId)
}

$JsonPath = "appgate-oidc-app.json"
$AppMetadata | ConvertTo-Json -Depth 3 | Set-Content -Path $JsonPath -Encoding UTF8

Write-Host ("App metadata saved to file: {0}" -f (Resolve-Path $JsonPath))