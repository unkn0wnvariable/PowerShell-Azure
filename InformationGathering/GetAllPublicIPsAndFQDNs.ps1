# Script to get all assigned public IPs and FQDNs for resources in an Azure tenant.
#
# Outputs full details of the results to a CSV file plus a basic list of IPs to a text file for each subscription
#

# Where to save the results?
$outputPath = 'C:\Temp\'

# Filename and suffix for results files
$outputFilesPrefix = 'PublicIPsAndFQDNs_'

# RegEx to find the relevant subscriptions
$subscriptionRegEx = '^.*$'

# Import required Az modules and connect to Azure
Import-Module -Name Az.Accounts, Az.Network
Connect-AzAccount

# Get all the relevant subscriptions
$subscriptions = Get-AzSubscription | Where-Object { $_.Name -match $subscriptionRegEx }

# Initialise the variable for results
$allPublicIPs = @()

# Run through the subscriptions getting all the public IPs in them, output a file for each sub, and add the results to the overall output
foreach ($subscription in $subscriptions) {
    Write-Output ('Getting resources from subscription: ' + $subscription.Name)
    $null = Set-AzContext -SubscriptionObject $subscription
    $publicIPs = Get-AzPublicIpAddress | Where-Object { $_.IpAddress -ne 'Not Assigned' } | Select-Object Name, IpAddress, PublicIpAllocationMethod, @{Name = "Fqdn"; Expression = { $_.DnsSettings.Fqdn } }

    # Add sorted list of all FQDN's, and sorted list of all static IP addresses with no FQDN, to output data
    $subOutputData = @(
        (($publicIPs | Where-Object { $_.Fqdn -ne $null }).Fqdn | Sort-Object),
        (($publicIPs | Where-Object { $_.PublicIpAllocationMethod -eq 'Static' -and $_.Fqdn -eq $null }).IpAddress | Sort-Object)
    )

    $subOutputFilePath = $outputPath + $outputFilesPrefix + $subscription.Name + '.txt'
    $subOutputData | Out-File -FilePath $subOutputFilePath

    $allPublicIPs += $publicIPs
}

# Save output to file
$outputFilePath = $outputPath + $outputFilesPrefix + 'all.csv'
$allPublicIPs | Sort-Object -Property Name | Export-Csv -Path $outputFilePath -NoTypeInformation

# Disconnect from Azure
Disconnect-AzAccount
