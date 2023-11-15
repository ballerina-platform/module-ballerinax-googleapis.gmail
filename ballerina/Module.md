## Overview


[Gmail](https://blog.google/products/gmail/) is a product of Google LLC, which is a widely-used email service that enables users to send and receive emails over the internet.

The `ballerinax/googleapis.gmail` package provides APIs to connect and interact with [Gmail API](https://developers.google.com/gmail/api/guides) endpoints.

## Quickstart

**Note**: Ensure to follow the [prerequisites](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail#set-up-gmail-api) to set up the Gmail API.

To utilize the `gmail` connector in your Ballerina application, modify the `.bal` file as follows:

### Step 1: Import the connector
Import the `ballerinax/googleapis.gmail` package into your Ballerina project.
```ballerina
import ballerinax/googleapis.gmail;
```

### Step 2: Instantiate a new connector
Create a `gmail:ConnectionConfig` with the obtained OAuth2.0 tokens and initialize the connector with it.
```ballerina
gmail:Client gmailClient = check new gmail:Client (
        config = {
            auth: {
                refreshToken: refreshToken,
                clientId: clientId,
                clientSecret: clientSecret
            }
        }
    );
```

### Step 3: Invoke the connector operation
You can now utilize the operations available within the connector.
```ballerina
gmail:MessageListPage messageList = check gmailClient->/users/me/messages(q = "label:INBOX is:unread");
```

## Examples

The `gmail` connector provides several practical examples that illustrate its usage in various scenarios. These [examples](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples) cover a variety of use cases including sending emails, retrieving messages, and managing labels.

1. [Process customer feedback emails](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/process-mails/main.bal)
    This example shows how to manage customer feedback emails. It checks for unread emails in the inbox, processes these emails, and adds details such as the subject and sender to a CSV file. After processing, all emails will be marked as read.

2. [Send maintenance break notifications](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/send-mails/main.bal)
    This example demonstrates how to automatically send emails to users or administrators when a scheduled maintenance break is imminent or has begun. It includes code to embed inline images in the email.

3. [Send automated response to emails](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/reply-mails/main.bal)
    This example showcases how to automate the process of fetching unread emails from the Inbox, and subsequently sending a personalized response to the customer, expressing appreciation for their valuable feedback.

4. [Search for relevant email threads](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/search-threads/main.bal)
    This example shows how to use the Gmail API to search for email threads based on a specific query.

For more detailed information about the connector's functionality including how to configure and use it in your Ballerina programs, go to the comprehensive reference guide for the `gmail` connector available in [Ballerina Central](https://central.ballerina.io/ballerinax/googleapis.gmail/latest).

## Set up Gmail API

In order to use the `gmail` connector, you need to first create the Gmail credentials for the connector to interact with Gmail.

1. **Create a Google Cloud Platform project**: You need to create a new project on the Google Cloud Platform (GCP). Once the project is created, you can enable the Gmail API for this project.

2. **Create OAuth client ID**: In the GCP console, you need to create credentials for the OAuth client ID. This process involves setting up the OAuth consent screen and creating the credentials for the OAuth client ID.

3. **Get the access token and refresh token**: You need to generate an access token and a refresh token. The Oauth playground can be used to easily exchange the authorization code for the tokens.

For detailed steps including the necessary links, go to the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/docs/setup/setup.md).
