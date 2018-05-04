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

documentation{
    Decodes the message body of text/* mime message parts.

    P{{sourceMessagePartJsonObject}} Json message part object
    R{{}} If successful, returns string base64 decoded message body. Else returns GmailError.
}
function decodeMsgBodyData(json sourceMessagePartJsonObject) returns string|GmailError {
    string decodedBody;
    string jsonMessagePartMimeType = sourceMessagePartJsonObject.mimeType != () ?
                                                         sourceMessagePartJsonObject.mimeType.toString() : EMPTY_STRING;
    if (isMimeType(jsonMessagePartMimeType, TEXT_ANY)) {
        string sourceMessagePartBody = sourceMessagePartJsonObject.body.data != () ?
                                                        sourceMessagePartJsonObject.body.data.toString() : EMPTY_STRING;
        decodedBody = sourceMessagePartBody.replace(DASH_SYMBOL, PLUS_SYMBOL)
                                            .replace(UNDERSCORE_SYMBOL, FORWARD_SLASH_SYMBOL)
                                            .replace(STAR_SYMBOL, EQUAL_SYMBOL);
        match (decodedBody.base64Decode()){
            string decodeString => decodedBody = decodeString;
            error err => {
                GmailError gmailError = {message : "Error occured while base64 decoding text/* message body: "
                                                    + decodedBody};
                gmailError.cause = err;
                return gmailError;
            }
        }
    }
    return decodedBody;
}

documentation{
    Gets only the attachment MIME messageParts from the json message payload of the email.

    P{{messagePayload}} Json message payload which is the parent message part of the email
    P{{msgAttachments}} Initial array of attachment message parts
    R{{}} An array of MessageAttachments
}
function getAttachmentPartsFromPayload(json messagePayload, MessageAttachment[] msgAttachments)
                                                                                returns @tainted MessageAttachment[] {
    MessageAttachment[] attachmentParts = msgAttachments;
    string disposition = EMPTY_STRING;
    if (messagePayload.headers != ()){
        map headers = convertJsonHeadersToHeaderMap(messagePayload.headers);
        string contentDispositionHeader = getKeyValueFromMap(headers, CONTENT_DISPOSITION);
        string[] headerParts = contentDispositionHeader.split(SEMICOLON_SYMBOL);
        disposition = headerParts[0];
    }
    string messagePayloadMimeType = messagePayload.mimeType != () ? messagePayload.mimeType.toString() : EMPTY_STRING;
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

    P{{messagePayload}} Json message payload which is the parent message part of the email
    P{{inlineMessageImages}} Initial array of inline image message parts
    R{{}} If successful, returns an array of MessageBodyParts. Else returns GmailError.
}
//Extract inline image MIME message parts from the email
function getInlineImgPartsFromPayloadByMimeType(json messagePayload, MessageBodyPart[] inlineMessageImages)
                                                                        returns @tainted MessageBodyPart[]|GmailError {
    MessageBodyPart[] inlineImgParts = inlineMessageImages;
    string disposition = EMPTY_STRING;
    if (messagePayload.headers != ()){
        map headers = convertJsonHeadersToHeaderMap(messagePayload.headers);
        string contentDispositionHeader = getKeyValueFromMap(headers, CONTENT_DISPOSITION);
        string[] headerParts = contentDispositionHeader.split(";");
        disposition = headerParts[0];
    }
    string messagePayloadMimeType = messagePayload.mimeType != () ? messagePayload.mimeType.toString() : EMPTY_STRING;
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

documentation{
    Gets the body MIME messagePart with the specified content type (excluding attachments and inline images)
    from the json message payload of the email.
    Can be used only if there is only one message part with the given mime type in the email payload,
    otherwise, it will return with first found matching message part.

    P{{messagePayload}} Json message payload which is the parent message part of the email
    P{{mimeType}} Initial array of inline image message parts
    R{{}} If successful returns MessageBodyPart. Else returns GmailError
}
function getMessageBodyPartFromPayloadByMimeType(json messagePayload, string mimeType)
                                                                        returns @tainted MessageBodyPart|GmailError {
    MessageBodyPart msgBodyPart;
    string disposition = EMPTY_STRING;
    if (messagePayload.headers != ()){
        map headers = convertJsonHeadersToHeaderMap(messagePayload.headers);
        string contentDispositionHeader = getKeyValueFromMap(headers,CONTENT_DISPOSITION);
        string[] headerParts = contentDispositionHeader.split(SEMICOLON_SYMBOL);
        disposition = headerParts[0];
    }
    string messageBodyPayloadMimeType = messagePayload.mimeType != () ? messagePayload.mimeType.toString()
                                                                                                        : EMPTY_STRING;
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

documentation{
    Converts json string array to string array.

    P{{sourceJsonObject}} Json array
    R{{}} String array
}
function convertJSONArrayToStringArray(json[] sourceJsonObject) returns string[] {
    string[] targetStringArray = [];
    foreach i, element in sourceJsonObject {
        targetStringArray[i] = element.toString();
    }
    return targetStringArray;
}

documentation{
    Converts string array to json string array.

    P{{sourceStringObject}} String array
    R{{}} Json array
}
function convertStringArrayToJSONArray(string[] sourceStringObject) returns json[] {
    json[] targetJSONArray = [];
    foreach i, element in sourceStringObject {
        targetJSONArray[i] = element;
    }
    return targetJSONArray;
}

documentation{
    Checks whether mime type in the message part is same as the given the mime type. Returns true if both types
    matches, returns false if not.

    P{{msgMimeType}} The mime type of the message part you want check
    P{{mType}} The given mime type which you wants check against with
    R{{}} Boolean status of mime type match
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

documentation{
    Opens a file from file path and returns the as base 64 encoded string.

    P{{filePath}} File path
    R{{encodedFile}} If successful returns encoded file. Else returns GmailError
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


documentation{
    Gets the file name from the given file path.

    P{{filePath}} File path (including the file name and extension at the end)
    R{{pathParts}} Returns the file name extracted from the file path
}
function getFileNameFromPath(string filePath) returns string {
    string[] pathParts = filePath.split("/");
    return pathParts[lengthof pathParts - 1];
}

documentation{
    Handles the http response.

    P{{response}} Http response or HttpConnectorEror
    R{{}} If successful returns json reponse. Else returns GmailError
}
function handleResponse (http:Response|error response) returns (json|GmailError){
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
                error payloadError => {
                    GmailError gmailError = { message:"Error occurred when parsing to json response; message: " +
                                             payloadError.message, cause:payloadError.cause };
                    return gmailError;
                }
            }
        }
        error err => {
            GmailError gmailError = { message:"Error occurred during HTTP Client invocation; message: "
                +  err.message, cause:err.cause };
            return gmailError;
        }
    }
}

documentation{
    Create url encoded request body with given key and value.

    P{{requestPath}} Request path to be appended values
    P{{key}} Key of the form value parameter
    P{{value}} Value of the form value parameter
    R{{}} If successful returns created request with encoded string. Else returns GmailError
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

documentation{
    Get the value of the given key of the map.

    P{{targetMap}} Target map
    P{{key}} Key to get value of
    R{{}} Returns the string value if key is present, if not returns an empty string
}
function getKeyValueFromMap(map targetMap, string key) returns string {
   return targetMap.hasKey(key) ? <string>targetMap[key] : EMPTY_STRING;
}

function createEncodedRawMessage(MessageRequest msgRequest) returns string|GmailError {
    if (msgRequest.contentType != TEXT_PLAIN && msgRequest.contentType != TEXT_HTML) {
        GmailError gmailError;
        gmailError.message = "Does not support the given content type: " + msgRequest.contentType
            + " for the message with subject: " + msgRequest.subject;
        return gmailError;
    }
    if (msgRequest.contentType == TEXT_PLAIN && (lengthof msgRequest.inlineImagePaths != 0)){
        GmailError gmailError;
        gmailError.message = "Does not support adding inline images to text/plain body of the message with subject: "
            + msgRequest.subject;
        return gmailError;
    }
    string concatRequest = EMPTY_STRING;

    //Set the general headers of the message
    concatRequest += TO + COLON_SYMBOL + msgRequest.recipient + NEW_LINE;
    concatRequest += SUBJECT + COLON_SYMBOL + msgRequest.subject + NEW_LINE;
    if (msgRequest.sender != EMPTY_STRING) {
        concatRequest += FROM + COLON_SYMBOL + msgRequest.sender + NEW_LINE;
    }
    if (msgRequest.cc != EMPTY_STRING) {
        concatRequest += CC + COLON_SYMBOL + msgRequest.cc + NEW_LINE;
    }
    if (msgRequest.bcc != EMPTY_STRING) {
        concatRequest += BCC + COLON_SYMBOL + msgRequest.bcc + NEW_LINE;
    }
    //------Start of multipart/mixed mime part (parent mime part)------

    //Set the content type header of top level MIME message part
    concatRequest += CONTENT_TYPE + COLON_SYMBOL + mime:MULTIPART_MIXED + SEMICOLON_SYMBOL + BOUNDARY + EQUAL_SYMBOL
        + APOSTROPHE_SYMBOL + BOUNDARY_STRING + APOSTROPHE_SYMBOL + NEW_LINE;

    concatRequest += NEW_LINE + DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING + NEW_LINE;

    //------Start of multipart/related mime part------
    concatRequest += CONTENT_TYPE + COLON_SYMBOL + mime:MULTIPART_RELATED + SEMICOLON_SYMBOL + WHITE_SPACE + BOUNDARY
        + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + BOUNDARY_STRING_1 + APOSTROPHE_SYMBOL + NEW_LINE;

    concatRequest += NEW_LINE + DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING_1 + NEW_LINE;

    //------Start of multipart/alternative mime part------
    concatRequest += CONTENT_TYPE + COLON_SYMBOL + mime:MULTIPART_ALTERNATIVE + SEMICOLON_SYMBOL + WHITE_SPACE +
        BOUNDARY + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + BOUNDARY_STRING_2 + APOSTROPHE_SYMBOL + NEW_LINE;

    //Set the body part : text/plain
    if (msgRequest.contentType == TEXT_PLAIN){
        concatRequest += NEW_LINE + DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING_2 + NEW_LINE;
        concatRequest += CONTENT_TYPE + COLON_SYMBOL + TEXT_PLAIN + SEMICOLON_SYMBOL + CHARSET + EQUAL_SYMBOL
            + APOSTROPHE_SYMBOL + UTF_8 + APOSTROPHE_SYMBOL + NEW_LINE;
        concatRequest += NEW_LINE + msgRequest.messageBody + NEW_LINE;
    }

    //Set the body part : text/html
    if (msgRequest.contentType == TEXT_HTML) {
        concatRequest += NEW_LINE + DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING_2 + NEW_LINE;
        concatRequest += CONTENT_TYPE + COLON_SYMBOL + TEXT_HTML + SEMICOLON_SYMBOL + CHARSET + EQUAL_SYMBOL
            + APOSTROPHE_SYMBOL + UTF_8 + APOSTROPHE_SYMBOL + NEW_LINE;
        concatRequest += NEW_LINE + msgRequest.messageBody + NEW_LINE + NEW_LINE;
    }

    concatRequest += DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING_2 + DASH_SYMBOL + DASH_SYMBOL;
    //------End of multipart/alternative mime part------

    //Set inline Images as body parts
    foreach inlineImage in msgRequest.inlineImagePaths {
        concatRequest += NEW_LINE + DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING_1 + NEW_LINE;
        if (inlineImage.mimeType == EMPTY_STRING){
            GmailError gmailError;
            gmailError.message = "Image content type cannot be empty for image: " + inlineImage.imagePath;
            return gmailError;
        } else if (inlineImage.imagePath == EMPTY_STRING){
            GmailError gmailError;
            gmailError.message = "File path of inline image in message with subject: " + msgRequest.subject
                + "cannot be empty";
            return gmailError;
        }
        if (isMimeType(inlineImage.mimeType, IMAGE_ANY)) {
            string encodedFile;
            //Open and encode the image file into base64. Return a GmailError if fails.
            match encodeFile(inlineImage.imagePath) {
                string eFile => encodedFile = eFile;
                GmailError gmailError => return gmailError;
            }
            //Set the inline image headers of the message
            concatRequest += CONTENT_TYPE + COLON_SYMBOL + inlineImage.mimeType + SEMICOLON_SYMBOL + WHITE_SPACE
                + NAME + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + getFileNameFromPath(inlineImage.imagePath)
                + APOSTROPHE_SYMBOL + NEW_LINE;
            concatRequest += CONTENT_DISPOSITION + COLON_SYMBOL + INLINE + SEMICOLON_SYMBOL + WHITE_SPACE
                + FILE_NAME + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + getFileNameFromPath(inlineImage.imagePath)
                + APOSTROPHE_SYMBOL + NEW_LINE;
            concatRequest += CONTENT_TRANSFER_ENCODING + COLON_SYMBOL + BASE_64 + NEW_LINE;
            concatRequest += CONTENT_ID + COLON_SYMBOL + LESS_THAN_SYMBOL + INLINE_IMAGE_CONTENT_ID_PREFIX
                + getFileNameFromPath(inlineImage.imagePath) + GREATER_THAN_SYMBOL + NEW_LINE;
            concatRequest += NEW_LINE + encodedFile + NEW_LINE + NEW_LINE;
        } else {
            //Return an error if an un supported content type other than image/* is passed
            GmailError gmailError;
            gmailError.message = "Unsupported content type:" + inlineImage.mimeType + "for the image:"
                + inlineImage.imagePath;
            return gmailError;
        }
    }
    if (lengthof (msgRequest.inlineImagePaths) != 0) {
        concatRequest += DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING_1 + DASH_SYMBOL + DASH_SYMBOL + NEW_LINE;
    }
    //------End of multipart/related mime part------

    //Set attachments
    foreach attachment in msgRequest.attachmentPaths {
        concatRequest += NEW_LINE + DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING + NEW_LINE;
        if (attachment.mimeType == EMPTY_STRING){
            GmailError gmailError;
            gmailError.message = "Content type of attachment:" + attachment.attachmentPath + "cannot be empty";
            return gmailError;
        } else if (attachment.attachmentPath == EMPTY_STRING){
            GmailError gmailError;
            gmailError.message = "File path of attachment in message with subject: " + msgRequest.subject
                + "cannot be empty";
            return gmailError;
        }
        string encodedFile;
        //Open and encode the file into base64. Return a GmailError if fails.
        match encodeFile(attachment.attachmentPath) {
            string eFile => encodedFile = eFile;
            GmailError gmailError => return gmailError;
        }
        concatRequest += CONTENT_TYPE + COLON_SYMBOL + attachment.mimeType + SEMICOLON_SYMBOL + WHITE_SPACE + NAME
            + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + getFileNameFromPath(attachment.attachmentPath)
            + APOSTROPHE_SYMBOL + NEW_LINE;
        concatRequest += CONTENT_DISPOSITION + COLON_SYMBOL + ATTACHMENT + SEMICOLON_SYMBOL + WHITE_SPACE + FILE_NAME
            + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + getFileNameFromPath(attachment.attachmentPath)
            + APOSTROPHE_SYMBOL + NEW_LINE;
        concatRequest += CONTENT_TRANSFER_ENCODING + COLON_SYMBOL + BASE_64 + NEW_LINE;
        concatRequest += NEW_LINE + encodedFile + NEW_LINE + NEW_LINE;
    }
    if (lengthof (msgRequest.attachmentPaths) != 0)   {
        concatRequest += DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING + DASH_SYMBOL + DASH_SYMBOL;
    }
    //------End of multipart/mixed mime part------

    string encodedRequest;
    match (concatRequest.base64Encode()){
        string encodeString => encodedRequest = encodeString;
        error encodeError => {
            GmailError gmailError;
            gmailError.message = "Error occurred during base64 encoding of the mime message request : " + concatRequest;
            gmailError.cause = encodeError;
            return gmailError;
        }
    }
    return encodedRequest.replace(PLUS_SYMBOL, DASH_SYMBOL).replace(FORWARD_SLASH_SYMBOL, UNDERSCORE_SYMBOL);
}
