## Overview
Ballerina Gmail Connector provides the capability to send, read, and delete emails through the Gmail REST API. It also provides the ability to read, trash, untrash, and delete threads, as well as the ability to get the Gmail profile and mailbox history, etc. The connector supports OAuth 2.0 authentication.

This module supports [Gmail API v1](https://developers.google.com/gmail/api).

## Prerequisites

Before using this connector in your Ballerina application, complete the following:

1. Create a [Google account](https://accounts.google.com/signup/v2/webcreateaccount?utm_source=ga-ob-search&utm_medium=google-account&flowName=GlifWebSignIn&flowEntry=SignUp). (If you already have one, you can use that.)

2. Obtain tokens 
    - Follow [this guide](https://developers.google.com/identity/protocols/oauth2)

## Quickstart

To use the Gmail connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import connector
Import the `ballerinax/googleapis.gmail` module into the Ballerina project.
```ballerina
import ballerinax/googleapis.gmail;
```

### Step 2: Create a new connector instance
Create a `gmail:ConnectionConfig` with the OAuth 2.0 tokens obtained, and initialize the connector with it.

```ballerina
gmail:ConnectionConfig gmailConfig = {
    auth: {
        refreshUrl: gmail:REFRESH_URL,
        refreshToken: <REFRESH_TOKEN>,
        clientId: <CLIENT_ID>,
        clientSecret: <CLIENT_SECRET>
    }
};

gmail:Client gmailClient = check new (gmailConfig);
```

### Step 3: Invoke connector operation
1. Now you can use the operations available within the connector. Note that they are in the form of remote operations.  
Following is an example on how to send an email using the connector.

    ```ballerina
    public function main() returns error? {
        string userId = "me";
        gmail:MessageRequest messageRequest = {
            recipient : "aa@gmail.com",
            cc : "cc@gmail.com",
            subject : "Email-Subject",
            messageBody : "Email Message Body Text",
            // Set the content type of the mail as TEXT_PLAIN or TEXT_HTML.
            contentType : gmail:TEXT_PLAIN
        };

        gmail:Message sendMessageResponse = check gmailClient->sendMessage(messageRequest, userId = userId);
    }
    ```
2. Use `bal run` command to compile and run the Ballerina program.

**[You can find a list of samples here](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/samples)**
