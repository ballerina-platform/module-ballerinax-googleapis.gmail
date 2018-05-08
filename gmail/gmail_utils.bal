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
import ballerina/mime;

documentation{
    Gets only the attachment and inline image MIME messageParts from the json message payload of the email.

    P{{messagePayload}} Json message payload which is the parent message part of the email
    P{{msgAttachments}} Initial array of attachment message parts
    P{{inlineMessageImages}} Initial array of inline image message parts
    R{{}} Returns a tuple of two arrays of attachement parts and inline image parts
}
function getFilePartsFromPayload(json messagePayload, MessageBodyPart[] msgAttachments,
                        MessageBodyPart[] inlineMessageImages) returns @tainted (MessageBodyPart[], MessageBodyPart[]) {
    MessageBodyPart[] attachmentParts = msgAttachments;
    MessageBodyPart[] inlineImgParts = inlineMessageImages;
    string disposition = getDispostionFromPayload(messagePayload);
    string messagePayloadMimeType = messagePayload.mimeType != () ? messagePayload.mimeType.toString() : EMPTY_STRING;
    //If parent mime part is an attachment
    if (disposition == ATTACHMENT) {
        //Get the attachment message body part
        attachmentParts[lengthof attachmentParts] = convertJSONToMsgBodyType(messagePayload);
    } else if (isMimeType(messagePayloadMimeType, IMAGE_ANY) && (disposition == INLINE)) {
        //Get the inline message body part
        inlineImgParts[lengthof inlineImgParts] = convertJSONToMsgBodyType(messagePayload);
    } //Else if is any multipart/*
    else if (isMimeType(messagePayloadMimeType, MULTIPART_ANY) && (messagePayload.parts != ())) {
        json messageParts = messagePayload.parts;
        if (lengthof messageParts != 0) {
            //Iterate each child parts of the parent mime part
            foreach part in messageParts {
                //Recursively check each ith child mime part
                (MessageBodyPart[], MessageBodyPart[]) parts =
                                                         getFilePartsFromPayload(part, attachmentParts, inlineImgParts);
                (attachmentParts, inlineImgParts) = parts;
            }
        }
    }
    return (attachmentParts, inlineImgParts);
}

documentation{
    Gets the body MIME messagePart with the specified content type (excluding attachments and inline images)
    from the json message payload of the email.
    Can be used only if there is only one message part with the given mime type in the email payload,
    otherwise, it will return with first found matching message part.

    P{{messagePayload}} Json message payload which is the parent message part of the email
    P{{mimeType}} Mime type of the message body part to retrieve
    R{{}} Returns MessageBodyPart
}
function getMessageBodyPartFromPayloadByMimeType(json messagePayload, string mimeType) returns @tainted MessageBodyPart {
    MessageBodyPart msgBodyPart;
    string disposition = getDispostionFromPayload(messagePayload);
    string messageBodyPayloadMimeType = messagePayload.mimeType != () ? messagePayload.mimeType.toString()
                                                                                                        : EMPTY_STRING;
    //If parent mime part is given mime type and not an attachment or an inline part
    if (isMimeType(messageBodyPayloadMimeType, mimeType) && (disposition != ATTACHMENT) && (disposition != INLINE)) {
        //Get the message body part.
        msgBodyPart = convertJSONToMsgBodyType(messagePayload);
    } //Else if is any multipart/*
    else if (isMimeType(messageBodyPayloadMimeType, MULTIPART_ANY) && (messagePayload.parts != ())) {
        json messageParts = messagePayload.parts;
        if (lengthof messageParts != 0) {
            //Iterate each child parts of the parent mime part
            foreach part in messageParts {
                //Recursively check each ith child mime part.
                msgBodyPart = getMessageBodyPartFromPayloadByMimeType(part, mimeType);
                //If the returned msg body is a match for given mime type, stop iterating over the other child parts
                if (msgBodyPart.mimeType != EMPTY_STRING && isMimeType(msgBodyPart.mimeType, mimeType)) {
                    break;
                }
            }
        }
    }
    return msgBodyPart;
}

documentation{
    Get the disposition of the message body part from the message body part headers.

    P{{messagePayload}} Payload to get the disposition from
    R{{}} Returns disposition of the message body part
}
function getDispostionFromPayload(json messagePayload) returns string {
    string disposition;
    if (messagePayload.headers != ()){
        //If no key name CONTENT_DISPOSITION in the payload, disposition is an empty string.
        map headers = convertJSONToHeaderMap(messagePayload.headers);
        string contentDispositionHeader = getValueForMapKey(headers, CONTENT_DISPOSITION);
        string[] headerParts = contentDispositionHeader.split(SEMICOLON_SYMBOL);
        disposition = headerParts[0];
    }
    return disposition;
}

documentation{
    Converts json string array to string array.

    P{{sourceJsonObject}} Json array
    R{{}} String array
}
function convertJSONArrayToStringArray(json[] sourceJsonObject) returns string[] {
    string[] targetStringArray;
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
    json[] targetJSONArray;
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
    R{{encodedFile}} If successful returns encoded file. Else returns GmailError.
}
function encodeFile(string filePath) returns (string|GmailError) {
    io:ByteChannel fileChannel = io:openFile(filePath, io:READ);
    int bytesChunk = BYTES_CHUNK;
    blob readEncodedContent;
    int readEncodedCount;
    match fileChannel.base64Encode() {
        io:ByteChannel encodedfileChannel => {
            match encodedfileChannel.read(bytesChunk) {
                (blob, int) readChannel => (readEncodedContent, readEncodedCount) = readChannel;
                error err => {
                    GmailError gmailError;
                    gmailError.cause = err;
                    gmailError.message = "Error occured while reading byte channel for file: " + filePath;
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
    return readEncodedContent.toString(UTF_8);
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

    P{{response}} Http response or error
    R{{}} If successful returns json response. Else returns GmailError.
}
function handleResponse (http:Response|error response) returns (json|GmailError){
    match response {
        http:Response httpResponse => {
            if (httpResponse.statusCode == http:NO_CONTENT_204){
                //If status 204, then no response body. So returns json boolean true.
                return true;
            }
            match httpResponse.getJsonPayload(){ //For every other responses, get json payload
                json jsonPayload => {
                    if (httpResponse.statusCode == http:OK_200) {
                        //If status is 200, request is successful. Returns resulting payload.
                        return jsonPayload;
                    }
                    else { //If status is not 200 or 204, request is unsuccessful. Returns gmailError.
                        GmailError gmailError;
                        gmailError.message = STATUS_CODE + COLON_SYMBOL + jsonPayload.error.code.toString()
                                             + SEMICOLON_SYMBOL + WHITE_SPACE + MESSAGE + COLON_SYMBOL + WHITE_SPACE
                                             + jsonPayload.error.message.toString();
                        //Iterate the errors array in Gmail API error response and concat the error information to
                        //Gmail error message
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
                    //Error occurred in getting the json payload from response. Eg: When response body is not json
                    GmailError gmailError = { message:"Error occurred when parsing to json response; message: " +
                                             payloadError.message, cause:payloadError.cause };
                    return gmailError;
                }
            }
        }
        error err => {
            //Error occurred in http connector. Eg: Timeout
            GmailError gmailError = { message:"Error occurred during HTTP Client invocation; message: " +  err.message,
                                      cause:err.cause };
            return gmailError;
        }
    }
}

documentation{
    Append given key and value as URI query parameter.

    P{{requestPath}} Request path to append values
    P{{key}} Key of the form value parameter
    P{{value}} Value of the form value parameter
    R{{}} If successful, returns created request path as an encoded string. Else returns GmailError.
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
function getValueForMapKey(map targetMap, string key) returns string {
   //If the key is not present, returns an empty string
   return targetMap.hasKey(key) ? <string>targetMap[key] : EMPTY_STRING;
}

documentation{
    Create and encode the whole message as a raw string.

    P{{msgRequest}} MessageRequest to create the message
    R{{}} If successful, returns the encoded raw string. Else returns GmailError.
}
function createEncodedRawMessage(MessageRequest msgRequest) returns string|GmailError {
    //The content type should be either TEXT_PLAIN or TEXT_HTML. If not returns an error.
    if (msgRequest.contentType != TEXT_PLAIN && msgRequest.contentType != TEXT_HTML) {
        GmailError gmailError;
        gmailError.message = "Does not support the given content type: " + msgRequest.contentType
                                + " for the message with subject: " + msgRequest.subject;
        return gmailError;
    }
    //Adding inline images to messages of TEXT_PLAIN content type is not unsupported.
    if (msgRequest.contentType == TEXT_PLAIN && (lengthof msgRequest.inlineImagePaths != 0)){
        GmailError gmailError;
        gmailError.message = "Does not support adding inline images to text/plain body of the message with subject: "
            + msgRequest.subject;
        return gmailError;
    }
    //Raw string of message
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
        //The mime type of inline image cannot be empty
        if (inlineImage.mimeType == EMPTY_STRING){
            GmailError gmailError;
            gmailError.message = "Image content type cannot be empty for image: " + inlineImage.imagePath;
            return gmailError;
        } else if (inlineImage.imagePath == EMPTY_STRING){ //Inline image path cannot be empty
            GmailError gmailError;
            gmailError.message = "File path of inline image in message with subject: " + msgRequest.subject
                                + "cannot be empty";
            return gmailError;
        }
        //If the mime type of the inline image is image/*
        if (isMimeType(inlineImage.mimeType, IMAGE_ANY)) {
            //Open and encode the image file into base64. Return a GmailError if fails.
            string encodedFile = check encodeFile(inlineImage.imagePath);
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
            //Return an error if an unsupported content type other than image/* is passed
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
        //The mime type of the attachment cannot be empty
        if (attachment.mimeType == EMPTY_STRING){
            GmailError gmailError;
            gmailError.message = "Content type of attachment:" + attachment.attachmentPath + "cannot be empty";
            return gmailError;
        } else if (attachment.attachmentPath == EMPTY_STRING){ //The attachment path cannot be empty
            GmailError gmailError;
            gmailError.message = "File path of attachment in message with subject: " + msgRequest.subject
                                + "cannot be empty";
            return gmailError;
        }
        //Open and encode the file into base64. Return a GmailError if fails.
        string encodedFile = check encodeFile(attachment.attachmentPath);
        //Set attachment headers of the messsage
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

    match (concatRequest.base64Encode()){
        string encodedRequest => return encodedRequest.replace(PLUS_SYMBOL, DASH_SYMBOL)
                                                      .replace(FORWARD_SLASH_SYMBOL, UNDERSCORE_SYMBOL);
        error encodeError => {
            GmailError gmailError;
            gmailError.message = "Error occurred during base64 encoding of the mime message request : " + concatRequest;
            gmailError.cause = encodeError;
            return gmailError;
        }
    }
}
