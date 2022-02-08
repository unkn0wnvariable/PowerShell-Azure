# Script to retrieve backup items from all matching subscriptions

# Where to save the output file to?
$outputFilePath = 'C:\Temp\'

# Output file name suffix
$outputFileNameSuffix = 'BackupItems'

# Container type for which we want to retrieve backup items.
# One of AzureVM, AzureSQL, AzureStorage, or AzureVMAppContainer.
$containerType = 'AzureVM'

# Workload type for which we want to retrieve backup items.
# One of AzureVM, AzureSQLDatabase, AzureFiles, or MSSQL.
$workloadType = 'AzureVM'

# Import the Az module and connect to Azure
Import-Module Az
Connect-AzAccount

# RegEx to find the subscriptions we care about
$subscriptionRegEx = '^.*$'

# Get all the relevant subscriptions
$subscriptions = Get-AzSubscription | Where-Object { $_.Name -match $subscriptionRegEx }

# Run through the subscriptions getting all the backups in them
$backupItems = @()
foreach ($subscription in $subscriptions) {

    # Output what we're doing 
    Write-Output ('Getting backups from subscription: ' + $subscription.Name)
    $null = Set-AzContext -SubscriptionObject $subscription

    # Get all vaults in the subscription and run through them
    $recoveryServicesVaults = Get-AzRecoveryServicesVault
    foreach ($recoveryServicesVault in $recoveryServicesVaults) {

        # Get all VM backup containers in the vault and run through them
        $recoveryServicesContainers = Get-AzRecoveryServicesBackupContainer -VaultId $recoveryServicesVault.ID $containerType
        foreach ($recoveryServicesContainer in $recoveryServicesContainers) {

            # Get backup item for the container
            $backupItem = Get-AzRecoveryServicesBackupItem -VaultId $recoveryServicesVault.ID -Container $recoveryServicesContainer -WorkloadType $workloadType

            # Add backup item to results array
            $backupItems += [PSCustomObject]@{
                'VMName'              = $backupItem.Name.split(';')[3];
                'VMResourceGroup'     = $backupItem.Name.split(';')[2];
                'BackupVault'         = $recoveryServicesVault.Name;
                'ProtectionStatus'    = $backupItem.ProtectionStatus;
                'HealthStatus'        = $backupItem.HealthStatus;
                'LatestRecoveryPoint' = $backupItem.LatestRecoveryPoint;
            }
        }
    }
}

# Output results to CSV file
$outputFile = $outputFilePath + $outputFileNameSuffix + '_' + $containerType + '_' + $workloadType + '.csv'
$backupItems | Export-Csv -Path $outputFile -NoTypeInformation

# Disconnect from Azure
Disconnect-AzAccount
