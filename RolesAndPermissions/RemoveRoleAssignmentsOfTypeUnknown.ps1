# Script to get all roles assignments where the object type is unknown (object deleted) and remove them
#

# RegEx to find the relevant subscriptions
$subscriptionRegEx = '^.*$'

# Import the module and connect to Azure
Import-Module -Name Az.Accounts, Az.Resources
Connect-AzAccount

# Get all the relevant subscriptions
$subscriptions = Get-AzSubscription | Where-Object { $_.Name -match $subscriptionRegEx }

# Remove role assignments
foreach ($subscription in $subscriptions) {
    $null = Set-AzContext -Subscription $subscription
    $roleAssignments = (Get-AzRoleAssignment | Where-Object -FilterScript { $_.ObjectType -eq 'Unknown' } | Sort-Object -Property Scope)

    foreach ($roleAssignment in $roleAssignments) {
        Remove-AzRoleAssignment -ObjectId $roleAssignment.ObjectId -RoleDefinitionName $roleAssignment.RoleDefinitionName -Scope $roleAssignment.Scope
    }
}
