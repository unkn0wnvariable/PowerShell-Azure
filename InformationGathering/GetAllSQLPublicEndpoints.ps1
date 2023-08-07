# 
#

# Where to create the output file?
$outputFilePath = 'C:\Temp\'

# Variable for the output filename
$outputFilePrefix = 'SQLServerPublicEndpoints_'
$outputFileSuffix = '.csv'

# RegEx to find the subscriptions we care about
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
    $null = Set-AzContext -SubscriptionObject $subscription
    $sqlServers = Get-AzResourceGroup | Get-AzSqlServer | Select-Object -Property ResourceGroupName, ServerName, Location, SqlAdministratorLogin, ServerVersion, FullyQualifiedDomainName, MinimalTlsVersion, PublicNetworkAccess, RestrictOutboundNetworkAccess # | Where-Object {$_.PublicNetworkAccess -eq 'Enabled'}

    $outputFileSubscription = $outputFilePath + $outputFilePrefix + $subscription.Name + $outputFileSuffix
    $sqlServers | Sort-Object -Property Timestamp | Export-Csv -Path $outputFileSubscription -NoTypeInformation
    $allSqlServers += $sqlServers
}

# Establish output filename
$outputFileAll = $outputFilePath + $outputFilePrefix + 'all' + $outputFileSuffix

# Output results to file
$allSqlServers | Sort-Object -Property Timestamp | Export-Csv -Path $outputFileAll -NoTypeInformation

# Disconnect from Azure
Disconnect-AzAccount
