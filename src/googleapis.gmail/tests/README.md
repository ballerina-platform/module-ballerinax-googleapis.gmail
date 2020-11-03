## Compatibility

| Ballerina Language Version | Gmail API Version |  
|:--------------------------:|:-----------------:|
| Swan Lake Preview5         |        v1         |

### Prerequisites

* To use Gmail endpoint, you need to provide the following:
    * Client Id
    * Client Secret
    * Access Token
    * Refresh Token
    
    *Please note that, providing Client Id, Client Secret, Refresh Token are optional if you are only providing a
valid Access Token vise versa.*

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
In order to run the tests, the user will need to have a Gmail account and create a configuration file named `ballerina.conf` in the project's root directory with the obtained tokens and other parameters.

#### ballerina.conf
```ballerina.conf
//Give the credentials and tokens for the authorized user
ACCESS_TOKEN="enter your access token here"
CLIENT_ID="enter your client id here"
CLIENT_SECRET="enter your client secret here"
REFRESH_TOKEN="enter your refresh token here"
TRUST_STORE_PATH = "enter a truststore path if required"
TRUST_STORE_PASSWORD = "enter a truststore password if required"

//Give values for the following to run the tests
RECIPIENT="recipient@gmail.com"
SENDER="sender@gmail.com"
CC="cc@gmail.com"
ATTACHMENT_PATH="src/gmail/tests/resources/hello.txt"
ATTACHMENT_CONTENT_TYPE="text/plain"
INLINE_IMAGE_PATH="src/gmail/tests/resources/workplace.jpg"
INLINE_IMAGE_NAME="workplace.jpg"
IMAGE_CONTENT_TYPE="image/jpeg"
```

Assign the values for the accessToken, clientId, clientSecret and refreshToken inside constructed endpoint in 
main_test.bal
in either way following,

```ballerina
GmailConfiguration gmailConfig = {
    oauthClientConfig: {
        accessToken: config:getAsString("ACCESS_TOKEN"),
        refreshConfig: {
            refreshUrl: REFRESH_URL,
            refreshToken: config:getAsString("REFRESH_TOKEN"),
            clientId: config:getAsString("CLIENT_ID"),
            clientSecret: config:getAsString("CLIENT_SECRET")
        }
    }
};

Client gmailClient = new(gmailConfig);
```

Assign values for other necessary parameters to perform api operations in test.bal as follows.
```ballerina
string recipient = config:getAsString("RECIPIENT"); 
string sender = config:getAsString("SENDER"); 
string cc = config:getAsString("CC"); 
string attachmentPath = config:getAsString("ATTACHMENT_PATH"); 
string attachmentContentType = config:getAsString("ATTACHMENT_CONTENT_TYPE"); 
string inlineImagePath = config:getAsString("INLINE_IMAGE_PATH"); 
string inlineImageName = config:getAsString("INLINE_IMAGE_NAME"); 
string imageContentType = config:getAsString("IMAGE_CONTENT_TYPE"); 
```
Run tests :

```
ballerina test gmail
```
