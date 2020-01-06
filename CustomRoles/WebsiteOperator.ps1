# Script to create a new role in Azure which grants access to view and restart websites.
#
# Also grants read access to resource groups to view the websites and access to support.
#

Import-Module -Name Az
Connect-AzAccount -UseDeviceAuthentication

$subscriptionNames = @('')

$roleName = 'Website Operator'

$roleDescription = 'Lets you view and restart websites and download logs.'

$roleActions = @(
    'Microsoft.Authorization/*/read',
    'Microsoft.Resources/subscriptions/resourceGroups/read',
    'Microsoft.Web/*/read',
    'Microsoft.Web/sites/restart/Action',
    'Microsoft.Web/sites/containerLogs/Action',
    'Microsoft.Web/sites/containerLogs/download/Action',
    'Microsoft.Support/*'
)

$subscriptionIDs = (Get-AzSubscription | Where-Object { $_.Name -in $subscriptionNames }).Id
$roleAssignableScopes = @()
foreach ($subscriptionID in $subscriptionIDs) {
    $roleAssignableScopes += '/subscriptions/' + $subscriptionID
}

try {
    $role = Get-AzRoleDefinition -Name $roleName -ErrorAction Stop
    $role.Name = $roleName
    $role.Description = $roleDescription
    $role.IsCustom = $true
    $role.Actions = $roleActions
    $role.AssignableScopes = $roleAssignableScopes
    Set-AzRoleDefinition -Role $role
}
catch {
    $role = [Microsoft.Azure.Commands.Resources.Models.Authorization.PSRoleDefinition]::new()
    $role.Name = $roleName
    $role.Description = $roleDescription
    $role.IsCustom = $true
    $role.Actions = $roleActions
    $role.AssignableScopes = $roleAssignableScopes
    New-AzRoleDefinition -Role $role
}
