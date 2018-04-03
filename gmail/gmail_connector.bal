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

import ballerina/io;
import ballerina/mime;
import ballerina/net.http;
import ballerina/net.uri;
import oauth2;

@Description {value:"Struct to define the Gmail Client Connector"}
public struct GmailConnector {
    oauth2:OAuth2Endpoint oauthEndpoint;
    string baseUrl;
}

@Description {value:"List the messages in user's mailbox"}
@Param {value:"userId: The user's email address. The special value *me* can be used to indicate the authenticated user"}
@Param {value:"filter: SearchFilter struct with optional query parameters"}
@Return {value:"MessageListPage struct with array of messages, size estimation and next page token"}
@Return {value:"GmailError is thrown if any error occurs in sending the request and receiving the response"}
public function <GmailConnector gmailConnector> listAllMails (string userId, SearchFilter filter) returns (MessageListPage)|GmailError {
    endpoint oauth2:OAuth2Endpoint oauthEP = gmailConnector.oauthEndpoint;
    http:Request request = {};
    http:Response response = {};
    http:HttpConnectorError connectionError = {};
    GmailError gmailError = {};
    string getListMessagesPath = USER_RESOURCE + userId + MESSAGE_RESOURCE;
    string uriParams = "";
    //Add optional query parameters
    uriParams = uriParams + INCLUDE_SPAMTRASH + filter.includeSpamTrash;
    foreach labelId in filter.labelIds {
        uriParams = labelId != EMPTY_STRING ? uriParams + LABEL_IDS + labelId : uriParams;
    }
    uriParams = filter.maxResults != EMPTY_STRING ? uriParams + MAX_RESULTS + filter.maxResults : uriParams;
    uriParams = filter.pageToken != EMPTY_STRING ? uriParams + PAGE_TOKEN + filter.pageToken : uriParams;
    if (filter.q != EMPTY_STRING) {
        match uri:encode(filter.q, UTF_8) {
            string encodedQuery => uriParams += QUERY + encodedQuery;
            error e => {
                gmailError.errorMessage = "Error occured during encoding the query";
                return gmailError;
            }
        }
    }
    getListMessagesPath = uriParams != EMPTY_STRING ? getListMessagesPath + "?" + uriParams.subString(1, uriParams.length()) : getListMessagesPath;
    var httpResponse = oauthEP -> get(getListMessagesPath, request);
    match httpResponse {
        http:Response res => response = res;
        http:HttpConnectorError connectErr => connectionError = connectErr;
    }
    if (connectionError.message != "") {
        gmailError.errorMessage = connectionError.message;
        gmailError.statusCode = connectionError.statusCode;
        return gmailError;
    }
    json jsonlistMsgResponse;
    match response.getJsonPayload() {
        mime:EntityError err => gmailError.errorMessage = err.message;
        json jsonResponse => jsonlistMsgResponse = jsonResponse;
    }
    if (gmailError.errorMessage != "") {
        return gmailError;
    }
    MessageListPage messageListPage = {};
    if (response.statusCode == STATUS_CODE_200_OK) {
        int i = 0;
        if (jsonlistMsgResponse.messages != null) {
            messageListPage.resultSizeEstimate = jsonlistMsgResponse.resultSizeEstimate != null ? jsonlistMsgResponse.resultSizeEstimate.toString() : EMPTY_STRING;
            messageListPage.nextPageToken = jsonlistMsgResponse.nextPageToken != null ? jsonlistMsgResponse.nextPageToken.toString() : EMPTY_STRING;
            //for each message resource in messages json array of the response
            foreach message in jsonlistMsgResponse.messages {
                //read mail from the message id
                var readMailResponse = gmailConnector.readMail(userId, message.id.toString(), {});
                match readMailResponse {
                    Message mail => {messageListPage.messages[i] = mail; //Add the message to the message list page's list of message
                                     i++;
                    }
                    GmailError e => return e;
                }
            }
        }
        return messageListPage;
    } else {
        gmailError.errorMessage = jsonlistMsgResponse.error.message.toString();
        gmailError.statusCode = response.statusCode;
        return gmailError;
    }
}

@Description {value:"Create the raw base 64 encoded string of the whole message and send the email from the user's
mailbox to its recipient."}
@Param {value:"userId: User's email address. The special value -> me"}
@Param {value:"message: Message to send"}
@Return {value:"Returns the message id of the successfully sent message"}
@Return {value:"Returns the thread id of the succesfully sent message"}
@Return {value:"Returns GmailError if the message is not sent successfully"}
public function <GmailConnector gmailConnector> sendMessage (string userId, Message message) returns (string, string)|GmailError {
    endpoint oauth2:OAuth2Endpoint oauthEP = gmailConnector.oauthEndpoint;
    string concatRequest = EMPTY_STRING;
    //Set the general headers of the message
    concatRequest += TO + ":" + message.headerTo.value + NEW_LINE;
    concatRequest += SUBJECT + ":" + message.headerSubject.value + NEW_LINE;

    if (message.headerFrom.value != EMPTY_STRING) {
        concatRequest += FROM + ":" + message.headerFrom.value + NEW_LINE;
    }
    if (message.headerCc.value != EMPTY_STRING) {
        concatRequest += CC + ":" + message.headerCc.value + NEW_LINE;
    }
    if (message.headerBcc.value != EMPTY_STRING) {
        concatRequest += BCC + ":" + message.headerBcc.value + NEW_LINE;
    }
    //------Start of multipart/mixed mime part (parent mime part)------
    //Set the content type header of top level MIME message part
    concatRequest += message.headerContentType.name + ":" + message.headerContentType.value + NEW_LINE;
    concatRequest += NEW_LINE + "--" + BOUNDARY_STRING + NEW_LINE;
    //------Start of multipart/related mime part------
    concatRequest += CONTENT_TYPE + ":" + MULTIPART_RELATED + "; " + BOUNDARY + "=\"" + BOUNDARY_STRING_1 + "\"" + NEW_LINE;
    concatRequest += NEW_LINE + "--" + BOUNDARY_STRING_1 + NEW_LINE;
    //------Start of multipart/alternative mime part------
    concatRequest += CONTENT_TYPE + ":" + MULTIPART_ALTERNATIVE + "; " + BOUNDARY + "=\"" + BOUNDARY_STRING_2 + "\"" + NEW_LINE;
    //Set the body part : text/plain
    concatRequest += NEW_LINE + "--" + BOUNDARY_STRING_2 + NEW_LINE;
    foreach header in message.plainTextBodyPart.bodyHeaders {
        concatRequest += header.name + ":" + header.value + NEW_LINE;
    }
    concatRequest += NEW_LINE + message.plainTextBodyPart.body + NEW_LINE;
    //Set the body part : text/html
    if (message.htmlBodyPart.body != "") {
        concatRequest += NEW_LINE + "--" + BOUNDARY_STRING_2 + NEW_LINE;
        foreach header in message.htmlBodyPart.bodyHeaders {
            concatRequest += header.name + ":" + header.value + NEW_LINE;
        }
        concatRequest += NEW_LINE + message.htmlBodyPart.body + NEW_LINE + NEW_LINE;
        concatRequest += "--" + BOUNDARY_STRING_2 + "--";
    }
    //------End of multipart/alternative mime part------
    //Set inline Images as body parts
    boolean isExistInlineImageBody = false;
    foreach inlineImagePart in message.inlineImgParts {
        concatRequest += NEW_LINE + "--" + BOUNDARY_STRING_1 + NEW_LINE;
        foreach header in inlineImagePart.bodyHeaders {
            concatRequest += header.name + ":" + header.value + NEW_LINE;
        }
        concatRequest += NEW_LINE + inlineImagePart.body + NEW_LINE + NEW_LINE;
        isExistInlineImageBody = true;
    }
    if (isExistInlineImageBody) {
        concatRequest += "--" + BOUNDARY_STRING_1 + "--" + NEW_LINE;
    }
    //------End of multipart/related mime part------
    //Set attachments
    boolean isExistAttachment = false;
    foreach attachment in message.msgAttachments {
        concatRequest += NEW_LINE + "--" + BOUNDARY_STRING + NEW_LINE;
        foreach header in attachment.attachmentHeaders {
            concatRequest += header.name + ":" + header.value + NEW_LINE;
        }
        concatRequest += NEW_LINE + attachment.attachmentBody + NEW_LINE + NEW_LINE;
        isExistAttachment = true;
    }
    if (isExistInlineImageBody) {
        concatRequest += "--" + BOUNDARY_STRING + "--";
    }
    //------End of multipart/mixed mime part------
    string encodedRequest = util:base64Encode(concatRequest);
    encodedRequest = encodedRequest.replace("+", "-").replace("/", "_");
    //Set the encoded message as raw
    message.raw = encodedRequest;
    http:Request request = {};
    http:Response response = {};
    http:HttpConnectorError connectionError = {};
    GmailError gmailError = {};
    json jsonPayload = {"raw":message.raw};
    string sendMessagePath = USER_RESOURCE + userId + MESSAGE_SEND_RESOURCE;
    request.setJsonPayload(jsonPayload);
    request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
    var sendMessageResponse = oauthEP -> post(sendMessagePath, request);
    match sendMessageResponse {
        http:Response res => response = res;
        http:HttpConnectorError connectErr => connectionError = connectErr;
    }
    if (connectionError.message != "") {
        gmailError.errorMessage = connectionError.message;
        gmailError.statusCode = connectionError.statusCode;
        return gmailError;
    }
    json jsonSendMessageResponse;
    match response.getJsonPayload() {
        mime:EntityError err => gmailError.errorMessage = err.message;
        json jsonResponse => jsonSendMessageResponse = jsonResponse;
    }
    if (gmailError.errorMessage != "") {
        return gmailError;
    }
    if (response.statusCode == STATUS_CODE_200_OK) {
        string id = jsonSendMessageResponse.id.toString();
        string threadId = jsonSendMessageResponse.threadId.toString();
        return (id, threadId);
    } else {
        gmailError.errorMessage = jsonSendMessageResponse.error.message.toString();
        gmailError.statusCode = response.statusCode;
        return gmailError;
    }
}

@Description {value:"Read the specified mail from users mailbox"}
@Param {value:"userId: user's email address. The special value -> me"}
@Param {value:"messageId: message id of the specified mail to retrieve"}
@Param {value:"filter: GetMessageThreadFilter struct object with the optional format and metadataHeaders query parameters"}
@Param {value:"Returns the specified mail as a Message struct"}
@Return {value:"Returns GmailError if the message cannot be read successfully"}
public function <GmailConnector gmailConnector> readMail (string userId, string messageId, GetMessageThreadFilter filter) returns (Message)|GmailError {
    endpoint oauth2:OAuth2Endpoint oauthEP = gmailConnector.oauthEndpoint;
    http:Request request = {};
    http:Response response = {};
    http:HttpConnectorError connectionError = {};
    GmailError gmailError = {};
    string uriParams = "";
    string readMailPath = USER_RESOURCE + userId + MESSAGE_RESOURCE + "/" + messageId;
    //Add format optional query parameter
    uriParams = filter.format != "" ? uriParams + FORMAT + filter.format : uriParams;
    //Add the optional meta data headers as query parameters
    foreach metaDataHeader in filter.metadataHeaders {
        uriParams = metaDataHeader != "" ? uriParams + METADATA_HEADERS + metaDataHeader : uriParams;
    }
    readMailPath = uriParams != "" ? readMailPath + "?" + uriParams.subString(1, uriParams.length()) : readMailPath;
    var httpResponse = oauthEP -> get(readMailPath, request);
    match httpResponse {
        http:Response res => response = res;
        http:HttpConnectorError connectErr => connectionError = connectErr;
    }
    if (connectionError.message != "") {
        gmailError.errorMessage = connectionError.message;
        gmailError.statusCode = connectionError.statusCode;
        return gmailError;
    }
    json jsonMail;
    match response.getJsonPayload() {
        mime:EntityError err => gmailError.errorMessage = err.message;
        json jsonResponse => jsonMail = jsonResponse;
    }
    if (gmailError.errorMessage != "") {
        return gmailError;
    }
    if (response.statusCode == STATUS_CODE_200_OK) {
        //Transform the json mail response from Gmail API to Message struct
        Message message = convertJsonMailToMessage(jsonMail);
        return message;
    }
    else {
        gmailError.errorMessage = jsonMail.error.message.toString();
        gmailError.statusCode = response.statusCode;
        return gmailError;
    }
}

@Description {value:"Gets the specified message attachment from users mailbox"}
@Param {value:"userId: user's email address. The special value -> me"}
@Param {value:"messageId: message id of the specified mail to retrieve"}
@Param {value:"attachmentId: the ID of the attachment."}
@Param {value:"Returns the specified mail as a MessageAttachment struct"}
@Return {value:"Returns GmailError if the attachment read is not successful"}
public function <GmailConnector gmailConnector> getAttachment (string userId, string messageId, string attachmentId) returns (MessageAttachment)|GmailError {
    endpoint oauth2:OAuth2Endpoint oauthEP = gmailConnector.oauthEndpoint;
    http:Request request = {};
    http:Response response = {};
    http:HttpConnectorError connectionError = {};
    GmailError gmailError = {};
    string uriParams = "";
    string getAttachmentPath = USER_RESOURCE + userId + MESSAGE_RESOURCE + "/" + messageId + ATTACHMENT_RESOURCE + attachmentId;
    var httpResponse = oauthEP -> get(getAttachmentPath, request);
    match httpResponse {
        http:Response res => response = res;
        http:HttpConnectorError connectErr => connectionError = connectErr;
    }
    if (connectionError.message != "") {
        gmailError.errorMessage = connectionError.message;
        gmailError.statusCode = connectionError.statusCode;
        return gmailError;
    }
    json jsonAttachment;
    match response.getJsonPayload() {
        mime:EntityError err => gmailError.errorMessage = err.message;
        json jsonResponse => jsonAttachment = jsonResponse;
    }
    if (gmailError.errorMessage != "") {
        return gmailError;
    }
    if (response.statusCode == STATUS_CODE_200_OK) {
        //Transform the json mail response from Gmail API to MessageAttachment struct
        MessageAttachment attachment = convertJsonMessageBodyToMsgAttachment(jsonAttachment);
        return attachment;
    }
    else {
        gmailError.errorMessage = jsonAttachment.error.message.toString();
        gmailError.statusCode = response.statusCode;
        return gmailError;
    }
}

@Description {value:"Move the specified message to the trash"}
@Param {value:"userId: user's email address. The special value me can be used to indicate the authenticated user."}
@Param {value:"messageId: The ID of the message to trash"}
@Return {value:"Returns true if trashing the message is successful"}
@Return {value:"Returns GmailError if trashing is not successdul"}
public function <GmailConnector gmailConnector> trashMail (string userId, string messageId) returns boolean|GmailError {
    endpoint oauth2:OAuth2Endpoint oauthEP = gmailConnector.oauthEndpoint;
    http:Request request = {};
    http:Response response = {};
    http:HttpConnectorError connectionError = {};
    GmailError gmailError = {};
    json jsonPayload = {};
    string trashMailPath = USER_RESOURCE + userId + MESSAGE_RESOURCE + "/" + messageId + "/trash";
    request.setJsonPayload(jsonPayload);
    var httpResponse = oauthEP -> post(trashMailPath, request);
    match httpResponse {
        http:Response res => response = res;
        http:HttpConnectorError connectErr => {connectionError = connectErr;
                                               gmailError.errorMessage = connectionError.message;
                                               gmailError.statusCode = connectionError.statusCode;
                                               return gmailError;
        }
    }
    json jsonTrashMailResponse;
    match response.getJsonPayload() {
        mime:EntityError err => gmailError.errorMessage = err.message;
        json jsonResponse => jsonTrashMailResponse = jsonResponse;
    }
    if (gmailError.errorMessage != "") {
        return gmailError;
    }
    if (response.statusCode == STATUS_CODE_200_OK) {
        return true;
    }
    else {
        gmailError.errorMessage = jsonTrashMailResponse.error.message.toString();
        gmailError.statusCode = response.statusCode;
        return gmailError;
    }
}

@Description {value:"Removes the specified message from the trash"}
@Param {value:"userId: user's email address. The special value me can be used to indicate the authenticated user."}
@Param {value:"messageId: The ID of the message to untrash"}
@Return {value:"Returns true if untrashing the message is successful"}
@Return {value:"Returns GmailError if untrashing is not successdul"}
public function <GmailConnector gmailConnector> untrashMail (string userId, string messageId) returns boolean|GmailError {
    endpoint oauth2:OAuth2Endpoint oauthEP = gmailConnector.oauthEndpoint;
    http:Request request = {};
    http:Response response = {};
    http:HttpConnectorError connectionError = {};
    GmailError gmailError = {};
    json jsonPayload = {};
    string untrashMailPath = USER_RESOURCE + userId + MESSAGE_RESOURCE + "/" + messageId + "/untrash";
    request.setJsonPayload(jsonPayload);
    var httpResponse = oauthEP -> post(untrashMailPath, request);
    match httpResponse {
        http:Response res => response = res;
        http:HttpConnectorError connectErr => {connectionError = connectErr;
                                               gmailError.errorMessage = connectionError.message;
                                               gmailError.statusCode = connectionError.statusCode;
                                               return gmailError;
        }
    }
    json jsonUntrashMailResponse;
    match response.getJsonPayload() {
        mime:EntityError err => gmailError.errorMessage = err.message;
        json jsonResponse => jsonUntrashMailResponse = jsonResponse;
    }
    if (gmailError.errorMessage != "") {
        return gmailError;
    }
    if (response.statusCode == STATUS_CODE_200_OK) {
        return true;
    }
    else {
        gmailError.errorMessage = jsonUntrashMailResponse.error.message.toString();
        gmailError.statusCode = response.statusCode;
        return gmailError;
    }
}

@Description {value:"Immediately and permanently deletes the specified message. This operation cannot be undone."}
@Param {value:"userId: user's email address. The special value me can be used to indicate the authenticated user."}
@Param {value:"messageId: The ID of the message to untrash"}
@Return {value:"Returns true if deleting the message is successful"}
@Return {value:"Returns GmailError if deleting is not successdul"}
public function <GmailConnector gmailConnector> deleteMail (string userId, string messageId) returns boolean|GmailError {
    endpoint oauth2:OAuth2Endpoint oauthEP = gmailConnector.oauthEndpoint;
    http:Request request = {};
    http:Response response = {};
    http:HttpConnectorError connectionError = {};
    GmailError gmailError = {};
    string deleteMailPath = USER_RESOURCE + userId + MESSAGE_RESOURCE + "/" + messageId;
    var httpResponse = oauthEP -> delete(deleteMailPath, request);
    match httpResponse {
        http:Response res => response = res;
        http:HttpConnectorError connectErr => {connectionError = connectErr;
                                               gmailError.errorMessage = connectionError.message;
                                               gmailError.statusCode = connectionError.statusCode;
                                               return gmailError;
        }
    }
    if (response.statusCode == STATUS_CODE_204_NO_CONTENT) {
        return true;
    }
    else {
        match response.getJsonPayload() {
            mime:EntityError err => {gmailError.errorMessage = err.message;
                                     return gmailError;
            }
            json jsonResponse => {   gmailError.errorMessage = jsonResponse.error.message.toString();
                                     gmailError.statusCode = response.statusCode;
                                     return gmailError;
            }
        }
    }
}

@Description {value:"List the threads in user's mailbox"}
@Param {value:"userId: The user's email address. The special value *me* can be used to indicate the authenticated user"}
@Param {value:"filter: SearchFilter struct with optional query parameters"}
@Return {value:"ThreadListPage struct with thread list, result set size estimation and next page token"}
@Return {value:"GmailError is thrown if any error occurs in sending the request and receiving the response"}
public function <GmailConnector gmailConnector> listThreads (string userId, SearchFilter filter) returns (ThreadListPage)|GmailError {
    endpoint oauth2:OAuth2Endpoint oauthEP = gmailConnector.oauthEndpoint;
    http:Request request = {};
    http:Response response = {};
    http:HttpConnectorError connectionError = {};
    GmailError gmailError = {};
    string getListThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE;
    string uriParams = "";
    //Add optional query parameters
    uriParams = uriParams + INCLUDE_SPAMTRASH + filter.includeSpamTrash;
    foreach labelId in filter.labelIds {
        uriParams = labelId != EMPTY_STRING ? uriParams + LABEL_IDS + labelId : uriParams;
    }
    uriParams = filter.maxResults != EMPTY_STRING ? uriParams + MAX_RESULTS + filter.maxResults : uriParams;
    uriParams = filter.pageToken != EMPTY_STRING ? uriParams + PAGE_TOKEN + filter.pageToken : uriParams;
    if (filter.q != EMPTY_STRING) {
        match uri:encode(filter.q, UTF_8) {
            string encodedQuery => uriParams += QUERY + encodedQuery;
            error e => {
                gmailError.errorMessage = "Error occured during encoding the query";
                return gmailError;
            }
        }
    }
    getListThreadPath = uriParams != EMPTY_STRING ? getListThreadPath + "?" + uriParams.subString(1, uriParams.length()) : getListThreadPath;
    var httpResponse = oauthEP -> get(getListThreadPath, request);
    match httpResponse {
        http:Response res => response = res;
        http:HttpConnectorError connectErr => connectionError = connectErr;
    }
    if (connectionError.message != "") {
        gmailError.errorMessage = connectionError.message;
        gmailError.statusCode = connectionError.statusCode;
        return gmailError;
    }
    json jsonlistThreadResponse;
    match response.getJsonPayload() {
        mime:EntityError err => gmailError.errorMessage = err.message;
        json jsonResponse => jsonlistThreadResponse = jsonResponse;
    }
    if (gmailError.errorMessage != "") {
        return gmailError;
    }
    ThreadListPage threadListPage = {};
    if (response.statusCode == STATUS_CODE_200_OK) {
        int i = 0;
        if (jsonlistThreadResponse.threads != null) {
            threadListPage.resultSizeEstimate = jsonlistThreadResponse.resultSizeEstimate != null ? jsonlistThreadResponse.resultSizeEstimate.toString() : EMPTY_STRING;
            threadListPage.nextPageToken = jsonlistThreadResponse.nextPageToken != null ? jsonlistThreadResponse.nextPageToken.toString() : EMPTY_STRING;
            //for each thread resource in threads json array of the response
            foreach thread in jsonlistThreadResponse.threads {
                //read thread from the thread id
                var readThreadResponse = gmailConnector.readThread(userId, thread.id.toString(), {});
                match readThreadResponse {
                    Thread messageThread => {threadListPage.threads[i] = messageThread; //Add the thread to the thread list page's list of threads
                                             i++;
                    }
                    GmailError e => return e;
                }
            }
        }
        return threadListPage;
    } else {
        gmailError.errorMessage = jsonlistThreadResponse.error.message.toString();
        gmailError.statusCode = response.statusCode;
        return gmailError;
    }
}

@Description {value:"Read the specified thread from users mailbox"}
@Param {value:"userId: user's email address. The special value -> me"}
@Param {value:"threadId: thread id of the specified mail to retrieve"}
@Param {value:"filter: GetMessageThreadFilter struct object with the optional format and metadataHeaders query parameters"}
@Param {value:"Returns the specified thread as a Thread struct"}
@Return {value:"Returns GmailError if the thread cannot be read successfully"}
public function <GmailConnector gmailConnector> readThread (string userId, string threadId, GetMessageThreadFilter filter) returns (Thread)|GmailError {
    endpoint oauth2:OAuth2Endpoint oauthEP = gmailConnector.oauthEndpoint;
    http:Request request = {};
    http:Response response = {};
    http:HttpConnectorError connectionError = {};
    GmailError gmailError = {};
    string uriParams = "";
    string readThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + "/" + threadId;
    //Add format optional query parameter
    uriParams = filter.format != "" ? uriParams + FORMAT + filter.format : uriParams;
    //Add the optional meta data headers as query parameters
    foreach metaDataHeader in filter.metadataHeaders {
        uriParams = metaDataHeader != "" ? uriParams + METADATA_HEADERS + metaDataHeader : uriParams;
    }
    readThreadPath = uriParams != "" ? readThreadPath + "?" + uriParams.subString(1, uriParams.length()) : readThreadPath;
    var httpResponse = oauthEP -> get(readThreadPath, request);
    match httpResponse {
        http:Response res => response = res;
        http:HttpConnectorError connectErr => connectionError = connectErr;
    }
    if (connectionError.message != "") {
        gmailError.errorMessage = connectionError.message;
        gmailError.statusCode = connectionError.statusCode;
        return gmailError;
    }
    json jsonThread;
    match response.getJsonPayload() {
        mime:EntityError err => gmailError.errorMessage = err.message;
        json jsonResponse => jsonThread = jsonResponse;
    }
    if (gmailError.errorMessage != "") {
        return gmailError;
    }
    if (response.statusCode == STATUS_CODE_200_OK) {
        //Transform the json mail response from Gmail API to Thread struct
        Thread thread = convertJsonThreadToThreadStruct(jsonThread);
        return thread;
    }
    else {
        gmailError.errorMessage = jsonThread.error.message.toString();
        gmailError.statusCode = response.statusCode;
        return gmailError;
    }
}

@Description {value:"Move the specified thread to the trash"}
@Param {value:"userId: user's email address. The special value me can be used to indicate the authenticated user."}
@Param {value:"threadId: The ID of the thread to trash"}
@Return {value:"Returns true if trashing the thrad is successful"}
@Return {value:"Returns GmailError if trashing is not successdul"}
public function <GmailConnector gmailConnector> trashThread (string userId, string threadId) returns boolean|GmailError {
    endpoint oauth2:OAuth2Endpoint oauthEP = gmailConnector.oauthEndpoint;
    http:Request request = {};
    http:Response response = {};
    http:HttpConnectorError connectionError = {};
    GmailError gmailError = {};
    json jsonPayload = {};
    string trashThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + "/" + threadId + "/trash";
    request.setJsonPayload(jsonPayload);
    var httpResponse = oauthEP -> post(trashThreadPath, request);
    match httpResponse {
        http:Response res => response = res;
        http:HttpConnectorError connectErr => {connectionError = connectErr;
                                               gmailError.errorMessage = connectionError.message;
                                               gmailError.statusCode = connectionError.statusCode;
                                               return gmailError;
        }
    }
    json jsonTrashThreadResponse;
    match response.getJsonPayload() {
        mime:EntityError err => gmailError.errorMessage = err.message;
        json jsonResponse => jsonTrashThreadResponse = jsonResponse;
    }
    if (gmailError.errorMessage != "") {
        return gmailError;
    }
    if (response.statusCode == STATUS_CODE_200_OK) {
        return true;
    }
    else {
        gmailError.errorMessage = jsonTrashThreadResponse.error.message.toString();
        gmailError.statusCode = response.statusCode;
        return gmailError;
    }
}

@Description {value:"Removes the specified thread from the trash"}
@Param {value:"userId: user's email address. The special value me can be used to indicate the authenticated user."}
@Param {value:"threadId: The ID of the thread to untrash"}
@Return {value:"Returns true if untrashing the thread is successful"}
@Return {value:"Returns GmailError if untrashing is not successdul"}
public function <GmailConnector gmailConnector> untrashThread (string userId, string threadId) returns boolean|GmailError {
    endpoint oauth2:OAuth2Endpoint oauthEP = gmailConnector.oauthEndpoint;
    http:Request request = {};
    http:Response response = {};
    http:HttpConnectorError connectionError = {};
    GmailError gmailError = {};
    json jsonPayload = {};
    string untrashThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + "/" + threadId + "/untrash";
    request.setJsonPayload(jsonPayload);
    var httpResponse = oauthEP -> post(untrashThreadPath, request);
    match httpResponse {
        http:Response res => response = res;
        http:HttpConnectorError connectErr => {connectionError = connectErr;
                                               gmailError.errorMessage = connectionError.message;
                                               gmailError.statusCode = connectionError.statusCode;
                                               return gmailError;
        }
    }
    json jsonUntrashThreadResponse;
    match response.getJsonPayload() {
        mime:EntityError err => gmailError.errorMessage = err.message;
        json jsonResponse => jsonUntrashThreadResponse = jsonResponse;
    }
    if (gmailError.errorMessage != "") {
        return gmailError;
    }
    if (response.statusCode == STATUS_CODE_200_OK) {
        return true;
    }
    else {
        gmailError.errorMessage = jsonUntrashThreadResponse.error.message.toString();
        gmailError.statusCode = response.statusCode;
        return gmailError;
    }
}

@Description {value:"Immediately and permanently deletes the specified thread. This operation cannot be undone."}
@Param {value:"userId: user's email address. The special value me can be used to indicate the authenticated user."}
@Param {value:"threadId: The ID of the thread to untrash"}
@Return {value:"Returns true if deleting the thread is successful"}
@Return {value:"Returns GmailError if deleting is not successdul"}
public function <GmailConnector gmailConnector> deleteThread (string userId, string threadId) returns boolean|GmailError {
    endpoint oauth2:OAuth2Endpoint oauthEP = gmailConnector.oauthEndpoint;
    http:Request request = {};
    http:Response response = {};
    http:HttpConnectorError connectionError = {};
    GmailError gmailError = {};
    string deleteThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + "/" + threadId;
    var httpResponse = oauthEP -> delete(deleteThreadPath, request);
    match httpResponse {
        http:Response res => response = res;
        http:HttpConnectorError connectErr => {connectionError = connectErr;
                                               gmailError.errorMessage = connectionError.message;
                                               gmailError.statusCode = connectionError.statusCode;
                                               return gmailError;
        }
    }
    if (response.statusCode == STATUS_CODE_204_NO_CONTENT) {
        return true;
    }
    else {
        match response.getJsonPayload() {
            mime:EntityError err => {gmailError.errorMessage = err.message;
                                     return gmailError;
            }
            json jsonResponse => {   gmailError.errorMessage = jsonResponse.error.message.toString();
                                     gmailError.statusCode = response.statusCode;
                                     return gmailError;
            }
        }
    }
}

@Description {value:"Get the current user's Gmail Profile"}
@Param {value:"userId: user's email address. The special value me can be used to indicate the authenticated user."}
@Return {value:"Returns UserProfile struct if success"}
@Return {value:"Returns GmailError if unsuccessful"}
public function <GmailConnector gmailConnector> getUserProfile (string userId) returns UserProfile|GmailError {
    endpoint oauth2:OAuth2Endpoint oauthEP = gmailConnector.oauthEndpoint;
    http:Request request = {};
    http:Response response = {};
    http:HttpConnectorError connectionError = {};
    GmailError gmailError = {};
    string uriParams = "";
    string getProfilePath = USER_RESOURCE + userId + PROFILE_RESOURCE;
    var httpResponse = oauthEP -> get(getProfilePath, request);
    match httpResponse {
        http:Response res => response = res;
        http:HttpConnectorError connectErr => connectionError = connectErr;
    }
    if (connectionError.message != "") {
        gmailError.errorMessage = connectionError.message;
        gmailError.statusCode = connectionError.statusCode;
        return gmailError;
    }
    json jsonProfile;
    match response.getJsonPayload() {
        mime:EntityError err => gmailError.errorMessage = err.message;
        json jsonResponse => jsonProfile = jsonResponse;
    }
    if (gmailError.errorMessage != "") {
        return gmailError;
    }
    if (response.statusCode == STATUS_CODE_200_OK) {
        //Transform the json profile response from Gmail API to User Profile struct
        UserProfile profile = convertJsonProfileToUserProfileStruct(jsonProfile);
        return profile;
    }
    else {
        gmailError.errorMessage = jsonProfile.error.message.toString();
        gmailError.statusCode = response.statusCode;
        return gmailError;
    }
}



