# Send maintenance break emails

This example demonstrates the automated sending of emails for scheduled maintenance breaks.

## Prerequisites

### 1. Setup Gmail API

Refer to the [Setup Guide](https://central.ballerina.io/ballerinax/googleapis.gmail/latest#setup-guide) for necessary credentials (client ID, secret, tokens).

### 2. Configuration

Configure Gmail API credentials in `Config.toml` in the example directory:

```toml
refreshToken="<Refresh Token>"
clientId="<Client Id>"
clientSecret="<Client Secret>"
recipient="<Recipient Email Address>"
```

## Run the Example

Execute the following command to run the example:

```bash
bal run
```
