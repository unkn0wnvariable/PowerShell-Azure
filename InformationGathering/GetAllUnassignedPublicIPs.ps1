# Script to get all assigned public IPs and FQDNs for resources in an Azure tenant.
#

# Import the Az module and connect to Azure
Import-Module Az
Connect-AzAccount

# RegEx to find the subscriptions we care about
$subscriptionRegEx = '^.*$'

# Get all the relevant subscriptions
$subscriptions = Get-AzSubscription | Where-Object { $_.Name -match $subscriptionRegEx }

# Initialise the variable for results
$unassignedPublicIPs = @()

# Run through the subscriptions getting all the unassigned public IPs in them
foreach ($subscription in $subscriptions) {
    Write-Output ('Getting resources from subscription: ' + $subscription.Name)
    $null = Set-AzContext -SubscriptionObject $subscription
    $unassignedPublicIPs += Get-AzPublicIpAddress | Where-Object { $_.IpAddress -eq 'Not Assigned' } | Select-Object Name, IpAddress, PublicIpAllocationMethod, @{Name = "Fqdn"; Expression = { $_.DnsSettings.Fqdn } }
}

$unassignedPublicIPs | Format-Table

# Disconnect from Azure
Disconnect-AzAccount
