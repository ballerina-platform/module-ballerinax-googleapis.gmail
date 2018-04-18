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
public type Message object {
    public {
        @readonly string threadId;
        @readonly string id;
        @readonly string[] labelIds;
        @readonly string raw;
        @readonly string snippet;
        @readonly string historyId;
        @readonly string internalDate;
        @readonly string sizeEstimate;
        MessagePartHeader[] headers;
        MessagePartHeader headerTo;
        MessagePartHeader headerFrom;
        MessagePartHeader headerBcc;
        MessagePartHeader headerCc;
        MessagePartHeader headerSubject;
        MessagePartHeader headerDate;
        MessagePartHeader headerContentType;
        string mimeType;
        MessageBodyPart plainTextBodyPart;
        MessageBodyPart htmlBodyPart;
        MessageBodyPart[] inlineImgParts;
        MessageAttachment[] msgAttachments;
    }

    documentation {
        Creates a text email message

        P{{recipient}} - Email recipient's email addresss
        P{{subject}} - Email subject
        P{{bodyText}} - Email text body
        P{{options}} - MessageOptions with optional email headers (Sender,Cc,Bcc)
    }
    public function createTextMessage (string recipient, string subject, string bodyText, MessageOptions options);

    documentation {
        Creates a html email message

        P{{recipient}} - Email recipient's email addresss
        P{{subject}} - Email subject
        P{{bodyText}} - Email text body
        P{{options}} - MessageOptions with optional email headers (Sender,Cc,Bcc)
        P{{images}} - InlineImage arrya with inline images
        R{{}} - GMailError if html message creation is unsuccessful.
    }
    public function createHTMLMessage (string recipient, string subject, string bodyText, MessageOptions options,
                                                                        InlineImage[] images) returns ()|GMailError;

    documentation{
        Sets the common email headers in the message

        P{{recipient}} - Email recipient's email addresss
        P{{subject}} - Email subject
        P{{options}} - MessageOptions with optional email headers (Sender,Cc,Bcc)
    }
    function setMailHeaders (string recipient, string subject, MessageOptions options);

    documentation {
        Sets the inline image content of the message.
        *Note: Inline images can only be set in html body messages. Put the image into the html body by using <img> tag.
        Give the src value of img element as cid:image-<Your image name with extension>'
                                    Eg: <img src="cid:image-ImageName.jpg">*
        P{{imagePath}} - The inline image file path
        P{{contentType}} - The image content type
        R{{}} - GMailError if the content type is not supported.
    }
    function addInlineImage (string imagePath, string contentType) returns ()|GMailError;

    documentation {
        Adds an attachment to the message.

        P{{filePath}} - The file path of the attachment
        P{{contentType}} - The content type of the attachment
        R{{}} - GMailError if the attaching unsuccessful.
    }
    public function addAttachment (string filePath, string contentType) returns ()|GMailError;
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
public type MessageBodyPart object {
    public {
        string body;
        string mimeType;
        MessagePartHeader[] bodyHeaders;
        string fileId;
        string fileName;
        @readonly string partId;
        @readonly string size;
    }

    documentation{
        Sets the values of message body part of an email
        P{{body}} - Body of the message part
        P{{mimeType}} - The mime type of the message part
    }
    function setMessageBody (string body, string mimeType);
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
public type MessageAttachment object {
    public {
        string attachmentFileId;
        string attachmentBody;
        string size;
        string attachmentFileName;
        string mimeType;
        MessagePartHeader[] attachmentHeaders;
        @readonly string partId;
    }

    documentation{
        Sets the values of an attachment part of an email.

        P{{encodedAttachment}} - Body of the attachment
        P{{mimeType}} -  The mime type of the attachment
    }
    function setAttachment (string encodedAttachment, string mimeType);
};

documentation{
    Represents message part header

    F{{name}} - Header name
    F{{value}} - Header value
}
public type MessagePartHeader {
    string name;
    string value;
};

documentation{
    Represents GMail error

    F{{message}} - GMail error message
    F{{cause}} - The error which caused the GMail error
    F{{statusCode}} - The error status code
}
public type GMailError {
    string message;
    error? cause;
    int statusCode;
};

documentation{
    Represents the optional parameters which are used to create a mail.

    F{{sender}} - Sender of the mail
    F{{cc}} - Cc recipient of the mail
    F{{bcc}} - Bcc recipient of the mail
}
public type MessageOptions {
    string sender;
    string cc;
    string bcc;
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

    F{{format}} - Format of the get message/thread response.
                    *Acceptable values for format for a get message/thread request are:
                        * "full": Returns the full email message data with body content parsed in the payload field;
                                  the raw field is not used. (default)
                        * "metadata": Returns only email message ID, labels, and email headers.
                        * "minimal": Returns only email message ID and labels; does not return the email headers, body,
                                     or payload.
                        * "raw": Returns the full email message data with body content in the raw field as a base64url
                                 encoded string. (the payload field is not included in the response)*
    F{{metadataHeaders}} - The meta data headers array to include in the reponse when the format is given as *METADATA*.
}
public type MessageThreadFilter {
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
    Message[] messages;
    string resultSizeEstimate;
    string nextPageToken;
};

documentation{
    Represents a page of the mail thread list received as reponse for list threads api call

    F{{threads}} - Thread list in the page
    F{{resultSizeEstimate}} - Estimated size of the whole list
    F{{nextPageToken}} - Token for next page of mail thread list
}
public type ThreadListPage {
    Thread[] threads;
    string resultSizeEstimate;
    string nextPageToken;
};

documentation{
    Represents an inline image of an email.

    F{{imagePath}} - The file path of the image.
    F{{contentType}} - The content type of the image.
}
public type InlineImage {
    string imagePath;
    string contentType;
};

public function Message::createTextMessage (string recipient, string subject, string bodyText, MessageOptions options) {
    //Set email Headers
    self.setMailHeaders(recipient, subject, options);
    //Set the plain text type MIME Message body part of the message
    self.plainTextBodyPart.setMessageBody(bodyText, TEXT_PLAIN);
    self.plainTextBodyPart.bodyHeaders = [{name:CONTENT_TYPE, value:TEXT_PLAIN + SEMICOLON_SYMBOL + CHARSET
                                                       + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + UTF_8 + APOSTROPHE_SYMBOL}];
    self.plainTextBodyPart.mimeType = TEXT_PLAIN;
}

public function Message::createHTMLMessage (string recipient, string subject, string bodyText, MessageOptions options,
    InlineImage[] images) returns ()|GMailError {
    //Set email Headers
    self.setMailHeaders(recipient, subject, options);
    //Set the html body part of the message
    self.htmlBodyPart.mimeType = TEXT_HTML;
    self.htmlBodyPart.setMessageBody(bodyText, TEXT_HTML);
    self.htmlBodyPart.bodyHeaders = [{name:CONTENT_TYPE, value:TEXT_HTML + SEMICOLON_SYMBOL + CHARSET + EQUAL_SYMBOL
                                                                + APOSTROPHE_SYMBOL + UTF_8 + APOSTROPHE_SYMBOL}];
    if (lengthof images != 0){
        foreach image in images{
            match self.addInlineImage(image.imagePath, image.contentType){
                GMailError gMailError => return gMailError;
                () => {}
            }
        }
    }
    return ();
}

function Message::setMailHeaders (string recipient, string subject, MessageOptions options) {
    //Set the general header To of top level message part
    self.headerTo = {name:TO, value:recipient};
    //Include the seperate header to the existing header list
    self.headers[0] = self.headerTo;
    self.headerSubject = {name:SUBJECT, value:subject};
    self.headers[1] = self.headerSubject;
    if (options.sender != EMPTY_STRING) {
        self.headerFrom = {name:FROM, value:options.sender};
        self.headers[lengthof self.headers] = self.headerFrom;
    }
    if (options.cc != EMPTY_STRING) {
        self.headerCc = {name:CC, value:options.cc};
        self.headers[lengthof self.headers] = self.headerCc;
    }
    if (options.bcc != EMPTY_STRING) {
        self.headerBcc = {name:BCC, value:options.bcc};
        self.headers[lengthof self.headers] = self.headerBcc;
    }
    //Set the general content type header of top level MIME message part as multipart/mixed with the
    //boundary=boundaryString
    self.headerContentType = {name:CONTENT_TYPE, value:MULTIPART_MIXED + SEMICOLON_SYMBOL + BOUNDARY + EQUAL_SYMBOL
                                                        + APOSTROPHE_SYMBOL + BOUNDARY_STRING + APOSTROPHE_SYMBOL};
    self.headers[lengthof self.headers] = self.headerContentType;
    self.mimeType = MULTIPART_MIXED;
}

function Message::addInlineImage (string imagePath, string contentType) returns ()|GMailError {
    if (contentType == EMPTY_STRING){
        GMailError gMailError = {};
        gMailError.message = "image content type cannot be empty";
        return gMailError;
    }
    if (isMimeType(contentType, IMAGE_ANY)) {
        string encodedFile;
        //Open and encode the image file into base64. Return an IOError if fails.
        match encodeFile(imagePath) {
            string eFile => encodedFile = eFile;
            GMailError gMailError => return gMailError;
        }
        //Set the inline image body part of the message
        MessageBodyPart inlineImgBody = new;
        inlineImgBody.fileName = getFileNameFromPath(imagePath);
        MessagePartHeader contentTypeHeader = {name:CONTENT_TYPE, value:contentType + SEMICOLON_SYMBOL + WHITE_SPACE
                                                + NAME + EQUAL_SYMBOL + APOSTROPHE_SYMBOL
                                                + inlineImgBody.fileName + APOSTROPHE_SYMBOL};
        MessagePartHeader dispositionHeader = {name:CONTENT_DISPOSITION, value:INLINE + SEMICOLON_SYMBOL + WHITE_SPACE
                                                + FILE_NAME + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + inlineImgBody.fileName
                                                + APOSTROPHE_SYMBOL};
        MessagePartHeader transferEncodeHeader = {name:CONTENT_TRANSFER_ENCODING, value:BASE_64};
        MessagePartHeader contentIdHeader = {name:CONTENT_ID, value:LESS_THAN_SYMBOL + INLINE_IMAGE_CONTENT_ID_PREFIX +
                                                                        inlineImgBody.fileName + GREATER_THAN_SYMBOL};
        inlineImgBody.bodyHeaders = [contentTypeHeader, dispositionHeader, transferEncodeHeader, contentIdHeader];
        inlineImgBody.setMessageBody(encodedFile, contentType);
        inlineImgBody.mimeType = contentType;
        self.inlineImgParts[lengthof self.inlineImgParts] = inlineImgBody;
    } else {
        //Return an error if an un supported content type other than image/* is passed
        GMailError gMailError = {};
        gMailError.message = ERROR_CONTENT_TYPE_UNSUPPORTED;
        return gMailError;
    }
    return ();
}

public function Message::addAttachment (string filePath, string contentType) returns ()|GMailError {
    if (contentType == EMPTY_STRING){
        GMailError gMailError = {};
        gMailError.message = "content type of attachment cannot be empty";
        return gMailError;
    } else if (filePath == EMPTY_STRING){
        GMailError gMailError = {};
        gMailError.message = "file path of attachment cannot be empty";
        return gMailError;
    }
    string encodedFile;
    //Open and encode the file into base64. Return an IOError if fails.
    match encodeFile(filePath) {
        string eFile => encodedFile = eFile;
        GMailError gMailError => return gMailError;
    }
    MessageAttachment attachment = new;
    attachment.mimeType = contentType;
    attachment.attachmentFileName = getFileNameFromPath(filePath);
    MessagePartHeader contentTypeHeader = {name:CONTENT_TYPE, value:contentType + SEMICOLON_SYMBOL + WHITE_SPACE + NAME
                                            + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + attachment.attachmentFileName
                                            + APOSTROPHE_SYMBOL};
    MessagePartHeader dispositionHeader = {name:CONTENT_DISPOSITION, value:ATTACHMENT + SEMICOLON_SYMBOL + WHITE_SPACE
                                            + FILE_NAME + EQUAL_SYMBOL + APOSTROPHE_SYMBOL
                                            + attachment.attachmentFileName + APOSTROPHE_SYMBOL};
    MessagePartHeader transferEncodeHeader = {name:CONTENT_TRANSFER_ENCODING, value:BASE_64};
    attachment.attachmentHeaders = [contentTypeHeader, dispositionHeader, transferEncodeHeader];
    attachment.setAttachment(encodedFile, contentType);
    self.msgAttachments[lengthof self.msgAttachments] = attachment;
    return ();
}

function MessageBodyPart::setMessageBody (string body, string mimeType) {
    self.body = body;
    self.mimeType = mimeType;
}

function MessageAttachment::setAttachment (string encodedAttachment, string mimeType) {
    self.attachmentBody = encodedAttachment;
    self.mimeType = mimeType;
}
