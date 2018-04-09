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

@Description {value:"Record to define the UserProfile"}
public type UserProfile {
    //The user's email address
    string emailAddress;
    //The total number of messages in the mailbox
    string messagesTotal;
    //The total number of threads in the mailbox
    string threadsTotal;
    //The ID of the mailbox's current history record
    string historyId;
};

@Description {value:"Record to define the threads resource"}
public type Thread {
    //The unique ID of the thread
    string id;
    //A short part of the message text
    string snippet;
    //The ID of the last history record that modified this thread
    string historyId;
    //The list of messages in the thread
    Message[] messages;
};

@Description {value:"Record to define the message resource"}
public type Message object {
    public {
        //Thread ID which the message belongs to
        string threadId;
        //Message Id
        string id;
        //The label ids of the message
        string[] labelIds;
        //The headers in the top level message part representing the entire message payload in a  standard RFC 2822
        //message
        MessagePartHeader[] headers;
        //Following are the set of general headers taken from above header list
        MessagePartHeader headerTo;
        MessagePartHeader headerFrom;
        MessagePartHeader headerBcc;
        MessagePartHeader headerCc;
        MessagePartHeader headerSubject;
        MessagePartHeader headerDate;
        MessagePartHeader headerContentType;
        //MIME type of the top level message part.
        string mimeType;
        //MIME Message Part with the content type as text/plain
        MessageBodyPart plainTextBodyPart;
        //MIME Message Part with the content type as text/html
        MessageBodyPart htmlBodyPart;
        //MIME Message Part for the inline images with the content type as image/*
        MessageBodyPart[] inlineImgParts;
        //MIME Message Parts of the message consisting the attachments
        MessageAttachment[] msgAttachments;
        //If the top level message part is multipart/*
        boolean isMultipart;
    }
    private {
        //Represent the entire message in base64 encoded string
        string raw;
        //Short part of the message text
        string snippet;
        //ID of the last history record that modified the message
        string historyId;
        //Internal message creation timestamp(epoch ms)
        string internalDate;
        //Estimated size of the message in bytes
        string sizeEstimate;
    }

    //Functions binded to Message type

    @Description{value:"Create a text email message"}
    @Param{value:"recipient: Email recipient's email addresss"}
    @Param{value:"subject: Email subject"}
    @Param{value:"bodyText: Email text body"}
    @Param{value:"options: MessageOptions with optional email headers as Sender,Cc,Bcc"}
    public function createTextMessage (string recipient, string subject, string bodyText, MessageOptions options) {
        //Set email Headers
        self.setMailHeaders(recipient, subject, options);
        //Set the plain text type MIME Message body part of the message
        self.plainTextBodyPart.setMessageBody(bodyText, TEXT_PLAIN);
        self.plainTextBodyPart.bodyHeaders = [{name:CONTENT_TYPE, value:TEXT_PLAIN + ";" + CHARSET + "=\"" + UTF_8 +
                                                                                                                "\""}];
        self.plainTextBodyPart.mimeType = TEXT_PLAIN;
    }

    @Description{value:"Create a html email message"}
    @Param{value:"recipient: Email recipient's email addresss"}
    @Param{value:"subject: Email subject"}
    @Param{value:"bodyText: Email text body"}
    @Param{value:"options: MessageOptions with optional email headers as Sender,Cc,Bcc"}
    @Param{value:"images: InlineImage array with inline images of html email"}
    @Return{value:"Returns GMailError if html error creation unsuccessful"}
    public function createHTMLMessage (string recipient, string subject, string bodyText, MessageOptions options,
                                                                        InlineImage[] images) returns ()|GMailError {
        //Set email Headers
        self.setMailHeaders(recipient, subject, options);
        //Set the html body part of the message
        self.htmlBodyPart.mimeType = TEXT_HTML;
        self.htmlBodyPart.setMessageBody(bodyText, TEXT_HTML);
        self.htmlBodyPart.bodyHeaders = [{name:CONTENT_TYPE, value:TEXT_HTML + ";" + CHARSET + "=\"" + UTF_8 + "\""}];
        if (lengthof images != 0){
            foreach image in images{
                match self.setInlineImage(image.imagePath, image.contentType){
                    GMailError err => return err;
                }
            }
        }
        return ();
    }

    @Description{value:"Set common email headers"}
    @Param{value:"recipient: Email recipient's email addresss"}
    @Param{value:"subject: Email subject"}
    @Param{value:"options: MessageOptions with optional email headers as Sender,Cc,Bcc"}
    function setMailHeaders (string recipient, string subject, MessageOptions options) {
        //set the general header To of top level message part
        self.headerTo = {name:TO, value:recipient};
        //Include the seperate header to the existing header list
        self.headers[0] = self.headerTo;
        self.headerSubject = {name:SUBJECT, value:subject};
        self.headers[1] = self.headerSubject;
        if (options.sender != "") {
            self.headerFrom = {name:FROM, value:options.sender};
            self.headers[lengthof self.headers] = self.headerFrom;
        }
        if (options.cc != "") {
            self.headerCc = {name:CC, value:options.cc};
            self.headers[lengthof self.headers] = self.headerCc;
        }
        if (options.bcc != "") {
            self.headerBcc = {name:BCC, value:options.bcc};
            self.headers[lengthof self.headers] = self.headerBcc;
        }
        //Set the general content type header of top level MIME message part as multipart/mixed with the
        //boundary=boundaryString
        self.headerContentType = {name:CONTENT_TYPE, value:MULTIPART_MIXED + ";" + BOUNDARY + "=\""
                                                                                            + BOUNDARY_STRING + "\""};
        self.headers[lengthof self.headers] = self.headerContentType;
        self.mimeType = MULTIPART_MIXED;
        self.isMultipart = true;
    }

    @Description {value:"Set the inline image content of the message. Put the image into the html body by using <img> tag.
    Give the src value of img element as cid:image-<Your image name with extension>'
    Eg: <img src=\"cid:image-ImageName.jpg\""}
    @Param {value:"imagePath: the string inline image file path"}
    @Param {value:"contentType: the content type"}
    @Return {value:"Returns GMailError if the content type is not supported"}
    public function setInlineImage (string imagePath, string contentType) returns ()|GMailError {
        if (contentType == EMPTY_STRING){
            GMailError gMailError = {};
            gMailError.errorMessage = "image content type cannot be empty";
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
            MessageBodyPart inlineImgBody = new ();
            inlineImgBody.fileName = getFileNameFromPath(imagePath);
            MessagePartHeader contentTypeHeader = {name:CONTENT_TYPE, value:contentType + "; " + NAME + "=\"" +
                                                                                    inlineImgBody.fileName + "\""};
            MessagePartHeader dispositionHeader = {name:CONTENT_DISPOSITION, value:INLINE + "; " + FILE_NAME
                                                                            + "=\"" + inlineImgBody.fileName + "\""};
            MessagePartHeader transferEncodeHeader = {name:CONTENT_TRANSFER_ENCODING, value:BASE_64};
            MessagePartHeader contentIdHeader = {name:CONTENT_ID, value:"<" + INLINE_IMAGE_CONTENT_ID_PREFIX +
                                                                                        inlineImgBody.fileName + ">"};
            inlineImgBody.bodyHeaders = [contentTypeHeader, dispositionHeader, transferEncodeHeader, contentIdHeader];
            inlineImgBody.setMessageBody(encodedFile, contentType);
            inlineImgBody.mimeType = contentType;
            self.inlineImgParts[lengthof self.inlineImgParts] = inlineImgBody;
        } else {
            //Return an error if an un supported content type other than image/* is passed
            GMailError gMailError = {};
            gMailError.errorMessage = ERROR_CONTENT_TYPE_UNSUPPORTED;
            return gMailError;
        }
        return ();
    }

    @Description {value:"Add an attachment to the message"}
    @Param {value:"filePath: the string file path of the attachment"}
    @Param {value:"contentType: the content type of the attachment"}
    @Return {value:"Returns GMailError if the attachment process is unsuccessful"}
    public function addAttachment (string filePath, string contentType) returns ()|GMailError {
        if (contentType == EMPTY_STRING){
            GMailError gMailError = {};
            gMailError.errorMessage = "content type of attachment cannot be empty";
            return gMailError;
        } else if (filePath == EMPTY_STRING){
            GMailError gMailError = {};
            gMailError.errorMessage = "file path of attachment cannot be empty";
            return gMailError;
        }
        string encodedFile;
        //Open and encode the file into base64. Return an IOError if fails.
        match encodeFile(filePath) {
            string eFile => encodedFile = eFile;
            GMailError gMailError => return gMailError;
        }
        MessageAttachment attachment = new ();
        attachment.mimeType = contentType;
        attachment.attachmentFileName = getFileNameFromPath(filePath);
        MessagePartHeader contentTypeHeader = {name:CONTENT_TYPE, value:contentType + "; " + NAME + "=\"" +
                                                                            attachment.attachmentFileName + "\""};
        MessagePartHeader dispositionHeader = {name:CONTENT_DISPOSITION, value:ATTACHMENT + "; " + FILE_NAME + "=\"" +
                                                                            attachment.attachmentFileName + "\""};
        MessagePartHeader transferEncodeHeader = {name:CONTENT_TRANSFER_ENCODING, value:BASE_64};
        attachment.attachmentHeaders = [contentTypeHeader, dispositionHeader, transferEncodeHeader];
        attachment.setAttachment(encodedFile, contentType);
        self.msgAttachments[lengthof self.msgAttachments] = attachment;
        return ();
    }
};

@Description {value:"Type to define the MIME Message Body Part"}
public type MessageBodyPart object {
    public {
        //The body data of a MIME message part. If not a text/*, this would be a base64 encoded string
        string body;
        //Number of bytes of message part data
        string size;
        //MIME type of the message part
        string mimeType;
        //Headers of the MIME Message Part
        MessagePartHeader[] bodyHeaders;
        //File ID of the attachment in message part (This is empty unless the message part represent an inline image)
        string fileId;
        //File name of the attachment in message part (This is empty unless the message part represent an inline image)
        string fileName;
    }
    private {
        //Part id of the message part
        string partId;
    }

    //Functions binded to MessageBodyPart type

    @Description {value:"set the values of message body part of an email "}
    @Param {value:"body: body of the message part. This could be plain text, html content or encoded inline image"}
    @Param {value:"mimeType: mime type of message part"}
    function setMessageBody (string body, string mimeType) {
        self.body = body;
        self.mimeType = mimeType;
    }
};

@Description {value:"Type to define the MIME Message Part which represents an attachment"}
public type MessageAttachment object {
    public {
        //File ID of the attachment in the message.
        string attachmentFileId;
        //Attachment body of the MIME Message Part encoded with base64
        //This is empty when the attachment body data is sent as a seperate attachment
        string attachmentBody;
        //Size of the attachment message part
        string size;
        //File name of the attachment in the message
        string attachmentFileName;
        //Mime Type of the MIME message part which represent the attachment
        string mimeType;
        //Headers of MIME Message Part representing the attachment
        MessagePartHeader[] attachmentHeaders;
    }
    private {
        //Part Id of the message part
        string partId;
    }

    //Functions binded to MessageAttachment type

    @Description {value:"set the values of an attachment part of an email "}
    @Param {value:"encodedAttachment: body of the attachment."}
    @Param {value:"mimeType: mime type of the attachment"}
    function setAttachment (string encodedAttachment, string mimeType) {
        self.attachmentBody = encodedAttachment;
        self.mimeType = mimeType;
    }
};

@Description {value:"Type to define the message part header"}
public type MessagePartHeader {
    string name;
    string value;
};

@Description {value:"Type to define message error"}
public type GMailError {
    string errorMessage;
    int statusCode;
    error[] cause;
};

@Description {value:"Type to define the optional parameters which are used to create a mail."}
public type MessageOptions {
    string sender;
    string cc;
    string bcc;
};

@Description {value:"Type to define the optional search message filter fields"}
public type SearchFilter {
    //Includes messages/threads from SPAM and TRASH in the results
    boolean includeSpamTrash;
    //Only return messages/threads with labels that match all of the specified label IDs
    string[] labelIds;
    //Maximum number of messages/threads to return in the page for a single request
    string maxResults;
    //Page token to retrieve a specific page of results in the list
    string pageToken;
    //Only returns messages/threads matching the specified query.
    //Supports the same query format as the GMail search box
    string q;
};

@Description {value:"Type to define the optional get message filter fields"}
public type GetMessageThreadFilter {
    //Acceptable values for format for a get message/thread request are:
    //"full": Returns the full email message data with body content parsed in the payload field;
    //the raw field is not used. (default)
    //"metadata": Returns only email message ID, labels, and email headers.
    //"minimal": Returns only email message ID and labels; does not return the email headers, body, or payload.
    //"raw": Returns the full email message data with body content in the raw field as a base64url encoded string;
    //the payload field is not used."}
    string format;
    //metaDataHeaders: when given and format is METADATA, only include the metadDataHeaders specified.
    string[] metadataHeaders;
};

@Description {value:"Type to define a page of message list"}
public type MessageListPage {
    Message[] messages;
    //Estimated size of the whole list
    string resultSizeEstimate;
    //Token for next page of message list
    string nextPageToken;
};

@Description {value:"Type to define a page of thread list"}
public type ThreadListPage {
    Thread[] threads;
    //Estimated size of the whole list
    string resultSizeEstimate;
    //Token for next page of thread list
    string nextPageToken;
};

@Description {value:"Type to define inline image of an email"}
public type InlineImage {
    string imagePath;
    string contentType;
};
