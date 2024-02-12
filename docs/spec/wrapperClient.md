# Introduction

This document outlines significant enhancements made to the OpenAPI specification for the wrapper client. These updates introduce new functionalities and modify existing ones to enhance useability.

## `MessageRequest` parameter

The module will require `MessageRequest` record for users to give email data easily. These inputs are then transformed into RFC822 formatted encoded strings, facilitating integration with the generated client's operations. This enhancement has been applied across various resource functions, including draft, message, and thread.

```ballerina
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
    # ID of the thread the message must be replied to.
    string threadId?;
    # **Message-ID** header of the message being replied to.
    string initialMessageId?;
    # List of **Message-ID** headers identifying ancestors of the message being replied to.
    string[] references?;
|};
```

## `Message` payload

The module will return `Message` record for any retrieved emails. This record includes wider array of email-related data, ensuring comprehensive coverage of email attributes. This refinement affects resource functions such as draft, message, and thread, ensuring a more structured and accessible presentation of email data.

```ballerina
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
    # Email header **Message-ID**
    string messageId?;
    # Email header **ContentType**
    string contentType?;
    # MIME type of the top level message part. Values in `multipart/alternative` such as `text/plain` and `text/html` and in `multipart/*` including `multipart/mixed` and `multipart/related` indicate that the message contains a structured body with MIME parts. Values in `message/rfc822` indicate that the message is a container for the message parts that follow after the header.    
    string mimeType?;
    # Body of the message.
    MessagePart payload?;
};
```
