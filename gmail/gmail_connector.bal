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

import ballerina/http;
import ballerina/mime;
import ballerina/log;

documentation{Represents the Gmail Client Connector.
    F{{client}} - HTTP Client used in Gmail connector.
}
public type GmailConnector object {
    public {
        http:Client client;
    }

    documentation{List the messages in user's mailbox.
        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{filter}} - Optional. SearchFilter with optional query parameters to search emails.
        R{{}} -  If successful, returns MessageListPage. Else returns GmailError.
    }
    public function listMessages(string userId, SearchFilter? filter = ()) returns MessageListPage|GmailError;

    documentation{Create the raw base 64 encoded string of the whole message and send it as an email from the user's
        mailbox to its recipient.
        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{message}} - MessageRequest to send.
        R{{}} - If successful, returns (message id, thread id) of the successfully sent message. Else
                returns GmailError.
    }
    public function sendMessage(string userId, MessageRequest message) returns (string, string)|GmailError;

    documentation{Read the specified mail from users mailbox.
        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} -  The message id of the specified mail to retrieve.
        P{{format}} - Optional. The format to return the messages in.
                  Acceptable values for format for a get message request are defined as following constants
                  in the package:

                    *FORMAT_FULL* : Returns the full email message data with body content parsed in the payload
                                    field;the raw field is not used. (default)

                    *FORMAT_METADATA* : Returns only email message ID, labels, and email headers.

                    *FORMAT_MINIMAL* : Returns only email message ID and labels; does not return the email headers,
                                      body, or payload.

                    *FORMAT_RAW* : Returns the full email message data with body content in the raw field as a
                                   base64url encoded string. (the payload field is not included in the response)
        P{{metadataHeaders}} - Optional. The meta data headers array to include in the reponse when the format is given
                               as *FORMAT_METADATA*.
        R{{}} - If successful, returns Message type of the specified mail. Else returns GmailError.
    }
    public function readMessage(string userId, string messageId, string? format = (), string[]? metadataHeaders = ())
                                                                                        returns Message|GmailError;
    documentation{Gets the specified message attachment from users mailbox.
        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} -  The message id of the specified mail to retrieve.
        P{{attachmentId}} - The id of the attachment to retrieve.
        R{{}} - If successful, returns MessageAttachment type object of the specified attachment. Else returns
                GmailError.
    }
    public function getAttachment(string userId, string messageId, string attachmentId)
                                                                                returns MessageAttachment|GmailError;

    documentation{Move the specified message to the trash.
        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} -  The message id of the specified mail to trash.
        R{{}} - If successful, returns boolean specifying the status of trashing. Else returns GmailError.
    }
    public function trashMail(string userId, string messageId) returns boolean|GmailError;

    documentation{Removes the specified message from the trash.
        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} - The message id of the specified message to untrash.
        R{{}} - If successful, returns boolean specifying the status of untrashing. Else returns GmailError.
    }
    public function untrashMail(string userId, string messageId) returns boolean|GmailError;

    documentation{Immediately and permanently deletes the specified message. This operation cannot be undone.
        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} - The message id of the specified message to delete.
        R{{}} - If successful, returns boolean status of deletion. Else returns GmailError.
    }
    public function deleteMail(string userId, string messageId) returns boolean|GmailError;

    documentation{List the threads in user's mailbox.
        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{filter}} - Optional. The SearchFilter with optional query parameters to search a thread.
        R{{}} - If successful, returns ThreadListPage type. Else returns GmailError.
    }
    public function listThreads(string userId, SearchFilter? filter = ()) returns ThreadListPage|GmailError;

    documentation{Read the specified mail thread from users mailbox.
        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{threadId}} -  The thread id of the specified mail to retrieve.
        P{{format}} - Optional. The format to return the messages in.
                  Acceptable values for format for a get thread request are defined as following constants
                  in the package:

                    *FORMAT_FULL* : Returns the full email message data with body content parsed in the payload
                                    field;the raw field is not used. (default)

                    *FORMAT_METADATA* : Returns only email message ID, labels, and email headers.

                    *FORMAT_MINIMAL* : Returns only email message ID and labels; does not return the email headers,
                                      body, or payload.

                    *FORMAT_RAW* : Returns the full email message data with body content in the raw field as a
                                   base64url encoded string. (the payload field is not included in the response)
        P{{metadataHeaders}} - Optional. The meta data headers array to include in the reponse when the format is given
                               as *FORMAT_METADATA*.
        R{{}} - If successful, returns Thread type of the specified mail thread. Else returns GmailError.
    }
    public function readThread(string userId, string threadId, string? format = (), string[]? metadataHeaders = ())
                                                                                           returns Thread|GmailError;

    documentation{Move the specified mail thread to the trash.
        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{threadId}} -  The thread id of the specified mail thread to trash.
        R{{}} - If successful, returns boolean status of trashing. Else returns GmailError.
    }
    public function trashThread(string userId, string threadId) returns boolean|GmailError;

    documentation{Removes the specified mail thread from the trash.
        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{threadId}} - The thread id of the specified mail thread to untrash.
        R{{}} - If successful, returns boolean status of untrashing. Else returns GmailError.
    }
    public function untrashThread(string userId, string threadId) returns boolean|GmailError;

    documentation{Immediately and permanently deletes the specified mail thread. This operation cannot be undone.
        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{threadId}} - The thread id of the specified mail thread to delete.
        R{{}} - If successful, returns boolean status of deletion. Else returns GmailError.
    }
    public function deleteThread(string userId, string threadId) returns boolean|GmailError;

    documentation{Get the current user's Gmail Profile.
        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        R{{}} - If successful, returns UserProfile type. Else returns GmailError.
    }
    public function getUserProfile(string userId) returns UserProfile|GmailError;
};

public function GmailConnector::listMessages(string userId, SearchFilter? filter = ()) returns MessageListPage|
                                                                                                          GmailError {
    endpoint http:Client httpClient = self.client;
    string getListMessagesPath = USER_RESOURCE + userId + MESSAGE_RESOURCE;
    SearchFilter searchFilter = filter ?: {};
    string uriParams;
    //The default value for include spam trash query parameter of the api call is false
    uriParams = check appendEncodedURIParameter(uriParams, INCLUDE_SPAMTRASH, <string>searchFilter.includeSpamTrash);
    //Add optional query parameters
    foreach labelId in searchFilter.labelIds {
        uriParams = check appendEncodedURIParameter(uriParams, LABEL_IDS, labelId);
    }
    uriParams = searchFilter.maxResults != EMPTY_STRING ?
                             check appendEncodedURIParameter(uriParams, MAX_RESULTS, searchFilter.maxResults) : uriParams;
    uriParams = searchFilter.pageToken != EMPTY_STRING ?
                               check appendEncodedURIParameter(uriParams, PAGE_TOKEN, searchFilter.pageToken) : uriParams;
    uriParams = searchFilter.q != EMPTY_STRING ?
                                            check appendEncodedURIParameter(uriParams, QUERY, searchFilter.q) : uriParams;
    getListMessagesPath = getListMessagesPath + uriParams;
    var httpResponse = httpClient->get(getListMessagesPath);
    match handleResponse(httpResponse){
        json jsonlistMsgResponse => return convertJsonMsgListToMessageListPageType(jsonlistMsgResponse);
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::sendMessage(string userId, MessageRequest message) returns (string, string)|GmailError {
    endpoint http:Client httpClient = self.client;
    if (message.contentType != TEXT_PLAIN && message.contentType != TEXT_HTML) {
        GmailError gmailError;
        gmailError.message = "Does not support the given content type: " + message.contentType
                                + " for the message with subject: " + message.subject;
        return gmailError;
    }
    if (message.contentType == TEXT_PLAIN && (lengthof message.inlineImagePaths != 0)){
        GmailError gmailError;
        gmailError.message = "Does not support adding inline images to text/plain body of the message with subject: "
                            + message.subject;
        return gmailError;
    }
    string concatRequest = EMPTY_STRING;

    //Set the general headers of the message
    concatRequest += TO + COLON_SYMBOL + message.recipient + NEW_LINE;
    concatRequest += SUBJECT + COLON_SYMBOL + message.subject + NEW_LINE;
    if (message.sender != EMPTY_STRING) {
        concatRequest += FROM + COLON_SYMBOL + message.sender + NEW_LINE;
    }
    if (message.cc != EMPTY_STRING) {
        concatRequest += CC + COLON_SYMBOL + message.cc + NEW_LINE;
    }
    if (message.bcc != EMPTY_STRING) {
        concatRequest += BCC + COLON_SYMBOL + message.bcc + NEW_LINE;
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
    if (message.contentType == TEXT_PLAIN){
        concatRequest += NEW_LINE + DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING_2 + NEW_LINE;
        concatRequest += CONTENT_TYPE + COLON_SYMBOL + TEXT_PLAIN + SEMICOLON_SYMBOL + CHARSET + EQUAL_SYMBOL
                        + APOSTROPHE_SYMBOL + UTF_8 + APOSTROPHE_SYMBOL + NEW_LINE;
        concatRequest += NEW_LINE + message.messageBody + NEW_LINE;
    }

    //Set the body part : text/html
    if (message.contentType == TEXT_HTML) {
        concatRequest += NEW_LINE + DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING_2 + NEW_LINE;
        concatRequest += CONTENT_TYPE + COLON_SYMBOL + TEXT_HTML + SEMICOLON_SYMBOL + CHARSET + EQUAL_SYMBOL
                        + APOSTROPHE_SYMBOL + UTF_8 + APOSTROPHE_SYMBOL + NEW_LINE;
        concatRequest += NEW_LINE + message.messageBody + NEW_LINE + NEW_LINE;
    }

    concatRequest += DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING_2 + DASH_SYMBOL + DASH_SYMBOL;
    //------End of multipart/alternative mime part------

    //Set inline Images as body parts
    foreach inlineImage in message.inlineImagePaths {
        concatRequest += NEW_LINE + DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING_1 + NEW_LINE;
        if (inlineImage.mimeType == EMPTY_STRING){
            GmailError gmailError;
            gmailError.message = "Image content type cannot be empty for image: " + inlineImage.imagePath;
            return gmailError;
        } else if (inlineImage.imagePath == EMPTY_STRING){
            GmailError gmailError;
            gmailError.message = "File path of inline image in message with subject: " + message.subject
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
    if (lengthof (message.inlineImagePaths) != 0) {
        concatRequest += DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING_1 + DASH_SYMBOL + DASH_SYMBOL + NEW_LINE;
    }
    //------End of multipart/related mime part------

    //Set attachments
    foreach attachment in message.attachmentPaths {
        concatRequest += NEW_LINE + DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING + NEW_LINE;
        if (attachment.mimeType == EMPTY_STRING){
            GmailError gmailError;
            gmailError.message = "Content type of attachment:" + attachment.attachmentPath + "cannot be empty";
            return gmailError;
        } else if (attachment.attachmentPath == EMPTY_STRING){
            GmailError gmailError;
            gmailError.message = "File path of attachment in message with subject: " + message.subject
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
    if (lengthof (message.attachmentPaths) != 0)   {
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
    encodedRequest = encodedRequest.replace(PLUS_SYMBOL, DASH_SYMBOL).replace(FORWARD_SLASH_SYMBOL, UNDERSCORE_SYMBOL);
    http:Request request = new;
    json jsonPayload = {raw:encodedRequest};
    string sendMessagePath = USER_RESOURCE + userId + MESSAGE_SEND_RESOURCE;
    request.setJsonPayload(jsonPayload);
    var httpResponse = httpClient->post(sendMessagePath, request = request);
    match handleResponse(httpResponse){
        json jsonSendMessageResponse => {
            return (jsonSendMessageResponse.id.toString(), jsonSendMessageResponse.threadId.toString());
        }
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::readMessage(string userId, string messageId, string? format = (),
                                         string[]? metadataHeaders = ()) returns Message|GmailError {
    endpoint http:Client httpClient = self.client;
    string uriParams;
    string messageFormat = format ?: FORMAT_FULL;
    string[] messageMetadataHeaders = metadataHeaders ?: [];
    string readMessagePath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId;
    //Add format query parameter
    uriParams = check appendEncodedURIParameter(uriParams, FORMAT, messageFormat);
    //Add the optional meta data headers as query parameters
    foreach metaDataHeader in messageMetadataHeaders {
        uriParams = check appendEncodedURIParameter(uriParams, METADATA_HEADERS, metaDataHeader);
    }
    readMessagePath = readMessagePath + uriParams;
    var httpResponse = httpClient->get(readMessagePath);
    match handleResponse(httpResponse){
        json jsonreadMessageResponse => {
            //Transform the json mail response from Gmail API to Message type
            match (convertJsonMailToMessage(jsonreadMessageResponse)){
                Message message => return message;
                GmailError gmailError => return gmailError;
            }
        }
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::getAttachment(string userId, string messageId, string attachmentId)
                                                                            returns MessageAttachment|GmailError {
    endpoint http:Client httpClient = self.client;
    string getAttachmentPath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId
                               + ATTACHMENT_RESOURCE + attachmentId;
    var httpResponse = httpClient->get(getAttachmentPath);
    match handleResponse(httpResponse){
        json jsonAttachment => {
            //Transform the json mail response from Gmail API to MessageAttachment type
            return convertJsonMessageBodyToMsgAttachment(jsonAttachment);
        }
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::trashMail(string userId, string messageId) returns boolean|GmailError {
    endpoint http:Client httpClient = self.client;
    string trashMailPath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId
                           + FORWARD_SLASH_SYMBOL + TRASH;
    var httpResponse = httpClient->post(trashMailPath);
    match handleResponse(httpResponse){
        json jsonTrashMailResponse => {
            return true;
        }
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::untrashMail(string userId, string messageId) returns boolean|GmailError {
    endpoint http:Client httpClient = self.client;
    string untrashMailPath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId
                            + FORWARD_SLASH_SYMBOL + UNTRASH;
    var httpResponse = httpClient->post(untrashMailPath);
    match handleResponse(httpResponse){
        json jsonUntrashMailReponse => {
            return true;
        }
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::deleteMail(string userId, string messageId) returns boolean|GmailError {
    endpoint http:Client httpClient = self.client;
    string deleteMailPath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId;
    var httpResponse = httpClient->delete(deleteMailPath);
    match handleResponse(httpResponse){
        json jsonDeleteMailResponse => {
            return true;
        }
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::listThreads(string userId, SearchFilter? filter = ()) returns ThreadListPage|GmailError {
    endpoint http:Client httpClient = self.client;
    string getListThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE;
    string uriParams;
    SearchFilter searchFilter = filter ?: {};
    //The default value for include spam trash query parameter of the api call is false
    uriParams = check appendEncodedURIParameter(uriParams, INCLUDE_SPAMTRASH, <string>searchFilter.includeSpamTrash);
    //Add optional query parameters
    foreach labelId in searchFilter.labelIds {
        uriParams = check appendEncodedURIParameter(uriParams, LABEL_IDS, labelId);
    }
    uriParams = searchFilter.maxResults != EMPTY_STRING ?
                            check appendEncodedURIParameter(uriParams, MAX_RESULTS, searchFilter.maxResults) : uriParams;
    uriParams = searchFilter.pageToken != EMPTY_STRING ?
                            check appendEncodedURIParameter(uriParams, PAGE_TOKEN, searchFilter.pageToken) : uriParams;
    uriParams = searchFilter.q != EMPTY_STRING ?
                            check appendEncodedURIParameter(uriParams, QUERY, searchFilter.q) : uriParams;
    getListThreadPath = getListThreadPath + uriParams;
    var httpResponse = httpClient->get(getListThreadPath);
    match handleResponse(httpResponse) {
        json jsonListThreadResponse => return convertJsonThreadListToThreadListPageType(jsonListThreadResponse);
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::readThread(string userId, string threadId, string? format = (),
                                           string[]? metadataHeaders = ()) returns Thread|GmailError {
    endpoint http:Client httpClient = self.client;
    string uriParams;
    string messageFormat = format ?: FORMAT_FULL;
    string[] messageMetadataHeaders = metadataHeaders ?: [];
    string readThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId;
    //Add format optional query parameter
    uriParams = check appendEncodedURIParameter(uriParams, FORMAT, messageFormat);
    //Add the optional meta data headers as query parameters
    foreach metaDataHeader in messageMetadataHeaders {
        uriParams = check appendEncodedURIParameter(uriParams, METADATA_HEADERS, metaDataHeader);
    }
    readThreadPath += uriParams;
    var httpResponse = httpClient->get(readThreadPath);
    match handleResponse(httpResponse) {
        json jsonReadThreadResponse => {
            //Transform the json mail response from Gmail API to Thread type
            match convertJsonThreadToThreadType(jsonReadThreadResponse){
                Thread thread => return thread;
                GmailError gmailError => return gmailError;
            }
        }
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::trashThread(string userId, string threadId) returns boolean|GmailError {
    endpoint http:Client httpClient = self.client;
    string trashThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId
                            + FORWARD_SLASH_SYMBOL + TRASH;
    var httpResponse = httpClient->post(trashThreadPath);
    match handleResponse(httpResponse){
        json jsonTrashThreadResponse => return true;
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::untrashThread(string userId, string threadId) returns boolean|GmailError {
    endpoint http:Client httpClient = self.client;
    string untrashThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId
                                + FORWARD_SLASH_SYMBOL + UNTRASH;
    var httpResponse = httpClient->post(untrashThreadPath);
    match handleResponse(httpResponse) {
        json jsonUntrashThreadResponse => return true;
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::deleteThread(string userId, string threadId) returns boolean|GmailError {
    endpoint http:Client httpClient = self.client;
    string deleteThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId;
    var httpResponse = httpClient->delete(deleteThreadPath);
    match handleResponse(httpResponse){
        json jsonDeleteThreadResponse => return true;
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::getUserProfile(string userId) returns UserProfile|GmailError {
    endpoint http:Client httpClient = self.client;
    string getProfilePath = USER_RESOURCE + userId + PROFILE_RESOURCE;
    var httpResponse = httpClient->get(getProfilePath);
    match handleResponse(httpResponse){
        json jsonProfileResponse => {
            //Transform the json profile response from Gmail API to User Profile type
            return convertJsonProfileToUserProfileType(jsonProfileResponse);
        }
        GmailError gmailError => return gmailError;
    }
}
