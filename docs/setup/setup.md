# Configure Gmail API

_Owners_: @niveathika \
_Reviewers_: @daneshk \
_Created_: 2022/11/09 \
_Updated_: 2023/11/13 \

## Introduction

To utilize the Gmail connector, you must have access to the Gmail REST API through a [Google Cloud Platform (GCP)](https://console.cloud.google.com/) account and a project under it. If you do not have a GCP account, you can sign up for one [here](https://cloud.google.com/).

## Step 1: Create a Google Cloud Platform Project

1. Open the [GCP Console](https://console.cloud.google.com/).
2. Click on the project drop-down and either select an existing project or create a new one for which you want to add an API key.

    <div align="center">
        <img src="resources/gcp-console-project-view.png" width="500">
    </div>

3. Navigate to the **Library** and enable the Gmail API.

    <div align="center">
        <img src="resources/enable-gmail-api.png" width="500">
    </div>

## Step 2: Create OAuth Client ID

1. Navigate to the **Credentials** tab in your Google Cloud Platform console.

2. Click  **Create credentials** and from the dropdown menu, select **OAuth client ID**.

    <div align="center">
        <img src="resources/create-credentials.png" width="500">
    </div>

3. You will be directed to the **OAuth consent** screen, in which you need to fill in the necessary information below.

    | Field                     | Value |
    | ------------------------- | ----- |
    | Application type          | Web Application |
    | Name                      | GmailConnector  |
    | Authorized redirect URIs  | https://developers.google.com/oauthplayground |

    After filling in these details, click **Create**.

    **Note**: Save the provided Client ID and Client secret.

## Step 3: Get the access token and refresh token

**Note**: It is recommended to use the OAuth 2.0 playground to obtain the tokens.

1. Configure the OAuth playground with the OAuth client ID and client secret.

    <div align="center">
        <img src="resources/oauth-playground.png" width="500">
    </div>

2. Authorize the Gmail APIs.

    <div align="center">
        <img src="resources/authorize-apis.png" width="500">
    </div>

3. Exchange the authorization code for tokens.

    <div align="center">
        <img src="resources/exchange-tokens.png" width="500">
    </div>
