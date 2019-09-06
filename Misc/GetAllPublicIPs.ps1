# Script to get all assigned public IPs and FQDNs for resources in an Azure tenant.

Import-Module Az
Connect-AzAccount -UseDeviceAuthentication

$subscriptionWildcard = '*'
$subscriptionExclusion = @('')

$subscriptions = Get-AzSubscription | Where-Object {$_.Name -like $subscriptionWildcard -and $_.Name -notin $subscriptionExclusion}

$publicIPs = @()

foreach ($subscription in $subscriptions) {
    Set-AzContext -SubscriptionObject $subscription
    $publicIPs += Get-AzPublicIpAddress
}

$publicIPs | Select-Object Name,IpAddress,PublicIpAllocationMethod,@{Name="FQDN";Expression={$_.DnsSettings.Fqdn}} | Format-Table -AutoSize
