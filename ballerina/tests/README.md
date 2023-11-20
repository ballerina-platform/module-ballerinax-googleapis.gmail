# Prerequisites for Running Tests

Before running the tests, ensure you have the following prerequisites in place, including a Gmail account and the necessary authentication credentials. You can set up these credentials either in a `Config.toml` file within the tests directory or as environment variables.

## Using a Config.toml File

Create a `Config.toml` file in the tests directory and include your authentication credentials and tokens for the authorized user:

```toml
refreshToken = "<your-refresh-token>"
clientId = "<your-client-id>"
clientSecret = "<your-client-secret>"
recipient = "<recipient-email-address>"
```

## Using Environment Variables

Alternatively, you can set your authentication credentials as environment variables:

```bash
export REFRESH_TOKEN="<your-refresh-token>"
export CLIENT_ID="<your-client-id>"
export CLIENT_SECRET="<your-client-secret>"
export RECIPIENT="<recipient-email-address>"
```
