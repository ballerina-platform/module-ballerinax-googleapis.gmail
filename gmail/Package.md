# Package Overview
Connects to Gmail from Ballerina. 

This package provides a Ballerina API for the Gmail REST API. It provides the ability to send emails, read emails, 
delete emails, read threads, get the Gmail profile, etc. It handles OAuth 2.0 and provides auto completion and 
type conversions.

**Message Operations**

The wso2/gmail package contains operations to send emails in Text and HTML formats with attachments and inline images. 
It supports searching and reading messages in Gmail using Gmail filters. The package also supports trashing, untrashing, 
and deleting messages as well.

**Thread Operations**

The wso2/gmail package contains operations to read, search, trash, untrash, and delete mail threads in Gmail.

**UserProfile Operations**

The wso2/gmail package contains operations to get Gmail user profile details.

## Compatibility
|                    |    Version     |  
| :-----------------:|:--------------:| 
| Ballerina Language | 0.970.0-beta15 |
|  Gmail Basic API   |    v1         |  

## Sample
The Gmail connector can be used to send, read, and delete email. First, import the `wso2/gmail` package into the 
Ballerina project.
```ballerina
import wso2/gmail;
```
Instantiate the connector by giving authentication details in the HTTP client config, which has inbuilt support for 
BasicAuth and OAuth 2.0. Gmail uses OAuth 2.0 to authenticate and authorize requests. The Gmail connector can be 
minimally instantiated in the HTTP client config using the access token or using the client ID, client secret, 
and refresh token.

**Obtaining Tokens to Run the Sample**

1. Visit [Google API Console](https://console.developers.google.com). Continue through the wizard, configure the OAuth consent screen under **Credentials**, and 
give a product name to be shown to users.
2. Create OAuth client ID credentials by selecting an application type and giving a name and a redirect URI. *Give the 
redirect URI as (https://developers.google.com/oauthplayground) if you are using 
[OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the 
access token and refresh token.*
3. Visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground) and select the required Gmail API scopes.
4. Provide the client ID and client secret to obtain the refresh token and access token. 

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
The `readMessage` function reads messages via the Gmail API. It returns the `Message` struct when successful and 
`GmailError` when unsuccessful. 
```ballerina
var response = gmailEP -> readMessage(userId, messageIdToRead);
match response {
    gmail:Message m => io:println("Sent Message: " + m);
    gmail:GmailError e => io:println(e);
} 
```
The `deleteMessage` function deletes messages via the Gmail API. It returns a `GmailError` when unsuccessful. 
```ballerina
var delete = gmailEP -> deleteMessage(userId, messageIdToDelete);
match delete {
    boolean success => io:println("Message deletion success!");
    gmail:GmailError e => io:println(e);
}
```