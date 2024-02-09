# Process customer feedback emails

This example demonstrates how to efficiently manage customer feedback emails. The Ballerina programme retrieves unread messages from the INBOX, extracts sender and subject information, and stores it in a CSV file for later access.

## Prerequisites

### 1. Setup Gmail API

Refer to the [Setup Guide](https://central.ballerina.io/ballerinax/googleapis.gmail/latest#setup-guide) for necessary credentials (client ID, secret, tokens).

### 2. Configuration

Configure Gmail API credentials in `Config.toml` in the example directory:

```toml
refreshToken="<Refresh Token>"
clientId="<Client Id>"
clientSecret="<Client Secret>"
```

## Run the Example

Execute the following command to run the example:

```bash
bal run
```

Check the results in the generated `feedback.csv` file.
