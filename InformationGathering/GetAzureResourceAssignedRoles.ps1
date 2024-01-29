# Script to get all roles assigned at all levels in all subscriptions and output to a set of CSV files
#

# Where to save the results?
$outputFilePath = 'C:\Temp\'
$outputFileSuffix = '_RoleAssignments.csv'

# RegEx to find the subscriptions we care about
$subscriptionRegEx = '^.*$'

# Import required Az modules and connect to Azure
Import-Module -Name Az.Accounts, Az.Resources
Connect-AzAccount

# Get all the relevant subscriptions
$subscriptions = Get-AzSubscription | Where-Object { $_.Name -match $subscriptionRegEx -and $_.State -eq 'Enabled' } | Sort-Object -Property 'Name'

# Properties to include in the output
$properties = @(
    'DisplayName',
    'SignInName',
    'ObjectId',
    'ObjectType',
    'RoleDefinitionName',
    'Scope'
)

# Run through the subscriptions getting all the assigned roles and saving them to seperate CSV files
foreach ($subscription in $subscriptions) {
    $outputPath = $outputFilePath + $subscription.Name + $outputFileSuffix
    $null = Set-AzContext -SubscriptionObject $subscription
    $roleAssignments = (Get-AzRoleAssignment | Where-Object { $_.ObjectType -ne 'ServicePrincipal' } | Select-Object -Property $properties )
    $roleAssignments | Sort-Object -Property Scope | Export-Csv -Path $outputPath -NoTypeInformation
}

# Disconnect from Azure
Disconnect-AzAccount
