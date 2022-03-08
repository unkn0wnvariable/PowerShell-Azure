# Script to get all roles assigned at all levels in all subscriptions and output to a set of CSV files
#

# Where to save the results?
$outputFilePath = 'C:\Temp\'
$outputFileSuffix = '_RoleAssignments.csv'

# RegEx to find the subscriptions we care about
$subscriptionRegEx = '^.*$'

# Import the module and connect to Azure
Import-Module -Name Az
Connect-AzAccount

# Get all the relevant subscriptions
$subscriptions = Get-AzSubscription | Where-Object {$_.Name -match $subscriptionRegEx}

# Run through the subscriptions getting all the assigned roles and saving them to seperate CSV files
foreach ($subscription in $subscriptions) {
    $outputPath = $outputFilePath + $subscription.Name + $outputFileSuffix
    $null = Set-AzContext -Subscription $subscription
    $roleAssignments = (Get-AzRoleAssignment | Where-Object {$_.ObjectType -ne 'ServicePrincipal'} | Select-Object -Property DisplayName,SignInName,ObjectType,RoleDefinitionName,Scope)
    $roleAssignments | Sort-Object -Property Scope | Export-Csv -Path $outputPath -NoTypeInformation
}

# Disconnect from Azure
Disconnect-AzAccount
