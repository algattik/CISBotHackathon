$ErrorActionPreference = "Stop"
$scriptDir=($PSScriptRoot, '.' -ne "")[0]
. "$scriptDir\Include\common.ps1"


Write-Host "Create a Stream Analytics job..."  -ForegroundColor Green

$eventHubListenPolicyKey=(Get-AzureRmEventHubNamespaceKey -ResourceGroupName $resourceGroupName -NamespaceName $eventHubNamespace -AuthorizationRuleName $eventHubListenPolicyName).PrimaryConnectionString
$eventHubListenPolicySASKey=[regex]::Match($eventHubListenPolicyKey, ';SharedAccessKey=([^;]+)').Captures.Groups[1].Value

$temp=New-TemporaryFile
substituteInTemplate ..\Resources\FromEventHubStreamAnalytics\Definition.json @{
 '$eventHubName' = $eventHubName
 '$eventHubNamespace' = $eventHubNamespace
 '$eventHubListenPolicyName' = $eventHubListenPolicyName
 '$eventHubListenPolicyKey' = $eventHubListenPolicySASKey
 '$location' = $location
} | Out-File $temp

New-AzureRmStreamAnalyticsJob -ResourceGroupName $resourceGroupName -File $temp -Name $streamAnalyticsName -Force

$sub=(Get-AzureRmContext).Subscription.SubscriptionId
Write-Host -ForegroundColor Magenta "Perform this manual configuration"
Write-Host -ForegroundColor Magenta "https://portal.azure.com/#resource/subscriptions/$sub/resourceGroups/$resourceGroupName/providers/Microsoft.StreamAnalytics/streamingjobs/$streamAnalyticsName/outputs"
Write-Host -ForegroundColor Magenta "Create output with alias 'datalake', Sink: Data Lake Store, Path prefix pattern: 'botdata/{date}/{time}/'"
Write-Host -ForegroundColor Magenta "Create output with alias 'powerbi', Sink: Power BI, Dataset name: cisbot, Table name: botdata"
Write-Host -ForegroundColor Magenta "Then, start Stream Analytics job (from Overview pane)"
