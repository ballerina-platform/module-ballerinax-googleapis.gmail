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
import ballerina/http;

documentation{Converts the json message array into Message type array.

    P{{sourceMessageArrayJsonObject}} - Json message array object
    R{{}} - Message type array
    R{{}} - GmailError if coversion is not successful.
}
function convertToMessageArray(json[] sourceMessageArrayJsonObject) returns Message[]|GmailError {
    Message[] messages = [];
    foreach i, jsonMessage in sourceMessageArrayJsonObject {
        match (convertJsonMailToMessage(jsonMessage)){
            Message msg => {
                messages[i] = msg;
            }
            GmailError gmailError => return gmailError;
        }
    }
    return messages;
}

documentation{Decodes the message body of text/* mime message parts.

    P{{sourceMessagePartJsonObject}} - Json message part object
    R{{}} - String base 64 decoded message body.
    R{{}} - GmailError if error occurs in base64 encoding.
}
function decodeMsgBodyData(json sourceMessagePartJsonObject) returns string|GmailError {
    string decodedBody;
    string jsonMessagePartMimeType = sourceMessagePartJsonObject.mimeType.toString();
    if (isMimeType(jsonMessagePartMimeType, TEXT_ANY)) {
        string sourceMessagePartBody = sourceMessagePartJsonObject.body.data.toString();
        decodedBody = sourceMessagePartBody.replace(DASH_SYMBOL, PLUS_SYMBOL).replace(UNDERSCORE_SYMBOL, FORWARD_SLASH_SYMBOL).replace(STAR_SYMBOL, EQUAL_SYMBOL);
        match (decodedBody.base64Decode()){
            string decodeString => decodedBody = decodeString;
            error err => {
                GmailError gmailError;
                gmailError.message = "Error occured while base64 decoding text/* message body: " + decodedBody;
                gmailError.cause = err;
                return gmailError;
            }
        }
    }
    return decodedBody;
}

documentation{Gets only the attachment MIME messageParts from the json message payload of the email.

    P{{messagePayload}} - Json message payload which is the parent message part of the email.
    P{{msgAttachments}} - Initial array of attachment message parts.
    R{{}} -  An array of MessageAttachments.
}
function getAttachmentPartsFromPayload(json messagePayload, MessageAttachment[] msgAttachments)
                                                                                returns @tainted MessageAttachment[] {
    MessageAttachment[] attachmentParts = msgAttachments;
    string disposition = EMPTY_STRING;
    if (messagePayload.headers != ()){
        MessagePartHeader contentDispositionHeader =
                    getMsgPartHeaderContentDisposition(convertToMsgPartHeaders(check <json[]>messagePayload.headers));
        string[] headerParts = contentDispositionHeader.value.split(SEMICOLON_SYMBOL);
        disposition = headerParts[0];
    }
    string messagePayloadMimeType = messagePayload.mimeType.toString();
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

documentation{Gets only the inline image MIME messageParts from the json message payload of the email.

    P{{messagePayload}} - Json message payload which is the parent message part of the email.
    P{{inlineMailImages}} - Initial array of inline image message parts.
    R{{}} - An array of MessageBodyParts.
    R{{}} - GmailError if unsuccessful.
}
//Extract inline image MIME message parts from the email
function getInlineImgPartsFromPayloadByMimeType(json messagePayload, MessageBodyPart[] inlineMailImages)
                                                                        returns @tainted MessageBodyPart[]|GmailError {
    MessageBodyPart[] inlineImgParts = inlineMailImages;
    string disposition = EMPTY_STRING;
    if (messagePayload.headers != ()){
        MessagePartHeader contentDispositionHeader =
        getMsgPartHeaderContentDisposition(convertToMsgPartHeaders(check <json[]>messagePayload.headers));
        string[] headerParts = contentDispositionHeader.value.split(";");
        disposition = headerParts[0];
    }
    string messagePayloadMimeType = messagePayload.mimeType.toString();
    //If parent mime part is image/* and it is inline
    if (isMimeType(messagePayloadMimeType, IMAGE_ANY) && (disposition == INLINE)) {
        match convertJsonMsgBodyPartToMsgBodyType(messagePayload){
            MessageBodyPart bodyPart => inlineImgParts[lengthof inlineImgParts] = bodyPart;
            GmailError gmailError => return gmailError;
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
                    GmailError gmailError => return gmailError;
                }
            }
        }
    }
    return inlineImgParts;
}

documentation{Gets the body MIME messagePart with the specified content type (excluding attachments and inline images)
    from the json message payload of the email.
    *Can be used only if there is only one message part with the given mime type in the email payload,
    otherwise, it will return with first found matching message part.*

    P{{messagePayload}} - Json message payload which is the parent message part of the email.
    P{{mimeType}} - Initial array of inline image message parts.
    R{{}} -  MessageBodyPart
    R{{}} - GmailError if unsuccessful.
}
function getMessageBodyPartFromPayloadByMimeType(json messagePayload, string mimeType)
                                                                        returns @tainted MessageBodyPart|GmailError {
    MessageBodyPart msgBodyPart;
    string disposition = EMPTY_STRING;
    if (messagePayload.headers != ()){
        MessagePartHeader contentDispositionHeader =
        getMsgPartHeaderContentDisposition(convertToMsgPartHeaders(check <json[]> messagePayload.headers));
        string[] headerParts = contentDispositionHeader.value.split(SEMICOLON_SYMBOL);
        disposition = headerParts[0];
    }
    string messageBodyPayloadMimeType = messagePayload.mimeType.toString();
    //If parent mime part is given mime type and not an attachment or an inline part
    if (isMimeType(messageBodyPayloadMimeType, mimeType) && (disposition != ATTACHMENT) && (disposition != INLINE)) {
        match convertJsonMsgBodyPartToMsgBodyType(messagePayload){
            MessageBodyPart body => msgBodyPart = body;
            GmailError gmailError => return gmailError;
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
                    GmailError gmailError => return gmailError;
                }
                //If the returned msg body is a match for given mime type stop iterating over the other child parts
                if (msgBodyPart.mimeType != EMPTY_STRING && isMimeType(msgBodyPart.mimeType, mimeType)) {
                    break;
                }
            }
        }
    }
    return msgBodyPart;
}

documentation {Gets the message header Content-Disposition from the message part header array.

    P{{headers}} - An array of MessagePart headers
    R{{}} - **Content-Disposition** header
}
function getMsgPartHeaderContentDisposition(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerContentDisposition;
    foreach header in headers {
        if (header.name == CONTENT_DISPOSITION) {
            headerContentDisposition = header;
        }
    }
    return headerContentDisposition;
}

documentation{Gets the message header **To** from the message part header array.

    P{{headers}} - An array of MessagePart headers
    R{{}} - **To** header
}
function getMsgPartHeaderTo(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerTo;
    foreach header in headers {
        if (header.name == TO) {
            headerTo = header;
        }
    }
    return headerTo;
}

documentation{Gets the message header **From** from the message part header array.

    P{{headers}} - An array of MessagePart headers
    R{{}} - **From** header
}
function getMsgPartHeaderFrom(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerFrom;
    foreach header in headers {
        if (header.name == FROM) {
            headerFrom = header;
        }
    }
    return headerFrom;
}

documentation{Gets the message header Cc from the message part header array.

    P{{headers}} - An array of MessagePart headers
    R{{}} - **Cc** header
}
function getMsgPartHeaderCc(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerCc;
    foreach header in headers {
        if (header.name == CC) {
            headerCc = header;
        }
    }
    return headerCc;
}

documentation{Gets the message header Bcc from the message part header array.

    P{{headers}} - An array of MessagePart headers
    R{{}} - **Bcc** header
}
function getMsgPartHeaderBcc(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerBcc;
    foreach header in headers {
        if (header.name == BCC) {
            headerBcc = header;
        }
    }
    return headerBcc;
}

documentation{Gets the message header Subject from the message part header array.

    P{{headers}} - An array of MessagePart headers
    R{{}} - **Subject** header
}
function getMsgPartHeaderSubject(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerSubject;
    foreach header in headers {
        if (header.name == SUBJECT) {
            headerSubject = header;
        }
    }
    return headerSubject;
}

documentation{Gets the message header Date from the message part header array.

    P{{headers}} - An array of MessagePart headers
    R{{}} - **Date** header
}
function getMsgPartHeaderDate(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerDate;
    foreach header in headers {
        if (header.name == DATE) {
            headerDate = header;
        }
    }
    return headerDate;
}

documentation{Gets the message header ContentType from the message part header array.

    P{{headers}} - An array of MessagePart headers
    R{{}} - **ContentType** header
}
function getMsgPartHeaderContentType(MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerContentType;
    foreach header in headers {
        if (header.name == CONTENT_TYPE) {
            headerContentType = header;
        }
    }
    return headerContentType;
}

documentation{Converts the message part header json array to MessagePartHeader array.

    P{{jsonMsgPartHeaders}} - Json array of message part headers
    R{{}} - MessagePartHeader array
}
function convertToMsgPartHeaders(json[] jsonMsgPartHeaders) returns MessagePartHeader[] {
    MessagePartHeader[] msgPartHeaders = [];
    foreach i, jsonHeader in jsonMsgPartHeaders {
        msgPartHeaders[i] = convertJsonToMesagePartHeader(jsonHeader);
    }
    return msgPartHeaders;
}

documentation{Converts json string array to string array.

    P{{sourceJsonObject}} - Json array
    R{{}} - String array
}
function convertJSONArrayToStringArray(json[] sourceJsonObject) returns string[] {
    string[] targetStringArray = [];
    foreach i, element in sourceJsonObject {
        targetStringArray[i] = element.toString();
    }
    return targetStringArray;
}

documentation{Checks whether mime type in the message part is same as the given the mime type. Returns true if both types
    matches, returns false if not.

    P{{msgMimeType}} - The mime type of the message part you want check
    P{{mType}} - The given mime type which you wants check against with
    R{{}} - Boolean status of mime type match
}
function isMimeType(string msgMimeType, string mType) returns boolean {
    string[] msgTypes = msgMimeType.split(FORWARD_SLASH_SYMBOL);
    string msgPrimaryType = msgTypes[0];
    string msgSecondaryType = msgTypes[1];

    string[] requestmTypes = mType.split(FORWARD_SLASH_SYMBOL);
    string reqPrimaryType = requestmTypes[0];
    string reqSecondaryType = requestmTypes[1];

    if (!msgPrimaryType.equalsIgnoreCase(reqPrimaryType)) {
        return false;
    } else if ((reqSecondaryType.substring(0, 1) != STAR_SYMBOL) && (msgSecondaryType.substring(0, 1) != STAR_SYMBOL)) {
        return msgSecondaryType.equalsIgnoreCase(reqSecondaryType);
    } else {
        return true;
    }
}

documentation{Opens a file from file path and returns the as base 64 encoded string.

    P{{filePath}} - File path
    R{{encodedFile}} - If successful returns encoded file. Else returns GmailError.
}
function encodeFile(string filePath) returns (string|GmailError) {
    io:ByteChannel fileChannel = io:openFile(filePath, io:READ);
    int bytesChunk = BYTES_CHUNK;
    blob readEncodedContent;
    int readEncodedCount;
    string encodedFile;
    match fileChannel.base64Encode(){
        io:ByteChannel encodedfileChannel => {
            match encodedfileChannel.read(bytesChunk) {
                (blob, int) readChannel => (readEncodedContent, readEncodedCount) = readChannel;
                error err => {
                    GmailError gmailError;
                    gmailError.cause = err;
                    gmailError.message = "Error occured while reading byte channel for file: " + filePath ;
                    return gmailError;
                }
            }
        }
        error err => {
            GmailError gmailError;
            gmailError.message = "Error occured while base64 encoding byte channel for file: " + filePath;
            gmailError.cause = err;
            return gmailError;
        }
    }
    encodedFile = readEncodedContent.toString(UTF_8);
    return encodedFile;
}


documentation{Gets the file name from the given file path.

    P{{filePath}} - File path **(including the file name and extension at the end)**
    R{{pathParts}} - Returns the file name extracted from the file path.
}
function getFileNameFromPath(string filePath) returns string {
    string[] pathParts = filePath.split("/");
    return pathParts[lengthof pathParts - 1];
}

function handleResponse (http:Response|http:HttpConnectorError response) returns (json|GmailError){
    match response {
        http:Response httpResponse => {
            if (httpResponse.statusCode == http:NO_CONTENT_204){
                return true;
            }
            match httpResponse.getJsonPayload(){
                json jsonPayload => {
                    if (httpResponse.statusCode == http:OK_200) {
                        return jsonPayload;
                    }
                    else {
                        GmailError gmailError;
                        gmailError.message = STATUS_CODE + COLON_SYMBOL + jsonPayload.error.code.toString()
                                             + SEMICOLON_SYMBOL + WHITE_SPACE + MESSAGE + COLON_SYMBOL + WHITE_SPACE
                                             + jsonPayload.error.message.toString();
                        foreach err in jsonPayload.error.errors {
                            string reason = err.reason.toString();
                            string message = err.message.toString();
                            string location = err.location.toString();
                            string locationType = err.locationType.toString();
                            string domain = err.domain.toString();
                            gmailError.message += NEW_LINE + ERROR + COLON_SYMBOL + WHITE_SPACE + NEW_LINE + DOMAIN
                                                  + COLON_SYMBOL + WHITE_SPACE + domain + SEMICOLON_SYMBOL + WHITE_SPACE
                                                  + REASON + COLON_SYMBOL + WHITE_SPACE + reason + SEMICOLON_SYMBOL
                                                  + WHITE_SPACE + MESSAGE + COLON_SYMBOL + WHITE_SPACE + message
                                                  + SEMICOLON_SYMBOL + WHITE_SPACE + LOCATION_TYPE + COLON_SYMBOL
                                                  + WHITE_SPACE + locationType + SEMICOLON_SYMBOL + WHITE_SPACE
                                                  + LOCATION + COLON_SYMBOL + WHITE_SPACE + location;
                        }
                        return gmailError;
                    }
                }
                http:PayloadError payloadError => {
                    GmailError gmailError = { message:"Error occurred when parsing to json response; message: " +
                                             payloadError.message, cause:payloadError.cause };
                    return gmailError;
                }
            }
        }
        http:HttpConnectorError httpError => {
            GmailError gmailError = { message:"Error occurred during HTTP Client invocation; status code:" +
                                     httpError.statusCode + "; message: " +  httpError.message, cause:httpError.cause };
            return gmailError;
        }
    }
}

documentation{Create url encoded request body with given key and value.
    P{{requestPath}} - Request path to be appended values.
    P{{key}} - Key of the form value parameter.
    P{{value}} - Value of the form value parameter.
    R{{}} - If successful returns created request with encoded string. Else returns GmailError.
}
function appendEncodedURIParameter(string requestPath, string key, string value) returns (string|GmailError) {
    var encodedVar = http:encode(value, UTF_8);
    string encodedString;
    match encodedVar {
        string encoded => encodedString = encoded;
        error err => {
            GmailError gmailError = {message:"Error occurred when encoding the value " + value + " with charset "
                                                + UTF_8, cause:err};
            return gmailError;
        }
    }
    if (requestPath != EMPTY_STRING) {
        requestPath += AMPERSAND_SYMBOL;
    }
    else {
        requestPath += QUESTION_MARK_SYMBOL;
    }
    return requestPath + key + EQUAL_SYMBOL + encodedString;
}
