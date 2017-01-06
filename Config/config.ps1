#region - used for creating Azure service names
$namePrefix = [Environment]::UserName + "cisbot"
#endregion

#region - service names
$resourceGroupName = "CISBot"
$location = "East US 2" # Data Lake Store only available in few regions
$dataFactoryLocation = "East US"
$cognitiveServiceLocation = "West US"
#endregion

#region - service names
$dataLakeStoreName = $namePrefix + "adls"
$dataLakeAnalyticsName = $namePrefix + "adla"
$storageAccountName = $namePrefix + "was"
#endregion

$sqlName = $namePrefix + "sql"
$dwName = $namePrefix + "dw"

$dataFactoryName = $namePrefix + "df"

$eventHubNamespace = $namePrefix + "eventhubs"
$eventHubName = $namePrefix + "eventhub"
$eventHubSendPolicyName = "sendFromBot"
$eventHubListenPolicyName = "listenIntoStreamAnalytics"
$functionAppName = $namePrefix + "function"
$functionName = "PostToEventHub"
$logicAppName = $namePrefix + "logicapp"
$streamAnalyticsName = $namePrefix + "streamjob"
$cognitiveServiceName =  $namePrefix + "analytics"


$username = "zeus"

