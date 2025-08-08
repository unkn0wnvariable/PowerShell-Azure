# Script to export a selection of entries from the Azure Activity Log for a specific user
#

# When do we want our export window to start and end? (Date and time in format yyyy-mm-ddThh:mm)
$startTime = ''
$endTime = ''

# Who are we exporting for? (UserPrincipalName)
$username = ''

# Where to create the CSV file?
$outputFile = 'C:\Temp\AzureActivityLogs.csv'

# RegEx to find the relevant subscriptions
$subscriptionRegEx = '^.*$'

# Import required Az modules and connect to Azure
Import-Module -Name Az.Accounts, Az.Monitor
Connect-AzAccount

# Get all the relevant subscriptions
$subscriptions = Get-AzSubscription | Where-Object { $_.Name -match $subscriptionRegEx }

# Prime our output array and start running through the subscriptions
$outputEntries = @()
foreach ($subscription in $subscriptions) {
    # Switch to the subscription
    $null = Set-AzContext -SubscriptionObject $subscription

    # Get all activity log entries matching our criteria
    $activityLog = Get-AzActivityLog -StartTime $startTime -EndTime $endTime -Caller $username -DetailedOutput

    # Run through each log entry and pick out the information we want
    foreach ($activity in $activityLog) {

        # Creating resourceType manually because Get-AzActivityLog currently returns the proper field empty
        $splitString = $activity.Properties.Content.entity.Split('/')
        $resourceType = $splitString[$splitString.IndexOf('providers') + 1]
        if ($splitString[$splitString.IndexOf('providers') + 2]) {
            $resourceType += '/' + $splitString[$splitString.IndexOf('providers') + 2]
        }
    
        # Add the entry to our output array as a new object
        $outputEntries += [PSCustomObject]@{
            CorrelationId     = $activity.CorrelationId;
            OperationName     = $activity.OperationName;
            Status            = $activity.Status;
            EventCategory     = $activity.Category;
            Level             = $activity.Level;
            Timestamp         = $activity.EventTimestamp;
            SubscriptionId    = $activity.SubscriptionId;
            IPAddress         = $activity.Claims.Content.ipaddr;
            InitiatedBy       = $activity.Caller;
            ResourceType      = $resourceType;
            ResourceGroupName = $activity.ResourceGroupName;
            Resource          = $activity.ResourceId;
        }
    }
}

# Output all our reformatted entries to a CSV file
$outputEntries | Sort-Object -Property Timestamp | Export-Csv -Path $outputFile -NoTypeInformation

# Disconnect from Azure
Disconnect-AzAccount
