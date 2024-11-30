# Script to get all roles assignments where the object type is unknown (object deleted) and output them to a CSV file
#

# Where to create the CSV file?
$outputFile = 'C:\Temp\UnknownRoleAssignments.csv'

# RegEx to find the subscriptions we care about
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
    $allRoleAssignments += (Get-AzRoleAssignment | Where-Object -FilterScript { $_.ObjectType -eq 'Unknown' })
}

# Export to CSV
$allRoleAssignments | Sort-Object -Property Scope | Export-CSV -Path $outputFile -NoTypeInformation
