## Compatibility

| Ballerina Language Version | Gmail API Version |  
|:--------------------------:|:-----------------:|
| Swan Lake Alpha 4          |   v1              |

### Prerequisites

* To use Gmail endpoint, you need to provide the following:
    * Client Id
    * Client Secret
    * Refresh Token

* Go through the following steps to obtain client id, client secret, refresh token and access token for Gmail API.
    *   Go to [Google API Console](https://console.developers.google.com) to create a project and an app for the project to connect with Gmail API.
    
    *   Configure the OAuth consent screen under **Credentials** and give a product name to shown to users.
    
    *   Create OAuth Client ID credentials by selecting an application type and giving a name and a redirect URI.

    *Give the redirect URI as (https://developers.google.com/oauthplayground), if you are using [OAuth 2.0 Playground](https://developers.google.com/oauthplayground) to
    receive the authorization code and obtain access token and refresh token.*

    *   Visit [OAuth 2.0 Playground](https://developers.google.com/oauthplayground) and select the required Gmail API scopes.

    *   Give previously obtained client id and client secret and obtain the refresh token and access token.

    
### Working with Gmail Connector.

In order to use the Gmail connector, first you need to create a Gmail endpoint by passing above mentioned parameters.

Visit `main_test.bal` file to find the way of creating Gmail endpoint.

### Running Gmail tests
In order to run the tests, the user will need to have a Gmail account and create a configuration file named `Config.toml` in the project's root directory with the obtained tokens and other parameters.

#### Config.toml
```ballerina

[ballerinax.googleapis_gmail]
//Give the credentials and tokens for the authorized user
refreshToken = "enter your refresh token here"
clientId = "enter your client id here"
clientSecret = "enter your client secret here"
trustStorePath = "enter a truststore path if required"
trustStorePassword = "enter a truststore password if required"

//Give values for the following to run the tests
testRecipient = "name@gmail.com"
testSender = "recipient@gmail.com"
testCc = "anothername@gmail.com"
testAttachmentPath = "tests/resources/test.txt"
attachmentContentType = "text/plain"
inlineImagePath = "tests/resources/Test_image.jpg"
inlineImageName = "Test_image.jpg"
imageContentType = "image/jpeg"
```

Assign the values for the clientId, clientSecret and refreshToken inside constructed endpoint in 
main_test.bal

```ballerina

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;

gmail:GmailConfiguration gmailConfig = {
    oauthClientConfig: {
        refreshUrl: REFRESH_URL,
        refreshToken: refreshToken,
        clientId: clientId,
        clientSecret: clientSecret
    }
};

Client gmailClient = new(gmailConfig);
```

Assign values for other necessary parameters to perform api operations in test.bal as follows.
```ballerina
configurable string testRecipient = ?; //Example: "recipient@gmail.com"
configurable string testSender = ?; //Example: "sender@gmail.com"
configurable string testCc = ?; //Example: "cc@gmail.com"
configurable string testAttachmentPath = ?; //Example: "/home/user/hello.txt"
configurable string attachmentContentType = ?; //Example: "text/plain"
configurable string inlineImagePath = ?; //Example: "/home/user/Picture2.jpg"
configurable string inlineImageName = ?; //Example: "Picture2.jpg"
configurable string imageContentType = ?; //Example: "image/jpeg"
```
Run tests :

```
bal test
```
