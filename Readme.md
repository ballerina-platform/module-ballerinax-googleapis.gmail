# Ballerina GMail Connector

[Gmail](https://www.google.com/gmail/) is a free, Web-based e-mail service provided by Google.
### Why would you use a Ballerina connector for Gmail

Ballerina GMail connector allows you to access the [Gmail REST API](https://developers.google.com/gmail/api/v1/reference/) and perfom actions like creating and sending a simple text mail, mail
with html content and inline images, mail with attachments, search and get mail etc.

Following are the gmail api methods supported by the current version

* Send Message
* Get Message
* Delete Message
* Trash Message
* Untrash Message
* List Messages
* Get Message Attachment
* List Threads
* Get Thread
* Delete Thread
* Trash Thread
* Untrash Thread
* Get User Profile

## Compatibility
| Language Version        | Connector Version          |
| ------------- |:-------------:|
| ballerina-tools-0.970.0-alpha1-SNAPSHOT     | 0.8.0 | 


### Getting started

* Clone the repository by running the following command
```
git clone https://github.com/wso2-ballerina/package-gmail
```
* Import the package to your ballerina project.

##### Prerequisites
1. Download the ballerina [distribution](https://ballerinalang.org/downloads/).

2. Create a project in Google APIs console (https://console.developers.google.com/) and obtain the client credentials and obtain access tokens and refresh tokens from OAuth 2.0 Playground (https://developers.google.com/oauthplayground/).

IMPORTANT: This access token and refresh token can be used to make API requests on your own account's behalf. Do not share these credentials.