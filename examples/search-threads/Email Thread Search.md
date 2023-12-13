# Email thread search

This example showcases an efficient method to search for email threads based on a specified query. The code extracts and displays the subject and snippet of the first message in each relevant thread for streamlined information retrieval.

## Prerequisites

### 1. Set up Gmail API

Refer to the [Set up Guide](https://central.ballerina.io/ballerinax/googleapis.gmail/latest#set-up-guide) for necessary credentials (client ID, secret, tokens).

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
