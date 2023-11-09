# Examples

This directory contains a collection of sample code examples for `ballerinax/googleapis.gmail` module. These examples demonstrate various
use cases of the module.

1. Process Customer Feedback Mails (process-mails)
   This example demonstrates how to keep track of customer feedback mails. This project checks for unread emails in the INBOX, processes the mails, and adds details such as subject and sender to a CSV file. Finally, all processed mails will be marked as read.

2. Send Maintenance Break Mail (send-mails)
   The example might be used to automatically send emails to users or administrators when a scheduled maintenance break is about to occur or has started. This includes code to embed inline images in the email. 

3. Get relevant threads for search query (search-threads)
   The example can be used to interact with the Gmail API to search for email threads based on a specific query.

## Prerequisite

1. If you don't already have one, create a [Google account](https://accounts.google.com/signup/v2/webcreateaccount?utm_source=ga-ob-search&utm_medium=google-account&flowName=GlifWebSignIn&flowEntry=SignUp).

2. Obtain OAuth2 tokens. For guidance, refer to [Using OAuth 2.0 to Access Google APIs](https://developers.google.com/identity/protocols/oauth2).

3. For each example, create a `config.toml` file and add your OAuth2 tokens, client ID, and client secret. Here's an example of what your `config.toml` file should look like:
  ```yaml
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