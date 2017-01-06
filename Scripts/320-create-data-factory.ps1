$ErrorActionPreference = "Stop"
$scriptDir=($PSScriptRoot, '.' -ne "")[0]
. "$scriptDir\Include\common.ps1"


#region

if (-Not(Get-AzureRmResourceProvider -ProviderNamespace Microsoft.DataFactory -ErrorAction SilentlyContinue)) {
    Register-AzureRmResourceProvider -ProviderNamespace Microsoft.DataFactory
}
New-AzureRmDataFactory -ResourceGroupName $resourceGroupName -Name $dataFactoryName -Location $dataFactoryLocation
$df=Get-AzureRmDataFactory -ResourceGroupName $resourceGroupName -Name $dataFactoryName 

#endregion

#region
$resDir="$scriptDir\..\Resources\ProcessBotTextDataFactory"
$linkedServicesDir="$resDir\LinkedServices"
$pipelinesDir="$resDir\Pipelines"

$temp=New-TemporaryFile

$storageContext = getStorageContext
$storageKey = getStorageKey

substituteInTemplate $linkedServicesDir\BlobLinkedService.json @{
    '$storageAccountName' = "$storageAccountName";
    '$storageKey' = "$storageKey";
    } | Out-File $temp
New-AzureRmDataFactoryLinkedService -DataFactory $df -File $temp -Force

Set-AzureStorageBlobContent -Container "adf-resources" -File "$pipelinesDir\extract-key-phrases.usql" -Context $storageContext -Force

function ProvisionService($name, $uiMenu) {
$template=substituteInTemplate $linkedServicesDir\${name}LinkedService.json @{
    '$dataLakeAnalyticsName' = "$dataLakeAnalyticsName"
    '$dataLakeStoreName' = "$dataLakeStoreName"
    }
    
$sub=(Get-AzureRmContext).Subscription.SubscriptionId
Write-Host -ForegroundColor Magenta "Perform this manual configuration"
Write-Host -ForegroundColor Magenta "`nNavigate to:"
Write-Host -ForegroundColor Magenta "https://ms.portal.azure.com/#resource/subscriptions/$sub/resourceGroups/$resourceGroupName/providers/Microsoft.DataFactory/dataFactories/$dataFactoryName"
Write-Host -ForegroundColor Magenta "Provision manually the following LinkedService ($uiMenu, Azure $name, then copy-paste the JSON below, and Authorize and Deploy it): "
Write-Host -ForegroundColor Cyan    $template

assertWithTimeout -block {
    Get-AzureRmDataFactoryLinkedService -DataFactory $df | ? {$_.LinkedServiceName -eq "${name}LinkedService" -and $_.ProvisioningState -eq "Succeeded" }
}
Write-Host "Provisioning detected. " -ForegroundColor Cyan
}

ProvisionService DataLakeStore "New data store"
ProvisionService DataLakeAnalytics "...More, New compute"

substituteInTemplate $linkedServicesDir\SqlDwLinkedService.json @{
    '$sqlName' = $sqlName
    '$dwName' = $dwName
    '$username' = $username
    '$password' = $passwordString
    } | Out-File $temp
New-AzureRmDataFactoryLinkedService -DataFactory $df -File $temp -Force

New-AzureRmDataFactoryDataset -DataFactory $df -File $pipelinesDir\BotTextDataset.json -Force
New-AzureRmDataFactoryDataset -DataFactory $df -File $pipelinesDir\BotKeyPhrasesDataset.json -Force
New-AzureRmDataFactoryDataset -DataFactory $df -File $pipelinesDir\SqlDwBotDetailedDataset.json -Force

$today=Get-Date -Format "yyyy-MM-dd"

substituteInTemplate $pipelinesDir\ProcessBotTextPipeline.json @{
    '$startDate' = $today
    }| Out-File $temp
New-AzureRmDataFactoryPipeline -DataFactory $df -File $temp -Force
#endregion

