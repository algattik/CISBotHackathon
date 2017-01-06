$ErrorActionPreference = "Stop"
$scriptDir=($PSScriptRoot, '.' -ne "")[0]
. "$scriptDir\Include\common.ps1"

Write-Host "Create an Event Hub..."  -ForegroundColor Green

If (-Not(Get-AzureRmEventHubNamespace -ResourceGroupName $resourceGroupName -NamespaceName $eventHubNamespace -ErrorAction SilentlyContinue)) {
    New-AzureRmEventHubNamespace -ResourceGroupName $resourceGroupName -NamespaceName $eventHubNamespace -Location $location -SkuName Basic
}
If (-Not(Get-AzureRmEventHub -ResourceGroupName $resourceGroupName -NamespaceName $eventHubNamespace -EventHubName $eventHubName -ErrorAction SilentlyContinue)) {
    New-AzureRmEventHub -ResourceGroupName $resourceGroupName -NamespaceName $eventHubNamespace -EventHubName $eventHubName -Location $location
}
If (-Not(Get-AzureRmEventHubNamespaceAuthorizationRule -ResourceGroupName $resourceGroupName -NamespaceName $eventHubNamespace -AuthorizationRuleName $eventHubSendPolicyName -ErrorAction SilentlyContinue)) {
    New-AzureRmEventHubNamespaceAuthorizationRule -ResourceGroupName $resourceGroupName -NamespaceName $eventHubNamespace -AuthorizationRuleName $eventHubSendPolicyName -Rights @("Send")
}
If (-Not(Get-AzureRmEventHubNamespaceAuthorizationRule -ResourceGroupName $resourceGroupName -NamespaceName $eventHubNamespace -AuthorizationRuleName $eventHubListenPolicyName -ErrorAction SilentlyContinue)) {
    New-AzureRmEventHubNamespaceAuthorizationRule -ResourceGroupName $resourceGroupName -NamespaceName $eventHubNamespace -AuthorizationRuleName $eventHubListenPolicyName -Rights @("Listen")
}

