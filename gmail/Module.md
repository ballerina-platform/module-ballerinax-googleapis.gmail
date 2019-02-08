Connects to Gmail from Ballerina. 

# Module Overview

The Gmail connector allows you to send, read, and delete emails through the Gmail REST API. It handles OAuth 2.0 
authentication. It also provides the ability to read, trash, untrash, delete threads, get the Gmail profile, mailbox 
history, etc.

**Working with Messages**

The `wso2/gmail` module contains operations to send emails in Text and HTML formats with attachments and inline images. 
It supports searching and reading messages in Gmail using Gmail filters. The module also supports trashing, untrashing, 
deleting, and modifying messages as well.

**Working with Threads**

The `wso2/gmail` module contains operations to read, search, trash, untrash, modify, and delete mail threads in Gmail.

**Working with Drafts**

The `wso2/gmail` module contains operations to search, read, delete, create, update, and send drafts in Gmail.   

**Working with Labels**

The `wso2/gmail` module containes operations to list, read, create, update, and delete labels in Gmail.

**Working with User Profiles**

The `wso2/gmail` module contains operations to get Gmail user profile details.

**Working with User History**

The `wso2/gmail` module contains operations to lists the history of changes to the user's mailbox.

## Compatibility
|                    |    Version     |  
|:------------------:|:--------------:|
| Ballerina Language | 0.990.3         |
| Gmail API          | v1             |

## Sample
First, import the `wso2/gmail` module into the Ballerina project.
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
6. In a separate browser window or tab, visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground). Click on the `OAuth 2.0 configuration`
 icon in the top right corner and click on `Use your own OAuth credentials` and provide your `OAuth Client ID` and `OAuth Client secret`.
7. Select the required Gmail API scopes from the list of API's, and then click **Authorize APIs**.
8. When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the refresh token and access token.

You can now enter the credentials in the HTTP client config. 
```ballerina
gmail:GmailConfiguration gmailConfig = {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            accessToken: testAccessToken,
            clientId: testClientId,
            clientSecret: testClientSecret,
            refreshToken: testRefreshToken
        }
    }
};

gmail:Client gmailClient = new(gmailConfig);
```
The `sendMessage` function sends an email. `MessageRequest` is an object that contains all the data that is required
to send an email. The `userId` represents the authenticated user and can be a Gmail address or ‘me’ (the currently authenticated user).

```ballerina
gmail:MessageRequest messageRequest = {};
messageRequest.recipient = "recipient@mail.com";
messageRequest.sender = "sender@mail.com";
messageRequest.cc = "cc@mail.com";
messageRequest.subject = "Email-Subject";
messageRequest.messageBody = "Email Message Body Text";
//Set the content type of the mail as TEXT_PLAIN or TEXT_HTML.
messageRequest.contentType = gmail:TEXT_PLAIN;
//Send the message.
var sendMessageResponse = gmailClient->sendMessage(userId, messageRequest);
```

The response from `sendMessage` is either a string tuple with the message ID and thread ID (if the message was sent successfully) or an `error` (if the message was unsuccessful).

```ballerina
if (sendMessageResponse is (string, string)) {
    // If successful, print the message ID and thread ID.
    string messageId = "";
    string threadId = "";
    (messageId, threadId) = sendMessageResponse;
    io:println("Sent Message ID: " + messageId);
    io:println("Sent Thread ID: " + threadId);
} else {
    // If unsuccessful, print the error returned.
    io:println("Error: ", sendMessageResponse);
}
```

The `readMessage` function reads messages. It returns the `Message` object when successful or an `error` when unsuccessful.

```ballerina
var response = gmailClient->readMessage(userId, messageIdToRead);
if (response is gmail:Message) {
    io:println("Sent Message: " + response);
} else {
    io:println("Error: ", response);
}
```

The `deleteMessage` function deletes messages. It returns an `error` when unsuccessful.

```ballerina    
var delete = gmailClient->deleteMessage(userId, messageIdToDelete);
if (delete is boolean) {
    io:println("Message deletion success!");
} else {
    io:println("Error: ", delete);
}
```

## Example

```ballerina
import ballerina/io;
import ballerina/http;
import wso2/gmail;

gmail:GmailConfiguration gmailConfig = {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            accessToken: "<accessToken>",
            clientId: "<clientId>",
            clientSecret: "<clientSecret>",
            refreshToken: "<refreshToken>"
        }
    }
};

gmail:Client gmailClient = new(gmailConfig);

public function main(string... args) {
    gmail:MessageRequest messageRequest = {};
    messageRequest.recipient = "aa@gmail.com";
    messageRequest.sender = "bb@gmail.com";
    messageRequest.cc = "cc@gmail.com";
    messageRequest.subject = "Email-Subject";
    messageRequest.messageBody = "Email Message Body Text";
    //Set the content type of the mail as TEXT_PLAIN or TEXT_HTML.
    messageRequest.contentType = gmail:TEXT_PLAIN;
    string userId = "me";
    //Send the message.
    var sendMessageResponse = gmailClient->sendMessage(userId, messageRequest);
    if (sendMessageResponse is (string, string)) {
        //If successful, print the message ID and thread ID.
        string messageId = "";
        string threadId = "";
        (messageId, threadId) = sendMessageResponse;
        io:println("Sent Message ID: " + messageId);
        io:println("Sent Thread ID: " + threadId);
    } else {
        // If unsuccessful, print the error returned.
        io:println("Error: ", sendMessageResponse);
    }
}
```