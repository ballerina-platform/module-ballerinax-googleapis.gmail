// Copyright (c) 2022 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

# Client configuration details.
@display {label: "Connection Config"}
public type ConnectionConfig record {|
    # Configurations related to client authentication
    BearerTokenConfig|OAuth2RefreshTokenGrantConfig auth;
    # The HTTP version understood by the client
    HttpVersion httpVersion = HTTP_V1_1;
    # Configurations related to HTTP/1.x protocol
    ClientHttp1Settings http1Settings = {};
    # Configurations related to HTTP/2 protocol
    ClientHttp2Settings http2Settings = {};
    # The maximum time to wait (in seconds) for a response before closing the connection
    decimal timeout = 60;
    # The choice of setting `forwarded`/`x-forwarded` header
    string forwarded = "disable";
    # Configurations associated with Redirection
    PoolConfiguration poolConfig?;
    # HTTP caching related configurations
    CacheConfig cache = {};
    # Specifies the way of handling compression (`accept-encoding`) header
    Compression compression = COMPRESSION_AUTO;
    # Configurations associated with the behaviour of the Circuit Breaker
    CircuitBreakerConfig circuitBreaker?;
    # Configurations associated with retrying
    RetryConfig retryConfig?;
    # Configurations associated with inbound response size limits
    ResponseLimitConfigs responseLimits = {};
    #SSL/TLS-related options
    ClientSecureSocket secureSocket?;
    # Proxy server related options
    ProxyConfig proxy?;
    # Enables the inbound payload validation functionalty which provided by the constraint package. Enabled by default
    boolean validation = true;
|};

# Represents token for Bearer token authentication.
#
# + token - Bearer token for authentication
public type BearerTokenConfig record {|
    string token;
|};

# Represents OAuth2 refresh token grant configurations for OAuth2 authentication.
#
# + refreshUrl - Refresh token URL of the token endpoint
# + refreshToken - Refresh token for the token endpoint
# + clientId - Client ID of the client authentication
# + clientSecret - Client secret of the client authentication
# + scopes - Scope(s) of the access request
# + defaultTokenExpTime - Expiration time (in seconds) of the tokens if the token endpoint response does not contain an `expires_in` field
# + clockSkew - Clock skew (in seconds) that can be used to avoid token validation failures due to clock synchronization problems
# + optionalParams - Map of the optional parameters used for the token endpoint
# + credentialBearer - Bearer of the authentication credentials, which is sent to the token endpoint
# + clientConfig - HTTP client configurations, which are used to call the token endpoint
public type OAuth2RefreshTokenGrantConfig record {|
    string refreshUrl;
    string refreshToken;
    string clientId;
    string clientSecret;
    string[] scopes?;
    decimal defaultTokenExpTime = 3600;
    decimal clockSkew = 0;
    map<string> optionalParams?;
    CredentialBearer credentialBearer = AUTH_HEADER_BEARER;
    ClientConfiguration clientConfig = {};
|};

# Represents the credential-bearing methods.
public enum CredentialBearer {
    AUTH_HEADER_BEARER,
    POST_BODY_BEARER
}

# Represents the configurations of the client used to call the introspection endpoint.
#
# + httpVersion - The HTTP version of the client
# + customHeaders - The list of custom HTTP headers
# + customPayload - The list of custom HTTP payload parameters
# + auth - The client auth configurations
# + secureSocket - SSL/TLS-related configurations
public type ClientConfiguration record {|
    Oauth2HttpVersion httpVersion = HTTP_1_1;
    map<string> customHeaders?;
    string customPayload?;
    ClientAuth auth?;
    SecureSocket secureSocket?;
|};

# Represents the HTTP versions.
public enum Oauth2HttpVersion {
    HTTP_1_1,
    HTTP_2
}

# Represents the the authentication configuration types for the HTTP client used for token introspection.
public type ClientAuth ClientCredentialsGrantConfig|PasswordGrantConfig|RefreshTokenGrantConfig;

# Represents the data structure, which is used to configure the OAuth2 client credentials grant type.
#
# + tokenUrl - Token URL of the token endpoint
# + clientId - Client ID of the client authentication
# + clientSecret - Client secret of the client authentication
# + scopes - Scope(s) of the access request
# + defaultTokenExpTime - Expiration time (in seconds) of the tokens if the token endpoint response does not contain an `expires_in` field
# + clockSkew - Clock skew (in seconds) that can be used to avoid token validation failures due to clock synchronization problems
# + optionalParams - Map of the optional parameters used for the token endpoint
# + credentialBearer - Bearer of the authentication credentials, which is sent to the token endpoint
# + clientConfig - HTTP client configurations, which are used to call the token endpoint
public type ClientCredentialsGrantConfig record {|
    string tokenUrl;
    string clientId;
    string clientSecret;
    string[] scopes?;
    decimal defaultTokenExpTime = 3600;
    decimal clockSkew = 0;
    map<string> optionalParams?;
    CredentialBearer credentialBearer = AUTH_HEADER_BEARER;
    ClientConfiguration clientConfig = {};
|};

# Represents the data structure, which is used to configure the OAuth2 password grant type.
#
# + tokenUrl - Token URL of the token endpoint
# + username - Username for the password grant type
# + password - Password for the password grant type
# + clientId - Client ID of the client authentication
# + clientSecret - Client secret of the client authentication
# + scopes - Scope(s) of the access request
# + refreshConfig - Configurations for refreshing the access token
# + defaultTokenExpTime - Expiration time (in seconds) of the tokens if the token endpoint response does not contain an `expires_in` field
# + clockSkew - Clock skew (in seconds) that can be used to avoid token validation failures due to clock synchronization problems
# + optionalParams - Map of the optional parameters used for the token endpoint
# + credentialBearer - Bearer of the authentication credentials, which is sent to the token endpoint
# + clientConfig - HTTP client configurations, which are used to call the token endpoint
public type PasswordGrantConfig record {|
    string tokenUrl;
    string username;
    string password;
    string clientId?;
    string clientSecret?;
    string[] scopes?;
    record {|
        string refreshUrl;
        string[] scopes?;
        map<string> optionalParams?;
        CredentialBearer credentialBearer = AUTH_HEADER_BEARER;
        ClientConfiguration clientConfig = {};
    |} refreshConfig?;
    decimal defaultTokenExpTime = 3600;
    decimal clockSkew = 0;
    map<string> optionalParams?;
    CredentialBearer credentialBearer = AUTH_HEADER_BEARER;
    ClientConfiguration clientConfig = {};
|};

# Represents the data structure, which is used to configure the OAuth2 refresh token grant type.
#
# + refreshUrl - Refresh token URL of the token endpoint
# + refreshToken - Refresh token for the token endpoint
# + clientId - Client ID of the client authentication
# + clientSecret - Client secret of the client authentication
# + scopes - Scope(s) of the access request
# + defaultTokenExpTime - Expiration time (in seconds) of the tokens if the token endpoint response does not contain an `expires_in` field
# + clockSkew - Clock skew (in seconds) that can be used to avoid token validation failures due to clock synchronization problems
# + optionalParams - Map of the optional parameters used for the token endpoint
# + credentialBearer - Bearer of the authentication credentials, which is sent to the token endpoint
# + clientConfig - HTTP client configurations, which are used to call the token endpoint
public type RefreshTokenGrantConfig record {|
    string refreshUrl;
    string refreshToken;
    string clientId;
    string clientSecret;
    string[] scopes?;
    decimal defaultTokenExpTime = 3600;
    decimal clockSkew = 0;
    map<string> optionalParams?;
    CredentialBearer credentialBearer = AUTH_HEADER_BEARER;
    ClientConfiguration clientConfig = {};
|};

# Represents the SSL/TLS configurations.
#
# + disable - Disable SSL validation
# + cert - Configurations associated with the `crypto:TrustStore` or single certificate file that the client trusts
# + key - Configurations associated with the `crypto:KeyStore` or combination of certificate and private key of the client
public type SecureSocket record {|
    boolean disable = false;
    TrustStore|string cert?;
    KeyStore|CertKey key?;
|};

# Represents the truststore-related configurations.
#
# + path - Path to the TrustStore file
# + password - TrustStore password
public type TrustStore record {|
    string path;
    string password;
|};

# Represents the KeyStore-related configurations.
#
# + path - Path to the KeyStore file
# + password - KeyStore password
public type KeyStore record {|
    string path;
    string password;
|};

# Represents the combination of the certificate file path, private key file path, and private key password if encrypted.
#
# + certFile - A file containing the certificate
# + keyFile - A file containing the private key
# + keyPassword - Password of the private key (if encrypted)
public type CertKey record {|
   string certFile;
   string keyFile;
   string keyPassword?;
|};

# Provides settings related to HTTP/1.x protocol.
#
# + keepAlive - Specifies whether to reuse a connection for multiple requests
# + chunking - The chunking behaviour of the request
# + proxy - Proxy server related options
public type ClientHttp1Settings record {|
    KeepAlive keepAlive = KEEPALIVE_AUTO;
    Chunking chunking = CHUNKING_AUTO;
    ProxyConfig proxy?;
|};

# Defines the possible values for the keep-alive configuration in service and client endpoints.
public type KeepAlive KEEPALIVE_AUTO|KEEPALIVE_ALWAYS|KEEPALIVE_NEVER;

# Defines the possible values for the chunking configuration in HTTP services and clients.
#
# `AUTO`: If the payload is less than 8KB, content-length header is set in the outbound request/response,
#         otherwise chunking header is set in the outbound request/response
# `ALWAYS`: Always set chunking header in the response
# `NEVER`: Never set the chunking header even if the payload is larger than 8KB in the outbound request/response
public type Chunking CHUNKING_AUTO|CHUNKING_ALWAYS|CHUNKING_NEVER;

# Proxy server configurations to be used with the HTTP client endpoint.
#
# + host - Host name of the proxy server
# + port - Proxy server port
# + userName - Proxy server username
# + password - proxy server password
public type ProxyConfig record {|
    string host = "";
    int port = 0;
    string userName = "";
    string password = "";
|};

# Decides to keep the connection alive or not based on the `connection` header of the client request }
public const KEEPALIVE_AUTO = "AUTO";
# Keeps the connection alive irrespective of the `connection` header value }
public const KEEPALIVE_ALWAYS = "ALWAYS";
# Closes the connection irrespective of the `connection` header value }
public const KEEPALIVE_NEVER = "NEVER";

# If the payload is less than 8KB, content-length header is set in the outbound request/response,
# otherwise chunking header is set in the outbound request/response.}
public const CHUNKING_AUTO = "AUTO";

# Always set chunking header in the response.
public const CHUNKING_ALWAYS = "ALWAYS";

# Never set the chunking header even if the payload is larger than 8KB in the outbound request/response.
public const CHUNKING_NEVER = "NEVER";

# Provides settings related to HTTP/2 protocol.
#
# + http2PriorKnowledge - Configuration to enable HTTP/2 prior knowledge
public type ClientHttp2Settings record {|
    boolean http2PriorKnowledge = false;
|};

# Provides a set of configurations for controlling the caching behaviour of the endpoint.
#
# + enabled - Specifies whether HTTP caching is enabled. Caching is enabled by default.
# + isShared - Specifies whether the HTTP caching layer should behave as a public cache or a private cache
# + capacity - The capacity of the cache
# + evictionFactor - The fraction of entries to be removed when the cache is full. The value should be
#                    between 0 (exclusive) and 1 (inclusive).
# + policy - Gives the user some control over the caching behaviour. By default, this is set to
#            `CACHE_CONTROL_AND_VALIDATORS`. The default behaviour is to allow caching only when the `cache-control`
#            header and either the `etag` or `last-modified` header are present.
public type CacheConfig record {|
    boolean enabled = true;
    boolean isShared = false;
    int capacity = 16;
    float evictionFactor = 0.2;
    CachingPolicy policy = CACHE_CONTROL_AND_VALIDATORS;
|};

# Used for configuring the caching behaviour. Setting the `policy` field in the `CacheConfig` record allows
# the user to control the caching behaviour.
public type CachingPolicy CACHE_CONTROL_AND_VALIDATORS|RFC_7234;

# This is a more restricted mode of RFC 7234. Setting this as the caching policy restricts caching to instances
# where the `cache-control` header and either the `etag` or `last-modified` header are present.
public const CACHE_CONTROL_AND_VALIDATORS = "CACHE_CONTROL_AND_VALIDATORS";

# Caching behaviour is as specified by the RFC 7234 specification.
public const RFC_7234 = "RFC_7234";

# Options to compress using gzip or deflate.
#
# `AUTO`: When service behaves as a HTTP gateway inbound request/response accept-encoding option is set as the
#         outbound request/response accept-encoding/content-encoding option
# `ALWAYS`: Always set accept-encoding/content-encoding in outbound request/response
# `NEVER`: Never set accept-encoding/content-encoding header in outbound request/response
public type Compression COMPRESSION_AUTO|COMPRESSION_ALWAYS|COMPRESSION_NEVER;

# When service behaves as a HTTP gateway inbound request/response accept-encoding option is set as the
# outbound request/response accept-encoding/content-encoding option.
public const COMPRESSION_AUTO = "AUTO";

# Always set accept-encoding/content-encoding in outbound request/response.
public const COMPRESSION_ALWAYS = "ALWAYS";

# Never set accept-encoding/content-encoding header in outbound request/response.
public const COMPRESSION_NEVER = "NEVER";

# Provides a set of configurations for controlling the behaviour of the Circuit Breaker.
public type CircuitBreakerConfig record {|
    # The `http:RollingWindow` options of the `CircuitBreaker`
    RollingWindow rollingWindow = {};
    # The threshold for request failures. When this threshold exceeds, the circuit trips. The threshold should be a
    # value between 0 and 1
    float failureThreshold = 0.0;
    # The time period (in seconds) to wait before attempting to make another request to the upstream service
    decimal resetTime = 0;
    # Array of HTTP response status codes which are considered as failures
    int[] statusCodes = [];
|};

# Represents a rolling window in the Circuit Breaker.
#
public type RollingWindow record {|
    # Minimum number of requests in a `RollingWindow` that will trip the circuit.
    int requestVolumeThreshold = 10;
    # Time period in seconds for which the failure threshold is calculated
    decimal timeWindow = 60;
    # The granularity at which the time window slides. This is measured in seconds.
    decimal bucketSize = 10;
|};

# Provides configurations for controlling the retrying behavior in failure scenarios.
#
# + count - Number of retry attempts before giving up
# + interval - Retry interval in seconds
# + backOffFactor - Multiplier, which increases the retry interval exponentially.
# + maxWaitInterval - Maximum time of the retry interval in seconds
# + statusCodes - HTTP response status codes which are considered as failures
public type RetryConfig record {|
    int count = 0;
    decimal interval = 0;
    float backOffFactor = 0.0;
    decimal maxWaitInterval = 0;
    int[] statusCodes = [];
|};

# Provides inbound response status line, total header and entity body size threshold configurations.
#
# + maxStatusLineLength - Maximum allowed length for response status line(`HTTP/1.1 200 OK`). Exceeding this limit will
#                         result in a `ClientError`
# + maxHeaderSize - Maximum allowed size for headers. Exceeding this limit will result in a `ClientError`
# + maxEntityBodySize - Maximum allowed size for the entity body. By default it is set to -1 which means there is no
#                       restriction `maxEntityBodySize`, On the Exceeding this limit will result in a `ClientError`
public type ResponseLimitConfigs record {|
    int maxStatusLineLength = 4096;
    int maxHeaderSize = 8192;
    int maxEntityBodySize = -1;
|};

# Provides configurations for facilitating secure communication with a remote HTTP endpoint.
#
# + enable - Enable SSL validation
# + cert - Configurations associated with `crypto:TrustStore` or single certificate file that the client trusts
# + key - Configurations associated with `crypto:KeyStore` or combination of certificate and private key of the client
# + protocol - SSL/TLS protocol related options
# + certValidation - Certificate validation against OCSP_CRL, OCSP_STAPLING related options
# + ciphers - List of ciphers to be used
#             eg: TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA
# + verifyHostName - Enable/disable host name verification
# + shareSession - Enable/disable new SSL session creation
# + handshakeTimeout - SSL handshake time out
# + sessionTimeout - SSL session time out
public type ClientSecureSocket record {|
    boolean enable = true;
    TrustStore|string cert?;
    KeyStore|CertKey key?;
    record {|
        Protocol name;
        string[] versions = [];
    |} protocol?;
    record {|
        CertValidationType 'type = OCSP_STAPLING;
        int cacheSize;
        int cacheValidityPeriod;
    |} certValidation?;
    string[] ciphers?;
    boolean verifyHostName = true;
    boolean shareSession = true;
    decimal handshakeTimeout?;
    decimal sessionTimeout?;
|};

# Represents certification validation type options.
public enum CertValidationType {
   OCSP_CRL,
   OCSP_STAPLING
}

# Represents protocol options.
public enum Protocol {
   SSL,
   TLS,
   DTLS
}

# Configurations for managing HTTP client connection pool.
#
# + maxActiveConnections - Max active connections per route(host:port). Default value is -1 which indicates unlimited.
# + maxIdleConnections - Maximum number of idle connections allowed per pool.
# + waitTime - Maximum amount of time (in seconds), the client should wait for an idle connection before it sends an error when the pool is exhausted
# + maxActiveStreamsPerConnection - Maximum active streams per connection. This only applies to HTTP/2.
public type PoolConfiguration record {|
    int maxActiveConnections = -1;
    int maxIdleConnections = 100;
    decimal waitTime = 30;
    int maxActiveStreamsPerConnection = 50;
|};

# Represents the HTTP versions.
public enum HttpVersion {
    # Represents HTTP/1.0 protocol
    HTTP_V1_0 = "1.0",
    # Represents HTTP/1.1 protocol
    HTTP_V1_1 = "1.1",
    # Represents HTTP/2.0 protocol
    HTTP_V2_0 = "2.0"
}
