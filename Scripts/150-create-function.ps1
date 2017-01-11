$ErrorActionPreference = "Stop"
$scriptDir=($PSScriptRoot, '.' -ne "")[0]
. "$scriptDir\Include\common.ps1"

Write-Host "Create a Function App..."  -ForegroundColor Green

$eventHubSendPolicyKey=(Get-AzureRmEventHubNamespaceKey -ResourceGroupName $resourceGroupName -NamespaceName $eventHubNamespace -AuthorizationRuleName $eventHubSendPolicyName).PrimaryConnectionString

Write-Host -ForegroundColor Magenta "Perform this manual configuration"
Write-Host -ForegroundColor Magenta "`nNavigate to:"
$sub=(Get-AzureRmContext).Subscription.SubscriptionId
Write-Host -ForegroundColor Magenta "https://portal.azure.com/#blade/WebsitesExtension/FunctionsIFrameBlade/id/%2Fsubscriptions%2F$sub%2FresourceGroups%2F$resourceGroupName%2Fproviders%2FMicrosoft.Web%2Fsites%2F$functionAppName"
Write-Host -ForegroundColor Magenta "`nCreate new resource of type Function App, name '$functionAppName'. When Function App is created, navigate to it."
Write-Host -ForegroundColor Magenta "`nClick New Function -> GenericWebHook-CSharp -> Name your function '$functionName'. Paste following code: "
Write-Host -ForegroundColor Cyan    (Get-Content -Path ..\Resources\PostToEventHubFunction\run.csx -Raw)

Write-Host -ForegroundColor Magenta "`nClick -> Integrate -> + New Output -> Azure Event Hub. Configure connection:"
Write-Host -ForegroundColor Magenta "`nEvent hub name:"
Write-Host -ForegroundColor Cyan     $eventHubName
Write-Host -ForegroundColor Magenta "Event hub connection: new, Connection name:"
Write-Host -ForegroundColor Cyan     $eventHubNamespace
Write-Host -ForegroundColor Magenta "Connection string:"
Write-Host -ForegroundColor Cyan     $eventHubSendPolicyKey



