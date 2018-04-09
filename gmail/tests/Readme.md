## Compatibility

| Ballerina Version         | Connector Version         | API Version |
| ------------------------- | ------------------------- | ------------|
| ballerina-tools-0.970.0-alpha1-SNAPSHOT  | 0.8.0   |   v1     |

### Prerequisites
Get Access Token and Refresh Token for Gmail

* First, create an application to connect with Gmail API
* For that, visit Google APIs console (https://console.developers.google.com/) to create a project and create an app for the project
* After creating the project, configure the OAuth consent screen under Credentials and give a product name to shown to users.
* Then create OAuth client ID credentials. (Select webapplication -> create and give a name and a redirect URI(Get the code to request an accessToken call to Gmail API) -> create)

    (Give the redirect URI as (https://developers.google.com/oauthplayground), if you are using OAuth2 playground to obtain access token and refresh token )
* Visit OAuth 2.0 Playground (https://developers.google.com/oauthplayground/), select the needed api scopes and give the obtained client id and client secret and obtain the refresh token and access token 

* So to use gmail connector, you need to provide the following:
    * Base URl (https://www.googleapis.com/gmail)
    * Client Id
    * Client Secret
    * Access Token
    * Refresh Token
    * Refresh Token Endpoint (https://www.googleapis.com)
    * Refresh Token Path (/oauth2/v3/token)
    
### Working with Gmail REST connector.

In order to use the Gmail connector, first you need to create a Gmail endpoint by passing above mentioned parameters.

Visit `test.bal` file to find the way of creating Gmail endpoint.

#### Running gmail tests
In order to run the tests, the user will need to have a Gmail account and configure the `ballerina.conf` configuration
file with the obtained tokens.

###### ballerina.conf
```ballerina.conf
ENDPOINT="enter your endpoint here"
ACCESS_TOKEN="enter your access token here"
CLIENT_ID="enter your client id here"
CLIENT_SECRET="enter your client secret here"
REFRESH_TOKEN="enter your refresh token here"
REFRESH_TOKEN_ENDPOINT="enter your refresh token endpoint here"
REFRESH_TOKEN_PATH="enter your refresh token path here"
```

Assign the values for the accessToken, clientId, clientSecret and refreshToken inside constructed endpoint in test.bal in either way following,
```ballerina
endpoint Client gMailEP {
    oAuth2ClientConfig:{
        accessToken:accessToken,
        baseUrl:url,
        clientConfig:{}
    }
};
```

```ballerina
endpoint Client gMailEP {
    oAuth2ClientConfig:{
        baseUrl:url,
        clientId:clientId,
        clientSecret:clientSecret,
        refreshToken:refreshToken,
        refreshTokenEP:refreshTokenEndpoint,
        refreshTokenPath:refreshTokenPath,
        clientConfig:{}
    }
};
```

Assign values for the following variables defined at the top in test.bal file.
* recipient (Example: "recipient@gmail.com")
* sender (Example: "sender@gmail.com")
* cc (Example: "cc@gmail.com")
* attachmentPath (Example: "/home/user/hello.txt")
* attachmentContentType (Example: "text/plain")
* inlineImagePath (Example: "/home/user/Picture2.jpg")
* inlineImageName (Example: "Picture2.jpg")
* imageContentType (Example: "image/jpeg")

Run tests :

```
ballerina init
ballerina test gmail
```
 