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
        refreshUrl: gmail:REFRESH_URL,
        refreshToken: <REFRESH_TOKEN>,
        clientId: <CLIENT_ID>,
        clientSecret: <CLIENT_SECRET>
    }
};

gmail:Client gmailClient = new (gmailConfig);
```

## Compatibility

| Ballerina Language Versions  | Gmail API Version |
|:----------------------------:|:-----------------:|
|  Swan Lake Alpha 5           |   v1              |

## Example Code
This code sample represents sending a new text message from one Gmail user to another one. Here, the receiver which needs to receive carbon copy is also mentioned.
```ballerina
import ballerina/io;
import ballerinax/googleapis.gmail as gmail;

gmail:GmailConfiguration gmailConfig = {
    oauthClientConfig: {
        refreshUrl: gmail:REFRESH_URL,
        refreshToken: <REFRESH_TOKEN>,
        clientId: <CLIENT_ID>,
        clientSecret: <CLIENT_SECRET>
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
# Listener Module

Connects to Gmail Listener using Ballerina.

# Module Overview

The Gmail Listener Ballerina Connector provides the capability to listen the push notification for changes to Gmail mailboxes. The Gmail Listener Ballerina Connector supports to listen the changes of Gmail mailboxes such as receiving new message, receiving new thread, adding new label to a message, adding star to a message, removing label to a message, removing star to a message and receiving a new attachment with following trigger methods: `onNewEmail`, `onNewThread`, `onNewLabeledEmail`, `onNewStarredEmail`, `onLabelRemovedEmail`,`onStarRemovedEmail`, `onNewAttachment`.


# Prerequisites:

* Java 11 Installed
Java Development Kit (JDK) with version 11 is required.

* Download the Ballerina [distribution](https://ballerinalang.org/downloads/)
Ballerina Swan Lake Alpha 5 is required.

* Instantiate the connector by giving authentication details in the HTTP client config. The HTTP client config has built-in support for BasicAuth and OAuth 2.0. Gmail uses OAuth 2.0 to authenticate and authorize requests. The Gmail connector can be minimally instantiated in the HTTP client config using the client ID, client secret, and refresh token.
    * Client ID
    * Client Secret
    * Refresh Token
    * Refresh URL

## Obtaining Tokens

1. Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and follow the wizard to create a new project.
2. Go to **Library** from the left side menu. In the search bar enter required API/Service name(Eg: Gmail, Cloud Pub/Sub). Then select required service and click **Enable** button.
3. Go to **Credentials -> OAuth consent screen**, enter a product name to be shown to users, and click **Save**.
4. On the **Credentials** tab, click **Create credentials** and select **OAuth client ID**. 
5. Select an application type, enter a name for the application, and specify a redirect URI (enter https://developers.google.com/oauthplayground if you want to use 
[OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the refresh token). 
6. Click **Create**. Your client ID and client secret appear. 
7. In a separate browser window or tab, visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground), select the required Gmail scopes and `https://www.googleapis.com/auth/pubsub` scope of `Cloud Pub/Sub API v1`, and then click **Authorize APIs**.

8. When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the refresh token.


## Add project configurations file
Add the project configuration file by creating a `Config.toml` file under the root path of the project structure.
This file should have following configurations. Add the token obtained in the previous step to the `Config.toml` file.

```
[ballerinax.googleapis.gmail]
refreshToken = "enter your refresh token here"
clientId = "enter your client id here"
clientSecret = "enter your client secret here"
port = "enter the port where your listener runs"
topicName = "enter your push topic name"
subscriptionName = "enter your subscription name"
project = "enter your project name"
pushEndpoint = "Listener endpoint"

```

# Compatibility

| Ballerina Language Versions  | Gmail API Version |
|:----------------------------:|:-----------------:|
|  Swan Lake Alpha 5           |   v1              |

# Quickstart(s):

## Working with Gmail Listener

### Step 1: Import Gmail and Gmail Listener Ballerina Library
First, import the ballerinax/googleapis.gmail and ballerinax/googleapis.gmail.'listener module into the Ballerina project.
```ballerina
    import ballerinax/googleapis.gmail as gmail;
    import ballerinax/googleapis.gmail.'listener as gmailListener;
```

### Step 2: Initialize the Gmail Listener
In order for you to use the Gmail Listener Endpoint, first you need to create a Gmail Listener endpoint.
```ballerina
configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable int port = ?;
configurable string project = ?;
configurable string pushEndpoint = ?;

gmail:GmailConfiguration gmailConfig = {
    oauthClientConfig: {
        refreshUrl: gmail:REFRESH_URL,
        refreshToken: refreshToken,
        clientId: clientId,
        clientSecret: clientSecret
        }

listener gmailListener:Listener gmailEventListener = new(port, gmailConfig,  project, pushEndpoint);



```
### Step 3: Write service with required trigger 
The Listener triggers can be invoked by using a service.
```ballerina
service / on gmailEventListener {
   remote function onNewEmail(gmail:Message message) returns error? {
           // You can write your logic here. 
   }   
}
```


# Samples

### On New Email

Triggers when a new e-mail appears in the mail inbox.

```ballerina
import ballerina/log;
import ballerinax/googleapis.gmail as gmail;
import ballerinax/googleapis.gmail.'listener as gmailListener;

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable int port = ?;
configurable string project = ?;
configurable string pushEndpoint = ?;

gmail:GmailConfiguration gmailConfig = {
    oauthClientConfig: {
        refreshUrl: gmail:REFRESH_URL,
        refreshToken: refreshToken,
        clientId: clientId,
        clientSecret: clientSecret
        }
};

listener gmailListener:Listener gmailEventListener = new(port, gmailConfig,  project, pushEndpoint);

service / on gmailEventListener {
   remote function onNewEmail(gmail:Message message) returns error? {
           log:printInfo("New Email : " , message);
   }   
}

```

### On New Labeled Email

Triggers when you label an email.

```ballerina
import ballerina/log;
import ballerinax/googleapis.gmail as gmail;
import ballerinax/googleapis.gmail.'listener as gmailListener;

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable int port = ?;
configurable string project = ?;
configurable string pushEndpoint = ?;

gmail:GmailConfiguration gmailConfig = {
    oauthClientConfig: {
        refreshUrl: gmail:REFRESH_URL,
        refreshToken: refreshToken,
        clientId: clientId,
        clientSecret: clientSecret
        }
};

listener gmailListener:Listener gmailEventListener = new(port, gmailConfig,  project, pushEndpoint);

service / on gmailEventListener {
   remote function onNewLabeledEmail(gmailListener:ChangedLabel changedLabeldMsg) returns error? {
           log:printInfo("Labeled : " , changedLabeldMsg);
   }   
}

```
More samples are available at "https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/samples/listener".
