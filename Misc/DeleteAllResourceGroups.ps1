# Script to delete all resource groups from a subscription, with exceptions
#

# Import the Az module and connect to Azure
Import-Module Az
Connect-AzAccount -UseDeviceAuthentication

# What subscription are we deleting resources from?
$subscriptionName = ''

# Any resource groups that shouldn't be deleted?
$rgDeletionExceptions = @('')

# Change context to the relevant subscription
Set-AzContext -Subscription $subscriptionName

# Get a list of all resource groups minus those which are to be kept
$rgsToDelete = (Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -notin $rgDeletionExceptions}).ResourceGroupName

# Remove the resource groups
foreach ($rgToDelete in $rgsToDelete) {
    Remove-AzResourceGroup -Name $rgToDelete
}
