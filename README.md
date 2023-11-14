# Ballerina Gmail Connector

[![CI](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/ballerina-platform/module-ballerinax-googleapis.gmail/branch/master/graph/badge.svg)](https://codecov.io/gh/ballerina-platform/module-ballerinax-googleapis.gmail)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/actions/workflows/build-with-bal-test-graalvm.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/actions/workflows/build-with-bal-test-graalvm.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-googleapis.gmail.svg)](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/commits/master)
[![GitHub Issues](https://img.shields.io/github/issues/ballerina-platform/ballerina-library/module/googleapis.gmail.svg?label=Open%20Issues)](https://github.com/ballerina-platform/ballerina-library/labels/module%2Fgoogleapis.gmail)

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

1. [Process customer feedback emails](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/process-mails)
    This example shows how to manage customer feedback emails. It checks for unread emails in the inbox, processes these emails, and adds details such as the subject and sender to a CSV file. After processing, all emails will be marked as read.

2. [Send maintenance break notifications](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/send-mails)
    This example demonstrates how to automatically send emails to users or administrators when a scheduled maintenance break is imminent or has begun. It includes code to embed inline images in the email.

3. [Search for relevant email threads](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/search-threads)
    This example shows how to use the Gmail API to search for email threads based on a specific query.

For more detailed information about the connector's functionality including how to configure and use it in your Ballerina programs, go to the comprehensive reference guide for the `gmail` connector available in [Ballerina Central](https://central.ballerina.io/ballerinax/googleapis.gmail/latest).

## Set up Gmail API

In order to use the `gmail` connector, you need to first create the Gmail credentials for the connector to interact with Gmail.

1. **Create a Google Cloud Platform project**: You need to create a new project on the Google Cloud Platform (GCP). Once the project is created, you can enable the Gmail API for this project.

2. **Create OAuth client ID**: In the GCP console, you need to create credentials for the OAuth client ID. This process involves setting up the OAuth consent screen and creating the credentials for the OAuth client ID.

3. **Get the access token and refresh token**: You need to generate an access token and a refresh token. The Oauth playground can be used to easily exchange the authorization code for the tokens.

For detailed steps including the necessary links, go to the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/docs/setup/setup.md).

## Issues and projects 

The **Issues** and **Projects** tabs are disabled for this repository as this is part of the Ballerina library. To report bugs, request new features, start new discussions, view project boards, etc., visit the Ballerina library [parent repository](https://github.com/ballerina-platform/ballerina-library). 

This repository only contains the source code for the package.

## Build from the source

### Prerequisites

1. Download and install Java SE Development Kit (JDK) version 17. You can download it from either of the following sources:

   * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
   * [OpenJDK](https://adoptium.net/)

    > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

    > **Note**: Ensure that the Docker daemon is running before executing any tests.

### Build options

Execute the commands below to build from the source.

1. To build the package:
   ```
   ./gradlew clean build
   ```

2. To run the tests:
   ```
   ./gradlew clean test
   ```

3. To build the without the tests:
   ```
   ./gradlew clean build -x test
   ```

5. To debug package with a remote debugger:
   ```
   ./gradlew clean build -Pdebug=<port>
   ```

6. To debug with the Ballerina language:
   ```
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina Central repository:
    ```
    ./gradlew clean build -PpublishToLocalCentral=true
    ```

8. Publish the generated artifacts to the Ballerina Central repository:
   ```
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`googleapis.gmail` package](https://lib.ballerina.io/ballerinax/googleapis.gmail/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
