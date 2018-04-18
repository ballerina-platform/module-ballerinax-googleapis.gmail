// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/util;
import ballerina/io;

documentation{
    Represents GMail UserProfile.

    F{{emailAddress}} - The user's email address.
    F{{messagesTotal}} - The total number of messages in the mailbox.
    F{{threadsTotal}} - The total number of threads in the mailbox.
    F{{historyId}} - The ID of the mailbox's current history record.
}
public type UserProfile {
    @readonly string emailAddress;
    @readonly string messagesTotal;
    @readonly string threadsTotal;
    @readonly string historyId;
};

documentation{
    Represents mail thread resource.

    F{{id}} - The unique ID of the thread.
    F{{snippet}} - A short part of the message text.
    F{{historyId}} - The ID of the last history record that modified this thread.
    F{{messages}} - The list of messages in the thread.
}
public type Thread {
    @readonly string id;
    @readonly string snippet;
    @readonly string historyId;
    @readonly Message[] messages;
};

public type MessageRequest {
    string recipient;
    string subject;
    string messageBody;
    string contentType;
    string sender;
    string cc;
    string bcc;
    InlineImagePath[] inlineImagePaths;
    AttachmentPath[] attachmentPaths;
};

documentation{
    Represents an inline image of an email.

    F{{imagePath}} - The file path of the image.
    F{{mimeType}} - The content type of the image.
}
public type InlineImagePath {
    string imagePath;
    string mimeType;
};

public type AttachmentPath {
    string attachmentPath;
    string mimeType;
};

documentation{
    Represents message resource.

    F{{threadId}} - Thread ID which the message belongs to.
    F{{id}} - Message Id
    F{{labelIds}} - The label ids of the message.
    F{{raw}} - Represent the entire message in base64 encoded string
    F{{snippet}} - Short part of the message text
    F{{historyId}} - The id of the last history record that modified the message
    F{{internalDate}} - The internal message creation timestamp(epoch ms)
    F{{sizeEstimate}} - Estimated size of the message in bytes
    F{{headers}} - The headers in the top level message part representing the entire message payload in a  standard RFC
                   2822 message.
    F{{headerTo}} - Email header **To**.
    F{{headerFrom}} - Email header **From**.
    F{{headerBcc}} - Email header **Bcc**.
    F{{headerCc}} - Email header **Cc**.
    F{{headerSubject}} - Email header **Subject**.
    F{{headerDate}} - Email header **Date**.
    F{{headerContentType}} - Email header **ContentType**.
    F{{mimeType}} - MIME type of the top level message part.
    F{{plainTextBodyPart}} - MIME Message Part with text/plain content type
    F{{htmlBodyPart}} - MIME Message Part with text/html content type
    F{{inlineImgParts}} - MIME Message Parts with inline images with the image/* content type
    F{{msgAttachments}} - MIME Message Parts of the message consisting the attachments
}

public type Message {
    @readonly string threadId;
    @readonly string id;
    @readonly string[] labelIds;
    @readonly string raw;
    @readonly string snippet;
    @readonly string historyId;
    @readonly string internalDate;
    @readonly string sizeEstimate;
    @readonly MessagePartHeader[] headers;
    @readonly MessagePartHeader headerTo;
    @readonly MessagePartHeader headerFrom;
    @readonly MessagePartHeader headerBcc;
    @readonly MessagePartHeader headerCc;
    @readonly MessagePartHeader headerSubject;
    @readonly MessagePartHeader headerDate;
    @readonly MessagePartHeader headerContentType;
    @readonly string mimeType;
    @readonly MessageBodyPart plainTextBodyPart;
    @readonly MessageBodyPart htmlBodyPart;
    @readonly MessageBodyPart[] inlineImgParts;
    @readonly MessageAttachment[] msgAttachments;
};

documentation{
    Represents the email message body part.

    F{{body}} - The body data of the message part. This is a base64 encoded string.
    F{{mimeType}} - MIME type of the message part.
    F{{bodyHeaders}} - Headers of the MIME Message Part.
    F{{fileId}} - The file id of the attachment in message part. *(This is empty unless the message part represent an
                  inline image)*
    F{{fileName}} - The file name of the attachment in message part. *(This is empty unless the message part represent an
                    inline image)*
    F{{partId}} - The part id of the message part.
    F{{size}} - Number of bytes of message part data.
}
public type MessageBodyPart {
    @readonly string body;
    @readonly string mimeType;
    @readonly MessagePartHeader[] bodyHeaders;
    @readonly string fileId;
    @readonly string fileName;
    @readonly string partId;
    @readonly string size;
};

documentation{
        Represents Message Part with an attachment

        F{{attachmentFileId}} - The file id of the attachment in the message.
        F{{attachmentBody}} - Base 64 encoded attachment body of the Message Part. *This is empty when the attachment
                              body data is sent as a seperate attachment*
        F{{size}} - Size of the attachment message part.
        F{{attachmentFileName}} - File name of the attachment in the message.
        F{{mimeType}} - Mime Type of the message part.
        F{{attachmentHeaders}} - Headers of message part.
        F{{partId}} - Part Id of the message part
}
public type MessageAttachment {
    @readonly string attachmentFileId;
    @readonly string attachmentBody;
    @readonly string size;
    @readonly string attachmentFileName;
    @readonly string mimeType;
    @readonly MessagePartHeader[] attachmentHeaders;
    @readonly string partId;
};

documentation{
    Represents message part header

    F{{name}} - Header name
    F{{value}} - Header value
}
public type MessagePartHeader {
    @readonly string name;
    @readonly string value;
};

documentation{
    Represents GMail error

    F{{message}} - GMail error message
    F{{cause}} - The error which caused the GMail error
}
public type GMailError {
    string message;
    error? cause;
};

documentation{
    Represents the optional search message filter fields.

    F{{includeSpamTrash}} - Specifies whether to include messages/threads from SPAM and TRASH in the results.
    F{{labelIds}} - Array of label ids. *Only return messages/threads with labels that match all of the specified
                    label Ids*
    F{{maxResults}} - Maximum number of messages/threads to return in the page for a single request.
    F{{pageToken}} - Page token to retrieve a specific page of results in the list.
    F{{q}} - Query for searching messages/threads. *Only returns messages/threads matching the specified query. Supports
             the same query format as the GMail search box.*
}
public type SearchFilter {
    boolean includeSpamTrash;
    string[] labelIds;
    string maxResults;
    string pageToken;
    string q;
};

documentation{
    Represents the optional message filter fields in get message api call.

    F{{format}} - Optional. Format of the get message/thread response.
                    *Acceptable values for format for a get message/thread request are defined as following constants
                        in the package:
                        * "FORMAT_FULL": Returns the full email message data with body content parsed in the payload
                                         field;the raw field is not used. (default)
                        * "FORMAT_METADATA": Returns only email message ID, labels, and email headers.
                        * "FORMAT_MINIMAL": Returns only email message ID and labels; does not return the email headers,
                                            body, or payload.
                        * "FORMAT_RAW": Returns the full email message data with body content in the raw field as a
                                        base64url encoded string. (the payload field is not included in the response)*
    F{{metadataHeaders}} - Optional. The meta data headers array to include in the reponse when the format is given as
                           *FORMAT_METADATA*.
}
public type MessageThreadReadFilter {
    string format;
    string[] metadataHeaders;
};

documentation{
    Represents a page of the message list received as reponse for list messages api call

    F{{messages}} - Message list in the page
    F{{resultSizeEstimate}} - Estimated size of the whole list
    F{{nextPageToken}} - Token for next page of message list
}
public type MessageListPage {
    @readonly Message[] messages;
    @readonly string resultSizeEstimate;
    @readonly string nextPageToken;
};

documentation{
    Represents a page of the mail thread list received as reponse for list threads api call

    F{{threads}} - Thread list in the page
    F{{resultSizeEstimate}} - Estimated size of the whole list
    F{{nextPageToken}} - Token for next page of mail thread list
}
public type ThreadListPage {
    @readonly Thread[] threads;
    @readonly string resultSizeEstimate;
    @readonly string nextPageToken;
};
