# Script to bulk add CanNotDelete locks to all resource groups in multiple subscriptions, with exceptions
#

# RegEx to find the relevant subscriptions
$subscriptionRegEx = '^.*$'

# Regex to exclude some common Azure auto created resource groups that shouldn't be locked
$rgExclusionsRegex = '^AzureBackup.*$|^cloud-shell-storage.*$|^NetworkWatcher.*$'

# Any additional resource groups that shouldn't be locked?
$lockExceptions = @('')

# Import the Az module and connect to Azure
Import-Module -Name Az.Accounts, Az.Resources
Connect-AzAccount

# Get all the relevant subscriptions
$subscriptions = Get-AzSubscription | Where-Object { $_.Name -match $subscriptionRegEx }

foreach ($subscription in $subscriptions) {
    # Change context to the relevant subscription
    $null = Set-AzContext -Subscription $subscription

    # Get a list of the Resource Groups that already have locks
    $alreadyLocked = (Get-AzResourceLock | Where-Object { $_.ResourceType -eq 'Microsoft.Authorization/locks' -and $_.Properties.level -eq 'CanNotDelete' }).ResourceGroupName

    # Get all resource groups except those for cloud shell and those in the exceptions list
    $resourceGroups = (Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -notmatch $rgExclusionsRegex -and $_.ResourceGroupName -notin $lockExceptions -and $_.ResourceGroupName -notin $alreadyLocked }).ResourceGroupName | Sort-Object

    # Lock all the resource groups
    foreach ($resourceGroup in $resourceGroups) {
        $lockName = $resourceGroup + '_cannot-delete'
        New-AzResourceLock -LockName $lockName -LockLevel CanNotDelete -ResourceGroupName $resourceGroup -Force
    }
}

# Disconnect from Azure
Disconnect-AzAccount
