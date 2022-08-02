# Script to get all enabled webapp default urls from Azure
#

# Import the Az module and connect to Azure
Import-Module Az
Connect-AzAccount

# RegEx to find the subscriptions we care about
$subscriptionRegEx = '^.*$'

# Where to save the results?
$outputFile = "C:\Temp\WebApps.txt"

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
