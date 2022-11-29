# Script to get all IP addresses connected to all vNets in a set of subscriptions
#
# Outputs full details of the results to a set of CSV files plus a basic list of IPs to text files
#

# Where to create the output files?
$outputFilesPath = 'C:\Temp\'
$outputFilesPrefix = 'vNetPrivateIPAddresses_'

# RegEx to find the subscriptions we care about
$subscriptionRegEx = '^.*$'

# Import the module and connect to Azure
Import-Module -Name Az
Connect-AzAccount

# Get all the relevant subscriptions
$subscriptions = Get-AzSubscription | Where-Object { $_.Name -match $subscriptionRegEx }

# Run through each subscription in the retreived list
foreach ($subscription in $subscriptions) {

    # Clear the output list ready for new results
    $vNetConnectedIPs = @()

    # Select the subscription to run commands against
    $null = Select-AzSubscription -SubscriptionObject $subscription

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
                        PrivateIpAddress = $ipConfiguration.PrivateIpAddress;
                        IPAddressName    = $ipConfiguration.Id.Split('/')[-1];
                        ResourceName     = $ipConfiguration.Id.Split('/')[8];
                        ResourceGroup    = $ipConfiguration.Id.Split('/')[4];
                        Provider         = $ipConfiguration.Id.Split('/')[6];
                        ResourceType     = $ipConfiguration.Id.Split('/')[7];
                    }
                }
            }
        }
        
    }

    # Output Full details to CSV a file
    $outputCsvFileSubscription = $outputFilesPath + $outputFilesPrefix + $subscription.Name + '.csv'
    $vNetConnectedIPs | Export-Csv -Path $outputCsvFileSubscription -NoTypeInformation

    # Output just the list of IP addresses to a txt file
    $outputTxtFileSubscription = $outputFilesPath + $outputFilesPrefix + $subscription.Name + '.txt'
    $vNetConnectedIPs.PrivateIpAddress | Out-File -FilePath $outputTxtFileSubscription
}

# Disconnect from Azure
Disconnect-AzAccount
