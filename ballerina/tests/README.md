### Prerequisites for running tests
In order to run the tests, the user will need to have a Gmail account and get authentication credentials. These credentials can be set with either a `Config.toml` file in tests directory or as environment variables.

#### Config.toml
```ballerina
//Give the credentials and tokens for the authorized user
refreshToken = "enter your refresh token here"
clientId = "enter your client id here"
clientSecret = "enter your client secret here"
```

#### Environment variables
```bash
export REFRESH_TOKEN="enter your refresh token here"
export CLIENT_ID="enter your client id here"
export CLIENT_SECRET="enter your client secret here"
```