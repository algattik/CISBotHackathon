using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using Newtonsoft.Json;
using Microsoft.Bot.Builder.Azure;
using Microsoft.Bot.Builder.Dialogs;
using Microsoft.Bot.Builder.Luis;
using Microsoft.Bot.Builder.Luis.Models;
using Microsoft.Bot.Connector;


// For more information about this template visit http://aka.ms/azurebots-csharp-luis
[Serializable]
public class BasicLuisDialog : LuisDialog<object>
{

    // Replace this with the Logic App Request URL.
    const string logicAppURL = "...";
    // Replace this with the URL for the web service
    const string mlWebServiceURL = "...";
    // Replace this with the API key for the web service
    const string mlWebServiceApiKey = "...";

    const string offer1 = "Would you like to schedule an appointment?";
    const string offer2 = "Would you like to receive a brochure?";

    //TODO use context
    private MsgObj lob = new MsgObj();

    public BasicLuisDialog() : base(new LuisService(new LuisModelAttribute(Utils.GetAppSetting("LuisAppId"), Utils.GetAppSetting("LuisAPIKey"))))
    {
    }

    [LuisIntent("None")]
    public async Task NoneIntent(IDialogContext context, LuisResult result)
    {
        await interact(context, result, "I didn't understand your request. You can call us at 1-800-FABRIKAM.");
    }

    [LuisIntent("complain about a model")]
    public async Task ComplainIntent(IDialogContext context, LuisResult result)
    {
        await interact(context, result, "We have taken note of your complaint about the {0}.");
    }

    [LuisIntent("get info about a model")]
    public async Task GetInfoIntent(IDialogContext context, LuisResult result)
    {
        await interact(context, result, "You will find detailed information about {0} at http://fabrikam.com/our-range");
    }

    private async Task interact(IDialogContext context, LuisResult result, string message)
    {

        string intent = "false";
        if (result.Intents.Count > 0)
        {
            intent = result.Intents[0].Intent;
        }

        string product = "None";
        foreach (var entity in result.Entities)
        {
            if (entity.Type == "product")
            {
                {
                    product = entity.Entity;
                    break;
                }
            }
        }

        await context.PostAsync(String.Format(message, product));

        lob.Text = result.Query;
        lob.Intent = intent;
        lob.Product = product;
        PostToLogicApp(lob);

        // Randomly select one of the two offers. Replace this with the line
        // below after the ML Web service is trained and deployed
        string offer = new Random().Next(2) == 0 ? offer1 : offer2;
        // string offer = await GetOptimalOfferFromMLService(intent, product);

        lob = lob.Clone();
        lob.Text = offer;

        PromptDialog.Confirm(context, AfterConfirming_interaction, lob.Text, promptStyle: PromptStyle.None);
    }

    public async Task AfterConfirming_interaction(IDialogContext context, IAwaitable<bool> confirmation)
    {
        string message;
        if (await confirmation)
        {
            lob.Intent = "accepted proposal";
            message = $"Ok, done.";
        }
        else
        {
            lob.Intent = "rejected proposal";
            message = $"What else can I help you with?";
        }
        await context.PostAsync(message);

        PostToLogicApp(lob);

        context.Wait(MessageReceived);
    }

    protected override Task<string> GetLuisQueryTextAsync(IDialogContext context, IMessageActivity message)
    {
        lob.ChannelId = message.ChannelId;
        lob.Id = message.Id;
        lob.ServiceUrl = message.ServiceUrl;
        lob.Type = message.Type;
        lob.Timestamp = message.Timestamp;
        lob.UserId = message.From.Id;
        lob.UserName = message.From.Name;
        return base.GetLuisQueryTextAsync(context, message);
    }

    private void PostToLogicApp(MsgObj data)
    {
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(logicAppURL);
        request.ContentType = "application/json";
        request.Method = "POST";

        using (var streamWriter = new StreamWriter(request.GetRequestStream()))
        {
            string json = Newtonsoft.Json.JsonConvert.SerializeObject(data);

            streamWriter.Write(json);
            streamWriter.Flush();
            streamWriter.Close();
        }

        HttpWebResponse response = (HttpWebResponse)request.GetResponse();

        if (response.StatusCode == HttpStatusCode.OK)
        {
            //do something 

        }

    }

    static async Task<String> GetOptimalOfferFromMLService(string intent, string product)
    {
        using (var client = new HttpClient())
        {
            var scoreRequest = new
            {
                Inputs = new Dictionary<string, StringTable>() {
                    {
                        "input1",
                        new StringTable()
                        {
                            ColumnNames = new string[] {"intent", "product", "offer", "outcome"},
                            Values = new string[,] {  { intent, product, offer1, "0" },  { intent, product, offer2, "0" },  }
                        }
                    },
                }
            };

            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", mlWebServiceApiKey);
            client.BaseAddress = new Uri(mlWebServiceURL);

            HttpResponseMessage response = await client.PostAsJsonAsync("", scoreRequest);

            if (response.IsSuccessStatusCode)
            {
                var result = await response.Content.ReadAsAsync<Dictionary<string,  Dictionary<string, ResultOutput>>>();
                var output = result["Results"]["output1"];
                var probIndex = Array.IndexOf(output.Value.ColumnNames, "Scored Probabilities");
                var offer1AcceptProb = Double.Parse(output.Value.Values[0, probIndex]);
                var offer2AcceptProb = Double.Parse(output.Value.Values[1, probIndex]);
                var offer = offer1AcceptProb >= offer2AcceptProb ? offer1 : offer2;
                return offer;
            }
            else
            {
                throw new Exception(string.Format("The request failed with status code: {0} - {1} - {2}", response.StatusCode, response.Headers.ToString(), await response.Content.ReadAsStringAsync()));
            }
        }
    }

}

[Serializable]
public class MsgObj
{
    [JsonProperty("type")]
    public string Type { get; set; }
    [JsonProperty("id")]
    public string Id { get; set; }
    [JsonProperty("timestamp")]
    public DateTime? Timestamp { get; set; }
    [JsonProperty("serviceUrl")]
    public string ServiceUrl { get; set; }
    [JsonProperty("channelId")]
    public string ChannelId { get; set; }
    [JsonProperty("text")]
    public string Text { get; set; }
    [JsonProperty("product")]
    public string Product { get; set; }
    [JsonProperty("intent")]
    public string Intent { get; set; }
    [JsonProperty("userid")]
    public string UserId { get; set; }
    [JsonProperty("username")]
    public string UserName { get; set; }
    public MsgObj Clone() { return (MsgObj)this.MemberwiseClone(); }
}


public class StringTable
{
    public string[] ColumnNames { get; set; }
    public string[,] Values { get; set; }
}


public class ResultOutput
{
    public string Type { get; set; }
    public ResultValue Value { get; set; }
}

public class ResultValue : StringTable
{
    public string[] ColumnTypes { get; set; }
}


