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

import ballerina/io;
import ballerina/util;

documentation{
    Converts the json message array into Message type array

    P{{sourceMessageArrayJsonObject}} - Json message array object
    R{{}} - Message type array
    R{{}} - GMailError if coversion is not successful.
}
function convertToMessageArray(json sourceMessageArrayJsonObject) returns Message[]|GMailError {
    Message[] messages = [];
    int i = 0;
    foreach jsonMessage in sourceMessageArrayJsonObject {
        match (convertJsonMailToMessage(jsonMessage)){
            Message msg => {
                messages[i] = msg;
                i++;
            }
            GMailError gmailError => return gmailError;
        }
    }
    return messages;
}

documentation{
    Decodes the message body of text/* mime message parts.

    P{{sourceMessagePartJsonObject}} - Json message part object
    R{{}} - String base 64 decoded message body.
    R{{}} - GMailError if error occurs in base64 encoding.
}
function decodeMsgBodyData(json sourceMessagePartJsonObject) returns string|GMailError {
    string decodedBody;
    string jsonMessagePartMimeType = sourceMessagePartJsonObject.mimeType.toString() but { () => EMPTY_STRING };
    if (isMimeType(jsonMessagePartMimeType, TEXT_ANY)) {
        string sourceMessagePartBody = sourceMessagePartJsonObject.body.data.toString() but { () => EMPTY_STRING };
        decodedBody = sourceMessagePartBody.replace("-", "+").replace("_", "/").replace("*", "=");
        match (util:base64DecodeString(decodedBody)){
            string decodeString => decodedBody = decodeString;
            util:Base64DecodeError err => {
                GMailError gMailError = {};
                gMailError.errorMessage = "Error occured while base64 decoding text/* message body";
                gMailError.cause = err;
                return gMailError;
            }
        }
    }
    return decodedBody;
}

documentation{
    Gets only the attachment MIME messageParts from the json message payload of the email.

    P{{messagePayload}} - Json message payload which is the parent message part of the email.
    P{{msgAttachments}} - Initial array of attachment message parts.
    R{{}} -  An array of MessageAttachments.
}
function getAttachmentPartsFromPayload(json messagePayload, MessageAttachment[] msgAttachments)
                                                                                returns @tainted MessageAttachment[] {
    MessageAttachment[] attachmentParts = msgAttachments;
    string disposition = "";
    if (messagePayload.headers != ()){
        MessagePartHeader contentDispositionHeader =
        getMsgPartHeaderContentDisposition(convertToMsgPartHeaders(messagePayload.headers));
        string[] headerParts = contentDispositionHeader.value.split(";");
        disposition = headerParts[0];
    }
    string messagePayloadMimeType = messagePayload.mimeType.toString() but { () => EMPTY_STRING };
    //If parent mime part is an attachment
    if (disposition == ATTACHMENT) {
        attachmentParts[lengthof attachmentParts] = convertJsonMsgPartToMsgAttachment(messagePayload);
    } //Else if is any multipart/*
    else if (isMimeType(messagePayloadMimeType, MULTIPART_ANY) && (messagePayload.parts != ())) {
        json messageParts = messagePayload.parts;
        if (lengthof messageParts != 0) {
            //Iterate each child parts of the parent mime part
            foreach part in messageParts {
                //Recursively check each ith child mime part
                attachmentParts = getAttachmentPartsFromPayload(part, attachmentParts);
            }
        }

    }
    return attachmentParts;
}

documentation{
    Gets only the inline image MIME messageParts from the json message payload of the email.

    P{{messagePayload}} - Json message payload which is the parent message part of the email.
    P{{inlineMailImages}} - Initial array of inline image message parts.
    R{{}} - An array of MessageBodyParts.
    R{{}} - GMailError if unsuccessful.
}
//Extract inline image MIME message parts from the email
function getInlineImgPartsFromPayloadByMimeType(json messagePayload, MessageBodyPart[] inlineMailImages)
                                                                        returns @tainted MessageBodyPart[]|GMailError {
    MessageBodyPart[] inlineImgParts = inlineMailImages;
    string disposition = "";
    if (messagePayload.headers != ()){
        MessagePartHeader contentDispositionHeader =
        getMsgPartHeaderContentDisposition(convertToMsgPartHeaders(messagePayload.headers));
        string[] headerParts = contentDispositionHeader.value.split(";");
        disposition = headerParts[0];
    }
    string messagePayloadMimeType = messagePayload.mimeType.toString() but { () => EMPTY_STRING };
    //If parent mime part is image/* and it is inline
    if (isMimeType(messagePayloadMimeType, IMAGE_ANY) && (disposition == INLINE)) {
        match convertJsonMsgBodyPartToMsgBodyType(messagePayload){
            MessageBodyPart bodyPart => inlineImgParts[lengthof inlineImgParts] = bodyPart;
            GMailError gmailError => return gmailError;
        }
    } //Else if is any multipart/*
    else if (isMimeType(messagePayloadMimeType, MULTIPART_ANY) && (messagePayload.parts != ())) {
        json messageParts = messagePayload.parts;
        if (lengthof messageParts != 0) {
            //Iterate each child parts of the parent mime part
            foreach part in messageParts {
                //Recursively check each ith child mime part
                match getInlineImgPartsFromPayloadByMimeType(part, inlineImgParts){
                    MessageBodyPart[] bodyParts => inlineImgParts = bodyParts;
                    GMailError gmailError => return gmailError;
                }
            }
        }
    }
    return inlineImgParts;
}

documentation{
    Gets the body MIME messagePart with the specified content type (excluding attachments and inline images)
    from the json message payload of the email.
    *Can be used only if there is only one message part with the given mime type in the email payload,
    otherwise, it will return with first found matching message part.*

    P{{messagePayload}} - Json message payload which is the parent message part of the email.
    P{{mimeType}} - Initial array of inline image message parts.
    R{{}} -  MessageBodyPart
    R{{}} - GMailError if unsuccessful.
}
function getMessageBodyPartFromPayloadByMimeType(json messagePayload, string mimeType)
                                                                        returns @tainted MessageBodyPart|GMailError {
    MessageBodyPart msgBodyPart = new();
    string disposition = "";
    if (messagePayload.headers != ()){
        MessagePartHeader contentDispositionHeader =
        getMsgPartHeaderContentDisposition(convertToMsgPartHeaders(messagePayload.headers));
        string[] headerParts = contentDispositionHeader.value.split(";");
        disposition = headerParts[0];
    }
    string messageBodyPayloadMimeType = messagePayload.mimeType.toString() but { () => EMPTY_STRING };
    //If parent mime part is given mime type and not an attachment or an inline part
    if (isMimeType(messageBodyPayloadMimeType, mimeType) && (disposition != ATTACHMENT) && (disposition != INLINE)) {
        match convertJsonMsgBodyPartToMsgBodyType(messagePayload){
            MessageBodyPart body => msgBodyPart = body;
            GMailError gmailError => return gmailError;
        }
    } //Else if is any multipart/*
    else if (isMimeType(messageBodyPayloadMimeType, MULTIPART_ANY) && (messagePayload.parts != ())) {
        json messageParts = messagePayload.parts;
        if (lengthof messageParts != 0) {
            //Iterate each child parts of the parent mime part
            foreach part in messageParts {
                //Recursively check each ith child mime part
                match getMessageBodyPartFromPayloadByMimeType(part, mimeType){
                    MessageBodyPart body => msgBodyPart = body;
                    GMailError gmailError => return gmailError;
                }
                //If the returned msg body is a match for given mime type stop iterating over the other child parts
                if (msgBodyPart.mimeType != "" && isMimeType(msgBodyPart.mimeType, mimeType)) {
                    break;
                }
            }
        }
    }
    return msgBodyPart;
}

documentation {
    Gets the message header Content-Disposition from the message part header array.

    P{{headers}} - An array of MessagePart headers
    R{{}} - **Content-Disposition** header
}
function getMsgPartHeaderContentDisposition(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerContentDisposition = {};
    foreach header in headers {
        if (header.name == CONTENT_DISPOSITION) {
            headerContentDisposition = header;
        }
    }
    return headerContentDisposition;
}

documentation{
    Gets the message header **To** from the message part header array.

    P{{headers}} - An array of MessagePart headers
    R{{}} - **To** header
}
function getMsgPartHeaderTo(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerTo = {};
    foreach header in headers {
        if (header.name == TO) {
            headerTo = header;
        }
    }
    return headerTo;
}

documentation{
    Gets the message header **From** from the message part header array.

    P{{headers}} - An array of MessagePart headers
    R{{}} - **From** header
}
function getMsgPartHeaderFrom(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerFrom = {};
    foreach header in headers {
        if (header.name == FROM) {
            headerFrom = header;
        }
    }
    return headerFrom;
}

documentation{
    Gets the message header Cc from the message part header array.

    P{{headers}} - An array of MessagePart headers
    R{{}} - **Cc** header
}
function getMsgPartHeaderCc(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerCc = {};
    foreach header in headers {
        if (header.name == CC) {
            headerCc = header;
        }
    }
    return headerCc;
}

documentation{
    Gets the message header Bcc from the message part header array.

    P{{headers}} - An array of MessagePart headers
    R{{}} - **Bcc** header
}
function getMsgPartHeaderBcc(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerBcc = {};
    foreach header in headers {
        if (header.name == BCC) {
            headerBcc = header;
        }
    }
    return headerBcc;
}

documentation{
    Gets the message header Subject from the message part header array.

    P{{headers}} - An array of MessagePart headers
    R{{}} - **Subject** header
}
function getMsgPartHeaderSubject(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerSubject = {};
    foreach header in headers {
        if (header.name == SUBJECT) {
            headerSubject = header;
        }
    }
    return headerSubject;
}

documentation{
    Gets the message header Date from the message part header array.

    P{{headers}} - An array of MessagePart headers
    R{{}} - **Date** header
}
function getMsgPartHeaderDate(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerDate = {};
    foreach header in headers {
        if (header.name == DATE) {
            headerDate = header;
        }
    }
    return headerDate;
}

documentation{
    Gets the message header ContentType from the message part header array.

    P{{headers}} - An array of MessagePart headers
    R{{}} - **ContentType** header
}
function getMsgPartHeaderContentType(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerContentType = {};
    foreach header in headers {
        if (header.name == CONTENT_TYPE) {
            headerContentType = header;
        }
    }
    return headerContentType;
}

documentation{
    Converts the message part header json array to MessagePartHeader array.

    P{{jsonMsgPartHeaders}} - Json array of message part headers
    R{{}} - MessagePartHeader array
}
function convertToMsgPartHeaders(json jsonMsgPartHeaders) returns MessagePartHeader[] {
    MessagePartHeader[] msgPartHeaders = [];
    int i = 0;
    foreach jsonHeader in jsonMsgPartHeaders {
        msgPartHeaders[i] = convertJsonToMesagePartHeader(jsonHeader);
        i++;
    }
    return msgPartHeaders;
}

documentation{
    Converts json string array to string array.

    P{{sourceJsonObject}} - Json array
    R{{}} - String array
}
function convertJSONArrayToStringArray(json sourceJsonObject) returns string[] {
    string[] targetStringArray = [];
    int i = 0;
    foreach element in sourceJsonObject {
        targetStringArray[i] = element.toString() but { () => EMPTY_STRING };
        i++;
    }
    return targetStringArray;
}

documentation{
    Checks whether mime type in the message part is same as the given the mime type. Returns true if both types
    matches, returns false if not.

    P{{msgMimeType}} - The mime type of the message part you want check
    P{{mType}} - The given mime type which you wants check against with
    R{{}} - Boolean status of mime type match
}
function isMimeType(string msgMimeType, string mType) returns boolean {
    string[] msgTypes = msgMimeType.split("/");
    string msgPrimaryType = msgTypes[0];
    string msgSecondaryType = msgTypes[1];

    string[] requestmTypes = mType.split("/");
    string reqPrimaryType = requestmTypes[0];
    string reqSecondaryType = requestmTypes[1];

    if (!msgPrimaryType.equalsIgnoreCase(reqPrimaryType)) {
        return false;
    } else if ((reqSecondaryType.subString(0, 1) != "*") && (msgSecondaryType.subString(0, 1) != "*")) {
        return msgSecondaryType.equalsIgnoreCase(reqSecondaryType);
    } else {
        return true;
    }
}

documentation{
    Opens a file from file path and returns the as base 64 encoded string.

    P{{filePath}} - File path
    R{{encodedFile}} - Encoded file
    R{{}} - GMailError if fails to open and encode.
}
function encodeFile(string filePath) returns (string|GMailError) {
    io:ByteChannel fileChannel = getFileChannel(filePath, "r");
    int bytesChunk = BYTES_CHUNK;
    blob readEncodedContent;
    int readEncodedCount;
    string encodedFile;
    match util:base64EncodeByteChannel(fileChannel){
        io:ByteChannel encodedfileChannel => {
            match readBytes(encodedfileChannel, bytesChunk) {
                (blob, int) readEncodedChannel => (readEncodedContent, readEncodedCount) = readEncodedChannel;
                GMailError gmailError => return gmailError;
            }
        }
        util:Base64EncodeError err => {
            GMailError gMailError = {};
            gMailError.errorMessage = "Error occured while base64 encoding byte channel";
            gMailError.cause = err.cause;
            return gMailError;
        }
    }
    encodedFile = readEncodedContent.toString(UTF_8);
    return encodedFile;
}

documentation{
    Gets the file name from the given file path.

    P{{filePath}} - File path **(including the file name and extension at the end)**
    R{{}} -  The file name extracted from the file path.
}
function getFileNameFromPath(string filePath) returns string {
    string[] pathParts = filePath.split("/");
    return pathParts[lengthof pathParts - 1];
}

documentation{
    Opens the file and returns the byte channel.

    P{{filePath}} - File path
    P{{permission}} - Permission to open the file with, for example for read permission give as *r*
    R{{}} - The byte channel of the file
}
function getFileChannel(string filePath, string permission) returns (io:ByteChannel) {
    io:ByteChannel channel = io:openFile(filePath, permission);
    return channel;
}

documentation{
    Gets the blob content from the byte channel.

    P{{channel}} - ByteChannel of the file
    P{{numberOfBytes}} - Number of bytes which should be read
    R{{}} - The bytes which were read
    R{{}} - Number of bytes read
    R{{}} - GMailError if fails to read blob content.
}
function readBytes(io:ByteChannel channel, int numberOfBytes) returns (blob, int)|GMailError {
    blob bytes;
    int numberOfBytesRead;
    match channel.read(numberOfBytes) {
        (blob, int) readChannel => (bytes, numberOfBytesRead) = readChannel;
        io:IOError e => {
            GMailError gMailError = {};
            gMailError.cause = e.cause;
            gMailError.errorMessage = "Error occured while reading byte channel";
            return gMailError;
        }
    }
    return (bytes, numberOfBytesRead);
}
