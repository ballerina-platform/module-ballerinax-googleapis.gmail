// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import ballerina/http;

# Provides a set of configurations for controlling the behaviours when communicating with a remote HTTP endpoint.
@display {label: "Connection Config"}
public type ConnectionConfig record {|
    # Configurations related to client authentication
    http:BearerTokenConfig|OAuth2RefreshTokenGrantConfig auth;
    # The HTTP version understood by the client
    http:HttpVersion httpVersion = http:HTTP_2_0;
    # Configurations related to HTTP/1.x protocol
    ClientHttp1Settings http1Settings?;
    # Configurations related to HTTP/2 protocol
    http:ClientHttp2Settings http2Settings?;
    # The maximum time to wait (in seconds) for a response before closing the connection
    decimal timeout = 60;
    # The choice of setting `forwarded`/`x-forwarded` header
    string forwarded = "disable";
    # Configurations associated with request pooling
    http:PoolConfiguration poolConfig?;
    # HTTP caching related configurations
    http:CacheConfig cache?;
    # Specifies the way of handling compression (`accept-encoding`) header
    http:Compression compression = http:COMPRESSION_AUTO;
    # Configurations associated with the behaviour of the Circuit Breaker
    http:CircuitBreakerConfig circuitBreaker?;
    # Configurations associated with retrying
    http:RetryConfig retryConfig?;
    # Configurations associated with inbound response size limits
    http:ResponseLimitConfigs responseLimits?;
    # SSL/TLS-related options
    http:ClientSecureSocket secureSocket?;
    # Proxy server related options
    http:ProxyConfig proxy?;
    # Enables the inbound payload validation functionality which provided by the constraint package. Enabled by default
    boolean validation = true;
|};

# Provides settings related to HTTP/1.x protocol.
public type ClientHttp1Settings record {|
    # Specifies whether to reuse a connection for multiple requests
    http:KeepAlive keepAlive = http:KEEPALIVE_AUTO;
    # The chunking behaviour of the request
    http:Chunking chunking = http:CHUNKING_AUTO;
    # Proxy server related options
    ProxyConfig proxy?;
|};

# Proxy server configurations to be used with the HTTP client endpoint.
public type ProxyConfig record {|
    # Host name of the proxy server
    string host = "";
    # Proxy server port
    int port = 0;
    # Proxy server username
    string userName = "";
    # Proxy server password
    @display {label: "", kind: "password"}
    string password = "";
|};

# OAuth2 Refresh Token Grant Configs
public type OAuth2RefreshTokenGrantConfig record {|
    *http:OAuth2RefreshTokenGrantConfig;
    # Refresh URL
    string refreshUrl = "https://accounts.google.com/o/oauth2/token";
|};

# Data format for response.
public type Alt "json"|"media"|"proto";

# V1 error format.
public type Xgafv "1"|"2";

# Profile for a Gmail user.
public type Profile record {
    # The user's email address.
    string emailAddress?;
    # The ID of the mailbox's current history record.
    string historyId?;
    # The total number of messages in the mailbox.
    int:Signed32 messagesTotal?;
    # The total number of threads in the mailbox.
    int:Signed32 threadsTotal?;
};

# An email message.
public type Message record {
    # The ID of the thread the message belongs to. 
    string threadId;
    # The immutable ID of the message.
    string id;
    # List of IDs of labels applied to this message.
    string[] labelIds?;
    # The entire email message in an RFC 2822 formatted. Returned in `messages.get` and `drafts.get` responses when the `format=RAW` parameter is supplied.
    string raw?;
    # A short part of the message text.
    string snippet?;
    # The ID of the last history record that modified this message.
    string historyId?;
    # The internal message creation timestamp (epoch ms), which determines ordering in the inbox. For normal SMTP-received email, this represents the time the message was originally accepted by Google, which is more reliable than the `Date` header. However, for API-migrated mail, it can be configured by client to be based on the `Date` header.
    string internalDate?;
    # Estimated size in bytes of the message.
    int:Signed32 sizeEstimate?;
    # Email header **To**
    string[] to?;
    # Email header **From**
    string 'from?;
    # Email header **Bcc**
    string[] bcc?;
    # Email header **Cc**
    string[] cc?;
    # Email header **Subject**
    string subject?;
    # Email header **Date**
    string date?;
    # Email header **ContentType**
    string contentType?;
    # MIME type of the top level message part. Values in `multipart/alternative` such as `text/plain` and `text/html` and in `multipart/*` including `multipart/mixed` and `multipart/related` indicate that the message contains a structured body with MIME parts. Values in `message/rfc822` indicate that the message is a container for the message parts that follow after the header.    
    string mimeType?;
    # Body of the message.
    MessagePart payload?;
};

# A single MIME message part.
public type MessagePart record {
    # The filename of the attachment. Only present if this message part represents an attachment.
    string filename?;
    # List of headers on this message part. For the top-level message part, representing the entire message payload, it will contain the standard RFC 2822 email headers such as `To`, `From`, and `Subject`.
    map<string> headers?;
    # The MIME type of the message part.
    string mimeType?;
    # The immutable ID of the message part.
    string partId;
    # When present, contains the ID of an external attachment that can be retrieved in a separate `messages.attachments.get` request. When not present, the entire content of the message part body is contained in the data field.
    string attachmentId?;
    # The body data of a MIME message part. May be empty for MIME container types that have no message body or when the body data is sent as a separate attachment. An attachment ID is present if the body data is contained in a separate attachment.
    string data?;
    # Number of bytes for the message part data.
    int:Signed32 size?;
    # The child MIME message parts of this part. This only applies to container MIME message parts, for example `multipart/*`. For non- container MIME message part types, such as `text/plain`, this field is empty. For more information, see RFC 1521.
    MessagePart[] parts?;
};

# List of messages.
public type ListMessagesResponse record {
    # List of messages. Note that each message resource contains only an `id` and a `threadId`. Additional message details can be fetched using the messages.get method.
    Message[] messages?;
    # Token to retrieve the next page of results in the list.
    string nextPageToken?;
    # Estimated total number of results.
    int resultSizeEstimate?;
};

public type BatchDeleteMessagesRequest record {|
    # The IDs of the messages to delete.
    string[] ids?;
|};

public type BatchModifyMessagesRequest record {|
    # A list of label IDs to add to messages.
    string[] addLabelIds?;
    # The IDs of the messages to modify. There is a limit of 1000 ids per request.
    string[] ids?;
    # A list of label IDs to remove from messages.
    string[] removeLabelIds?;
|};

public type ModifyMessageRequest record {|
    # A list of IDs of labels to add to this message. You can add up to 100 labels with each update.
    string[] addLabelIds?;
    # A list IDs of labels to remove from this message. You can remove up to 100 labels with each update.
    string[] removeLabelIds?;
|};

# An Attachment.
public type Attachment record {
    # Id of the attachment.
    string attachmentId?;
    # The body data of a MIME message part. 
    string data?;
    # Number of bytes for the message part data (encoding notwithstanding).
    int:Signed32 size?;
};

# Message Send Request-Payload (Charset UTF-8 will be used to encode the message body).
public type MessageRequest record {|
    # The recipients of the mail
    string[] to?;
    # The sender of the mail
    string 'from?;
    # The subject of the mail
    string subject?;
    # The cc recipients of the mail.
    string[] cc?;
    # The bcc recipients of the mail.
    string[] bcc?;
    # Message body of content type ```text/plain```. 
    string bodyInText?;
    # Message body of content type ```text/html```.
    string bodyInHtml?;
    # The file array consisting the inline images.
    ImageFile[] inlineImages?;
    # The file array consisting the attachments.
    AttachmentFile[] attachments?;
|};

# A file record to indicate attachment
public type AttachmentFile record {|
    # The mime type of the file (ex. application/pdf, text/plain)
    string mimeType;
    # The file name with extension. This will be used name the attachment/image in the mail.
    string name;
    # The file path
    string path;
|};

# A file record to indicate inline image
public type ImageFile record {|
    *AttachmentFile;
    # The content id of the image. This will be used to refer the image in the mail body.
    string contentId;
|};
