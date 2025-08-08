# Script to get all SQL server public endpoints in an Azure tenant.
#
# Outputs full details of the results to a CSV file plus a basic list of IPs to a text file for each subscription
#

# Where to create the output file?
$outputPath = 'C:\Temp\'

# Filename and suffix for results files
$outputFilesPrefix = 'SQLServerPublicEndpoints_'

# RegEx to find the relevant subscriptions
$subscriptionRegEx = '^.*$'

# Import required Az modules and connect to Azure
Import-Module -Name Az.Accounts, Az.Resources, Az.Sql
Connect-AzAccount

# Get all the relevant subscriptions
$subscriptions = Get-AzSubscription | Where-Object { $_.Name -match $subscriptionRegEx }

# Initialise the variable for results
$allSqlServers = @()

# Run through the subscriptions getting all SQL servers and their details
foreach ($subscription in $subscriptions) {
    Write-Output ('Getting resources from subscription: ' + $subscription.Name)
    $null = Set-AzContext -SubscriptionObject $subscription

    $properties = @(
        'ServerName',
        'ResourceGroupName',
        'FullyQualifiedDomainName',
        'Location',
        'SqlAdministratorLogin',
        'ServerVersion',
        'MinimalTlsVersion',
        'PublicNetworkAccess',
        'RestrictOutboundNetworkAccess'
    )

    $sqlServers = Get-AzResourceGroup | Get-AzSqlServer | Select-Object -Property $properties # | Where-Object {$_.PublicNetworkAccess -eq 'Enabled'}

    $subOutputFilePath = $outputPath + $outputFilesPrefix + $subscription.Name + '.txt'
    ($sqlServers.FullyQualifiedDomainName | Sort-Object) | Out-File -FilePath $subOutputFilePath

    $allSqlServers += $sqlServers
}

# Establish output filename
$outputFileAll = $outputPath + $outputFilesPrefix + 'all.csv'

# Output results to file
$allSqlServers | Sort-Object -Property 'ServerName' | Export-Csv -Path $outputFileAll -NoTypeInformation

# Disconnect from Azure
Disconnect-AzAccount
