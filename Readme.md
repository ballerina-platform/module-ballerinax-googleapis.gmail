# GMail Connector

GMail connector provides a Ballerina API to access the [Gmail REST API](https://developers.google.com/gmail/api/v1/reference/). It handles [OAuth2.0](http://tools.ietf.org/html/rfc6749), provides auto completion and type safety.

## Compatibility

| Ballerina Language Version | Connector Version  | Gmail API Version |  
| :-------------------------:|:------------------:|:-----------------:| 
| 0.970.0-beta3              | 0.8.7              | v1                | 

## Getting started

1.  Refer https://ballerina.io/learn/getting-started/ to download and install Ballerina.
2.  To use GMail endpoint, you need to provide the following:

       - Client Id
       - Client Secret
       - Access Token
       - Refresh Token
    
       *Please note that, providing ClientId, Client Secret, Refresh Token are optional if you are only providing a valid Access                   
       Token vise versa.*
    
       Refer https://developers.google.com/identity/protocols/OAuth2 to obtain the above credentials.

3. Create a new Ballerina project by executing the following command.

      ``<PROJECT_ROOT_DIRECTORY>$ ballerina init``

5. Import the gmail package to your Ballerina program as follows.

```ballerina
import ballerina/io;
import wso2/gmail;

//User credentials to access Gmail API
string accessToken = "<access_token>";
string clientId = "<client_id>";
string clientSecret = "<client_secret>";
string refreshToken = "<refresh_token>";
//The user's email address. The special value "me" can be used to indicate the authenticated user.
string userId = "me";

function main(string... args) {

    endpoint gmail:Client gMailEP {
        clientConfig:{
            auth:{
                accessToken:accessToken,
                clientId:clientId,
                clientSecret:clientSecret,
                refreshToken:refreshToken
            }
        }
    };

    //Set headers, message body and etc to MessageRequest.
    gmail:MessageRequest messageRequest;
    messageRequest.recipient = "recipient@mail.com";
    messageRequest.sender = "sender@mail.com";
    messageRequest.cc = "cc@mail.com";
    messageRequest.subject = "Email-Subject";
    messageRequest.messageBody = "Email Message Body Text";
    //Set the content type of the mail as TEXT_PLAIN or TEXT_HTML.
    messageRequest.contentType = gmail:TEXT_PLAIN;

    //Call the GMail endpoint function sendMessage().
    var sendMessageResponse = gMailEP -> sendMessage(userId, messageRequest);
    match sendMessageResponse {
        (string, string) sendStatus => {
            //For a successful message request, returns message and thread id.
            string messageId;
            string threadId;
            (messageId, threadId) = sendStatus;
            io:println("Sent Message Id : " + messageId);
            io:println("Sent Thread Id : " + threadId);
        }
        gmail:GMailError e => io:println(e); //For unsuccessful attempts, returns GMail Error.
    }
}
```
