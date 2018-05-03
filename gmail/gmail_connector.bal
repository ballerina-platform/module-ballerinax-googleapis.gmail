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

documentation{
    Represents the Gmail Client Connector.

    F{{client}} HTTP Client used in Gmail connector
}
public type GmailConnector object {
    public {
        http:Client client;
    }

    documentation{
        List the messages in user's mailbox.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{filter}} Optional. SearchFilter with optional query parameters to search emails.
        R{{}} If successful, returns MessageListPage. Else returns GmailError.
    }
    public function listMessages(string userId, SearchFilter? filter = ()) returns MessageListPage|GmailError;

    documentation{
        Create the raw base 64 encoded string of the whole message and send it as an email from the user's
        mailbox to its recipient.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{message}} MessageRequest to send
        R{{}} If successful, returns (message id, thread id) of the successfully sent message. Else
                returns GmailError.
    }
    public function sendMessage(string userId, MessageRequest message) returns (string, string)|GmailError;

    documentation{
        Read the specified mail from users mailbox.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} The message id of the specified mail to retrieve
        P{{format}} Optional. The format to return the messages in.
                  Acceptable values for format for a get message request are defined as following constants
                  in the package:

                    *FORMAT_FULL* : Returns the full email message data with body content parsed in the payload
                                    field;the raw field is not used. (default)

                    *FORMAT_METADATA* : Returns only email message ID, labels, and email headers.

                    *FORMAT_MINIMAL* : Returns only email message ID and labels; does not return the email headers,
                                      body, or payload.

                    *FORMAT_RAW* : Returns the full email message data with body content in the raw field as a
                                   base64url encoded string. (the payload field is not included in the response)
        P{{metadataHeaders}} The meta data headers array to include in the reponse when the format is given
                               as *FORMAT_METADATA*.
        R{{}} If successful, returns Message type of the specified mail. Else returns GmailError.
    }
    public function readMessage(string userId, string messageId, string? format = (), string[]? metadataHeaders = ())
                                                                                             returns Message|GmailError;
    documentation{
        Gets the specified message attachment from users mailbox.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} The message id of the specified mail to retrieve
        P{{attachmentId}} The id of the attachment to retrieve
        R{{}} If successful, returns MessageAttachment type object of the specified attachment. Else returns
                GmailError.
    }
    public function getAttachment(string userId, string messageId, string attachmentId)
                                                                                returns MessageAttachment|GmailError;

    documentation{
        Move the specified message to the trash.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} The message id of the specified mail to trash
        R{{}} If successful, returns boolean specifying the status of trashing. Else returns GmailError.
    }
    public function trashMessage(string userId, string messageId) returns boolean|GmailError;

    documentation{
        Removes the specified message from the trash.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} The message id of the specified message to untrash
        R{{}} If successful, returns boolean specifying the status of untrashing. Else returns GmailError.
    }
    public function untrashMessage(string userId, string messageId) returns boolean|GmailError;

    documentation{
        Immediately and permanently deletes the specified message. This operation cannot be undone.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} The message id of the specified message to delete.
        R{{}} If successful, returns boolean status of deletion. Else returns GmailError.
    }
    public function deleteMessage(string userId, string messageId) returns boolean|GmailError;

    documentation{
        List the threads in user's mailbox.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{filter}} Optional. The SearchFilter with optional query parameters to search a thread.
        R{{}} If successful, returns ThreadListPage type. Else returns GmailError.
    }
    public function listThreads(string userId, SearchFilter? filter = ()) returns ThreadListPage|GmailError;

    documentation{
        Read the specified mail thread from users mailbox.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{threadId}} The thread id of the specified mail to retrieve.
        P{{format}} Optional. The format to return the messages in.
                  Acceptable values for format for a get thread request are defined as following constants
                  in the package:

                    *FORMAT_FULL* : Returns the full email message data with body content parsed in the payload
                                    field;the raw field is not used. (default)

                    *FORMAT_METADATA* : Returns only email message ID, labels, and email headers.

                    *FORMAT_MINIMAL* : Returns only email message ID and labels; does not return the email headers,
                                      body, or payload.

                    *FORMAT_RAW* : Returns the full email message data with body content in the raw field as a
                                   base64url encoded string. (the payload field is not included in the response)
        P{{metadataHeaders}} Optional. The meta data headers array to include in the reponse when the format is given
                               as *FORMAT_METADATA*.
        R{{}} If successful, returns Thread type of the specified mail thread. Else returns GmailError.
    }
    public function readThread(string userId, string threadId, string? format = (), string[]? metadataHeaders = ())
                                                                                              returns Thread|GmailError;

    documentation{
        Move the specified mail thread to the trash.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{threadId}} The thread id of the specified mail thread to trash
        R{{}} If successful, returns boolean status of trashing. Else returns GmailError.
    }
    public function trashThread(string userId, string threadId) returns boolean|GmailError;

    documentation{
        Removes the specified mail thread from the trash.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{threadId}} The thread id of the specified mail thread to untrash
        R{{}} If successful, returns boolean status of untrashing. Else returns GmailError.
    }
    public function untrashThread(string userId, string threadId) returns boolean|GmailError;

    documentation{
        Immediately and permanently deletes the specified mail thread. This operation cannot be undone.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{threadId}} The thread id of the specified mail thread to delete
        R{{}} If successful, returns boolean status of deletion. Else returns GmailError.
    }
    public function deleteThread(string userId, string threadId) returns boolean|GmailError;

    documentation{
        Get the current user's Gmail Profile.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        R{{}} If successful, returns UserProfile type. Else returns GmailError.
    }
    public function getUserProfile(string userId) returns UserProfile|GmailError;

    documentation{
        Get the label.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{labelId}} The label Id
        R{{}} If successful, returns Label type. Else returns GmailError.
    }
    public function getLabel(string userId, string labelId) returns Label|GmailError;

    documentation{
        Create a new label.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{name}} The display name of the label
        P{{labelListVisibility}} The visibility of the label in the label list in the Gmail web interface.
                                 Acceptable values are:

                                *labelHide*: Do not show the label in the label list.
                                *labelShow*: Show the label in the label list.
                                *labelShowIfUnread*: Show the label if there are any unread messages with that label.
        P{{messageListVisibility}} The visibility of messages with this label in the message list in the Gmail web interface.
                                   Acceptable values are:

                                   *hide*: Do not show the label in the message list.
                                   *show*: Show the label in the message list. (Default)
        P{{backgroundColor}} Optional. The background color represented as hex string #RRGGBB (ex #000000).
                             This field is required in order to set the color of a label.
        P{{textColor}} Optional. The text color of the label, represented as hex string. This field is required in order
                       to set the color of a label.
        R{{}} If successful, returns id of the created label. If not, returns GmailError.
    }
    public function createLabel(string userId, string name, string labelListVisibility, string messageListVisibility,
                                string? backgroundColor = (), string? textColor = ()) returns string|GmailError;

    documentation{
        Lists all labels in the user's mailbox.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        R{{}} If successful, returns an array of Label type objects with values for a set of main fields only. (Use
              `getLabel` to get all the details for a specific label) If not successful, returns GmailError.
    }
    public function listLabels(string userId) returns Label[]|GmailError;

    documentation{
        Delete a label.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{labelId}} The id of the label to delete
        R{{}} If successful, returns boolean status of deletion. Else returns GmailError.
    }
    public function deleteLabel(string userId, string labelId) returns boolean|GmailError;
};

public function GmailConnector::listMessages(string userId, SearchFilter? filter = ()) returns MessageListPage|
                                                                                                            GmailError {
    endpoint http:Client httpClient = self.client;
    string getListMessagesPath = USER_RESOURCE + userId + MESSAGE_RESOURCE;
    match filter {
        SearchFilter searchFilter => {
            string uriParams;
            //The default value for include spam trash query parameter of the api call is false
            uriParams = check appendEncodedURIParameter(uriParams, INCLUDE_SPAMTRASH, <string>searchFilter.
                                                        includeSpamTrash);
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
            getListMessagesPath += uriParams;
        }
        () => {}
    }
    var httpResponse = httpClient->get(getListMessagesPath);
    match handleResponse(httpResponse) {
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
    json jsonPayload = { raw: encodedRequest };
    string sendMessagePath = USER_RESOURCE + userId + MESSAGE_SEND_RESOURCE;
    request.setJsonPayload(jsonPayload);
    var httpResponse = httpClient->post(sendMessagePath, request = request);
    match handleResponse(httpResponse) {
        json jsonSendMessageResponse => return (jsonSendMessageResponse.id.toString(),
                                                jsonSendMessageResponse.threadId.toString());
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::readMessage(string userId, string messageId, string? format = (),
                                            string[]? metadataHeaders = ()) returns Message|GmailError {
    endpoint http:Client httpClient = self.client;
    string uriParams;
    //Add format query parameter
    match format {
        string messageFormat => uriParams = check appendEncodedURIParameter(uriParams, FORMAT, messageFormat);
        () => {}
    }
    match metadataHeaders {
        string[] messageMetadataHeaders => {
            //Add the optional meta data headers as query parameters
            foreach metaDataHeader in messageMetadataHeaders {
                uriParams = check appendEncodedURIParameter(uriParams, METADATA_HEADERS, metaDataHeader);
            }
        }
        () => {}
    }
    string readMessagePath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId;
    readMessagePath += uriParams;
    var httpResponse = httpClient->get(readMessagePath);
    match handleResponse(httpResponse) {
        json jsonreadMessageResponse => {
            //Transform the json mail response from Gmail API to Message type
            match (convertJsonMessageToMessage(jsonreadMessageResponse)){
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
    match handleResponse(httpResponse) {
        json jsonAttachment => {
            //Transform the json mail response from Gmail API to MessageAttachment type
            return convertJsonMessageBodyToMsgAttachment(jsonAttachment);
        }
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::trashMessage(string userId, string messageId) returns boolean|GmailError {
    endpoint http:Client httpClient = self.client;
    string trashMessagePath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId
                           + FORWARD_SLASH_SYMBOL + TRASH;
    var httpResponse = httpClient->post(trashMessagePath);
    match handleResponse(httpResponse) {
        json jsonTrashMessageResponse => return true;
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::untrashMessage(string userId, string messageId) returns boolean|GmailError {
    endpoint http:Client httpClient = self.client;
    string untrashMessagePath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId
                                + FORWARD_SLASH_SYMBOL + UNTRASH;
    var httpResponse = httpClient->post(untrashMessagePath);
    match handleResponse(httpResponse) {
        json jsonUntrashMessageReponse => return true;
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::deleteMessage(string userId, string messageId) returns boolean|GmailError {
    endpoint http:Client httpClient = self.client;
    string deleteMessagePath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId;
    var httpResponse = httpClient->delete(deleteMessagePath);
    match handleResponse(httpResponse) {
        json jsonDeleteMessageResponse => return true;
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::listThreads(string userId, SearchFilter? filter = ()) returns ThreadListPage|GmailError {
    endpoint http:Client httpClient = self.client;
    string getListThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE;
    match filter {
        SearchFilter searchFilter => {
            string uriParams;
            //The default value for include spam trash query parameter of the api call is false
            uriParams = check appendEncodedURIParameter(uriParams, INCLUDE_SPAMTRASH,
                                                        <string>searchFilter.includeSpamTrash);
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
            getListThreadPath += uriParams;
        }
        () => {}
    }
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
    match format { //Add format optional query parameter
        string messageFormat => uriParams = check appendEncodedURIParameter(uriParams, FORMAT, messageFormat);
        () => {}
    }
    match metadataHeaders {
        string[] messageMetadataHeaders => { //Add the optional meta data headers as query parameters
            foreach metaDataHeader in messageMetadataHeaders {
                uriParams = check appendEncodedURIParameter(uriParams, METADATA_HEADERS, metaDataHeader);
            }
        }
        () => {}
    }
    string readThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId + uriParams;
    var httpResponse = httpClient->get(readThreadPath);
    match handleResponse(httpResponse) {
        json jsonReadThreadResponse => {
            //Transform the json mail response from Gmail API to Thread type
            match convertJsonThreadToThreadType(jsonReadThreadResponse) {
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
    match handleResponse(httpResponse) {
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
    match handleResponse(httpResponse) {
        json jsonDeleteThreadResponse => return true;
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::getUserProfile(string userId) returns UserProfile|GmailError {
    endpoint http:Client httpClient = self.client;
    string getProfilePath = USER_RESOURCE + userId + PROFILE_RESOURCE;
    var httpResponse = httpClient->get(getProfilePath);
    match handleResponse(httpResponse) {
        json jsonProfileResponse => {
            //Transform the json profile response from Gmail API to User Profile type
            return convertJsonProfileToUserProfileType(jsonProfileResponse);
        }
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::getLabel(string userId, string labelId) returns Label|GmailError {
    endpoint http:Client httpClient = self.client;
    string getLabelPath = USER_RESOURCE + userId + LABEL_RESOURCE + FORWARD_SLASH_SYMBOL + labelId;
    var httpResponse = httpClient->get(getLabelPath);
    match handleResponse(httpResponse) {
        json jsonGetLabelResponse => return convertJsonLabelToLabelType(jsonGetLabelResponse);
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::createLabel(string userId, string name, string labelListVisibility,
                                            string messageListVisibility, string? backgroundColor = (),
                                            string? textColor = ()) returns string|GmailError {
    endpoint http:Client httpClient = self.client;
    string createLabelPath = USER_RESOURCE + userId + LABEL_RESOURCE;
    json jsonPayload = { labelListVisibility: labelListVisibility, messageListVisibility: messageListVisibility,
        name: name };
    if (backgroundColor != ()){
        jsonPayload.backgroundColor = backgroundColor;
    }
    if (textColor != ()){
        jsonPayload.textColor = textColor;
    }
    http:Request request = new;
    request.setJsonPayload(jsonPayload);
    var httpResponse = httpClient->post(createLabelPath, request = request);
    match handleResponse(httpResponse) {
        json jsonCreateLabelResponse => return jsonCreateLabelResponse.id.toString();
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::listLabels(string userId) returns Label[]|GmailError {
    endpoint http:Client httpClient = self.client;
    string listLabelsPath = USER_RESOURCE + userId + LABEL_RESOURCE;
    var httpResponse = httpClient->get(listLabelsPath);
    match handleResponse(httpResponse) {
        json jsonLabelListResponse => return convertJsonLabelListToLabelTypeList(jsonLabelListResponse);
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::deleteLabel(string userId, string labelId) returns boolean|GmailError {
    endpoint http:Client httpClient = self.client;
    string deleteLabelPath = USER_RESOURCE + userId + LABEL_RESOURCE + FORWARD_SLASH_SYMBOL + labelId;
    var httpResponse = httpClient->delete(deleteLabelPath);
    match handleResponse(httpResponse) {
        json jsonDeleteMessageResponse => return true;
        GmailError gmailError => return gmailError;
    }
}
