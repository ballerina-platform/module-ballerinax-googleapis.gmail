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

# Represents Gmail UserProfile.
#
# + emailAddress - The user's email address
# + messagesTotal - The total number of messages in the mailbox
# + threadsTotal - The total number of threads in the mailbox
# + historyId - The ID of the mailbox's current history record
@display {label: "User Profile"}
public type UserProfile record {
    @display {label: "Email Address"}
    string emailAddress;
    @display {label: "Total Messages"}
    int messagesTotal;
    @display {label: "Total Threads"}
    int threadsTotal;
    @display {label: "History Id"}
    string historyId;
};

# Represents mail thread resource.
#
# + id - The unique ID of the thread
# + snippet - A short part of the message text
# + historyId - The ID of the last history record that modified this thread
# + messages - The list of messages in the thread
@display {label: "Mail Thread"}
public type MailThread record {
    @display {label: "Thread Id"}
    string id ;
    @display {label: "History Id"}
    string historyId?;
    @display {label: "Snippet"}
    string snippet?;
    @display {label: "Messages"}
    Message[] messages?;
};

# Represents message request to send a mail.
#
# + recipient - The recipient of the mail
# + subject - The subject of the mail
# + contentType - The content type of the mail, whether it is text/plain or text/html. Only pass one of the
#                        constant values defined in the module; `TEXT_PLAIN` or `TEXT_HTML`
# + messageBody - The message body of the mail. Can be either plain text or html text.
# + cc - The cc recipient of the mail. Optional.
# + bcc - The bcc recipient of the mail. Optional.
# + sender - The sender of the mail. Optional
# + inlineImagePaths - The InlineImagePath array consisting the inline image file paths and mime types. Optional.
#                            Note that inline images can only be send for `TEXT_HTML` messages.
# + attachmentPaths - The AttachmentPath array consisting the attachment file paths and mime types. Optional.
@display {label: "Message Request"}
public type MessageRequest record {
    @display {label: "Recipient"}
    string recipient;
    @display {label: "Subject"}
    string subject;
    @display {label: "Content Type"}
    string contentType;
    @display {label: "Message Body"}
    string messageBody;
    @display {label: "Cc"}
    string cc?;
    @display {label: "Bcc"}
    string bcc?;
    @display {label: "Sender"}
    string sender?;
    @display {label: "Inline Image Paths"}
    InlineImagePath[] inlineImagePaths?;
    @display {label: "Attachment Paths"}
    AttachmentPath[] attachmentPaths?;
};

# Represents image file path and mime type of an inline image in a message request.
#
# + imagePath - The file path of the image
# + mimeType - The mime type of the image. The primary type should be `image`.
#                  For ex: If you are sending a jpg image, give the mime type as `image/jpeg`.
#                          If you are sending a png image, give the mime type as `image/png`.
@display {label: "Inline Image Path"}
public type InlineImagePath record {
    @display {label: "Image Path"}
    string imagePath;
    @display {label: "Mime Type"}
    string mimeType;
};

# Represents an attachment file path and mime type of an attachment in a message request.
#
# + attachmentPath - The file path of the attachment
# + mimeType - The mime type of the attachment
#                  For ex: If you are sending a pdf document, give the mime type as `application/pdf`.
#                  If you are sending a text file, give the mime type as `text/plain`.
@display {label: "Attachment Path"}
public type AttachmentPath record {
    @display {label: "Attachment Path"}
    string attachmentPath;
    @display {label: "Mime Type"}
    string mimeType;
};

# Represents message resource which will be received as a response from the Gmail API.
#
# + threadId - Thread ID which the message belongs to
# + id - Message Id
# + labelIds - The label ids of the message
# + raw - Represent the entire message in base64 encoded string
# + snippet - Short part of the message text
# + historyId - The id of the last history record that modified the message
# + internalDate - The internal message creation timestamp(epoch ms)
# + sizeEstimate - Estimated size of the message in bytes
# + headers - The map of headers in the top level message part representing the entire message payload in a
#             standard RFC 2822 message. The key of the map is the header name and the value is the header value.
# + headerTo - Email header **To**
# + headerFrom - Email header **From**
# + headerBcc - Email header **Bcc**
# + headerCc - Email header **Cc**
# + headerSubject - Email header **Subject**
# + headerDate - Email header **Date**
# + headerContentType - Email header **ContentType**
# + mimeType - MIME type of the top level message part
# + emailBodyInText - MIME Message Part with text/plain content type
# + emailBodyInHTML - MIME Message Part with text/html content type
# + emailInlineImages - MIME Message Parts with inline images with the image/* content type
# + msgAttachments - MIME Message Parts of the message consisting the attachments
@display {label: "Message"}
public type Message record {
    @display {label: "Thread Id"}
    string threadId;
    @display {label: "Message Id"}
    string id;
    @display {label: "Label Ids"}
    string[] labelIds?;
    @display {label: "Raw"}
    string raw?;
    @display {label: "Snippet"}
    string snippet?;
    @display {label: "History Id"}
    string historyId?;
    @display {label: "Internal Date"}
    string internalDate?;
    @display {label: "Size Estimate"}
    string sizeEstimate?;
    @display {label: "Headers"}
    map<string> headers?;
    @display {label: "To"}
    string headerTo?;
    @display {label: "From"}
    string headerFrom?;
    @display {label: "Bcc"}
    string headerBcc?;
    @display {label: "Cc"}
    string headerCc?;
    @display {label: "Subject"}
    string headerSubject?;
    @display {label: "Date"}
    string headerDate?;
    @display {label: "Content Type"}
    string headerContentType?;
    @display {label: "Mime Type"}
    string mimeType?;
    @display {label: "Email Body in Text"}
    MessageBodyPart emailBodyInText?;
    @display {label: "Email Body in HTML"}
    MessageBodyPart emailBodyInHTML?;
    @display {label: "Email Inline Images"}
    MessageBodyPart[] emailInlineImages?;
    @display {label: "Message Attachments"}
    MessageBodyPart[] msgAttachments?;
};

# Represents the email message body part of a message resource response.
#
# + data - The body data of the message part. This is a base64 encoded string
# + mimeType - MIME type of the message part
# + bodyHeaders - Headers of the MIME Message Part
# + fileId - The file id of the attachment/inline image in message part *(This is empty unless the message part
#            represent an inline image/attachment)*
# + fileName - The file name of the attachment/inline image in message part *(This is empty unless the message part
#            represent an inline image/attachment)*
# + partId - The part id of the message part
# + size - Number of bytes of message part data
@display {label: "Message Body Part"}
public type MessageBodyPart record {
    @display {label: "Data"}
    string data?;
    @display {label: "Mime Type"}
    string mimeType?;
    @display {label: "Body Headers"}
    map<string> bodyHeaders?;
    @display {label: "File Id"}
    string fileId?;
    @display {label: "File Name"}
    string fileName?;
    @display {label: "Part Id"}
    string partId?;
    @display {label: "Size"}
    int size?;
};

# Represents the optional search message filter fields.
#
# + includeSpamTrash - Specifies whether to include messages/threads from SPAM and TRASH in the results
# + labelIds - Array of label ids. Only return messages/threads with labels that match all of the specified
#              label Ids.
# + maxResults - Maximum number of messages/threads to return in the page for a single request
# + pageToken - Page token to retrieve a specific page of results in the list
# + q - Query for searching messages/threads. Only returns messages/threads matching the specified query. Supports
#       the same query format as the Gmail search box.
@display {label: "Message Search Filter"}
public type MsgSearchFilter record {
    @display {label: "Include Spam Trash"}
    boolean includeSpamTrash?;
    @display {label: "Label Ids"}
    string[] labelIds?;
    @display {label: "Maximum Results"}
    int maxResults?;
    @display {label: "Page Token"}
    string pageToken?;
    @display {label: "Query"}
    string q?;
};

# Represents the optional search drafts filter fields.
#
# + includeSpamTrash - Specifies whether to include drafts from SPAM and TRASH in the results
# + maxResults - Maximum number of drafts to return in the page for a single request
# + pageToken - Page token to retrieve a specific page of results in the list
# + q - Query for searching . Only returns drafts matching the specified query. Supports
#       the same query format as the Gmail search box.
@display {label: "Draft Search Filter"}
public type DraftSearchFilter record {
    @display {label: "Include Spam Trash"}
    boolean includeSpamTrash?;
    @display {label: "Maximum Results"}
    int maxResults?;
    @display {label: "Page Token"}
    string pageToken?;
    @display {label: "Query"}
    string q?;
};

# Represents a page of the message list received as response for list messages api call.
#
# + messages - Array of message maps with messageId and threadId as keys
# + resultSizeEstimate - Estimated size of the whole list
# + nextPageToken - Token for next page of message list
@display {label: "Message List Page"}
public type MessageListPage record {
    @display {label: "Messages"}
    Message[] messages?;
    @display {label: "Result Size Estimate"}
    int resultSizeEstimate;
    @display {label: "Next Page Token"}
    string nextPageToken?;
};

# Represents a page of the mail thread list received as response for list threads api call.
#
# + threads - Array of thread maps with threadId, snippet and historyId as keys
# + resultSizeEstimate - Estimated size of the whole list
# + nextPageToken - Token for next page of mail thread list
@display {label: "Thread List Page"}
public type ThreadListPage record {
    @display {label: "Threads"}
    MailThread[] threads?;
    @display {label: "Result Size Estimate"}
    int resultSizeEstimate;
    @display {label: "Next Page Token"}
    string nextPageToken?;
};

# Represents a page of the drafts list received as response for list drafts api call.
#
# + drafts - Array of draft maps with draftId, messageId and threadId as keys
# + resultSizeEstimate - Estimated size of the whole list
# + nextPageToken - Token for next page of mail drafts list
@display {label: "Draft List Page"}
public type DraftListPage record {
    @display {label: "Drafts"}
    Draft[] drafts?;
    @display {label: "Result Size Estimate"}
    int resultSizeEstimate;
    @display {label: "Next Page Token"}
    string nextPageToken?;
};

# Represents a Label which is used to categorize messaages and threads within the user's mailbox.
#
# + id - The immutable ID of the label
# + name - The display name of the label
# + messageListVisibility - The visibility of messages with this label in the message list in the Gmail web interface.
#                           Acceptable values are:
#
#                            *hide*: Do not show the label in the message list.
#                            *show*: Show the label in the message list (Default)
# + labelListVisibility - The visibility of the label in the label list in the Gmail web interface.
#                         Acceptable values are:
#
#                            *labelHide*: Do not show the label in the label list
#                            *labelShow*: Show the label in the label list (Default)
#                            *labelShowIfUnread*: Show the label if there are any unread messages with that label
# + type - The owner type for the label.
#               Acceptable values are:
#                    *system*: Labels created by Gmail
#                    *user*: Custom labels created by the user or application
#
# + messagesTotal - The total number of messages with the label
# + messagesUnread - The number of unread messages with the label
# + threadsTotal - The total number of threads with the label
# + threadsUnread - The number of unread threads with the label
# + color - Reperesents the color of label
@display {label: "Label"}
public type Label record {
    @display {label: "Label Id"}
    string id;
    @display {label: "Label Name"}
    string name;
    @display {label: "Message List Visibility"}
    string messageListVisibility?;
    @display {label: "Label List Visibility"}
    string labelListVisibility?;
    @display {label: "Type"}
    string 'type?;
    @display {label: "Total Messages"}
    int messagesTotal?;
    @display {label: "Unread Messages"}
    int messagesUnread?;
    @display {label: "Total Threads"}
    int threadsTotal?;
    @display {label: "Unread Threads"}
    int threadsUnread?;
    @display {label: "Color"}
    Color color?;
};

# Represents the list of labels.
#
# + labels - The array of labels
@display {label: "Label List"}
public type LabelList record {
    @display {label: "Labels"}
    Label[] labels;
};

# Represents the color of label.
#
# + textColor - The text color of the label, represented as hex string
# + backgroundColor - The background color represented as hex string
@display {label: "Color"}
public type Color record {
    @display {label: "Text Color"}
    string textColor;
    @display {label: "Background Color"}
    string backgroundColor;
};

# Represents a page of the history list received as response for list history api call.
#
# + history - List of history records. Any messages contained in the response will typically only have id and
#                    threadId fields populated.
# + nextPageToken - Page token to retrieve the next page of results in the list
# + historyId - The ID of the mailbox's current history record
@display {label: "Mailbox History Page"}
public type MailboxHistoryPage record {
    @display {label: "History List"}
    History[] history?;
    @display {label: "Next Page Token"}
    string nextPageToken?;
    @display {label: "History Id"}
    string historyId;
};

# Represents a history reoced in MailboxHistoryPage.
#
# + id - The mailbox sequence ID
# + messages - List of messages changed in this history record
# + messagesAdded - 	Messages added to the mailbox in this history record
# + messagesDeleted - Messages deleted (not Trashed) from the mailbox in this history record
# + labelsAdded - Array of maps of Labels added to messages in this history record
# + labelsRemoved - Array of maps of Labels removed from messages in this history record
@display {label: "History"}
public type History record {
    @display {label: "History Id"}
    string id;
    @display {label: "Messages"}
    Message[] messages?;
    @display {label: "Messages Added"}
    HistoryEvent[] messagesAdded?;
    @display {label: "Messages Deleted"}
    HistoryEvent[] messagesDeleted?;
    @display {label: "Labels Added"}
    HistoryEvent[] labelsAdded?;
    @display {label: "Labels Removed"}
    HistoryEvent[] labelsRemoved?;
};

# Represents changes of messages in history record.
# 
# + message - The message changed  
# + labelIds - The label ids of the message  
@display {label: "History Event"}
public type HistoryEvent record {
    @display {label: "Message"}
    Message message;
    @display {label: "Label Ids"}
    string [] labelIds?;
};

# Represents a draft email in user's mailbox.
#
# + id - The immutable id of the draft
# + message - The message content of the draft
@display {label: "Draft"}
public type Draft record {
    @display {label: "Draft Id"}
    string id;
    @display {label: "Message"}
    Message message?;
};
