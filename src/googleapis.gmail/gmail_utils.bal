// Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/encoding;
import ballerina/http;
import ballerina/io;
import ballerina/java;
import ballerina/java.arrays as jarrays;
import ballerina/lang.'string as strings;
import ballerina/log;
import ballerina/mime;

# Gets only the attachment and inline image MIME messageParts from the JSON message payload of the email.
#
# + messagePayload - `json` message payload which is the parent message part of the email
# + msgAttachments - Initial array of attachment message parts
# + inlineMessageImages - Initial array of inline image message parts
# + return - Returns a tuple of two arrays of attachement parts and inline image parts
function getFilePartsFromPayload(json messagePayload, MessageBodyPart[] msgAttachments,
MessageBodyPart[] inlineMessageImages) returns @tainted [MessageBodyPart[], MessageBodyPart[]] {
    MessageBodyPart[] attachmentParts = msgAttachments;
    MessageBodyPart[] inlineImgParts = inlineMessageImages;
    string disposition = getDispostionFromPayload(messagePayload);
    string messagePayloadMimeType = messagePayload.mimeType != () ? messagePayload.mimeType.toString() : EMPTY_STRING;
    //If parent mime part is an attachment
    if (disposition == ATTACHMENT) {
        //Get the attachment message body part
        attachmentParts[attachmentParts.length()] = convertJSONToMsgBodyType(messagePayload);
    } else if (isMimeType(messagePayloadMimeType, IMAGE_ANY) && (disposition == INLINE)) {
        //Get the inline message body part
        inlineImgParts[inlineImgParts.length()] = convertJSONToMsgBodyType(messagePayload);
    } //Else if is any multipart/*
    else if (isMimeType(messagePayloadMimeType, MULTIPART_ANY) && (messagePayload.parts != ())) {
        json | error messageParts = messagePayload.parts;
        if (messageParts is json) {
            json[] messagePartsArr = <json[]>messageParts;
            if (messagePartsArr.length() != 0) {
                //Iterate each child parts of the parent mime part
                foreach json part in messagePartsArr {
                    //Recursively check each ith child mime part
                    [MessageBodyPart[], MessageBodyPart[]] parts = getFilePartsFromPayload(part, attachmentParts,
                    inlineImgParts);
                    [attachmentParts, inlineImgParts] = parts;
                }
            }
        }
    }
    return [attachmentParts, inlineImgParts];
}

# Gets the body MIME messagePart with the specified content type (excluding attachments and inline images)
#    from the JSON message payload of the email.
#    Can be used only if there is only one message part with the given mime type in the email payload,
#    otherwise, it will return with first found matching message part.
#
# + messagePayload - `json` message payload which is the parent message part of the email
# + mimeType - Mime type of the message body part to retrieve
# + return - Returns MessageBodyPart
function getMessageBodyPartFromPayloadByMimeType(json messagePayload, string mimeType) returns @tainted MessageBodyPart
{
    MessageBodyPart msgBodyPart = {};
    string disposition = getDispostionFromPayload(messagePayload);
    string messageBodyPayloadMimeType = messagePayload.mimeType != () ? messagePayload.mimeType.toString()
                                                                      : EMPTY_STRING;
    //If parent mime part is given mime type and not an attachment or an inline part
    if (isMimeType(messageBodyPayloadMimeType, mimeType) && (disposition != ATTACHMENT) && (disposition != INLINE)) {
        //Get the message body part.
        msgBodyPart = convertJSONToMsgBodyType(messagePayload);
    }    //Else if is any multipart/*
    else if (isMimeType(messageBodyPayloadMimeType, MULTIPART_ANY) && (messagePayload.parts != ())) {
        json | error messageParts = messagePayload.parts;
        if (messageParts is json) {
            json[] messagePartsArr = <json[]>messageParts;
            if (messagePartsArr.length() != 0) {
                //Iterate each child parts of the parent mime part
                foreach json part in messagePartsArr {
                    //Recursively check each ith child mime part.
                    msgBodyPart = getMessageBodyPartFromPayloadByMimeType(part, mimeType);
                    //If the returned msg body is a match for given mime type, stop iterating over the other
                    //child parts.
                    if (msgBodyPart.mimeType != EMPTY_STRING && isMimeType(msgBodyPart.mimeType, mimeType)) {
                        break;
                    }
                }
            }
        }
    }
    return msgBodyPart;
}

# Get the disposition of the message body part from the message body part headers.
#
# + messagePayload - Payload to get the disposition from
# + return - Returns disposition of the message body part
function getDispostionFromPayload(json messagePayload) returns string {
    string disposition = "";
    json | error payloadHeaders = messagePayload.headers;
    if (payloadHeaders is json) {
        if (payloadHeaders != ()) {
            //If no key name CONTENT_DISPOSITION in the payload, disposition is an empty string.
            map<string> headers = convertJSONToHeaderMap(payloadHeaders);
            string contentDispositionHeader = getValueForMapKey(headers, CONTENT_DISPOSITION);
            handle headerParts = split(java:fromString(contentDispositionHeader), java:fromString(SEMICOLON_SYMBOL));
            string? dispositionStr = java:toString(jarrays:get(headerParts, 0));
            if (dispositionStr is string) {
                disposition = dispositionStr;
            } else {
                log:printInfo("disposition is ()");
            }
        }
    } else {
        log:printError("Error occurred while getting hedaers from messagePayload.", err = payloadHeaders);
    }
    return disposition;
}

# Converts JSON string array to string array.
#
# + sourceJsonObject - `json` array
# + return - String array
isolated function convertJSONArrayToStringArray(json[] sourceJsonObject) returns string[] {
    string[] targetStringArray = [];
    int i = 0;
    foreach json element in sourceJsonObject {
        targetStringArray[i] = element.toString();
        i = i + 1;
    }
    return targetStringArray;
}

# Converts string array to JSON string array.
#
# + sourceStringObject - String array
# + return - `json` array
isolated function convertStringArrayToJSONArray(string[] sourceStringObject) returns json[] {
    json[] targetJSONArray = [];
    int i = 0;
    foreach json element in sourceStringObject {
        targetJSONArray[i] = element;
        i = i + 1;
    }
    return targetJSONArray;
}

# Checks whether mime type in the message part is same as the given the mime type. Returns true if both types
#    matches, returns false if not.
#
# + msgMimeType - The mime type of the message part you want check
# + mType - The given mime type which you wants check against with
# + return - Boolean status of mime type match
function isMimeType(string msgMimeType, string mType) returns boolean {
    handle msgTypes = split(java:fromString(msgMimeType), java:fromString(FORWARD_SLASH_SYMBOL));
    string | () msgPrimaryType = java:toString(jarrays:get(msgTypes, 0));
    string | () msgSecondaryType = java:toString(jarrays:get(msgTypes, 1));

    handle requestmTypes = split(java:fromString(mType), java:fromString(FORWARD_SLASH_SYMBOL));
    string | () reqPrimaryType = java:toString(jarrays:get(requestmTypes, 0));
    string | () reqSecondaryType = java:toString(jarrays:get(requestmTypes, 1));

    if (msgPrimaryType is () || msgSecondaryType is () || reqPrimaryType is () || reqSecondaryType is ()) {
        return false;
    } else {
        if (!equalsIgnoreCase(msgPrimaryType, reqPrimaryType)) {
            return false;
        } else if ((reqSecondaryType.substring(0, 1) != STAR_SYMBOL) && (msgSecondaryType.substring(0, 1) != STAR_SYMBOL)) {
            return equalsIgnoreCase(msgSecondaryType, reqSecondaryType);
        } else {
            return true;
        }
    }
}

# Opens a file from file path and returns the as base 64 encoded string.
#
# + filePath - File path
# + return - If successful returns encoded file. Else returns error.
function encodeFile(string filePath) returns string | error {
    io:ReadableByteChannel | io:Error fileChannel = io:openReadableFile(filePath);
    int bytesChunk = BYTES_CHUNK;
    byte[] readEncodedContent = [];

    if (fileChannel is io:ReadableByteChannel) {
        var fileContent = fileChannel.base64Encode();
        if (fileContent is io:ReadableByteChannel) {
            io:ReadableByteChannel encodedfileChannel = fileContent;
            var readChannel = encodedfileChannel.read(bytesChunk);
            if (readChannel is byte[]) {
                readEncodedContent = readChannel;
            } else {
                error err = error(GMAIL_ERROR_CODE, message = "Error occurred while reading the file channel");
                return err;
            }
        } else {
            error err = error(GMAIL_ERROR_CODE, message = "Error occurred encoding the file channel");
            return err;
        }
    } else if (fileChannel is io:GenericError) {
        error err = error(GMAIL_ERROR_CODE, message = "Generic error occurred while reading file from path: "
        + filePath);
        return err;
    } else {
        error err = error(GMAIL_ERROR_CODE,
        message = "Connection TimedOut error occurred while reading file from path: " + filePath);
        return err;
    }
    return <@untainted>strings:fromBytes(readEncodedContent);
}


# Gets the file name from the given file path.
#
# + filePath - File path (including the file name and extension at the end)
# + return - Returns the file name extracted from the file path
function getFileNameFromPath(string filePath) returns string | error {
    handle pathParts = split(java:fromString(filePath), java:fromString("/"));
    int pathPartsLength = jarrays:getLength(pathParts);
    string? fileName = java:toString(jarrays:get(pathParts, (pathPartsLength - 1)));
    if (fileName is string) {
        return fileName;
    } else {
        error err = error(GMAIL_ERROR_CODE, message = "Error occurred while getting file name from path: " + filePath);
        return err;
    }
}

# Handles the HTTP response.
#
# + httpResponse - Http response or error
# + return - If successful returns `json` response. Else returns error.
isolated function handleResponse(http:Response |http:Payload |error httpResponse) returns @tainted json | error {
    if (httpResponse is http:Response) {
        if (httpResponse.statusCode == http:STATUS_NO_CONTENT) {
            //If status 204, then no response body. So returns json boolean true.
            return true;
        }
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (httpResponse.statusCode == http:STATUS_OK) {
                //If status is 200, request is successful. Returns resulting payload.
                return jsonResponse;
            } else {
                //If status is not 200 or 204, request is unsuccessful. Returns error.
                string errorMsg = STATUS_CODE + COLON_SYMBOL + jsonResponse.'error.code.toString() + SEMICOLON_SYMBOL
                + WHITE_SPACE + MESSAGE + COLON_SYMBOL + WHITE_SPACE + jsonResponse.'error.message.toString();
                //Iterate the errors array in Gmail API error response and concat the error information to
                //Gmail error message
                json[] jsonErrors = <json[]>jsonResponse.'error.errors;
                foreach json err in jsonErrors {
                    string reason = "";
                    string message = "";
                    string location = "";
                    string locationType = "";
                    string domain = "";
                    map<json> | error errMap = err.cloneWithType(mapJson);
                    if (errMap is map<json>) {
                        if (errMap.hasKey("reason")) {
                            reason = err.reason.toString();
                        }
                        if (errMap.hasKey("message")) {
                            message = err.message.toString();
                        }
                        if (errMap.hasKey("location")) {
                            location = err.location.toString();
                        }
                        if (errMap.hasKey("locationType")) {
                            locationType = err.locationType.toString();
                        }
                        if (errMap.hasKey("domain")) {
                            domain = err.domain.toString();
                        }
                    }
                    errorMsg = errorMsg + NEW_LINE + ERROR + COLON_SYMBOL + WHITE_SPACE + NEW_LINE + DOMAIN
                    + COLON_SYMBOL + WHITE_SPACE + domain + SEMICOLON_SYMBOL + WHITE_SPACE + REASON + COLON_SYMBOL
                    + WHITE_SPACE + reason + SEMICOLON_SYMBOL + WHITE_SPACE + MESSAGE + COLON_SYMBOL + WHITE_SPACE
                    + message + SEMICOLON_SYMBOL + WHITE_SPACE + LOCATION_TYPE + COLON_SYMBOL + WHITE_SPACE
                    + locationType + SEMICOLON_SYMBOL + WHITE_SPACE + LOCATION + COLON_SYMBOL + WHITE_SPACE + location;
                }
                error err = error(GMAIL_ERROR_CODE, message = errorMsg);
                return err;
            }
        } else {
            error err = error(GMAIL_ERROR_CODE,
            message = "Error occurred while accessing the JSON payload of the response");
            return err;
        }
    } else {
        error err = error(GMAIL_ERROR_CODE, message = "Error occurred while invoking the REST API");
        return err;
    }
}

# Append given key and value as URI query parameter.
#
# + requestPath - Request path to append values
# + key - Key of the form value parameter
# + value - Value of the form value parameter
# + return - If successful, returns created request path as an encoded string. Else returns error.
isolated function appendEncodedURIParameter(string requestPath, string key, string value) returns string | error {
    var encodedVar = encoding:encodeUriComponent(value, "UTF-8");
    string encodedString = "";
    string path = "";
    if (encodedVar is string) {
        encodedString = encodedVar;
    } else {
        error err = error(GMAIL_ERROR_CODE, message = "Error occurred while encoding the string");
        return err;
    }
    if (requestPath != EMPTY_STRING) {
        path = requestPath + AMPERSAND_SYMBOL;
    } else {
        path = requestPath + QUESTION_MARK_SYMBOL;
    }
    return path + key + EQUAL_SYMBOL + encodedString;
}

# Get the value of the given key of the map.
#
# + targetMap - Target map
# + key - Key to get value of
# + return - Returns the string value if key is present, if not returns an empty string
isolated function getValueForMapKey(map<string> targetMap, string key) returns string {
    //If the key is not present, returns an empty string
    return targetMap.hasKey(key) ? <string>targetMap[key] : EMPTY_STRING;
}

# Create and encode the whole message as a raw string.
#
# + msgRequest - MessageRequest to create the message
# + return - If successful, returns the encoded raw string. Else returns error.
function createEncodedRawMessage(MessageRequest msgRequest) returns string | error {
    //The content type should be either TEXT_PLAIN or TEXT_HTML. If not returns an error.
    if (msgRequest.contentType != TEXT_PLAIN && msgRequest.contentType != TEXT_HTML) {
        error err = error(GMAIL_ERROR_CODE, message = "Does not support the given content type: "
        + msgRequest.contentType + " for the message with subject: " + msgRequest.subject);
        return err;
    }
    //Adding inline images to messages of TEXT_PLAIN content type is not supported.
    if (msgRequest.contentType == TEXT_PLAIN && (msgRequest.inlineImagePaths.length() != 0)) {
        error err = error(GMAIL_ERROR_CODE, message =
        "Does not support adding inline images to text/plain body of the message with subject: " + msgRequest.subject);
        return err;
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
    if (msgRequest.contentType == TEXT_PLAIN) {
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
    foreach InlineImagePath inlineImage in msgRequest.inlineImagePaths {
        concatRequest += NEW_LINE + DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING_1 + NEW_LINE;
        //The mime type of inline image cannot be empty
        if (inlineImage.mimeType == EMPTY_STRING) {
            error err = error(GMAIL_ERROR_CODE, message = "Image content type cannot be empty for image: "
                + inlineImage.imagePath);
            return err;
        } else if (inlineImage.imagePath == EMPTY_STRING) {
            //Inline image path cannot be empty
            error err = error(GMAIL_ERROR_CODE, message = "File path of inline image in message with subject: "
                + msgRequest.subject + "cannot be empty");
            return err;
        }
        //If the mime type of the inline image is image/*
        if (isMimeType(inlineImage.mimeType, IMAGE_ANY)) {
            //Open and encode the image file into base64. Return a GmailError if fails.
            string encodedFile = check encodeFile(inlineImage.imagePath);
            //Get inline image file name from path
            string | error inlineImgFileName = getFileNameFromPath(inlineImage.imagePath);
            if (inlineImgFileName is string) {
                //Set the inline image headers of the message
                concatRequest += CONTENT_TYPE + COLON_SYMBOL + inlineImage.mimeType + SEMICOLON_SYMBOL + WHITE_SPACE
                + NAME + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + inlineImgFileName + APOSTROPHE_SYMBOL + NEW_LINE;
                concatRequest += CONTENT_DISPOSITION + COLON_SYMBOL + INLINE + SEMICOLON_SYMBOL + WHITE_SPACE
                + FILE_NAME + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + inlineImgFileName + APOSTROPHE_SYMBOL + NEW_LINE;
                concatRequest += CONTENT_TRANSFER_ENCODING + COLON_SYMBOL + BASE_64 + NEW_LINE;
                concatRequest += CONTENT_ID + COLON_SYMBOL + LESS_THAN_SYMBOL + INLINE_IMAGE_CONTENT_ID_PREFIX
                + inlineImgFileName + GREATER_THAN_SYMBOL + NEW_LINE;
                concatRequest += NEW_LINE + encodedFile + NEW_LINE + NEW_LINE;
            } else {
                return inlineImgFileName;
            }
        } else {
            //Return an error if an unsupported content type other than image/* is passed
            error err = error(GMAIL_ERROR_CODE, message = "Unsupported content type:" + inlineImage.mimeType
            + "for the image:" + inlineImage.imagePath);
            return err;
        }
    }
    if (msgRequest.inlineImagePaths.length() != 0) {
        concatRequest += DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING_1 + DASH_SYMBOL + DASH_SYMBOL + NEW_LINE;
    }
    //------End of multipart/related mime part------

    //Set attachments
    foreach AttachmentPath attachment in msgRequest.attachmentPaths {
        concatRequest += NEW_LINE + DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING + NEW_LINE;
        //The mime type of the attachment cannot be empty
        if (attachment.mimeType == EMPTY_STRING) {
            error err = error(GMAIL_ERROR_CODE, message = "Content type of attachment:" + attachment.attachmentPath
            + "cannot be empty");
            return err;
        } else if (attachment.attachmentPath == EMPTY_STRING) {
            //The attachment path cannot be empty
            error err = error(GMAIL_ERROR_CODE, message = "File path of attachment in message with subject: "
            + msgRequest.subject + "cannot be empty");
            return err;
        }
        //Open and encode the file into base64. Return a error if fails.
        string encodedFile = check encodeFile(attachment.attachmentPath);
        //Get attachment file name from path
        string | error attachmentFileName = getFileNameFromPath(attachment.attachmentPath);
        if (attachmentFileName is string) {
            //Set attachment headers of the messsage
            concatRequest += CONTENT_TYPE + COLON_SYMBOL + attachment.mimeType + SEMICOLON_SYMBOL + WHITE_SPACE + NAME
            + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + attachmentFileName + APOSTROPHE_SYMBOL + NEW_LINE;
            concatRequest += CONTENT_DISPOSITION + COLON_SYMBOL + ATTACHMENT + SEMICOLON_SYMBOL + WHITE_SPACE
            + FILE_NAME + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + attachmentFileName + APOSTROPHE_SYMBOL + NEW_LINE;
            concatRequest += CONTENT_TRANSFER_ENCODING + COLON_SYMBOL + BASE_64 + NEW_LINE;
            concatRequest += NEW_LINE + encodedFile + NEW_LINE + NEW_LINE;
        } else {
            return attachmentFileName;
        }
    }
    if (msgRequest.attachmentPaths.length() != 0) {
        concatRequest += DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING + DASH_SYMBOL + DASH_SYMBOL;
    }
    //------End of multipart/mixed mime part------
    byte[] concatRequestByte = concatRequest.toBytes();
    string encodedRequest = encoding:encodeBase64Url(concatRequestByte);
    string? encodedRequestReplacePlus = java:toString(replace(java:fromString(encodedRequest),
    java:fromString(PLUS_SYMBOL), java:fromString(DASH_SYMBOL)));
    if (encodedRequestReplacePlus is string) {
        string? encodedRequestReplaceForwardSlash = java:toString(replace(java:fromString(encodedRequestReplacePlus),
        java:fromString(FORWARD_SLASH_SYMBOL), java:fromString(UNDERSCORE_SYMBOL)));
        if (encodedRequestReplaceForwardSlash is string) {
            return encodedRequestReplaceForwardSlash;
        } else {
            error err = error(GMAIL_ERROR_CODE, message = "encodedRequestReplaceForwardSlash is ()");
            return err;
        }
    } else {
        error err = error(GMAIL_ERROR_CODE, message = "encodedRequestReplacePlus is ()");
        return err;
    }
}

isolated function equalsIgnoreCase(string str1, string str2) returns boolean {
    if (str1.toUpperAscii() == str2.toUpperAscii()) {
        return true;
    } else {
        return false;
    }
}

isolated function elementExists(map<json> Map, string element) returns boolean {
    if (Map.hasKey(element)) {
        return true;
    } else {
        return false;
    }
}
