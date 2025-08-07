# Script to bulk add CanNotDelete locks to multiple similar resource groups across multiple subscriptions
#

# RegEx to find the subscriptions our groups are in
$subscriptionRegEx = '^.*$'

# RegEx to find the groups to lock
$groupRegEx = '^.*$'

# Import the Az module and connect to Azure
Import-Module -Name Az.Accounts, Az.Resources
Connect-AzAccount

# Get matching subscriptions
$subscriptions = Get-AzSubscription | Where-Object { $_.Name -match $subscriptionRegEx }

# Run through the retrieved subscriptions
foreach ($subscription in $subscriptions) {
    # Change context to the relevant subscription
    $null = Set-AzContext -Subscription $subscription

    # Get matching resource groups
    $resourceGroups = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -match $groupRegEx }

    # Run through the retrieved resource groups
    foreach ($resourceGroup in $resourceGroups) {
        # Check for an existing lock
        $existingLock = Get-AzResourceLock -ResourceGroupName $resourceGroup.ResourceGroupName | Where-Object { $_.ResourceType -eq 'Microsoft.Authorization/locks' -and $_.Properties.level -eq 'CanNotDelete' }

        # If no lock present then add one, else output details of the existing lock
        if (!($existingLock)) {
            $lockName = $resourceGroup.ResourceGroupName + '_cannot-delete'
            New-AzResourceLock -LockName $lockName -LockLevel CanNotDelete -ResourceGroupName $resourceGroup -Force
        }
        else {
            $existingLock
        }
    }
}

# Disconnect from Azure
Disconnect-AzAccount
