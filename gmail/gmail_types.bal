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
    public function createTextMessage (string recipient, string subject, string bodyText, MessageOptions options) {
        //Set email Headers
        self.setMailHeaders(recipient, subject, options);
        //Set the plain text type MIME Message body part of the message
        self.plainTextBodyPart.setMessageBody(bodyText, TEXT_PLAIN);
        self.plainTextBodyPart.bodyHeaders = [{name:CONTENT_TYPE, value:TEXT_PLAIN + ";" + CHARSET + "=\"" + UTF_8 +
                                                                                                                "\""}];
        self.plainTextBodyPart.mimeType = TEXT_PLAIN;
    }

    documentation {
        Creates a html email message

        P{{recipient}} - Email recipient's email addresss
        P{{subject}} - Email subject
        P{{bodyText}} - Email text body
        P{{options}} - MessageOptions with optional email headers (Sender,Cc,Bcc)
        P{{images}} - InlineImage arrya with inline images
        R{{gMailError}} - Returns GMailError if html message creation is unsuccessful
    }
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
                    GMailError gMailError => return gMailError;
                }
            }
        }
        return ();
    }

    documentation{
        Sets the common email headers in the message

        P{{recipient}} - Email recipient's email addresss
        P{{subject}} - Email subject
        P{{options}} - MessageOptions with optional email headers (Sender,Cc,Bcc)
    }
    function setMailHeaders (string recipient, string subject, MessageOptions options) {
        //Set the general header To of top level message part
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
    }

    documentation {
        Sets the inline image content of the message.
        *Note: Inline images can only be set in html body messages. Put the image into the html body by using <img> tag.
        Give the src value of img element as cid:image-<Your image name with extension>'
                                    Eg: <img src="cid:image-ImageName.jpg">*
        P{{imagePath}} - The inline image file path
        P{{contentType}} - The image content type
        R{{gMailError}} - Returns GMailError if the content type is not supported
    }
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

    documentation {
        Adds an attachment to the message.

        P{{filePath}} - The file path of the attachment
        P{{contentType}} - The content type of the attachment
        R{{gmailError}} - Returns GMailError if the attaching unsuccessful
    }
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
@Description {value:"Type to define the MIME Message Body Part"}
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
    error? cause;
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
public type MessageThreadFilter {
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
