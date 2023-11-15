## Overview

[Gmail](https://blog.google/products/gmail/) is a widely-used email service provided by Google LLC, enabling users to send and receive emails over the internet.

The `ballerinax/googleapis.gmail` package offers APIs to connect and interact with [Gmail API](https://developers.google.com/gmail/api/guides) endpoints.

## Quickstart

**Note**: Ensure you follow the [prerequisites](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail#set-up-gmail-api) to set up the Gmail API.

To use the `gmail` connector in your Ballerina application, modify the `.bal` file as follows:

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
Now, utilize the available connector operations.
```ballerina
gmail:MessageListPage messageList = check gmailClient->/users/me/messages(q = "label:INBOX is:unread");
```

## Examples

The `gmail` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples), covering use cases like sending emails, retrieving messages, and managing labels.

1. [Process customer feedback emails](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/process-mails/main.bal)
    Manage customer feedback emails by processing unread emails in the inbox, extracting details, and marking them as read.


2. [Send maintenance break notifications](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/send-mails/main.bal)
    Automatically send emails for scheduled maintenance breaks.

3. [Send automated response to emails](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/reply-mails/main.bal)
    Automate fetching unread emails from the Inbox and send personalized responses to customers.

4. [Search for relevant email threads](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/search-threads/main.bal)
    Use the Gmail API to search for email threads based on a specific query.

For comprehensive information about the connector's functionality, configuration, and usage in Ballerina programs, refer to the `gmail` connector's reference guide in [Ballerina Central](https://central.ballerina.io/ballerinax/googleapis.gmail/latest).

## Set up Gmail API

To use the `gmail` connector, create Gmail credentials to interact with Gmail.

1. **Create a Google Cloud Platform project**: Create a new project on [Google Cloud Platform (GCP)](https://console.cloud.google.com/getting-started?pli=1). Enable the Gmail API for this project.

2. **Create OAuth client ID**: In the GCP console, create credentials for the OAuth client ID by setting up the OAuth consent screen.

3. **Get the access token and refresh token**: Generate an access token and a refresh token using the OAuth playground.

For detailed steps, including necessary links, refer to the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/docs/setup/setup.md).
