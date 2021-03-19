import ballerina/http;
import ballerina/log;
import ballerinax/googleapis_gmail as gmail;
import ballerinax/googleapis_gmail.'listener as gmailListener;

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable int port = ?;
configurable string topicName = ?;

gmail:GmailConfiguration gmailConfig = {
    oauthClientConfig: {
        refreshUrl: gmail:REFRESH_URL,
        refreshToken: refreshToken,
        clientId: clientId,
        clientSecret: clientSecret
        }
};

gmail:Client gmailClient = new (gmailConfig);

listener gmailListener:Listener gmailEventListener = new(port, gmailClient, topicName);

service / on gmailEventListener {
    resource function post web(http:Caller caller, http:Request req) {
        var payload = req.getJsonPayload();
        var response = gmailEventListener.onMailboxChanges(caller , req);
        if(response is gmail:MailboxHistoryPage) {
            var triggerResponse = gmailEventListener.onLabelRemovedEmail(response);
            if(triggerResponse is gmailListener:ChangedLabel[]) {
                if (triggerResponse.length()>0){
                    //Write your logic here.....
                    foreach var changedLabel in triggerResponse {
                        log:print("Message ID: "+ changedLabel.message.id + " Changed Label ID: "
                            +changedLabel.changedLabelId[0]);
                    }
                }
            }
        }
    }     
}
