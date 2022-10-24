# Script to get all VMs from Azure
#

# OPutput file
$outputPath = 'C:\Temp\AllVMs.csv'

# Import the Az module and connect to Azure
Import-Module Az
Connect-AzAccount

# RegEx to find the subscriptions we care about
$subscriptionRegEx = '^.*$'

# Get all the relevant subscriptions
$subscriptions = Get-AzSubscription | Where-Object {$_.Name -match $subscriptionRegEx}

# Initialise the variable for results
$allVMs = @()

# Run through the subscriptions getting all the VMs in them
foreach ($subscription in $subscriptions) {
    Write-Output ('Getting VMs from subscription: ' + $subscription.Name)
    $null = Set-AzContext -SubscriptionObject $subscription
    $vms = Get-AzVM
    foreach ($vm in $vms) {
        $allVMs += [PSCustomObject]@{
            'Subscription'  = $subscription.Name;
            'VMName'        = $vm.Name;
            'VMRG'          = $vm.ResourceGroupName;
            'OSType'        = $vm.StorageProfile.OsDisk.OsType;
            'OSSku'         = $vm.StorageProfile.ImageReference.Sku;
            'VMSize'        = $vm.HardwareProfile.VmSize;
            'LicenseType'   = $vm.LicenseType
        }
    }
}

# Output sorted list of all default hostnames for the webapps
$allVMs | Sort-Object -Property VMName | Export-Csv -NoTypeInformation -Path $outputPath

# Disconnect from Azure
Disconnect-AzAccount
