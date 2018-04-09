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
import ballerina/mime;
import ballerina/util;

@Description {value:"Convert the json message array into Message type array"}
@Param {value:"sourceMessageArrayJsonObject: json message array"}
@Return {value:"Message type array"}
@Return {value:"Returns GMailError if coversion not successful"}
function convertToMessageArray(json sourceMessageArrayJsonObject) returns Message[]|GMailError {
    Message[] messages = [];
    int i = 0;
    foreach jsonMessage in sourceMessageArrayJsonObject {
        match (convertJsonMailToMessage(jsonMessage)){
            Message msg => {
                messages[i] = msg;
                i++;
            }
            GMailError err => return err;
        }
    }
    return messages;
}

@Description {value:"Decode the message body of text/* mime message parts"}
@Param {value:"sourceMessagePartJsonObject: json message part"}
@Return {value:"base 64 decoded message body string"}
@Return {value:"Returns GMailError if error occurs in base64 encoding"}
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
                gMailError.cause[0] = err;
                return gMailError;
            }
        }
    }
    return decodedBody;
}

@Description {value:"Get only the attachment MIME messageParts from the json message payload of th email"}
@Param {value:"messagePayload: parent json message payload in MIME Message"}
@Param {value:"msgAttachments: intial array of attachment message parts"}
@Return {value:"Returns array of MessageAttachment"}
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

@Description {value:"Get only inline MIME messageParts from the json message payload of the email"}
@Param {value:"messagePayload: parent json message payload in MIME Message"}
@Param {value:"inlineMailImages: intial array of inline image message parts"}
@Return {value:"Returns array of MessageBodyPart"}
@Return {value:"Returns GMailError if unsuccessful"}
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
            GMailError err => return err;
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
                    GMailError err => return err;
                }
            }
        }
    }
    return inlineImgParts;
}

@Description {value:"Get the body MIME messageParts(excluding attachments and inline images) from the json
message payload of the email.
Can be used only if there is only one message part with the given mime type in the email payload,
otherwise it will return with first found matching message part"}
@Param {value:"messagePayload: parent json message payload in MIME Message"}
@Param {value:"inlineMailImages: intial array of inline image message parts"}
@Return {value:"Returns array of MessageBodyPart"}
@Return {value:"Returns GMailError if unsuccessful"}
function getMessageBodyPartFromPayloadByMimeType(string mimeType, json messagePayload)
                                                                        returns @tainted MessageBodyPart|GMailError {
    MessageBodyPart msgBodyPart = new ();
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
            GMailError err => return err;
        }
    } //Else if is any multipart/*
    else if (isMimeType(messageBodyPayloadMimeType, MULTIPART_ANY) && (messagePayload.parts != ())) {
        json messageParts = messagePayload.parts;
        if (lengthof messageParts != 0) {
            //Iterate each child parts of the parent mime part
            foreach part in messageParts {
                //Recursively check each ith child mime part
                match getMessageBodyPartFromPayloadByMimeType(mimeType, part){
                    MessageBodyPart body => msgBodyPart = body;
                    GMailError err => return err;
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

@Description {value:"Get the message header Content-Disposition"}
@Param {value:"headers: array of MessagePart headers"}
@Return {value:"Returns message part header Content-Disposition"}
function getMsgPartHeaderContentDisposition(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerContentDisposition = {};
    foreach header in headers {
        if (header.name == CONTENT_DISPOSITION) {
            headerContentDisposition = header;
        }
    }
    return headerContentDisposition;
}

@Description {value:"Get the message header To"}
@Param {value:"headers: array of MessagePart headers"}
@Return {value:"Returns message part header To"}
function getMsgPartHeaderTo(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerTo = {};
    foreach header in headers {
        if (header.name == TO) {
            headerTo = header;
        }
    }
    return headerTo;
}

@Description {value:"Get the message header From"}
@Param {value:"headers: array of MessagePart headers"}
@Return {value:"Returns message part header From"}
function getMsgPartHeaderFrom(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerFrom = {};
    foreach header in headers {
        if (header.name == FROM) {
            headerFrom = header;
        }
    }
    return headerFrom;
}

@Description {value:"Get the message header Cc"}
@Param {value:"headers: array of MessagePart headers"}
@Return {value:"Returns message part header Cc"}
function getMsgPartHeaderCc(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerCc = {};
    foreach header in headers {
        if (header.name == CC) {
            headerCc = header;
        }
    }
    return headerCc;
}

@Description {value:"Get the message header Bcc"}
@Param {value:"headers: array of MessagePart headers"}
@Return {value:"Returns message part header Bcc"}
function getMsgPartHeaderBcc(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerBcc = {};
    foreach header in headers {
        if (header.name == BCC) {
            headerBcc = header;
        }
    }
    return headerBcc;
}

@Description {value:"Get the message header Subject"}
@Param {value:"headers: array of MessagePart headers"}
@Return {value:"Returns message part header Subject"}
function getMsgPartHeaderSubject(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerSubject = {};
    foreach header in headers {
        if (header.name == SUBJECT) {
            headerSubject = header;
        }
    }
    return headerSubject;
}

@Description {value:"Get the message header Date"}
@Param {value:"headers: array of MessagePart headers"}
@Return {value:"Returns message part header Date"}
function getMsgPartHeaderDate(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerDate = {};
    foreach header in headers {
        if (header.name == DATE) {
            headerDate = header;
        }
    }
    return headerDate;
}

@Description {value:"Get the message header ContentType"}
@Param {value:"headers: array of MessagePart headers"}
@Return {value:"Returns message part header ContetnType"}
function getMsgPartHeaderContentType(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerContentType = {};
    foreach header in headers {
        if (header.name == CONTENT_TYPE) {
            headerContentType = header;
        }
    }
    return headerContentType;
}

@Description {value:"Convert the message part header json array to MessagePartHeader type array"}
@Param {value:"jsonMsgPartHeaders: json array of message part headers"}
@Return {value:"Returns MessagePartHeader type array"}
function convertToMsgPartHeaders(json jsonMsgPartHeaders) returns MessagePartHeader[] {
    MessagePartHeader[] msgPartHeaders = [];
    int i = 0;
    foreach jsonHeader in jsonMsgPartHeaders {
        msgPartHeaders[i] = convertJsonToMesagePartHeader(jsonHeader);
        i++;
    }

    return msgPartHeaders;
}

@Description {value:"Convert json array to string array"}
@Param {value:"sourceJsonObject: json array"}
@Return {value:"Return string array"}
function convertJSONArrayToStringArray(json sourceJsonObject) returns string[] {
    string[] targetStringArray = [];
    int i = 0;
    foreach element in sourceJsonObject {
        targetStringArray[i] = element.toString() but { () => EMPTY_STRING };
        i++;
    }
    return targetStringArray;
}

@Description {value:"Check whether mime type in the message part is same as the given the mime type"}
@Param {value:"msgMimeType: mime type of the message part"}
@Param {value:"mType: given mime type which you wants check against with"}
@Return {value:"Returns true or false whether mime types match"}
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

@Description {value:"Encode a file into base 64 using MimeBase64Encoder"}
@Param {value:"filePath: string file path"}
@Return {value:"Returns the encoded string"}
@Return {value:"Returns IOError if there's any error while performaing I/O operation"}
@Return {value:"Returns Base64EncodeError if fails to encode"}
function encodeFile(string filePath) returns (string|GMailError) {
    io:ByteChannel fileChannel = getFileChannel(filePath, "r");
    int bytesChunk = BYTES_CHUNK;
    blob readContent;
    int readCount;
    string encodedFile;
    match readBytes(fileChannel, bytesChunk) {
        (blob, int)readChannel => (readContent, readCount) = readChannel;
        GMailError err => return err;
    }
    match mime:base64EncodeBlob(readContent) {
        blob blobEncode => encodedFile = blobEncode.toString(UTF_8);
        mime:Base64EncodeError err => {
            GMailError gMailError = {};
            gMailError.errorMessage = "Error occured while base64 encoding blob";
            gMailError.cause = err.cause;
            return gMailError;
        }
    }
    return encodedFile;
}

@Description {value:"Get the file name from the given file path"}
@Param {value:"filePath: string file path (including the file name and extension at the end)"}
@Return {value:"string file name extracted from the file path"}
function getFileNameFromPath(string filePath) returns string {
    string[] pathParts = filePath.split("/");
    return pathParts[lengthof pathParts - 1];
}

@Description {value:"Open the file and return the byte channel"}
@Param {value:"filePath: string file path"}
@Param {value:"permission: string permission to open the file with, for example for read permission give as: r"}
@Return {value:"Return byte channel of the file"}
function getFileChannel(string filePath, string permission) returns (io:ByteChannel) {
    io:ByteChannel channel = io:openFile(filePath, permission);
    return channel;
}

@Description {value:"Get the blob content from the byte channel"}
@Param {value:"channel: ByteChannel of the file"}
@Param {value:"num: Number of bytes which should be read"}
@Return {value:"The bytes which were read"}
@Return {value:"Number of bytes read"}
@Return {value:"Returns IOError if there's any error while performaing I/O operation"}
function readBytes(io:ByteChannel channel, int numberOfBytes) returns (blob, int)|GMailError {
    blob bytes;
    int numberOfBytesRead;
    match channel.read(numberOfBytes) {
        (blob, int)readChannel => (bytes, numberOfBytesRead) = readChannel;
        io:IOError e => {
            GMailError gMailError = {};
            gMailError.cause = e.cause;
            gMailError.errorMessage = "Error occured while reading byte channel";
            return gMailError;
        }
    }
    return (bytes, numberOfBytesRead);
}
