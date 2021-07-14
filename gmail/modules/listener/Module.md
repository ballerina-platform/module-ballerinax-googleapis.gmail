## Overview
The Gmail listener Ballerina Connector provides the capability to listen the push notification for changes of Gmail mailbox. The Gmail listener Ballerina Connector supports to listen the changes of Gmail mailbox such as receiving new message, receiving new thread, adding new label to a message, adding star to a message, removing label to a message, removing star to a message, and receiving a new attachment with following trigger methods: `onNewEmail`, `onNewThread`, `onEmailLabelAdded`, `onEmailStarred`, `onEmailLabelRemoved`,`onEmailStarRemoved`, `onNewAttachment`.

This module supports [Gmail API v1](https://developers.google.com/gmail/api).

## Prerequisites

Before using this connector in your Ballerina application, complete the following:

1. Create a [Google account](https://accounts.google.com/signup/v2/webcreateaccount?utm_source=ga-ob-search&utm_medium=google-account&flowName=GlifWebSignIn&flowEntry=SignUp). (If you already have one, you can use that.)

2. Obtain tokens 
- Follow [this guide](https://developers.google.com/identity/protocols/oauth2)
    > **Note :** If you want to use **`listener`**, then enable `Cloud Pub/Sub API` or user setup service account with pubsub admin role. If you want to use only Gmail scopes token then you can use service account configurations without  `Cloud Pub/Sub API v1` scope. [Create a service account](https://developers.google.com/identity/protocols/oauth2/service-account#creatinganaccount) with pubsub admin and download the p12 key file.

## Quickstart

To use the `Gmail` connector listener in your Ballerina application, update the .bal file as follows:

### Step 1: Import connector
Import the ballerinax/googleapis.gmail and ballerinax/googleapis.gmail.'listener module into the Ballerina project.
```ballerina
    import ballerinax/googleapis.gmail as gmail;
    import ballerinax/googleapis.gmail.'listener as gmailListener;
```

### Step 2: Create a new connector instance
You can now make the connection configuration using either one of the following and initialize the connector with it.

- Using Google pubsub scope authorization.

    If you are able to authorize the pubsub scope, then you can follow all these steps to create a listener.

    Create a `gmail:GmailConfiguration` with the OAuth2 tokens obtained and initialize the connector with it.
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

- Using Google service account

    If you prefer to use only gmail scopes in your tokens, then you can use a service account to do listener operations along with your gmail tokens. For that you need to initialize the connector using following method

    Create a `gmail:GmailConfiguration` and `gmailListener:GmailListenerConfiguration` with the OAuth2 tokens obtained, and initialize the connector with it.

    ```ballerina
    configurable string refreshToken = ?;
    configurable string clientId = ?;
    configurable string clientSecret = ?;
    configurable int port = ?;
    configurable string project = ?;
    configurable string pushEndpoint = ?;

    configurable string issuer = ?;
    configurable string aud = ?;
    configurable string keyId = ?;
    configurable string path = ?;
    configurable string password = ?;
    configurable string keyAlias = ?;
    configurable string keyPassword = ?;

    gmail:GmailConfiguration gmailConfig = {
        oauthClientConfig: {
            refreshUrl: gmail:REFRESH_URL,
            refreshToken: refreshToken,
            clientId: clientId,
            clientSecret: clientSecret
            }
    };

    gmailListener:GmailListenerConfiguration listenerConfig = {authConfig: {
            issuer: issuer,
            audience: aud,
            customClaims: {"sub": issuer},
            keyId: keyId,
            signatureConfig: {config: {
                    keyStore: {
                        path: path,
                        password: password
                    },
                    keyAlias: keyAlias,
                    keyPassword: keyPassword
                }}
        }};

    listener gmailListener:Listener gmailEventListener = new(port, gmailConfig,  project, pushEndpoint, listenerConfig);
    ```
> **NOTE :** 
>
> Here
> - `project` is the Id of the project which is created in `Google Cloud Platform`  to create credentials  (`clientId` and `clientSecret`).
> - `pushEndpoint` is the endpoint URL of the listener.

### Step 3: Define Ballerina service with the listener
1. Now start the listener as a service. Following is an example on how to listen arrival of a new email to the inbox using the connector listener.

    ```ballerina
    service / on gmailEventListener {
    remote function onNewEmail(gmail:Message message) returns error? {
            // You can write your logic here. 
    }   
    }
    ```
2. Use `bal run` command to compile and run the Ballerina program.

> **NOTE :**
If the user's logic inside any remote method of the connector listener throws an error, connector internal logic will 
covert that error into a HTTP 500 error response and respond to the webhook (so that event may get redelivered), 
otherwise it will respond with HTTP 200 OK. Due to this architecture, if the user logic in listener remote operations
includes heavy processing, the user may face HTTP timeout issues for webhook responses. In such cases, it is advised to
process events asynchronously as shown below.

```ballerina

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
        _ = @strand { thread: "any" } start userLogic(message);
   }   
}

function userLogic(gmail:Message message) returns error? {
    // Write your logic here
}
```

**[You can find a list of samples here](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/samples/listener)**

