# Script to get all assigned public IPs and FQDNs for resources in an Azure tenant.
#

# Where to save the results?
$outputFile = "C:\Temp\DynamicPublicIPsWithNoFQDN.csv"

# RegEx to find the subscriptions we care about
$subscriptionRegEx = '^.*$'

# Import required Az modules and connect to Azure
Import-Module Az.Accounts, Az.Network
Connect-AzAccount

# Get all the relevant subscriptions
$subscriptions = Get-AzSubscription | Where-Object {$_.Name -match $subscriptionRegEx}

# Initialise the variable for results
$publicIPs = @()

# Run through the subscriptions getting all the public IPs in them
foreach ($subscription in $subscriptions) {
    Write-Output ('Getting resources from subscription: ' + $subscription.Name)
    $null = Set-AzContext -SubscriptionObject $subscription
    $publicIPs += Get-AzPublicIpAddress | Select-Object Name,IpAddress,PublicIpAllocationMethod,@{Name="Fqdn";Expression={$_.DnsSettings.Fqdn}} | Where-Object {$_.PublicIpAllocationMethod -eq 'Dynamic' -and $_.Fqdn -eq $null}
}

# Output sorted list of all dynamic IP addresses with no FQDN
$publicIPs | Sort-Object | Export-Csv -Path $outputFile -NoTypeInformation

# Disconnect from Azure
Disconnect-AzAccount
