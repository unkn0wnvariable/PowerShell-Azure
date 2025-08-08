# Script to get all roles assigned at all levels in all subscriptions and output to a set of CSV files
#

# Where to save the results?
$outputFile = 'C:\Temp\RoleAssignmentsExport.xlsx'

# RegEx to find the relevant subscriptions
$subscriptionRegEx = '^.*$'

# Import the module and connect to Azure
Import-Module -Name Az.Accounts, Az.Resources, ImportExcel
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
$outputData = @()
foreach ($subscription in $subscriptions) {
    $null = Set-AzContext -Subscription $subscription
    $roleAssignments = (Get-AzRoleAssignment -IncludeClassicAdministrators | Select-Object -Property $properties )
    $outputData += [PSCustomObject]@{
        Subscription    = $subscription.Name
        RoleAssignments = $roleAssignments
    }
}

# If output file exists delete it
if (Test-Path -Path $outputFile) {
    Remove-Item -Path $outputFile
}

# Output data to seperate sheets an an Excel file
foreach ($dataSet in $outputData) {
    $dataSet.RoleAssignments |
    Sort-Object -Property Scope |
    Export-Excel -Path $outputFile -WorkSheetName $dataSet.Subscription -Append -AutoSize -AutoFilter -FreezeTopRowFirstColumn
}

# Disconnect from Azure
Disconnect-AzAccount
