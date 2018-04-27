# Gmail Connector

The Gmail connector allows you to send, read, and delete emails through the Gmail REST API. It handles OAuth 2.0 
authentication. It also provides the ability to read, trash, untrash, delete threads, get the Gmail profile, etc.

**Message Operations**

The `wso2/gmail` package contains operations to send emails in Text and HTML formats with attachments and inline images. 
It supports searching and reading messages in Gmail using Gmail filters. The package also supports trashing, untrashing, 
and deleting messages as well.

**Thread Operations**

The `wso2/gmail` package contains operations to read, search, trash, untrash, and delete mail threads in Gmail.

**UserProfile Operations**

The `wso2/gmail` package contains operations to get Gmail user profile details.

## Compatibility
|                    |    Version     |  
| :-----------------:|:--------------:| 
| Ballerina Language | 0.970.0-rc1    |
|     Gmail API      |    v1         |  

## Sample
First, import the `wso2/gmail` package into the Ballerina project.
```ballerina
import wso2/gmail;
```
Instantiate the connector by giving authentication details in the HTTP client config, which has built-in support for 
BasicAuth and OAuth 2.0. Gmail uses OAuth 2.0 to authenticate and authorize requests. The Gmail connector can be 
minimally instantiated in the HTTP client config using the access token or using the client ID, client secret, 
and refresh token.

**Obtaining Tokens to Run the Sample**

1. Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and follow the wizard to create a new project.
2. Go to **Credentials -> OAuth consent screen**, enter a product name to be shown to users, and click **Save**.
3. On the **Credentials** tab, click **Create credentials** and select **OAuth client ID**. 
4. Select an application type, enter a name for the application, and specify a redirect URI (enter https://developers.google.com/oauthplayground if you want to use 
[OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the 
access token and refresh token). 
5. Click **Create**. Your client ID and client secret appear. 
6. In a separate browser window or tab, visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground), select the required Gmail API scopes, and then click **Authorize APIs**.
7. When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the refresh token and access token. 

You can now enter the credentials in the HTTP client config. 
```ballerina
endpoint gmail:Client gmailEP {
    clientConfig:{
        auth:{
            accessToken:accessToken,
            clientId:clientId,
            clientSecret:clientSecret,
            refreshToken:refreshToken
        }
    }
};
```
The `sendMessage` function sends an email. `MessageRequest` is a structure that contains all the data that is required 
to send an email. The `userId` represents the authenticated user and can be a Gmail address or ‘me’ 
(the currently authenticated user).
```ballerina
gmail:MessageRequest messageRequest;
messageRequest.recipient = "recipient@mail.com";
messageRequest.sender = "sender@mail.com";
messageRequest.cc = "cc@mail.com";
messageRequest.subject = "Email-Subject";
messageRequest.messageBody = "Email Message Body Text";
//Set the content type of the mail as TEXT_PLAIN or TEXT_HTML.
messageRequest.contentType = gmail:TEXT_PLAIN;
//Send the message.
var sendMessageResponse = gmailEP -> sendMessage(userId, messageRequest);
```
The response from `sendMessage` is either a string tuple with the message ID and thread ID 
(if the message was sent successfully) or a `GmailError` (if the message was unsuccessful). The `match` operation can be 
used to handle the response if an error occurs.
```ballerina
match sendMessageResponse {
    (string, string) sendStatus => {
        //If successful, returns the message ID and thread ID.
        string messageId;
        string threadId;
        (messageId, threadId) = sendStatus;
        io:println("Sent Message ID: " + messageId);
        io:println("Sent Thread ID: " + threadId);
    }
    
    //Unsuccessful attempts return a Gmail error.
    gmail:GmailError e => io:println(e); 
}
```
The `readMessage` function reads messages. It returns the `Message` struct when successful and 
`GmailError` when unsuccessful. 
```ballerina
var response = gmailEP -> readMessage(userId, messageIdToRead);
match response {
    gmail:Message m => io:println("Sent Message: " + m);
    gmail:GmailError e => io:println(e);
} 
```
The `deleteMessage` function deletes messages. It returns a `GmailError` when unsuccessful. 
```ballerina    
var delete = gmailEP -> deleteMessage(userId, messageIdToDelete);
match delete {
    boolean success => io:println("Message deletion success!");
    gmail:GmailError e => io:println(e);
}
```
