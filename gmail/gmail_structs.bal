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

package gmail;

import ballerina/util;
import ballerina/io;

@Description {value:"Struct to define the UserProfile"}
public struct UserProfile {
    //The user's email address
    string emailAddress;
    //The total number of messages in the mailbox
    string messagesTotal;
    //The total number of threads in the mailbox
    string threadsTotal;
    //The ID of the mailbox's current history record
    string historyId;
}

@Description {value:"Struct to define the threads resource"}
public struct Thread {
    //The unique ID of the thread
    string id;
    //A short part of the message text
    string snippet;
    //The ID of the last history record that modified this thread
    string historyId;
    // 	The list of messages in the thread
    Message[] messages;
}

@Description {value:"Struct to define the message resource"}
public struct Message {
    //Thread ID which the message belongs to
    string threadId;
    //Message Id
    string id;
    //The label ids of the message
    string[] labelIds;
    //The headers in the top level message part representing the entire message payload in a  standard RFC 2822 message
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
    private:
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

@Description {value:"Struct to define the MIME Message Body Part"}
public struct MessageBodyPart {
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
    private:
    //Part id of the message part
        string partId;
}

@Description {value:"Struct to define the MIME Message Part which represents an attachment"}
public struct MessageAttachment {
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
    private:
    //Part Id of the message part
        string partId;
}

@Description {value:"Struct to define the message part header"}
public struct MessagePartHeader {
    string name;
    string value;
}

@Description {value:"Struct to define message error"}
public struct GmailError {
    string errorMessage;
    int statusCode;
}

@Description {value:"Struct to define the optional parameters which are used to create a mail."}
public struct MessageOptions {
    string sender;
    string cc;
    string bcc;
}

@Description {value:"Struct to define the optional search message filter fields"}
public struct SearchFilter {
    //Includes messages/threads from SPAM and TRASH in the results
    boolean includeSpamTrash;
    //Only return messages/threads with labels that match all of the specified label IDs
    string[] labelIds;
    //Maximum number of messages/threads to return in the page for a single request
    string maxResults;
    //Page token to retrieve a specific page of results in the list
    string pageToken;
    //Only returns messages/threads matching the specified query. Supports the same query format as the Gmail search box
    string q;
}

@Description {value:"Struct to define the optional get message filter fields"}
public struct GetMessageThreadFilter {
    //Acceptable values for format for a get message/thread request are:
    //"full": Returns the full email message data with body content parsed in the payload field;
    //       the raw field is not used. (default)
    //"metadata": Returns only email message ID, labels, and email headers.
    //"minimal": Returns only email message ID and labels; does not return the email headers, body, or payload.
    //"raw": Returns the full email message data with body content in the raw field as a base64url encoded string;
    //      the payload field is not used."}
    string format;
    //metaDataHeaders: when given and format is METADATA, only include the metadDataHeaders specified.
    string[] metadataHeaders;
}

@Description {value:"Struct to define a page of message list"}
public struct MessageListPage {
    Message[] messages;
    //Estimated size of the whole list
    string resultSizeEstimate;
    //Token for next page of message list
    string nextPageToken;
}

@Description {value:"Struct to define a page of thread list"}
public struct ThreadListPage {
    Thread[] threads;
    //Estimated size of the whole list
    string resultSizeEstimate;
    //Token for next page of thread list
    string nextPageToken;
}

//Functions binded to Message struct

@Description {value:"Create a message"}
@Param {value:"recipient:  email address of the receiver"}
@Param {value:"sender: email address of the sender, the mailbox account"}
@Param {value:"subject: subject of the email"}
@Param {value:"bodyText: body text of the email"}
@Param {value:"options: other optional headers of the email including Cc, Bcc and From"}
public function <Message message> createMessage (string recipient, string subject, string bodyText, MessageOptions options) {
    //set the general header To of top level message part
    message.headerTo = {name:TO, value:recipient};
    //Include the seperate header to the existing header list
    message.headers[0] = message.headerTo;
    message.headerSubject = {name:SUBJECT, value:subject};
    message.headers[1] = message.headerSubject;
    if (options.sender != "") {
        message.headerFrom = {name:FROM, value:options.sender};
        message.headers[lengthof message.headers] = message.headerFrom;
    }
    if (options.cc != "") {
        message.headerCc = {name:CC, value:options.cc};
        message.headers[lengthof message.headers] = message.headerCc;
    }
    if (options.bcc != "") {
        message.headerBcc = {name:BCC, value:options.bcc};
        message.headers[lengthof message.headers] = message.headerBcc;
    }
    //Set the general content type header of top level MIME message part as multipart/mixed with the
    //boundary=boundaryString
    message.headerContentType = {name:CONTENT_TYPE, value:MULTIPART_MIXED + ";" + BOUNDARY + "=\"" + BOUNDARY_STRING + "\""};
    message.headers[lengthof message.headers] = message.headerContentType;
    message.mimeType = MULTIPART_MIXED;
    message.isMultipart = true;
    //Set the plain text type MIME Message body part of the message
    message.plainTextBodyPart.setMessageBody(bodyText, TEXT_PLAIN);
    message.plainTextBodyPart.bodyHeaders = [{name:CONTENT_TYPE, value:TEXT_PLAIN + ";" + CHARSET + "=\"" + UTF_8 + "\""}];
    message.plainTextBodyPart.mimeType = TEXT_PLAIN;
}

@Description {value:"Set the html content or inline image content of the message. If you are sending an inline image,
set a html body in email and put the image into the body by using <img> tag.
Give the src value of img element as 'cid:image-<Your image name with extension>' Eg: <img src=\"cid:image-ImageName.jpg\""}
@Param {value:"content: the string html content or the string inline image file path"}
@Param {value:"contentType: the content type"}
@Return {value:"Returns true if the content is set successfully"}
@Return {value:"Returns IOError if there's any error while performaing I/O operation"}
@Return {value:"Returns GmailError if the content type is not supported"}
public function <Message message> setContent (string content, string contentType) returns (boolean|GmailError) {
    //If the mime type of the content is text/html
    if (isMimeType(contentType, TEXT_HTML)) {
        //Set the html body part of the message
        message.htmlBodyPart.mimeType = TEXT_HTML;
        message.htmlBodyPart.setMessageBody(content, contentType);
        message.htmlBodyPart.bodyHeaders = [{name:CONTENT_TYPE, value:TEXT_HTML + ";" + CHARSET + "=\"" + UTF_8 + "\""}];

    } else if (isMimeType(contentType, IMAGE_ANY)) {
        string encodedFile;
        //Open and encode the image file into base64. Return an IOError if fails.
        match encodeFile(content) {
            string eFile => encodedFile = eFile;
            io:IOError ioError => {GmailError gmailError = {};
                                   gmailError.errorMessage = ioError.message;
                                   return gmailError;
            }
        }
        //Set the inline image body part of the message
        MessageBodyPart inlineImgBody = {};
        inlineImgBody.fileName = getFileNameFromPath(content);
        MessagePartHeader contentTypeHeader = {name:CONTENT_TYPE, value:contentType + "; " + NAME + "=\"" + inlineImgBody.fileName + "\""};
        MessagePartHeader dispositionHeader = {name:CONTENT_DISPOSITION, value:INLINE + "; " + FILE_NAME + "=\"" + inlineImgBody.fileName + "\""};
        MessagePartHeader transferEncodeHeader = {name:CONTENT_TRANSFER_ENCODING, value:BASE_64};
        MessagePartHeader contentIdHeader = {name:CONTENT_ID, value:"<" + INLINE_IMAGE_CONTENT_ID_PREFIX + inlineImgBody.fileName + ">"};
        inlineImgBody.bodyHeaders = [contentTypeHeader, dispositionHeader, transferEncodeHeader, contentIdHeader];
        inlineImgBody.setMessageBody(encodedFile, contentType);
        inlineImgBody.mimeType = contentType;
        message.inlineImgParts[lengthof message.inlineImgParts] = inlineImgBody;
    } else {
        //Return an error if an un supported content type other than text/html or image/* is passed
        GmailError gmailError = {};
        gmailError.errorMessage = ERROR_CONTENT_TYPE_UNSUPPORTED;
        return gmailError;
    }
    return true;
}

@Description {value:"Add an attachment to the message"}
@Param {value:"filePath: the string file path of the attachment"}
@Param {value:"contentType: the content type of the attachment"}
@Return {value:"Returns true if the attachment process is success"}
@Return {value:"Returns IOError if there's any error while performaing I/O operation"}
public function <Message message> addAttachment (string filePath, string contentType) returns boolean|(io:IOError) {
    string encodedFile;
    //Open and encode the file into base64. Return an IOError if fails.
    match encodeFile(filePath) {
        string eFile => encodedFile = eFile;
        io:IOError ioError => return ioError;
    }
    MessageAttachment attachment = {};
    attachment.mimeType = contentType;
    attachment.attachmentFileName = getFileNameFromPath(filePath);
    MessagePartHeader contentTypeHeader = {name:CONTENT_TYPE, value:contentType + "; " + NAME + "=\"" + attachment.attachmentFileName + "\""};
    MessagePartHeader dispositionHeader = {name:CONTENT_DISPOSITION, value:ATTACHMENT + "; " + FILE_NAME + "=\"" + attachment.attachmentFileName + "\""};
    MessagePartHeader transferEncodeHeader = {name:CONTENT_TRANSFER_ENCODING, value:BASE_64};
    attachment.attachmentHeaders = [contentTypeHeader, dispositionHeader, transferEncodeHeader];
    attachment.setAttachment(encodedFile, contentType);
    message.msgAttachments[lengthof message.msgAttachments] = attachment;
    return true;
}

//Functions binded to MessageBodyPart struct

@Description {value:"set the values of message body part of an email "}
@Param {value:"body: body of the message part. This could be plain text, html content or encoded inline image"}
@Param {value:"mimeType: mime type of message part"}
function <MessageBodyPart messageBody> setMessageBody (string body, string mimeType) {
    messageBody.body = body;
    messageBody.mimeType = mimeType;
}

//Functions binded to MessageAttachment struct

@Description {value:"set the values of an attachment part of an email "}
@Param {value:"encodedAttachment: body of the attachment."}
@Param {value:"mimeType: mime type of the attachment"}
function <MessageAttachment attachment> setAttachment (string encodedAttachment, string mimeType) {
    attachment.attachmentBody = encodedAttachment;
    attachment.mimeType = mimeType;
}