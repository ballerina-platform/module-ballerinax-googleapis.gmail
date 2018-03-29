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

//Global Http Client
http:HttpClient httpClientGlobal = {};

@Description {value:"Struct to define the Gmail Client Connector"}
public struct GmailConnector {
    string accessToken;
    string clientId;
    string clientSecret;
    string refreshToken;
    string refreshTokenEP;
    string refreshTokenPath;
    string baseUrl;
    http:HttpClient httpClient;
    http:ClientEndpointConfiguration clientConfig;
    oauth2:OAuth2Connector oAuth2Connector;
}

boolean isOAuth2Initialized = false;

@Description {value:"Set up gmail environment"}
public function <GmailConnector gmailConnector> initOAuth2 () {
    gmailConnector.oAuth2Connector = {accessToken:gmailConnector.accessToken, clientId:gmailConnector.clientId,
                                                 clientSecret:gmailConnector.clientSecret,
                                                 refreshToken:gmailConnector.refreshToken,
                                                 refreshTokenEP:gmailConnector.refreshTokenEP,
                                                 refreshTokenPath:gmailConnector.refreshTokenPath,
                                                 baseUrl:gmailConnector.baseUrl,
                                                 httpClient:gmailConnector.httpClient,
                                                 clientConfig:gmailConnector.clientConfig, useUriParams:true};
    isOAuth2Initialized = true;
}

@Description {value:"list the messages in user's mailbox"}
@Param {value:"includeSpamTrash:  Includes messages from SPAM and TRASH in the results."}
@Param {value:"userId: The user's email address. The special value *me* can be used to indicate the authenticated user."}
@Param {value:"labelIds[]: Only return messages with labels that match all of the specified label IDs."}
@Param {value:"maxResults: Maximum number of messages to return"}
@Param {value:"pageToken: Page token to retrieve a specific page of results in the list."}
@Param {value:"q: Only returns messages matching the specified query. Supports the same query format as the Gmail search box."}
@Return {value:"Json array of message ids and their thread ids"}
@Return {value:"Next page token of the response"}
@Return {value:"Estimated result set size of the response"}
@Return {value:"GmailError is thrown if any error occurs in sending the request and receiving the response"}
public function <GmailConnector gmailConnector> listAllMails (string userId, string includeSpamTrash, string labelIds, string maxResults, string pageToken, string q) returns (json[], string, string)|GmailError {
    http:Request request = {};
    http:Response response = {};
    http:HttpConnectorError connectionError = {};
    GmailError gmailError = {};
    string getListMessagesPath = USER_RESOURCE + userId + MESSAGE_RESOURCE;
    string uriParams = "";
    uriParams = includeSpamTrash != EMPTY_STRING ? uriParams + INCLUDE_SPAMTRASH + includeSpamTrash : uriParams + EMPTY_STRING;
    uriParams = labelIds != EMPTY_STRING ? uriParams + LABEL_IDS + labelIds : uriParams + EMPTY_STRING;
    uriParams = maxResults != "" ? uriParams + MAX_RESULTS + maxResults : uriParams + EMPTY_STRING;
    uriParams = pageToken != EMPTY_STRING ? uriParams + PAGE_TOKEN + pageToken : uriParams + EMPTY_STRING;
    uriParams = q != EMPTY_STRING ? uriParams + QUERY + q : uriParams + EMPTY_STRING;
    getListMessagesPath = uriParams != EMPTY_STRING ? getListMessagesPath + "?" + uriParams.subString(1, uriParams.length()) : EMPTY_STRING;
    if (!isOAuth2Initialized) {
        gmailError.errorMessage = ERROR_CONNECTOR_NOT_INITALIZED;
        return gmailError;
    }
    match gmailConnector.oAuth2Connector.get(getListMessagesPath, request) {
        http:Response res => response = res;
        http:HttpConnectorError connectErr => connectionError = connectErr;
    }
    if (connectionError.message != "") {
        gmailError.errorMessage = connectionError.message;
        gmailError.statusCode = connectionError.statusCode;
        return gmailError;
    }
    json jsonMessageIDResponse;
    match response.getJsonPayload() {
        mime:EntityError err => gmailError.errorMessage = err.message;
        json jsonResponse => jsonMessageIDResponse = jsonResponse;
    }
    if (gmailError.errorMessage != "") {
        return gmailError;
    }
    json[] messageIdJSONArray;
    string nextPageToken;
    string resultSizeEstimate;
    if (response.statusCode == STATUS_CODE_200_OK) {
        int i = 0;
        if (jsonMessageIDResponse.messages != null) {
            //get all the message id and thread ids into meesageIdJSONArray
            foreach element in jsonMessageIDResponse.messages {
                messageIdJSONArray[i] = jsonMessageIDResponse.messages[i];
                i++;
            }
            resultSizeEstimate = jsonMessageIDResponse.resultSizeEstimate != null ? jsonMessageIDResponse.resultSizeEstimate.toString() : EMPTY_STRING;
            nextPageToken = jsonMessageIDResponse.nextPageToken != null ? jsonMessageIDResponse.nextPageToken.toString() : EMPTY_STRING;
        }
        return (messageIdJSONArray, nextPageToken, resultSizeEstimate);
    } else {
        gmailError.errorMessage = jsonMessageIDResponse.error.message.toString();
        gmailError.statusCode = response.statusCode;
        return gmailError;
    }
}

////TODO: Write read mail. Only support a single meta data header at the moment
//public function <GmailConnector gmailConnector> readMail (string userId, string messageId, string format, string metaDataHeaders) returns (Message)|GmailError {
//    http:Request request = {};
//    GmailError gmailError = {};
//    string uriParams;
//    string readMailPath = "/v1/users/" + userId + "/messages/" + messageId;
//    uriParams = format != "null" ? uriParams + "&format=" + format : "";
//    uriParams = metaDataHeaders != "null" ? uriParams + "&metadataHeaders=" + metaDataHeaders : "";
//
//    readMailPath = uriParams != "" ? readMailPath + "?" + uriParams.subString(1, uriParams.length()) : "";
//    io:println(readMailPath);
//    if (!isOAuth2Initialized) {
//        gmailError.errorMessage = "Connector is not initalized. Invoke init method first.";
//        return gmailError;
//    }
//    var httpResponse = gmailConnector.oAuth2Connector.get(readMailPath, request);
//    match httpResponse {
//        http:HttpConnectorError err => { gmailError.errorMessage = err.message;
//                                         gmailError.statusCode = err.statusCode;
//                                         return gmailError;
//        }
//        http:Response response => match response.getJsonPayload() {
//                                      mime:EntityError err => {
//                                          gmailError.errorMessage = err.message;
//                                          return gmailError;
//                                      }
//                                      json jsonResponse => {
//                                          if (response.statusCode == 200) {
//                                              return <Message, convertJsonToMessage()>jsonResponse;
//                                          }
//                                          else {
//                                              gmailError.errorMessage = jsonResponse.error.message.toString();
//                                              gmailError.statusCode = response.statusCode;
//                                              return gmailError;
//                                          }
//                                      }
//                                  }
//    }
//}

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
public function <GmailConnector gmailConnector> sendMessage (string userId, Message message) returns (string,string)|GmailError {
    if (!isOAuth2Initialized) {
        GmailError gmailError = {};
        gmailError.errorMessage = ERROR_CONNECTOR_NOT_INITALIZED;
        return gmailError;
    }
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
    encodedRequest = encodedRequest.replace("+", "-");
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
    match gmailConnector.oAuth2Connector.post(sendMessagePath, request) {
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