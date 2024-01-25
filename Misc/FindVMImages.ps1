# Script to find Azure VM image details from the huge list of those available.
#

# Import the Az module and connect to Azure
Import-Module -Name Az.Accounts, Az.Compute
Connect-AzAccount -UseDeviceAuthentication

# Show a selectable list of locations, e.g.: UK South
$location = (Get-AzLocation | Select-Object -Property DisplayName,Location | Out-GridView -PassThru -Title "Select the Azure location").Location

# Show a selectable list of publishers available in the selected location, e.g.: MicrosoftWindowsServer
$imagePublisher = (Get-AzVMImagePublisher -Location $location | Select-Object -Property PublisherName | Out-GridView -PassThru -Title "Select the image publisher").PublisherName

# Show a selectable list of image offers available from the selected publisher, e.g.: WindowsServer
$imageOffer = (Get-AzVMImageOffer -Location $location -PublisherName $imagePublisher | Select-Object -Property Offer | Out-GridView -PassThru -Title "Select the image offer").Offer

# Show a selectable list of SKUs available for the selected image offer, e.g.: 2019-Datacener-Core
$imageSku = (Get-AzVMImageSku -Location $location -PublisherName $imagePublisher -Offer $imageOffer | Select-Object -Property Skus | Out-GridView -PassThru -Title "Select the SKU").Skus

# Get all the image versions available for the selected SKU and output them to a table, you can also use 'Latest' as the image version to automatically select the most recent one
Get-AzVMImage -Location $location -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku | Select-Object PublisherName,Offer,Skus,Version | Out-GridView -Title "Available images"
