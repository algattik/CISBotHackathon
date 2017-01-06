using System.Net;

public static async Task<object> Run(HttpRequestMessage req, TraceWriter log, IAsyncCollector<string> outputEventHubMessage)
{
    log.Info($"Webhook was triggered!");

    string data = await req.Content.ReadAsStringAsync();
    await outputEventHubMessage.AddAsync(data);
    return req.CreateResponse(HttpStatusCode.OK, new {
        greeting = $"Invoke to Event Hub Done!"
    });
}

