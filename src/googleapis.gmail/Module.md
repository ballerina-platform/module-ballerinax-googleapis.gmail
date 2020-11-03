Connects to Gmail from Ballerina.

## Module Overview

Ballerina Gmail Connector provides the capability to send, read and delete emails through the Gmail REST API. It also provides the ability to read, trash, untrash and delete threads, ability to get the Gmail profile and mailbox history, etc. The connector handles OAuth 2.0 authentication.

## Configurations

Instantiate the connector by giving authentication details in the Gmail client config, which has built-in support for OAuth 2.0. Gmail uses OAuth 2.0 to authenticate and authorize requests. The Gmail connector can be minimally instantiated in the Gmail client config using the Access Token or by using the Client ID, Client Secret and Refresh Token.

**Obtaining Tokens to Run the Sample**

1. Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and follow the wizard to create a new project.
2. Go to **Credentials -> OAuth Consent Screen**, enter a product name to be shown to users, and click **Save**.
3. On the **Credentials** tab, click **Create Credentials** and select **OAuth Client ID**.
4. Select an application type, enter a name for the application, and specify a redirect URI (enter https://developers.google.com/oauthplayground if you want to use
[OAuth 2.0 Playground](https://developers.google.com/oauthplayground) to receive the Authorization Code and obtain the
Access Token and Refresh Token).
5. Click **Create**. Your Client ID and Client Secret will appear.
6. In a separate browser window or tab, visit [OAuth 2.0 Playground](https://developers.google.com/oauthplayground). Click on the `OAuth 2.0 Configuration`
 icon in the top right corner and click on `Use your own OAuth credentials` and provide your `OAuth Client ID` and `OAuth Client Secret`.
7. Select the required Gmail API scopes from the list of API's, and then click **Authorize APIs**.
8. When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the refresh token and access token.

You can now enter the credentials in the Gmail client config.

```ballerina
gmail:GmailConfiguration gmailConfig = {
    oauthClientConfig: {
        accessToken: <ACCESS_TOKEN>,
        refreshConfig: {
            refreshUrl: gmail:REFRESH_URL,
            refreshToken: <REFRESH_TOKEN>,
            clientId: <CLIENT_ID>,
            clientSecret: <CLIENT_SECRET>
        }
    }
};

gmail:Client gmailClient = new (gmailConfig);
```

## Compatibility

| Ballerina Language Versions  | Gmail API Version |
|:----------------------------:|:-----------------:|
|  Swan Lake Preview5          |   v1              |

## Sample

```ballerina
import ballerina/io;
import ballerinax/googleapis.gmail;

gmail:GmailConfiguration gmailConfig = {
    oauthClientConfig: {
        accessToken: <ACCESS_TOKEN>,
        refreshConfig: {
            refreshUrl: gmail:REFRESH_URL,
            refreshToken: <REFRESH_TOKEN>,
            clientId: <CLIENT_ID>,
            clientSecret: <CLIENT_SECRET>
        }
    }
};
gmail:Client gmailClient = new (gmailConfig);
public function main(string... args) {
    gmail:MessageRequest messageRequest = {};
    messageRequest.recipient = "aa@gmail.com";
    messageRequest.sender = "bb@gmail.com";
    messageRequest.cc = "cc@gmail.com";
    messageRequest.subject = "Email-Subject";
    messageRequest.messageBody = "Email Message Body Text";
    // Set the content type of the mail as TEXT_PLAIN or TEXT_HTML.
    messageRequest.contentType = gmail:TEXT_PLAIN;
    string userId = "me";
    // Send the message.
    var sendMessageResponse = gmailClient->sendMessage(userId, messageRequest);
    if (sendMessageResponse is [string, string]) {
        // If successful, print the message ID and thread ID.
        [string, string] [messageId, threadId] = sendMessageResponse;
        io:println("Sent Message ID: " + messageId);
        io:println("Sent Thread ID: " + threadId);
    } else {
        // If unsuccessful, print the error returned.
        io:println("Error: ", sendMessageResponse);
    }
}
```
