## Package overview

[Gmail](https://blog.google/products/gmail/) is a widely-used email service provided by Google LLC, enabling users to send and receive emails over the internet.

The `ballerinax/googleapis.gmail` package offers APIs to connect and interact with [Gmail API](https://developers.google.com/gmail/api/guides) endpoints, specifically based on [Gmail API v1](https://gmail.googleapis.com/$discovery/rest?version=v1).

## Setup guide

To use the Gmail connector, you must have access to the Gmail REST API through a [Google Cloud Platform (GCP)](https://console.cloud.google.com/) account and a project under it. If you do not have a GCP account, you can sign up for one [here](https://cloud.google.com/).

### Step 1: Create a Google Cloud Platform Project

1. Open the [Google Cloud Platform Console](https://console.cloud.google.com/).

2. Click on the project drop-down menu and select an existing project or create a new one for which you want to add an API key.

    ![GCP Console Project View](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.gmail/master/docs/setup/resources/gcp-console-project-view.png)

### Step 2: Enable Gmail API

1. Navigate to the **Library** tab and enable the Gmail API.

    ![Enable Gmail API](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.gmail/master/docs/setup/resources/enable-gmail-api.png)

### Step 3: Configure OAuth consent

1. Click on the **OAuth consent screen** tab in the Google Cloud Platform console.

    ![Consent Screen](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.gmail/master/docs/setup/resources/consent-screen.png)

2. Provide a name for the consent application and save your changes.

### Step 4: Create OAuth client

1. Navigate to the **Credentials** tab in your Google Cloud Platform console.

2. Click on **Create credentials** and select **OAuth client ID** from the dropdown menu.

    ![Create Credentials](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.gmail/master/docs/setup/resources/create-credentials.png)

3. You will be directed to the **Create OAuth client ID** screen, where you need to fill in the necessary information as follows:

    | Field                    | Value                |
    | ------------------------ | -------------------- |
    | Application type         | Web Application      |
    | Name                     | GmailConnector       |
    | Authorized Redirect URIs | https://developers.google.com/oauthplayground |

4. After filling in these details, click on **Create**.

5. Make sure to save the provided Client ID and Client secret.

### Step 5: Get the Access and Refresh token

**Note**: It is recommended to use the OAuth 2.0 playground to obtain the tokens.

1. Configure the OAuth playground with the OAuth client ID and client secret.

    ![OAuth Playground](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.gmail/master/docs/setup/resources/oauth-playground.png)

2. Authorize the Gmail APIs (Select all except the metadata scope).

    ![Authorize APIs](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.gmail/master/docs/setup/resources/authorize-apis.png)

3. Exchange the authorization code for tokens.

    ![Exchange Tokens](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-googleapis.gmail/master/docs/setup/resources/exchange-tokens.png)

## Quickstart

To use the `gmail` connector in your Ballerina application, modify the `.bal` file as follows:

### Step 1: Import the module

Import the `gmail` module.

```ballerina
import ballerinax/googleapis.gmail;
```

### Step 2: Instantiate a new connector

Create a `gmail:ConnectionConfig` with the obtained OAuth2.0 tokens and initialize the connector with it.

```ballerina
gmail:Client gmail = check new gmail:Client(
    config = {
        auth: {
            refreshToken,
            clientId,
            clientSecret
        }
    }
);
```

### Step 3: Invoke the connector operation

Now, utilize the available connector operations.

#### Get unread emails in INBOX

```ballerina
gmail:MessageListPage messageList = check gmail->/users/me/messages(q = "label:INBOX is:unread");
```

#### Send email

```ballerina
gmail:MessageRequest message = {
    to: ["<recipient>"],
    subject: "Scheduled Maintenance Break Notification",
    bodyInHtml: string `<html>
                            <head>
                                <title>Scheduled Maintenance</title>
                            </head>
                        </html>`;
};

gmail:Message sendResult = check gmail->/users/me/messages/send.post(message);
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The `gmail` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples), covering use cases like sending emails, retrieving messages, and managing labels.

1. [Process customer feedback emails](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/process-mails) - Manage customer feedback emails by processing unread emails in the inbox, extracting details, and marking them as read.

2. [Send maintenance break emails](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/send-mails) - Send emails for scheduled maintenance breaks

3. [Automated Email Responses](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/reply-mails) - Retrieve unread emails from the Inbox and subsequently send personalized responses.

4. [Email Thread Search](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/search-threads)
    Search for email threads based on a specified query.

## Report Issues

To report bugs, request new features, start new discussions, view project boards, etc., go to the [Ballerina library parent repository](https://github.com/ballerina-platform/ballerina-library).

## Useful Links

- Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
- Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
