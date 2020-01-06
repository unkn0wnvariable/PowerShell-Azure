# Script to create a new role in Azure which grants access to view and restart websites.
#
# Also grants read access to resource groups to view the websites and access to support.
#

# Import Az module and connect to account.
Import-Module -Name Az
Connect-AzAccount -UseDeviceAuthentication

# Which subscriptions should be able to use the new role?
$subscriptionNames = @('')

# What is the name of the new role?
$roleName = 'Website Operator'

# What is the description for the new role?
$roleDescription = 'Lets you view and restart websites and download logs.'

# What actions should the role be able to carry out?
$roleActions = @(
    'Microsoft.Authorization/*/read',
    'Microsoft.Resources/subscriptions/resourceGroups/read',
    'Microsoft.Web/*/read',
    'Microsoft.Web/sites/restart/Action',
    'Microsoft.Web/sites/containerLogs/Action',
    'Microsoft.Web/sites/containerLogs/download/Action',
    'Microsoft.Support/*'
)

# Convert subscription names into the assignable scopes format used for custom roles.
$subscriptionIDs = (Get-AzSubscription | Where-Object { $_.Name -in $subscriptionNames }).Id
$roleAssignableScopes = @()
foreach ($subscriptionID in $subscriptionIDs) {
    $roleAssignableScopes += '/subscriptions/' + $subscriptionID
}

# Check if the role already exists and if to update it, if not create a new one.
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
