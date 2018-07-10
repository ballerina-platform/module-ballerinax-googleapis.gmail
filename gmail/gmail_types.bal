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

documentation{
    Represents Gmail UserProfile.

    F{{emailAddress}} The user's email address
    F{{messagesTotal}} The total number of messages in the mailbox
    F{{threadsTotal}} The total number of threads in the mailbox
    F{{historyId}} The ID of the mailbox's current history record
}
public type UserProfile record {
    @readonly string emailAddress;
    @readonly string messagesTotal;
    @readonly string threadsTotal;
    @readonly string historyId;
};

documentation{
    Represents mail thread resource.

    F{{id}} The unique ID of the thread
    F{{snippet}} A short part of the message text
    F{{historyId}} The ID of the last history record that modified this thread
    F{{messages}} The list of messages in the thread
}
public type Thread record {
    @readonly string id;
    @readonly string snippet;
    @readonly string historyId;
    @readonly Message[] messages;
};

documentation{
    Represents message request to send a mail.

    F{{recipient}} The recipient of the mail
    F{{subject}} The subject of the mail
    F{{messageBody}} The message body of the mail. Can be either plain text or html text.
    F{{contentType}} The content type of the mail, whether it is text/plain or text/html. Only pass one of the
                        constant values defined in the package; TEXT_PLAIN or TEXT_HTML
    F{{sender}} The sender of the mail
    F{{cc}} The cc recipient of the mail. Optional.
    F{{bcc}} The bcc recipient of the mail. Optional.
    F{{inlineImagePaths}} The InlineImagePath array consisting the inline image file paths and mime types. Optional.
                            Note that inline images can only be send for TEXT_HTML messages.
    F{{attachmentPaths}} The AttachmentPath array consisting the attachment file paths and mime types. Optional.
}

public type MessageRequest record {
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
    Represents image file path and mime type of an inline image in a message request.

    F{{imagePath}} The file path of the image
    F{{mimeType}} The mime type of the image. The primary type should be **image**.
                  For ex: If you are sending a jpg image, give the mime type as **image/jpeg**.
                          If you are sending a png image, give the mime type as **image/png**.
}
public type InlineImagePath record {
    string imagePath;
    string mimeType;
};

documentation{
    Represents an attachment file path and mime type of an attachment in a message request.

    F{{attachmentPath}} The file path of the attachment
    F{{mimeType}} The mime type of the attachment
                  For ex: If you are sending a pdf document, give the mime type as **application/pdf**.
                          If you are sending a text file, give the mime type as **text/plain**.
}
public type AttachmentPath record {
    string attachmentPath;
    string mimeType;
};

documentation{
    Represents message resource which will be received as a response from the Gmail API.

    F{{threadId}} Thread ID which the message belongs to
    F{{id}} Message Id
    F{{labelIds}} The label ids of the message
    F{{raw}} Represent the entire message in base64 encoded string
    F{{snippet}} Short part of the message text
    F{{historyId}} The id of the last history record that modified the message
    F{{internalDate}} The internal message creation timestamp(epoch ms)
    F{{sizeEstimate}} Estimated size of the message in bytes
    F{{headers}} The map of headers in the top level message part representing the entire message payload in a
    standard RFC 2822 message. The key of the map is the header name and the value is the header value.
    F{{headerTo}} Email header **To**
    F{{headerFrom}} Email header **From**
    F{{headerBcc}} Email header **Bcc**
    F{{headerCc}} Email header **Cc**
    F{{headerSubject}} Email header **Subject**
    F{{headerDate}} Email header **Date**
    F{{headerContentType}} Email header **ContentType**
    F{{mimeType}} MIME type of the top level message part
    F{{plainTextBodyPart}} MIME Message Part with text/plain content type
    F{{htmlBodyPart}} MIME Message Part with text/html content type
    F{{inlineImgParts}} MIME Message Parts with inline images with the image/* content type
    F{{msgAttachments}} MIME Message Parts of the message consisting the attachments
}

public type Message record {
    @readonly string threadId;
    @readonly string id;
    @readonly string[] labelIds;
    @readonly string raw;
    @readonly string snippet;
    @readonly string historyId;
    @readonly string internalDate;
    @readonly string sizeEstimate;
    @readonly map headers;
    @readonly string headerTo;
    @readonly string headerFrom;
    @readonly string headerBcc;
    @readonly string headerCc;
    @readonly string headerSubject;
    @readonly string headerDate;
    @readonly string headerContentType;
    @readonly string mimeType;
    @readonly MessageBodyPart plainTextBodyPart;
    @readonly MessageBodyPart htmlBodyPart;
    @readonly MessageBodyPart[] inlineImgParts;
    @readonly MessageBodyPart[] msgAttachments;
};

documentation{
    Represents the email message body part of a message resource response.

    F{{body}} The body data of the message part. This is a base64 encoded string
    F{{mimeType}} MIME type of the message part
    F{{bodyHeaders}} Headers of the MIME Message Part
    F{{fileId}} The file id of the attachment/inline image in message part *(This is empty unless the message part
                represent an inline image/attachment)*
    F{{fileName}} The file name of the attachment/inline image in message part *(This is empty unless the message part
                represent an inline image/attachment)*
    F{{partId}} The part id of the message part
    F{{size}} Number of bytes of message part data
}
public type MessageBodyPart record {
    @readonly string body;
    @readonly string mimeType;
    @readonly map bodyHeaders;
    @readonly string fileId;
    @readonly string fileName;
    @readonly string partId;
    @readonly string size;
};

documentation{
    Represents Gmail error.

    F{{message}} Gmail error message
    F{{cause}} The error which caused the Gmail error
}
public type GmailError record {
    string message;
    error? cause;
};

documentation{
    Represents the optional search message filter fields.

    F{{includeSpamTrash}} Specifies whether to include messages/threads from SPAM and TRASH in the results
    F{{labelIds}} Array of label ids. Only return messages/threads with labels that match all of the specified
                  label Ids.
    F{{maxResults}} Maximum number of messages/threads to return in the page for a single request
    F{{pageToken}} Page token to retrieve a specific page of results in the list
    F{{q}} Query for searching messages/threads. Only returns messages/threads matching the specified query. Supports
           the same query format as the Gmail search box.
}
public type MsgSearchFilter record {
    boolean includeSpamTrash;
    string[] labelIds;
    string maxResults;
    string pageToken;
    string q;
};

documentation{
    Represents the optional search drafts filter fields.

    F{{includeSpamTrash}} Specifies whether to include drafts from SPAM and TRASH in the results
    F{{maxResults}} Maximum number of drafts to return in the page for a single request
    F{{pageToken}} Page token to retrieve a specific page of results in the list
    F{{q}} Query for searching . Only returns drafts matching the specified query. Supports
           the same query format as the Gmail search box.
}
public type DraftSearchFilter record {
    boolean includeSpamTrash;
    string maxResults;
    string pageToken;
    string q;
};

documentation{
    Represents a page of the message list received as response for list messages api call.

    F{{messages}} Array of message maps with messageId and threadId as keys
    F{{resultSizeEstimate}} Estimated size of the whole list
    F{{nextPageToken}} Token for next page of message list
}
public type MessageListPage record {
    @readonly map[] messages;
    @readonly string resultSizeEstimate;
    @readonly string nextPageToken;
};

documentation{
    Represents a page of the mail thread list received as response for list threads api call.

    F{{threads}} Array of thread maps with threadId, snippet and historyId as keys
    F{{resultSizeEstimate}} Estimated size of the whole list
    F{{nextPageToken}} Token for next page of mail thread list
}
public type ThreadListPage record {
    @readonly map[] threads;
    @readonly string resultSizeEstimate;
    @readonly string nextPageToken;
};

documentation{
    Represents a page of the drafts list received as response for list drafts api call.

    F{{drafts}} Array of draft maps with draftId, messageId and threadId as keys
    F{{resultSizeEstimate}} Estimated size of the whole list
    F{{nextPageToken}} Token for next page of mail drafts list
}
public type DraftListPage record {
    @readonly map[] drafts;
    @readonly string resultSizeEstimate;
    @readonly string nextPageToken;
};

documentation{
    Represents a Label which is used to categorize messaages and threads within the user's mailbox.

    F{{id}} The immutable ID of the label
    F{{name}} The display name of the label
    F{{messageListVisibility}} The visibility of messages with this label in the message list in the Gmail web interface.
                               Acceptable values are:

                                *hide*: Do not show the label in the message list.
                                *show*: Show the label in the message list (Default)
    F{{labelListVisibility}} The visibility of the label in the label list in the Gmail web interface.
                             Acceptable values are:

                                *labelHide*: Do not show the label in the label list
                                *labelShow*: Show the label in the label list (Default)
                                *labelShowIfUnread*: Show the label if there are any unread messages with that label
    F{{ownerType}} The owner type for the label.
                   Acceptable values are:
                        *system*: Labels created by Gmail
                        *user*: Custom labels created by the user or application

    F{{messagesTotal}} The total number of messages with the label
    F{{messagesUnread}} The number of unread messages with the label
    F{{threadsTotal}} The total number of threads with the label
    F{{threadsUnread}} The number of unread threads with the label
    F{{textColor}} The text color of the label, represented as hex string
    F{{backgroundColor}} The background color represented as hex string
}
public type Label record {
    @readonly string id;
    @readonly string name;
    @readonly string messageListVisibility;
    @readonly string labelListVisibility;
    @readonly string ownerType;
    @readonly int messagesTotal;
    @readonly int messagesUnread;
    @readonly int threadsTotal;
    @readonly int threadsUnread;
    @readonly string textColor;
    @readonly string backgroundColor;
};

documentation{
    Represents a page of the history list received as response for list history api call.

    F{{historyRecords}} List of history records. Any messages contained in the response will typically only have id and
                        threadId fields populated.
    F{{nextPageToken}} Page token to retrieve the next page of results in the list
    F{{historyId}} The ID of the mailbox's current history record
}
public type MailboxHistoryPage record {
    @readonly History[] historyRecords;
    @readonly string nextPageToken;
    @readonly string historyId;
};

documentation{
    Represents a history reoced in MailboxHistoryPage.

    F{{id}} The mailbox sequence ID
    F{{messages}} List of messages changed in this history record
    F{{messagesAdded}} 	Messages added to the mailbox in this history record
    F{{messagesDeleted}} Messages deleted (not Trashed) from the mailbox in this history record
    F{{labelsAdded}} Array of maps of Labels added to messages in this history record
    F{{labelsRemoved}} Array of maps of Labels removed from messages in this history record
}
public type History record {
    @readonly string id;
    @readonly Message[] messages;
    @readonly Message[] messagesAdded;
    @readonly Message[] messagesDeleted;
    @readonly map[] labelsAdded;
    @readonly map[] labelsRemoved;
};

documentation{
    Represents a draft email in user's mailbox.

    F{{id}} The immutable id of the draft
    F{{message}} The message content of the draft
}
public type Draft record {
    @readonly string id;
    @readonly Message message;
};
