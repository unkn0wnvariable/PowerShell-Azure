# Script to get all orphaned roles assignments and output them to a CSV file
#

<#
NOTE: This used to be done by finding all the assignments where the object type was unknown (object deleted), i.e.:

    Get-AzRoleAssignment | Where-Object -FilterScript { $_.ObjectType -eq 'Unknown' }

But for whatever reason it's been changed to to return what the objectType was before it was deleted. So instead now we're checking
to see if both the DisplayName and SignInName for the object are blank because if they are it's probbaly been deleted.

This is not 100% reliable, but then neither was checking the objectType - ALWAYS double check the results before deleting anything.
#>


# Where to create the CSV file?
$outputFile = 'C:\Temp\UnknownRoleAssignments.csv'

# RegEx to find the relevant subscriptions
$subscriptionRegEx = '^.*$'

# Import the module and connect to Azure
Import-Module -Name Az.Accounts, Az.Resources
Connect-AzAccount

# Get all the relevant subscriptions
$subscriptions = Get-AzSubscription | Where-Object { $_.Name -match $subscriptionRegEx }

# Get role assignments
$allRoleAssignments = @()
foreach ($subscription in $subscriptions) {
    $null = Set-AzContext -Subscription $subscription
    $allRoleAssignments += (Get-AzRoleAssignment | Where-Object -FilterScript { $_.DisplayName -eq $null -and $_.SignInName -eq $null })
}

# Export to CSV
$allRoleAssignments | Sort-Object -Property Scope | Export-CSV -Path $outputFile -NoTypeInformation
