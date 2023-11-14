# Examples

The `gmail` connector provides several practical examples that illustrate its usage in various scenarios. These [examples](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples) cover a variety of use cases including sending emails, retrieving messages, and managing labels.

1. [Process customer feedback emails](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/process-mails/main.bal)
    This example shows how to manage customer feedback emails. It checks for unread emails in the inbox, processes these emails, and adds details such as the subject and sender to a CSV file. After processing, all emails will be marked as read.

2. [Send maintenance break notifications](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/send-mails/main.bal)
    This example demonstrates how to automatically send emails to users or administrators when a scheduled maintenance break is imminent or has begun. It includes code to embed inline images in the email.

3. [Search for relevant email threads](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/search-threads/main.bal)
    This example shows how to use the Gmail API to search for email threads based on a specific query.

For more detailed information about the connector's functionality including how to configure and use it in your Ballerina programs, go to the comprehensive reference guide for the `gmail` connector available in [Ballerina Central](https://central.ballerina.io/ballerinax/googleapis.gmail/latest).

## Prerequisites

1. Follow the [instructions](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail#set-up-gmail-api) to set up the Gmail API.

2. For each example, create a `config.toml` file with your OAuth2 tokens, client ID, and client secret. Here's an example of how your `config.toml` file should look:
  ```toml
  refreshToken="<Refresh Token>"
  clientId="<Client Id>"
  clientSecret="<Client Secret>" 
  # The recipient detail is only needed for the send-mails example
  recipient="<Recipient Email Address>"
  ```

## Running an Example

Execute the following commands to build an example from the source.

* To build an example

  `bal build`

* To run an example

  `bal run`

## Building the Examples with the Local Module

**Warning**: Because of the absence of support for reading local repositories for single Ballerina files, the bala of
the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your
local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally.

* To build all the examples

  `./build.sh build`


* To run all the examples

  `./build.sh run`