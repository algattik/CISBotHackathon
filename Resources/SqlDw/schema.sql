CREATE TABLE [dbo].[BotDetailedData] (
    [timestamp] datetime2(7), 
    [intent] nvarchar(100), 
    [channelId] nvarchar(100), 
    [id] nvarchar(100) NOT NULL, 
    [product] nvarchar(250), 
    [score] decimal(19, 10), 
    [text] nvarchar(4000), 
    [EventProcessedUtcTime] datetime2(7), 
    [PartitionId] bigint,
    [EventEnqueuedUtcTime] datetime2(7), 
    [KeyPhrase] nvarchar(4000)
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([id]));


