# Script to get all IP addresses connected to all vNets in a set of subscriptions
#
# Outputs full details of the results to a CSV file plus a basic list of IPs to a text file for each subscription
#

# Where to create the output files?
$outputPath = 'C:\Temp\'

# Filename for results files
$outputFilesPrefix = 'vNetPrivateIPAddresses_'

# RegEx to find the subscriptions we care about
$subscriptionRegEx = '^.*$'

# Import required Az modules and connect to Azure
Import-Module -Name Az.Accounts, Az.Network
Connect-AzAccount

# Get all the relevant subscriptions
$subscriptions = Get-AzSubscription | Where-Object { $_.Name -match $subscriptionRegEx }

# Create output list for full details
$allVNetConnectedIPs = @()

# Run through each subscription in the retreived list
foreach ($subscription in $subscriptions) {

    # Clear the output list ready for new results
    $vNetConnectedIPs = @()

    # Select the subscription to run commands against
    Write-Output ('Getting resources from subscription: ' + $subscription.Name)
    $null = Set-AzContext -SubscriptionObject $subscription

    # Get all virtual networks from the selected subscription
    $virtualNetworks = Get-AzVirtualNetwork

    # Run through retrived virtual networks for the current subscription
    foreach ($virtualNetwork in $virtualNetworks) {

        # Get all subnets for the virtual network
        $virtualNetworkSubnets = Get-AzVirtualNetwork -Name $virtualNetwork.Name -ResourceGroupName $virtualNetwork.ResourceGroupName -ExpandResource 'subnets/ipConfigurations'

        # Run through the subnets adding their details as objects to the output list
        foreach ($subnet in $virtualNetworkSubnets.Subnets) {
            foreach ($ipConfiguration in $subnet.ipConfigurations) {
                if ($ipConfiguration.PrivateIpAddress.Length -gt 0) {
                    $vNetConnectedIPs += [PSCustomObject]@{
                        'Subscription'     = $subscription.Name;
                        'PrivateIpAddress' = $ipConfiguration.PrivateIpAddress;
                        'IPAddressName'    = $ipConfiguration.Id.Split('/')[-1];
                        'ResourceName'     = $ipConfiguration.Id.Split('/')[8];
                        'ResourceGroup'    = $ipConfiguration.Id.Split('/')[4];
                        'Provider'         = $ipConfiguration.Id.Split('/')[6];
                        'ResourceType'     = $ipConfiguration.Id.Split('/')[7];
                    }
                }
            }
        }
        
    }

    # Add results from current subscription to the full details list
    $allVNetConnectedIPs += $vNetConnectedIPs

    # Output just the list of IP addresses to a txt file
    $subOutputFilePath = $outputPath + $outputFilesPrefix + $subscription.Name + '.txt'
    $vNetConnectedIPs.PrivateIpAddress | Sort-Object -Property { [Version]$_ } | Out-File -FilePath $subOutputFilePath
}

# Output Full details to CSV a file
$outputFilePath = $outputPath + $outputFilesPrefix + 'all.csv'
$allVNetConnectedIPs | Sort-Object -Property { [Version]$_.PrivateIpAddress } | Export-Csv -Path $outputFilePath -NoTypeInformation

# Disconnect from Azure
Disconnect-AzAccount
