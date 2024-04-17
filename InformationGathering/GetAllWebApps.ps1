# Script to get all enabled webapp default urls from Azure
#
# Outputs full details of the results to a CSV file plus a basic list of IPs to a text file for each subscription
#

# Where to save the results?
$outputPath = 'C:\Temp\'

# Filename and suffix for results files
$outputFilesPrefix = 'WebApps_'

# RegEx to find the subscriptions we care about
$subscriptionRegEx = '^.*$'

# Import required Az modules and connect to Azure
Import-Module -Name Az.Accounts, Az.Websites
Connect-AzAccount

# Get all the relevant subscriptions
$subscriptions = Get-AzSubscription | Where-Object { $_.Name -match $subscriptionRegEx }

# Initialise the variable for results
$allWebApps = @()

# Run through the subscriptions getting all the webapps in them
foreach ($subscription in $subscriptions) {
    Write-Output ('Getting resources from subscription: ' + $subscription.Name)
    $null = Set-AzContext -SubscriptionObject $subscription

    $properties = @(
        'Name',
        'ResourceGroup',
        'DefaultHostName',
        'Location',
        'Enabled',
        'Kind',
        'HttpsOnly',
        'State',
        'AvailabilityState'
    )

    $webApps = Get-AzWebApp | Select-Object -Property $properties | Where-Object { $_.Enabled -eq $true }

    $subOutputFilePath = $outputPath + $outputFilesPrefix + $subscription.Name + '.txt'
    $webAppURLs = ($webApps).DefaultHostName | Sort-Object
    Out-File -FilePath $subOutputFilePath -InputObject $webAppURLs

    $allWebApps += $webApps
}

# Output sorted list of all default hostnames for the webapps
$outputFilePath = $outputPath + $outputFilesPrefix + 'all.csv'
$allWebApps | Sort-Object -Property 'Name' | Export-Csv -Path $outputFilePath -NoTypeInformation

# Disconnect from Azure
Disconnect-AzAccount
