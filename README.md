# Ballerina Gmail Connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/actions/workflows/ci.yml)
[![Trivy](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/actions/workflows/trivy-scan.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/actions/workflows/trivy-scan.yml)
[![codecov](https://codecov.io/gh/ballerina-platform/module-ballerinax-googleapis.gmail/branch/master/graph/badge.svg)](https://codecov.io/gh/ballerina-platform/module-ballerinax-googleapis.gmail)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/actions/workflows/build-with-bal-test-graalvm.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/actions/workflows/build-with-bal-test-graalvm.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-googleapis.gmail.svg)](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/commits/master)
[![GitHub Issues](https://img.shields.io/github/issues/ballerina-platform/ballerina-library/module/googleapis.gmail.svg?label=Open%20Issues)](https://github.com/ballerina-platform/ballerina-library/labels/module%2Fgoogleapis.gmail)

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
