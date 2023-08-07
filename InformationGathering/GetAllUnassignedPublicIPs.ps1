# Script to get all assigned public IPs and FQDNs for resources in an Azure tenant.
#

# RegEx to find the subscriptions we care about
$subscriptionRegEx = '^.*$'

# Import required Az modules and connect to Azure
Import-Module Az.Accounts, Az.Network
Connect-AzAccount

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

# Output results to screen as a table
$unassignedPublicIPs | Format-Table -AutoSize

# Disconnect from Azure
Disconnect-AzAccount
