## Compatibility

| Ballerina Version         | Connector Version         | API Version |
| ------------------------- | ------------------------- | ------------|
|  0.970.0-alpha1-SNAPSHOT  | 0.970.0-alpha1-SNAPSHOT   |   v1     |

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
    
Please note that gmail connector has already defined base url, refresh token endpoint and refresh token path as constant strings for you to use   

IMPORTANT: This access token and refresh token can be used to make API requests on your own account's behalf. Do not share your access token, client secret with anyone.


### Working with Gmail REST connector.

In order to use the Gmail connector, first you need to create a Gmail endpoint by passing above mentioned parameters.

Visit `test.bal` file to find the way of creating Gmail endpoint.
#### Gmail struct
```ballerina
public struct GmailConnector {
    oauth2:OAuth2Endpoint oauthEndpoint;
}
```
#### Gmail Endpoint
```ballerina
public struct GmailEndpoint {
    oauth2:OAuth2Endpoint oauthEP;
    GmailConfiguration gmailConfig;
    GmailConnector gmailConnector;
}
```
#### init() function
```ballerina
public function <GmailEndpoint ep> init (GmailConfiguration gmailConfig) {
    ep.oauthEP.init(gmailConfig.oauthClientConfig);
    ep.gmailConnector.oauthEndpoint = ep.oauthEP;
}
```
#### Running gmail tests
Assign the values for the accessToken, clientId, clientSecret and refreshToken inside constructed endpoint in test.bal
```ballerina
endpoint GmailEndpoint gmailEP {
    oauthClientConfig:{
        accessToken:"",
        clientId:"",
        clientSecret:"",
        refreshToken:"",
        refreshTokenEP: REFRESH_TOKEN_EP,
        refreshTokenPath: REFRESH_TOKEN_PATH,
        baseUrl: BASE_URL,
        clientConfig:{},
        useUriParams:true
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

Go inside `package-gmail` using terminal and run test.bal file using following command `ballerina test gmail1`.

 