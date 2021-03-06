# Script to get all assigned public IPs and FQDNs for resources in an Azure tenant.
#

# Import the Az module and connect to Azure
Import-Module Az
Connect-AzAccount -UseDeviceAuthentication

# RegEx to find the subscriptions we care about
$subscriptionRegEx = '^.*$'

# Get all the relevant subscriptions
$subscriptions = Get-AzSubscription | Where-Object {$_.Name -match $subscriptionRegEx}

# Initialise the variable for results
$publicIPs = @()

# Run through the subscriptions getting all the public IPs in them
foreach ($subscription in $subscriptions) {
    Write-Output ('Getting resources from subscription: ' + $subscription.Name)
    $null = Set-AzContext -SubscriptionObject $subscription
    $publicIPs += Get-AzPublicIpAddress | Select-Object Name,IpAddress,PublicIpAllocationMethod,@{Name="Fqdn";Expression={$_.DnsSettings.Fqdn}}
}

# Output sorted list of all static IP addresses with no FQDN
($publicIPs | Where-Object {$_.PublicIpAllocationMethod -eq 'Static' -and $_.Fqdn -eq $null}).IpAddress | Sort-Object

# Output sorted list of all FQDN's
($publicIPs | Where-Object {$_.Fqdn -ne $null}).Fqdn | Sort-Object

# Output sorted list of all dynamic IP addresses with no FQDN
$publicIPs | Where-Object {$_.PublicIpAllocationMethod -eq 'Dynamic' -and $_.Fqdn -eq $null} | Sort-Object
