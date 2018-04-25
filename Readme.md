# Gmail Connector

Connects to Gmail from Ballerina. 

The Gmail connector provides an optimized way to use the Gmail REST API from your Ballerina programs. 
It handles OAuth 2.0 and provides auto completion and type conversions.

## Compatibility

| Ballerina Language Version                   | Gmail API Version |  
| :-------------------------------------------:|:-----------------:| 
| 0.970.0-beta15                               | v1                | 

## Getting started

1.  To download and install Ballerina, see the [Getting Started](https://ballerina.io/learn/getting-started/) guide.

2.  Obtain your OAuth 2.0 credentials. To access a Gmail endpoint, you will need to provide the Client ID, 
    Client Secret, and Refresh Token, or just the Access Token. For more information, see the [Gmail OAuth 2.0 
    documentation](https://developers.google.com/identity/protocols/OAuth2).

3. Create a new Ballerina project by executing the following command.

    ```shell
    $ ballerina init
    ```     

4. Import the Gmail package to your Ballerina program as follows.

    ```ballerina
    import ballerina/io;
    import wso2/gmail;

    //User credentials to access Gmail API
    string accessToken = "<access_token>";
    string clientId = "<client_id>";
    string clientSecret = "<client_secret>";
    string refreshToken = "<refresh_token>";
    //The user's email address. The special value "me" can be used to indicate the authenticated user.
    string userId = "me";

    function main(string... args) {

       endpoint gmail:Client gmailEP {
           clientConfig:{
               auth:{
                   accessToken:accessToken,
                   clientId:clientId,
                   clientSecret:clientSecret,
                   refreshToken:refreshToken
               }
           }
       };

       //Set headers, message body and etc to MessageRequest.
       gmail:MessageRequest messageRequest;
       messageRequest.recipient = "recipient@mail.com";
       messageRequest.sender = "sender@mail.com";
       messageRequest.cc = "cc@mail.com";
       messageRequest.subject = "Email-Subject";
       messageRequest.messageBody = "Email Message Body Text";
       //Set the content type of the mail as TEXT_PLAIN or TEXT_HTML.
       messageRequest.contentType = gmail:TEXT_PLAIN;

       //Call the Gmail endpoint function sendMessage().
       var sendMessageResponse = gmailEP -> sendMessage(userId, messageRequest);
       match sendMessageResponse {
           (string, string) sendStatus => {
               //For a successful message request, returns message and thread id.
               string messageId;
               string threadId;
               (messageId, threadId) = sendStatus;
               io:println("Sent Message Id : " + messageId);
               io:println("Sent Thread Id : " + threadId);
           }
           gmail:GmailError e => io:println(e); //For unsuccessful attempts, returns Gmail Error.
       }
    }
    ```
