## Compatibility

| Ballerina Language Version | Gmail API Version |  
|:--------------------------:|:-----------------:|
| 0.983.0                    |        v1         |

### Prerequisites

* To use Gmail endpoint, you need to provide the following:
    * Client Id
    * Client Secret
    * Access Token
    * Refresh Token
    
    *Please note that, providing ClientId, Client Secret, Refresh Token are optional if you are only providing a 
valid Access Token vise versa.*

* Go through the following steps to obtain client id, client secret, refresh token and access token for Gmail API.
    *   Go to Google APIs console to create a project and create an app for the project to connect with Gmail API.
    
    *   Configure the OAuth consent screen under Credentials and give a product name to shown to users.
    
    *   Create OAuth client ID credentials by selecting an application type and giving a name and a redirect URI. 

        *Give the redirect URI as (https://developers.google.com/oauthplayground), if you are using OAuth2 playground to 
        receive the authorization code and obtain access token and refresh token.*

    *   Visit OAuth 2.0 Playground and select the required Gmail API scopes. 
    *   Give previously obtained client id and client secret and obtain the refresh token and access token.

    
### Working with Gmail Connector.

In order to use the Gmail connector, first you need to create a Gmail endpoint by passing above mentioned parameters.

Visit `test.bal` file to find the way of creating Gmail endpoint.

#### Running gmail tests
In order to run the tests, the user will need to have a Gmail account and configure the `ballerina.conf` configuration
file with the obtained tokens and other parameters.

###### ballerina.conf
```ballerina.conf
//Give the credentials and tokens for the authorized user
ACCESS_TOKEN="enter your access token here"
CLIENT_ID="enter your client id here"
CLIENT_SECRET="enter your client secret here"
REFRESH_TOKEN="enter your refresh token here"

//Give values for the following to run the tests
RECIPIENT="recipient@gmail.com"
SENDER="sender@gmail.com"
CC="cc@gmail.com"
ATTACHMENT_PATH="/home/dushaniw/hello.txt"
ATTACHMENT_CONTENT_TYPE="text/plain"
INLINE_IMAGE_PATH="/home/user/Picture2.jpg"
INLINE_IMAGE_NAME="Picture2.jpg"
IMAGE_CONTENT_TYPE="image/jpeg"
```

Assign the values for the accessToken, clientId, clientSecret and refreshToken inside constructed endpoint in test.bal 
in either way following,
```ballerina
endpoint Client gmailEP {
    clientConfig:{
        auth:{
            accessToken:config:getAsString("ACCESS_TOKEN")
        }
    }
};
```

```ballerina
endpoint Client gmailEP {
    clientConfig:{
        auth:{
            accessToken:config:getAsString("ACCESS_TOKEN"),
            clientId:config:getAsString("CLIENT_ID"),
            clientSecret:config:getAsString("CLIENT_SECRET"),
            refreshToken:config:getAsString("REFRESH_TOKEN")
        }
    }
};
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
ballerina init
ballerina test gmail --config ballerina.conf
```
