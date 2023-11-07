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

# A draft email in the user's mailbox.
public type Draft record {
    # The immutable ID of the draft.
    string id?;
    # An email message.
    Message message?;
};

public type ListDraftsResponse record {
    # List of drafts. Note that the `Message` property in each `Draft` resource only contains an `id` and a `threadId`. The messages.get method can fetch additional message details.
    Draft[] drafts?;
    # Token to retrieve the next page of results in the list.
    string nextPageToken?;
    # Estimated total number of results.
    int resultSizeEstimate?;
};

# Request payload to create a draft. 
public type DraftRequest record {|
    # The immutable ID of the draft.
    string id?;
    # An email message.
    MessageRequest message?;
|};

public type ListThreadsResponse record {
    # Page token to retrieve the next page of results in the list.
    string nextPageToken?;
    # Estimated total number of results.
    int resultSizeEstimate?;
    # List of threads. Note that each thread resource does not contain a list of `messages`. The list of `messages` for a given thread can be fetched using the threads.get method.
    MailThread[] threads?;
};

# A collection of messages representing a conversation.
public type MailThread record {
    # The ID of the last history record that modified this thread.
    string historyId?;
    # The unique ID of the thread.
    string id?;
    # The list of messages in the thread.
    Message[] messages?;
    # A short part of the message text.
    string snippet?;
};

# Request payload used to create a collection of messages representing a conversation.
public type MailThreadRequest record {|
    # The unique ID of the thread.
    string id?;
    # The list of messages in the thread.
    Message[] messages?;
|};

public type ModifyThreadRequest record {|
    # A list of IDs of labels to add to this thread. You can add up to 100 labels with each update.
    string[] addLabelIds?;
    # A list of IDs of labels to remove from this thread. You can remove up to 100 labels with each update.
    string[] removeLabelIds?;
|};

# Labels are used to categorize messages and threads within the user's mailbox. The maximum number of labels supported for a user's mailbox is 10,000.
public type Label record {
    # The color to assign to the label. Color is only available for labels that have their `type` set to `user`.
    LabelColor color?;
    # The immutable ID of the label.
    string id?;
    # The visibility of the label in the label list in the Gmail web interface.
    "labelShow"|"labelShowIfUnread"|"labelHide" labelListVisibility?;
    # The visibility of messages with this label in the message list in the Gmail web interface.
    "show"|"hide" messageListVisibility?;
    # The total number of messages with the label.
    int:Signed32 messagesTotal?;
    # The number of unread messages with the label.
    int:Signed32 messagesUnread?;
    # The display name of the label.
    string name?;
    # The total number of threads with the label.
    int:Signed32 threadsTotal?;
    # The number of unread threads with the label.
    int:Signed32 threadsUnread?;
    # The owner type for the label. User labels are created by the user and can be modified and deleted by the user and can be applied to any message or thread. System labels are internally created and cannot be added, modified, or deleted. System labels may be able to be applied to or removed from messages and threads under some circumstances but this is not guaranteed. For example, users can apply and remove the `INBOX` and `UNREAD` labels from messages and threads, but cannot apply or remove the `DRAFTS` or `SENT` labels from messages or threads.
    "system"|"user" 'type?;
};

public type ListLabelsResponse record {
    # List of labels. Note that each label resource only contains an `id`, `name`, `messageListVisibility`, `labelListVisibility`, and `type`. The labels.get method can fetch additional label details.
    Label[] labels?;
};

# The color to assign to the label. Color is only available for labels that have their `type` set to `user`.
public type LabelColor record {
    # The background color represented as hex string #RRGGBB (ex #000000). This field is required in order to set the color of a label. Only the following predefined set of color values are allowed: \#000000, #434343, #666666, #999999, #cccccc, #efefef, #f3f3f3, #ffffff, \#fb4c2f, #ffad47, #fad165, #16a766, #43d692, #4a86e8, #a479e2, #f691b3, \#f6c5be, #ffe6c7, #fef1d1, #b9e4d0, #c6f3de, #c9daf8, #e4d7f5, #fcdee8, \#efa093, #ffd6a2, #fce8b3, #89d3b2, #a0eac9, #a4c2f4, #d0bcf1, #fbc8d9, \#e66550, #ffbc6b, #fcda83, #44b984, #68dfa9, #6d9eeb, #b694e8, #f7a7c0, \#cc3a21, #eaa041, #f2c960, #149e60, #3dc789, #3c78d8, #8e63ce, #e07798, \#ac2b16, #cf8933, #d5ae49, #0b804b, #2a9c68, #285bac, #653e9b, #b65775, \#822111, #a46a21, #aa8831, #076239, #1a764d, #1c4587, #41236d, #83334c \#464646, #e7e7e7, #0d3472, #b6cff5, #0d3b44, #98d7e4, #3d188e, #e3d7ff, \#711a36, #fbd3e0, #8a1c0a, #f2b2a8, #7a2e0b, #ffc8af, #7a4706, #ffdeb5, \#594c05, #fbe983, #684e07, #fdedc1, #0b4f30, #b3efd3, #04502e, #a2dcc1, \#c2c2c2, #4986e7, #2da2bb, #b99aff, #994a64, #f691b2, #ff7537, #ffad46, \#662e37, #ebdbde, #cca6ac, #094228, #42d692, #16a765
    string backgroundColor?;
    # The text color of the label, represented as hex string. This field is required in order to set the color of a label. Only the following predefined set of color values are allowed: \#000000, #434343, #666666, #999999, #cccccc, #efefef, #f3f3f3, #ffffff, \#fb4c2f, #ffad47, #fad165, #16a766, #43d692, #4a86e8, #a479e2, #f691b3, \#f6c5be, #ffe6c7, #fef1d1, #b9e4d0, #c6f3de, #c9daf8, #e4d7f5, #fcdee8, \#efa093, #ffd6a2, #fce8b3, #89d3b2, #a0eac9, #a4c2f4, #d0bcf1, #fbc8d9, \#e66550, #ffbc6b, #fcda83, #44b984, #68dfa9, #6d9eeb, #b694e8, #f7a7c0, \#cc3a21, #eaa041, #f2c960, #149e60, #3dc789, #3c78d8, #8e63ce, #e07798, \#ac2b16, #cf8933, #d5ae49, #0b804b, #2a9c68, #285bac, #653e9b, #b65775, \#822111, #a46a21, #aa8831, #076239, #1a764d, #1c4587, #41236d, #83334c \#464646, #e7e7e7, #0d3472, #b6cff5, #0d3b44, #98d7e4, #3d188e, #e3d7ff, \#711a36, #fbd3e0, #8a1c0a, #f2b2a8, #7a2e0b, #ffc8af, #7a4706, #ffdeb5, \#594c05, #fbe983, #684e07, #fdedc1, #0b4f30, #b3efd3, #04502e, #a2dcc1, \#c2c2c2, #4986e7, #2da2bb, #b99aff, #994a64, #f691b2, #ff7537, #ffad46, \#662e37, #ebdbde, #cca6ac, #094228, #42d692, #16a765
    string textColor?;
};

public type ListHistoryResponse record {
    # List of history records. Any `messages` contained in the response will typically only have `id` and `threadId` fields populated.
    History[] history?;
    # The ID of the mailbox's current history record.
    string historyId?;
    # Page token to retrieve the next page of results in the list.
    string nextPageToken?;
};

# A record of a change to the user's mailbox. Each history change may affect multiple messages in multiple ways.
public type History record {
    # The mailbox sequence ID.
    string id?;
    # Labels added to messages in this history record.
    HistoryLabelAdded[] labelsAdded?;
    # Labels removed from messages in this history record.
    HistoryLabelRemoved[] labelsRemoved?;
    # List of messages changed in this history record. The fields for specific change types, such as `messagesAdded` may duplicate messages in this field. We recommend using the specific change-type fields instead of this.
    Message[] messages?;
    # Messages added to the mailbox in this history record.
    HistoryMessageAdded[] messagesAdded?;
    # Messages deleted (not Trashed) from the mailbox in this history record.
    HistoryMessageDeleted[] messagesDeleted?;
};

public type HistoryMessageAdded record {
    # An email message.
    Message message?;
};

public type HistoryMessageDeleted record {
    # An email message.
    Message message?;
};

public type HistoryLabelAdded record {
    # Label IDs added to the message.
    string[] labelIds?;
    # An email message.
    Message message?;
};

public type HistoryLabelRemoved record {
    # Label IDs removed from the message.
    string[] labelIds?;
    # An email message.
    Message message?;
};
