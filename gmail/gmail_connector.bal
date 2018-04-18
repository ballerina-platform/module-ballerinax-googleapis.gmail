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
import ballerina/file;

documentation{
    Represents the GMail Client Connector.

    F{{client}} - HTTP Client used in GMail connector.
}
public type GMailConnector object {
    public {
        http:Client client;
    }

    documentation{
        List the messages in user's mailbox.

        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{filter}} - SearchFilter with optional query parameters to search emails.
        R{{}} -  MessageListPage consisting an array of messages, size estimation and next page token.
        R{{}} - GMailError if any error occurs in sending the request and receiving the response.
    }
    public function listAllMails(string userId, SearchFilter filter) returns (MessageListPage|GMailError);

    documentation{
        Create the raw base 64 encoded string of the whole message and send it as an email from the user's
        mailbox to its recipient.

        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{message}} - Message to send.
        R{{}} - String message id of the successfully sent message.
        R{{}} - String thread id of the succesfully sent message.
        R{{}} - GMailError if the message is not sent successfully.
    }
    public function sendMessage(string userId, MessageRequest message) returns (string, string)|GMailError;

    documentation{
        Read the specified mail from users mailbox.

        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} -  The message id of the specified mail to retrieve.
        P{{filter}} - MessageThreadFilter with the optional parameters of response format and metadataHeaders.
        R{{}} - Message type object of the specified mail.
        R{{}} - GMailError if the message cannot be read successfully.
    }
    public function readMail(string userId, string messageId, MessageThreadFilter filter) returns (Message)|GMailError;

    documentation{
        Gets the specified message attachment from users mailbox.

        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} -  The message id of the specified mail to retrieve.
        P{{attachmentId}} - The id of the attachment to retrieve.
        R{{}} - MessageAttachment type object of the specified attachment.
        R{{}} - GMailError if the attachment cannot be read successfully.
    }
    public function getAttachment(string userId, string messageId, string attachmentId)
        returns (MessageAttachment)|GMailError;

    documentation{
        Move the specified message to the trash.

        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} -  The message id of the specified mail to trash.
        R{{}} - Boolean specifying the status of trashing. Returns as true if trashing the message is successful.
        R{{}} - GMailError if trashing the message is unsuccessful.
    }
    public function trashMail(string userId, string messageId) returns boolean|GMailError;

    documentation{
        Removes the specified message from the trash.

        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} - The message id of the specified message to untrash.
        R{{}} - Boolean specifying the status of untrashing. Returns true if untrashing the message is
                successful.
        R{{}} - GMailError if the untrashing is unsuccessful.
    }
    public function untrashMail(string userId, string messageId) returns boolean|GMailError;

    documentation{
        Immediately and permanently deletes the specified message. This operation cannot be undone.

        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} - The message id of the specified message to delete.
        R{{}} - Boolean status of deletion. Returns true if deleting the message is successful.
        R{{}} - GMailError if the deletion is unsuccessful.
    }
    public function deleteMail(string userId, string messageId) returns boolean|GMailError;

    documentation{
        List the threads in user's mailbox.

        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{filter}} - The SearchFilter with optional query parameters to search a thread.
        R{{}} - ThreadListPage with thread list, result set size estimation and next page token.
        R{{}} - GMailError if any error occurs in sending the request and receiving the response.
    }
    public function listThreads(string userId, SearchFilter filter) returns (ThreadListPage)|GMailError;

    documentation{
        Read the specified mail thread from users mailbox.

        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{threadId}} -  The thread id of the specified mail to retrieve.
        P{{filter}} - MessageThreadFilter with the optional parameters of response format and metadataHeaders.
        R{{}} - Thread type of the specified mail thread.
        R{{}} - GMailError if the thread cannot be read successfully.
    }
    public function readThread(string userId, string threadId, MessageThreadFilter filter) returns (Thread)|GMailError;

    documentation{
        Move the specified mail thread to the trash.

        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{threadId}} -  The thread id of the specified mail thread to trash.
        R{{}} - Boolean status of trashing. Returns true if trashing the thread is successful.
        R{{}} - GMailError if trashing the thread is unsuccessful.
    }
    public function trashThread(string userId, string threadId) returns boolean|GMailError;

    documentation{
        Removes the specified mail thread from the trash.

        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{threadId}} - The thread id of the specified mail thread to untrash.
        R{{}} - Boolean status of untrashing. Returns true if untrashing the mail thread is successful.
        R{{}} - GMailError if the untrashing is unsuccessful.
    }
    public function untrashThread(string userId, string threadId) returns boolean|GMailError;

    documentation{
        Immediately and permanently deletes the specified mail thread. This operation cannot be undone.

        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{threadId}} - The thread id of the specified mail thread to delete.
        R{{}} - Boolean status of deletion. Returns true if deleting the mail thread is successful.
        R{{}} - GMailError if the deletion is unsuccessful.
    }
    public function deleteThread(string userId, string threadId) returns boolean|GMailError;

    documentation{
        Get the current user's GMail Profile.

        P{{userId}} - The user's email address. The special value **me** can be used to indicate the authenticated user.
        R{{}} - UserProfile if successful.
        R{{}} - GMailError if unsuccessful.
    }
    public function getUserProfile(string userId) returns UserProfile|GMailError;
};

public function GMailConnector::listAllMails(string userId, SearchFilter filter) returns (MessageListPage|GMailError) {
    endpoint http:Client httpClient = self.client;
    http:Request request = new;
    string getListMessagesPath = USER_RESOURCE + userId + MESSAGE_RESOURCE;
    string uriParams = EMPTY_STRING;
    //Add optional query parameters
    uriParams = uriParams + QUESTION_MARK_SYMBOL + INCLUDE_SPAMTRASH + EQUAL_SYMBOL + filter.includeSpamTrash;
    foreach labelId in filter.labelIds {
        uriParams = labelId != EMPTY_STRING ? uriParams + AMPERSAND_SYMBOL + LABEL_IDS + EQUAL_SYMBOL + labelId:uriParams;
    }
    uriParams = filter.maxResults != EMPTY_STRING ? uriParams + AMPERSAND_SYMBOL + MAX_RESULTS + EQUAL_SYMBOL
                                                                + filter.maxResults : uriParams;
    uriParams = filter.pageToken != EMPTY_STRING ? uriParams + AMPERSAND_SYMBOL + PAGE_TOKEN + EQUAL_SYMBOL
                                                                + filter.pageToken : uriParams;
    if (filter.q != EMPTY_STRING) {
        match http:encode(filter.q, UTF_8) {
            string encodedQuery => uriParams += AMPERSAND_SYMBOL + QUERY + EQUAL_SYMBOL + encodedQuery;
            error e => {
                GMailError gMailError;
                gMailError.message = "Error occured during encoding the query: " + filter.q + "; message:" + e.message;
                gMailError.cause = e.cause;
                return gMailError;
            }
        }
    }
    getListMessagesPath = getListMessagesPath + uriParams;
    var httpResponse = httpClient -> get(getListMessagesPath, request);
    match handleResponse(httpResponse){
        json jsonlistMsgResponse => {
            MessageListPage messageListPage;
            if (jsonlistMsgResponse.messages != ()) {
                messageListPage.resultSizeEstimate = jsonlistMsgResponse.resultSizeEstimate.toString();
                messageListPage.nextPageToken = jsonlistMsgResponse.nextPageToken.toString();
                int i = 0;
                //for each message resource in messages json array of the response
                foreach message in jsonlistMsgResponse.messages {
                    string msgId = message.id.toString();
                    //read mail from the message id
                    match self.readMail(userId, msgId, {}){
                        Message mail => {
                            //Add the message to the message list page's list of message
                            messageListPage.messages[i] = mail;
                            i++;
                        }
                        GMailError gmailError => return gmailError;
                    }
                }
            }
            return messageListPage;
        }
        GMailError gmailError => return gmailError;
    }
}

public function GMailConnector::sendMessage(string userId, MessageRequest message) returns (string, string)|GMailError {
    endpoint http:Client httpClient = self.client;
    if (message.contentType == TEXT_PLAIN && (lengthof message.inlineImagePaths != 0)){
    GMailError gMailError;
        gMailError.message = "Does not support adding inline images to text/plain body of the email with subject: "
                             + message.subject;
        return gMailError;
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
    concatRequest += CONTENT_TYPE + COLON_SYMBOL + MULTIPART_MIXED + SEMICOLON_SYMBOL + BOUNDARY + EQUAL_SYMBOL
                        + APOSTROPHE_SYMBOL + BOUNDARY_STRING + APOSTROPHE_SYMBOL + NEW_LINE;

    concatRequest += NEW_LINE + DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING + NEW_LINE;

    //------Start of multipart/related mime part------
    concatRequest += CONTENT_TYPE + COLON_SYMBOL + MULTIPART_RELATED + SEMICOLON_SYMBOL + WHITE_SPACE + BOUNDARY
                     + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + BOUNDARY_STRING_1 + APOSTROPHE_SYMBOL + NEW_LINE;

    concatRequest += NEW_LINE + DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING_1 + NEW_LINE;

    //------Start of multipart/alternative mime part------
    concatRequest += CONTENT_TYPE + COLON_SYMBOL + MULTIPART_ALTERNATIVE + SEMICOLON_SYMBOL + WHITE_SPACE + BOUNDARY
                     + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + BOUNDARY_STRING_2 + APOSTROPHE_SYMBOL + NEW_LINE;

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
            GMailError gMailError;
            gMailError.message = "Image content type cannot be empty for image: " + inlineImage.imagePath;
            return gMailError;
        } else if (inlineImage.imagePath == EMPTY_STRING){
            GMailError gMailError;
            gMailError.message = "File path of inline image in message with subject: " + message.subject
                                    + "cannot be empty";
            return gMailError;
        }
        if (isMimeType(inlineImage.mimeType, IMAGE_ANY)) {
            file:Path filePath = new (inlineImage.imagePath);
            string encodedFile;
            //Open and encode the image file into base64. Return an GMailError if fails.
            match encodeFile(filePath.getPathValue()) {
                string eFile => encodedFile = eFile;
                GMailError gMailError => return gMailError;
            }
            //Set the inline image headers of the message
            concatRequest += CONTENT_TYPE + COLON_SYMBOL + inlineImage.mimeType + SEMICOLON_SYMBOL + WHITE_SPACE
                             + NAME + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + filePath.toAbsolutePath().getName()
                             + APOSTROPHE_SYMBOL + NEW_LINE;
            concatRequest += CONTENT_DISPOSITION + COLON_SYMBOL + INLINE + SEMICOLON_SYMBOL + WHITE_SPACE
                             + FILE_NAME + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + filePath.toAbsolutePath().getName()
                             + APOSTROPHE_SYMBOL + NEW_LINE;
            concatRequest += CONTENT_TRANSFER_ENCODING + COLON_SYMBOL + BASE_64 + NEW_LINE;
            concatRequest += CONTENT_ID + COLON_SYMBOL + LESS_THAN_SYMBOL + INLINE_IMAGE_CONTENT_ID_PREFIX
                             + filePath.toAbsolutePath().getName() + GREATER_THAN_SYMBOL + NEW_LINE;
            concatRequest += NEW_LINE + encodedFile + NEW_LINE + NEW_LINE;
        } else {
            //Return an error if an un supported content type other than image/* is passed
            GMailError gMailError;
            gMailError.message = "The given content type:" + inlineImage.mimeType + "of the image:"
                                  + inlineImage.imagePath + "is unsupported.";
            return gMailError;
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
            GMailError gMailError;
            gMailError.message = "Content type of attachment:" + attachment.attachmentPath + "cannot be empty";
            return gMailError;
        } else if (attachmentPath == EMPTY_STRING){
            GMailError gMailError;
            gMailError.message = "File path of attachment in message with subject: " + message.subject
                                    + "cannot be empty";
            return gMailError;
        }
        file:Path filePath = new (attachment.attachmentPath);
        string encodedFile;
        //Open and encode the file into base64. Return an GMailError if fails.
        match encodeFile(filePath.getPathValue()) {
            string eFile => encodedFile = eFile;
            GMailError gMailError => return gMailError;
        }
        concatRequest += CONTENT_TYPE + COLON_SYMBOL + attachment.mimeType + SEMICOLON_SYMBOL + WHITE_SPACE + NAME
                         + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + filePath.toAbsolutePath().getName()
                         + APOSTROPHE_SYMBOL + NEW_LINE;
        concatRequest += CONTENT_DISPOSITION + COLON_SYMBOL + ATTACHMENT + SEMICOLON_SYMBOL + WHITE_SPACE + FILE_NAME
                         + EQUAL_SYMBOL + APOSTROPHE_SYMBOL + filePath.toAbsolutePath().getName()
                         + APOSTROPHE_SYMBOL + NEW_LINE;
        concatRequest += CONTENT_TRANSFER_ENCODING + COLON_SYMBOL + BASE_64 + NEW_LINE;
        concatRequest += NEW_LINE + encodedFile + NEW_LINE + NEW_LINE;
    }
    if (lengthof (message.attachmentPaths) != 0 )   {
        concatRequest += DASH_SYMBOL + DASH_SYMBOL + BOUNDARY_STRING + DASH_SYMBOL + DASH_SYMBOL;
    }
    //------End of multipart/mixed mime part------

    string encodedRequest;
    match (util:base64EncodeString(concatRequest)){
        string encodeString => encodedRequest = encodeString;
        util:Base64EncodeError encodeError => {
            GMailError gMailError;
            gMailError.message = encodeError.message;
            gMailError.cause = encodeError.cause;
            return gMailError;
        }
    }
    encodedRequest = encodedRequest.replace(PLUS_SYMBOL, DASH_SYMBOL).replace(FORWARD_SLASH_SYMBOL, UNDERSCORE_SYMBOL);
    http:Request request = new;
    json jsonPayload = {raw:encodedRequest};
    string sendMessagePath = USER_RESOURCE + userId + MESSAGE_SEND_RESOURCE;
    request.setJsonPayload(jsonPayload);
    request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
    var httpResponse = httpClient -> post(sendMessagePath, request);
    match handleResponse(httpResponse){
        json jsonSendMessageResponse => {
            string msgId = jsonSendMessageResponse.id.toString();
            string threadId = jsonSendMessageResponse.threadId.toString();
            return (msgId, threadId);
        }
        GMailError gMailError => return gMailError;
    }
}

public function GMailConnector::readMail(string userId, string messageId, MessageThreadFilter filter)
                                                                                        returns (Message)|GMailError {
    endpoint http:Client httpClient = self.client;
    http:Request request = new;
    string uriParams = EMPTY_STRING;
    string readMailPath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId;
    //Add format optional query parameter
    uriParams = filter.format != EMPTY_STRING ? uriParams + AMPERSAND_SYMBOL + FORMAT + EQUAL_SYMBOL
                                                    + filter.format : uriParams;
    //Add the optional meta data headers as query parameters
    foreach metaDataHeader in filter.metadataHeaders {
        uriParams = metaDataHeader != EMPTY_STRING ? uriParams + AMPERSAND_SYMBOL + METADATA_HEADERS + EQUAL_SYMBOL +
                                                                                            metaDataHeader:uriParams;
    }
    readMailPath = uriParams != EMPTY_STRING ? readMailPath + QUESTION_MARK_SYMBOL
                                                            + uriParams.subString(1, uriParams.length()) : readMailPath;
    var httpResponse = httpClient -> get(readMailPath, request);
    match handleResponse(httpResponse){
        json jsonReadMailResponse => {
            //Transform the json mail response from GMail API to Message type
            match (convertJsonMailToMessage(jsonReadMailResponse)){
                Message message =>  return message;
                GMailError gMailError => return gMailError;
            }
        }
        GMailError gMailError => return gMailError;
    }
}

public function GMailConnector::getAttachment(string userId, string messageId, string attachmentId)
                                                                            returns (MessageAttachment)|GMailError {
    endpoint http:Client httpClient = self.client;
    http:Request request = new ;
    string getAttachmentPath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId +
                                                                                    ATTACHMENT_RESOURCE + attachmentId;
    var httpResponse = httpClient -> get(getAttachmentPath, request);
    match handleResponse(httpResponse){
        json jsonAttachment => {
            //Transform the json mail response from GMail API to MessageAttachment type
            return convertJsonMessageBodyToMsgAttachment(jsonAttachment);
        }
        GMailError gMailError => return gMailError;
    }
}

public function GMailConnector::trashMail(string userId, string messageId) returns boolean|GMailError {
    endpoint http:Client httpClient = self.client;
    http:Request request = new;
    string trashMailPath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId
                            + FORWARD_SLASH_SYMBOL + TRASH;
    var httpResponse = httpClient -> post(trashMailPath, request);
    match handleResponse(httpResponse){
        json jsonTrashMailResponse => {
            return true;
        }
        GMailError gMailError => return gMailError;
    }
}

public function GMailConnector::untrashMail(string userId, string messageId) returns boolean|GMailError {
    endpoint http:Client httpClient = self.client;
    http:Request request = new;
    string untrashMailPath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId
                             + FORWARD_SLASH_SYMBOL + UNTRASH;
    var httpResponse = httpClient -> post(untrashMailPath, request);
    match handleResponse(httpResponse){
        json jsonUntrashMailReponse => {
            return true;
        }
        GMailError gMailError => return gMailError;
    }
}

public function GMailConnector::deleteMail(string userId, string messageId) returns boolean|GMailError {
    endpoint http:Client httpClient = self.client;
    http:Request request = new;
    string deleteMailPath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId;
    var httpResponse = httpClient -> delete(deleteMailPath, request);
    match handleResponse(httpResponse){
        json jsonDeleteMailResponse => {
            return true;
        }
        GMailError gMailError => return gMailError;
    }
}

public function GMailConnector::listThreads(string userId, SearchFilter filter) returns (ThreadListPage)|GMailError {
    endpoint http:Client httpClient = self.client;
    http:Request request = new;
    string getListThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE;
    string uriParams = EMPTY_STRING;
    //Add optional query parameters
    uriParams = uriParams + QUESTION_MARK_SYMBOL + INCLUDE_SPAMTRASH + EQUAL_SYMBOL + filter.includeSpamTrash;
    foreach labelId in filter.labelIds {
        uriParams = labelId != EMPTY_STRING ? uriParams + AMPERSAND_SYMBOL + LABEL_IDS + EQUAL_SYMBOL + labelId:uriParams;
    }
    uriParams = filter.maxResults != EMPTY_STRING ? uriParams + AMPERSAND_SYMBOL + MAX_RESULTS + EQUAL_SYMBOL
                                                        + filter.maxResults : uriParams;
    uriParams = filter.pageToken != EMPTY_STRING ? uriParams +  AMPERSAND_SYMBOL + PAGE_TOKEN + EQUAL_SYMBOL
                                                        + filter.pageToken : uriParams;
    if (filter.q != EMPTY_STRING) {
        match http:encode(filter.q, UTF_8) {
            string encodedQuery => uriParams += AMPERSAND_SYMBOL + QUERY + EQUAL_SYMBOL + encodedQuery;
            error e => {
                GMailError gMailError;
                gMailError.message = "Error occured during encoding the query: " + filter.q + "; message:" + e.message;
                gMailError.cause = e.cause;
                return gMailError;
            }
        }
    }
    getListThreadPath = getListThreadPath + uriParams;
    var httpResponse = httpClient -> get(getListThreadPath, request);
    match handleResponse(httpResponse) {
        json jsonListThreadResponse => {
            ThreadListPage threadListPage;
            if (jsonListThreadResponse.threads != ()) {
                threadListPage.resultSizeEstimate = jsonListThreadResponse.resultSizeEstimate.toString();
                threadListPage.nextPageToken = jsonListThreadResponse.nextPageToken.toString();
                int i = 0;
                //for each thread resource in threads json array of the response
                foreach thread in jsonListThreadResponse.threads {
                    //read thread from the thread id
                    match self.readThread(userId, thread.id.toString(), {}){
                        Thread messageThread => {
                            //Add the thread to the thread list page's list of threads
                            threadListPage.threads[i] = messageThread;
                            i++;
                        }
                        GMailError err => return err;
                    }
                }
            }
            return threadListPage;
        }
        GMailError gMailError => return gMailError;
    }
}

public function GMailConnector::readThread(string userId, string threadId, MessageThreadFilter filter)
                                                                                        returns (Thread)|GMailError {
    endpoint http:Client httpClient = self.client;
    http:Request request = new;
    string uriParams = EMPTY_STRING;
    string readThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId;
    //Add format optional query parameter
    uriParams = filter.format != EMPTY_STRING ? uriParams + AMPERSAND_SYMBOL + FORMAT + EQUAL_SYMBOL
                                                          + filter.format : uriParams;
    //Add the optional meta data headers as query parameters
    foreach metaDataHeader in filter.metadataHeaders {
        uriParams = metaDataHeader != EMPTY_STRING ? uriParams + AMPERSAND_SYMBOL + METADATA_HEADERS + EQUAL_SYMBOL
                                                                                            + metaDataHeader:uriParams;
    }
    readThreadPath = uriParams != EMPTY_STRING ? readThreadPath + QUESTION_MARK_SYMBOL +
                                                            uriParams.subString(1, uriParams.length()) : readThreadPath;
    var httpResponse = httpClient -> get(readThreadPath, request);
    match handleResponse(httpResponse) {
        json jsonReadThreadResponse => {
            //Transform the json mail response from GMail API to Thread type
            match convertJsonThreadToThreadType(jsonReadThreadResponse){
                Thread thread => return thread;
                GMailError gMailError => return gMailError;
            }
        }
        GMailError gMailError => return gMailError;
    }
}

public function GMailConnector::trashThread(string userId, string threadId) returns boolean|GMailError {
    endpoint http:Client httpClient = self.client;
    http:Request request = new;
    string trashThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId
                                + FORWARD_SLASH_SYMBOL + TRASH;
    var httpResponse = httpClient -> post(trashThreadPath, request);
    match handleResponse(httpResponse){
        json jsonTrashThreadResponse => return true;
        GMailError gMailError => return gMailError;
    }
}

public function GMailConnector::untrashThread(string userId, string threadId) returns boolean|GMailError {
    endpoint http:Client httpClient = self.client;
    http:Request request = new;
    string untrashThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId
                                + FORWARD_SLASH_SYMBOL + UNTRASH;
    var httpResponse = httpClient -> post(untrashThreadPath, request);
    match handleResponse(httpResponse) {
        json jsonUntrashThreadResponse => return true;
        GMailError gMailError => return gMailError;
    }
}

public function GMailConnector::deleteThread(string userId, string threadId) returns boolean|GMailError {
    endpoint http:Client httpClient = self.client;
    http:Request request = new;
    string deleteThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId;
    var httpResponse = httpClient -> delete(deleteThreadPath, request);
    match handleResponse(httpResponse){
        json jsonDeleteThreadResponse => return true;
        GMailError gMailError => return gMailError;
    }
}

public function GMailConnector::getUserProfile(string userId) returns UserProfile|GMailError {
    endpoint http:Client httpClient = self.client;
    http:Request request = new;
    string getProfilePath = USER_RESOURCE + userId + PROFILE_RESOURCE;
    var httpResponse = httpClient -> get(getProfilePath, request);
    match handleResponse(httpResponse){
        json jsonProfileResponse => {
            //Transform the json profile response from GMail API to User Profile type
            return convertJsonProfileToUserProfileType(jsonProfileResponse);
        }
        GMailError gMailError => return gMailError;
    }
}
