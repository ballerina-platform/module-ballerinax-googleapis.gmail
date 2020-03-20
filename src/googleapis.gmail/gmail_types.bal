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
public type UserProfile record {
    string emailAddress = "";
    string messagesTotal = "";
    string threadsTotal = "";
    string historyId = "";
};

# Represents mail thread resource.
#
# + id - The unique ID of the thread
# + snippet - A short part of the message text
# + historyId - The ID of the last history record that modified this thread
# + messages - The list of messages in the thread
public type MailThread record {
    string id = "";
    string snippet = "";
    string historyId = "";
    Message[] messages = [];
};

# Represents message request to send a mail.
#
# + recipient - The recipient of the mail
# + subject - The subject of the mail
# + messageBody - The message body of the mail. Can be either plain text or html text.
# + contentType - The content type of the mail, whether it is text/plain or text/html. Only pass one of the
#                        constant values defined in the module; `TEXT_PLAIN` or `TEXT_HTML`
# + sender - The sender of the mail
# + cc - The cc recipient of the mail. Optional.
# + bcc - The bcc recipient of the mail. Optional.
# + inlineImagePaths - The InlineImagePath array consisting the inline image file paths and mime types. Optional.
#                            Note that inline images can only be send for `TEXT_HTML` messages.
# + attachmentPaths - The AttachmentPath array consisting the attachment file paths and mime types. Optional.
public type MessageRequest record {
    string recipient = "";
    string subject = "";
    string messageBody = "";
    string contentType = "";
    string sender = "";
    string cc = "";
    string bcc = "";
    InlineImagePath[] inlineImagePaths = [];
    AttachmentPath[] attachmentPaths = [];
};

# Represents image file path and mime type of an inline image in a message request.
#
# + imagePath - The file path of the image
# + mimeType - The mime type of the image. The primary type should be `image`.
#                  For ex: If you are sending a jpg image, give the mime type as `image/jpeg`.
#                          If you are sending a png image, give the mime type as `image/png`.
public type InlineImagePath record {
    string imagePath = "";
    string mimeType = "";
};

# Represents an attachment file path and mime type of an attachment in a message request.
#
# + attachmentPath - The file path of the attachment
# + mimeType - The mime type of the attachment
#                  For ex: If you are sending a pdf document, give the mime type as `application/pdf`.
#                  If you are sending a text file, give the mime type as `text/plain`.
public type AttachmentPath record {
    string attachmentPath = "";
    string mimeType = "";
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
#   standard RFC 2822 message. The key of the map is the header name and the value is the header value.
# + headerTo - Email header **To**
# + headerFrom - Email header **From**
# + headerBcc - Email header **Bcc**
# + headerCc - Email header **Cc**
# + headerSubject - Email header **Subject**
# + headerDate - Email header **Date**
# + headerContentType - Email header **ContentType**
# + mimeType - MIME type of the top level message part
# + plainTextBodyPart - MIME Message Part with text/plain content type
# + htmlBodyPart - MIME Message Part with text/html content type
# + inlineImgParts - MIME Message Parts with inline images with the image/* content type
# + msgAttachments - MIME Message Parts of the message consisting the attachments
public type Message record {
    string threadId = "";
    string id = "";
    string[] labelIds = [];
    string raw = "";
    string snippet = "";
    string historyId = "";
    string internalDate = "";
    string sizeEstimate = "";
    map<string> headers = {};
    string headerTo = "";
    string headerFrom = "";
    string headerBcc = "";
    string headerCc = "";
    string headerSubject = "";
    string headerDate = "";
    string headerContentType = "";
    string mimeType = "";
    MessageBodyPart plainTextBodyPart = {};
    MessageBodyPart htmlBodyPart = {};
    MessageBodyPart[] inlineImgParts = [];
    MessageBodyPart[] msgAttachments = [];
};

# Represents the email message body part of a message resource response.
#
# + body - The body data of the message part. This is a base64 encoded string
# + mimeType - MIME type of the message part
# + bodyHeaders - Headers of the MIME Message Part
# + fileId - The file id of the attachment/inline image in message part *(This is empty unless the message part
#            represent an inline image/attachment)*
# + fileName - The file name of the attachment/inline image in message part *(This is empty unless the message part
#            represent an inline image/attachment)*
# + partId - The part id of the message part
# + size - Number of bytes of message part data
public type MessageBodyPart record {
    string body = "";
    string mimeType = "";
    map<string> bodyHeaders = {};
    string fileId = "";
    string fileName = "";
    string partId = "";
    string size = "";
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
public type MsgSearchFilter record {
    boolean includeSpamTrash = false;
    string[] labelIds = [];
    string maxResults = "";
    string pageToken = "";
    string q = "";
};

# Represents the optional search drafts filter fields.
#
# + includeSpamTrash - Specifies whether to include drafts from SPAM and TRASH in the results
# + maxResults - Maximum number of drafts to return in the page for a single request
# + pageToken - Page token to retrieve a specific page of results in the list
# + q - Query for searching . Only returns drafts matching the specified query. Supports
#       the same query format as the Gmail search box.
public type DraftSearchFilter record {
    boolean includeSpamTrash = false;
    string maxResults = "";
    string pageToken = "";
    string q = "";
};

# Represents a page of the message list received as response for list messages api call.
#
# + messages - Array of message maps with messageId and threadId as keys
# + resultSizeEstimate - Estimated size of the whole list
# + nextPageToken - Token for next page of message list
public type MessageListPage record {
    json[] messages = [];
    string resultSizeEstimate = "";
    string nextPageToken = "";
};

# Represents a page of the mail thread list received as response for list threads api call.
#
# + threads - Array of thread maps with threadId, snippet and historyId as keys
# + resultSizeEstimate - Estimated size of the whole list
# + nextPageToken - Token for next page of mail thread list
public type ThreadListPage record {
    json[] threads = [];
    string resultSizeEstimate = "";
    string nextPageToken = "";
};

# Represents a page of the drafts list received as response for list drafts api call.
#
# + drafts - Array of draft maps with draftId, messageId and threadId as keys
# + resultSizeEstimate - Estimated size of the whole list
# + nextPageToken - Token for next page of mail drafts list
public type DraftListPage record {
    json[] drafts = [];
    string resultSizeEstimate = "";
    string nextPageToken = "";
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
# + ownerType - The owner type for the label.
#               Acceptable values are:
#                    *system*: Labels created by Gmail
#                    *user*: Custom labels created by the user or application
#
# + messagesTotal - The total number of messages with the label
# + messagesUnread - The number of unread messages with the label
# + threadsTotal - The total number of threads with the label
# + threadsUnread - The number of unread threads with the label
# + textColor - The text color of the label, represented as hex string
# + backgroundColor - The background color represented as hex string
public type Label record {
    string id = "";
    string name = "";
    string messageListVisibility = "";
    string labelListVisibility = "";
    string ownerType = "";
    int messagesTotal = 0;
    int messagesUnread = 0;
    int threadsTotal = 0;
    int threadsUnread = 0;
    string textColor = "";
    string backgroundColor = "";
};

# Represents a page of the history list received as response for list history api call.
#
# + historyRecords - List of history records. Any messages contained in the response will typically only have id and
#                    threadId fields populated.
# + nextPageToken - Page token to retrieve the next page of results in the list
# + historyId - The ID of the mailbox's current history record
public type MailboxHistoryPage record {
    History[] historyRecords = [];
    string nextPageToken = "";
    string historyId = "";
};

# Represents a history reoced in MailboxHistoryPage.
#
# + id - The mailbox sequence ID
# + messages - List of messages changed in this history record
# + messagesAdded - 	Messages added to the mailbox in this history record
# + messagesDeleted - Messages deleted (not Trashed) from the mailbox in this history record
# + labelsAdded - Array of maps of Labels added to messages in this history record
# + labelsRemoved - Array of maps of Labels removed from messages in this history record
public type History record {
    string id = "";
    Message[] messages = [];
    Message[] messagesAdded = [];
    Message[] messagesDeleted = [];
    Message[] labelsAdded = [];
    Message[] labelsRemoved = [];
};

# Represents a draft email in user's mailbox.
#
# + id - The immutable id of the draft
# + message - The message content of the draft
public type Draft record {
    string id = "";
    Message message = {};
};
