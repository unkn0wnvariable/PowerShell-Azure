# Script to retrieve backup items from all matching subscriptions

# Where to save the output file to?
$outputFilePath = 'C:\Temp\'

# Output file name suffix
$outputFileNameSuffix = 'AppServiceBackups'

# Import the Az module and connect to Azure
Import-Module Az
Connect-AzAccount -UseDeviceAuthentication

# RegEx to find the subscriptions we care about
$subscriptionRegEx = '^.*$'

# Get all the relevant subscriptions
$subscriptions = Get-AzSubscription | Where-Object { $_.Name -match $subscriptionRegEx }

# Run through the subscriptions getting all the backups in them
$appServiceBackups = @()
foreach ($subscription in $subscriptions) {

    # Output what we're doing 
    Write-Output ('Getting backups from subscription: ' + $subscription.Name)
    $null = Set-AzContext -SubscriptionObject $subscription

    $webApps = Get-AzWebApp

    foreach ($webApp in $webApps) {
        $appServiceBackups += Get-AzWebAppBackupList -ResourceGroupName $webApp.ResourceGroup -Name $webApp.Name
    }
}

# Output results to CSV file
$outputFile = $outputFilePath + $outputFileNameSuffix + '_' + $containerType + '_' + $workloadType + '.csv'
$appServiceBackups | Export-Csv -Path $outputFile -NoTypeInformation

# Disconnect from Azure
Disconnect-AzAccount
