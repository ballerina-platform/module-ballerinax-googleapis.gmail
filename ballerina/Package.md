## Package overview

[Gmail](https://blog.google/products/gmail/), a product of Google LLC, is a widely-used email service that enables users to send and receive emails over the internet.

The `ballerinax/googleapis.gmail` library provides APIs to connect and interact with [Gmail API](https://developers.google.com/gmail/api/guides) endpoints.

## Quickstart

**Note**: Ensure to follow the [prerequisite](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail#setting-up-gmail-api) to set up the Gmail API.

To utilize the `gmail` connector in your Ballerina application, modify the .bal file as follows:

### Step 1: Import the connector
Import the `ballerinax/googleapis.gmail` module into your Ballerina project.
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

### Step 3: Invoke connector operation
You can now utilize the operations available within the connector.
```ballerina
gmail:MessageListPage messageList = check gmailClient->/users/me/messages(q = "label:INBOX is:unread");
```

## Examples

The `gmail` connector provides several practical examples that illustrate its use in various scenarios. These examples, located in the [`examples`](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples) directory, cover a variety of use cases, including sending emails, retrieving messages, and managing labels.

1. [Process Customer Feedback Emails](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/process-mails)
    This example shows how to manage customer feedback emails. It checks for unread emails in the INBOX, processes these emails, and adds details such as the subject and sender to a CSV file. After processing, all emails are marked as read.

2. [Send Maintenance Break Notification](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/send-mails)
    This example demonstrates how to automatically send emails to users or administrators when a scheduled maintenance break is imminent or has begun. It includes code to embed inline images in the email.

3. [Search for Relevant Email Threads](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/search-threads)
    This example shows how to use the Gmail API to search for email threads based on a specific query.

For more detailed information about the connector's functionality, including how to configure and use it in your Ballerina programs, refer to the comprehensive reference guide for the `gmail` connector available at [Ballerina Central](https://central.ballerina.io/ballerinax/googleapis.gmail/latest).

## Setting up Gmail API

Inorder to use `gmail` connector, You need to first create Gmail credentials for the connector to use in order to interact with Gmail.

1. **Create a Google Cloud Platform Project**: You need to create a new project on the Google Cloud Platform (GCP). Once the project is created, you can enable the Gmail API for this project.

2. **Create OAuth Client ID**: In the GCP console, you need to create credentials for the OAuth client ID. This process involves setting up the OAuth consent screen and creating credentials for the OAuth client ID.

3. **Get Access Token and Refresh Token**: You need to generate an access token and a refresh token. Oauth playground can be used to easily exchang the authorization code for tokens.

For detailed steps including the necessary links refer [Setup Guide](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/docs/setup/setup.md).

## Report Issues
To report bugs, request new features, start new discussions, view project boards, etc., go to the [Ballerina library parent repository](https://github.com/ballerina-platform/ballerina-library).

## Useful Links
- Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
- Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.