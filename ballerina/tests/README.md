## Prerequisites for Running Tests

To run the tests, you need a Gmail account and authentication credentials. You can set these credentials either in a `Config.toml` file in the tests directory or as environment variables.

#### Using a Config.toml File

Create a `Config.toml` file in the tests directory and add your authentication credentials and tokens for the authorized user:

```toml
refreshToken = "<your-refresh-token>"
clientId = "<your-client-id>"
clientSecret = "<your-client-secret>"
sender = "<recipient-email-address>"
```

#### Using Environment Variables

Alternatively, you can set your authentication credentials as environment variables:
```bash
export REFRESH_TOKEN="<your-refresh-token>"
export CLIENT_ID="<your-client-id>"
export CLIENT_SECRET="<your-client-secret>"
export SENDER="<recipient-email-address>"
```
