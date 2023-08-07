# Script to get all enabled webapp default urls from Azure
#

# Where to save the results?
$outputFile = "C:\Temp\WebApps.txt"

# RegEx to find the subscriptions we care about
$subscriptionRegEx = '^.*$'

# Import required Az modules and connect to Azure
Import-Module Az.Accounts, Az.Websites
Connect-AzAccount

# Get all the relevant subscriptions
$subscriptions = Get-AzSubscription | Where-Object { $_.Name -match $subscriptionRegEx }

# Initialise the variable for results
$allWebAppURLs = @()

# Run through the subscriptions getting all the webapps in them
foreach ($subscription in $subscriptions) {
    Write-Output ('Getting resources from subscription: ' + $subscription.Name)
    $null = Set-AzContext -SubscriptionObject $subscription
    $allWebAppURLs += Get-AzWebApp | Select-Object Name, Enabled, DefaultHostName | Where-Object { $_.Enabled -eq $true }
}

# Output sorted list of all default hostnames for the webapps
Out-File -FilePath $outputFile -InputObject (($allWebAppURLs).DefaultHostName | Sort-Object)

# Disconnect from Azure
Disconnect-AzAccount
