# Examples

The `gmail` connector provides several practical examples that illustrate its use in various scenarios. These examples, located in this directory, cover a variety of use cases, including sending emails, retrieving messages, and managing labels.

1. [Process Customer Feedback Emails](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/process-mails)
    This example shows how to manage customer feedback emails. It checks for unread emails in the INBOX, processes these emails, and adds details such as the subject and sender to a CSV file. After processing, all emails are marked as read.

2. [Send Maintenance Break Notification](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/send-mails)
    This example demonstrates how to automatically send emails to users or administrators when a scheduled maintenance break is imminent or has begun. It includes code to embed inline images in the email.

3. [Search for Relevant Email Threads](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail/tree/master/examples/search-threads)
    This example shows how to use the Gmail API to search for email threads based on a specific query.

## Prerequisites

1. Follow the [instructions](https://github.com/ballerina-platform/module-ballerinax-googleapis.gmail#setting-up-gmail-api) to set up the Gmail API.

2. For each example, create a `config.toml` file with your OAuth2 tokens, client ID, and client secret. Here's an example of how your `config.toml` file should look:
  ```toml
  refreshToken="<Refresh Token>"
  clientId="<Client Id>"
  clientSecret="<Client Secret>" 
  # The sender detail is only needed for the send-mails example
  sender="<Recipient Email Address>"
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