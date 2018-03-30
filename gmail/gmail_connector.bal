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
import ballerina/user;
import oauth2;

@Description {value:"Struct to define the Gmail Client Connector"}
public struct GmailConnector {
    oauth2:OAuth2Endpoint oauthEndpoint;
    string baseUrl;
}

@Description {value:"list the messages in user's mailbox"}
@Param {value:"userId: The user's email address. The special value *me* can be used to indicate the authenticated user"}
@Param {value:"filter: SearchMessageFilter struct with optional query parameters"}
@Return {value:"Json array of message ids and their thread ids"}
@Return {value:"Next page token of the response"}
@Return {value:"Estimated result set size of the response"}
@Return {value:"GmailError is thrown if any error occurs in sending the request and receiving the response"}
public function <GmailConnector gmailConnector> listAllMails (string userId, SearchMessageFilter filter) returns (MessageListPage)|GmailError {
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
    uriParams = filter.q != EMPTY_STRING ? uriParams + QUERY + filter.q : uriParams;
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

@Description {value:"Create a message"}
@Param {value:"recipient:  email address of the receiver"}
@Param {value:"sender: email address of the sender, the mailbox account"}
@Param {value:"subject: subject of the email"}
@Param {value:"bodyText: body text of the email"}
@Param {value:"options: other optional headers of the email including Cc, Bcc and From"}
public function <GmailConnector gmailConnector> createMessage (string sender, string subject, string bodyText, MessageOptions options) returns (Message) {
    Message message = {};
    message.createMessage(sender, subject, bodyText, options);
    return message;
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
    encodedRequest = encodedRequest.replace("+", "-").replace("/", "_").replace("=","*");
    encodedRequest = encodedRequest.replace("/", "_");
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
@Param {value:"filter: GetMessageFilter struct object with the optional format and metadataHeaders query parameters"}
@Return {value:"Returns GmailError if the message is not sent successfully"}
public function <GmailConnector gmailConnector> readMail (string userId, string messageId, GetMessageFilter filter) returns (Message)|GmailError {
    endpoint oauth2:OAuth2Endpoint oauthEP = gmailConnector.oauthEndpoint;
    http:Request request = {};
    http:Response response = {};
    http:HttpConnectorError connectionError = {};
    GmailError gmailError = {};
    string uriParams = "";
    string readMailPath = "/v1/users/" + userId + "/messages/" + messageId;
    //Add format optional query parameter
    uriParams = filter.format != "" ? uriParams + "&format=" + filter.format : uriParams;
    //Add the optional meta data headers as query parameters
    foreach metaDataHeader in filter.metadataHeaders {
        uriParams = metaDataHeader != "" ? uriParams + "&metadataHeaders=" + metaDataHeader : uriParams;
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
    if (response.statusCode == 200) {
        //Transform the json mail response from Gmail API to Message struct
        Message message = <Message, convertJsonMailToMessage()>jsonMail;
        return message;
    }
    else {
        gmailError.errorMessage = jsonMail.error.message.toString();
        gmailError.statusCode = response.statusCode;
        return gmailError;
    }
}