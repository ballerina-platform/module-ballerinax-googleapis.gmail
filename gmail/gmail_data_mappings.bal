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

import ballerina/log;

//Includes all the transforming functions which transform required json to type object/record and vice versa

documentation{Transforms JSON mail object into Message.
    P{{sourceMailJsonObject}} - Json mail object
    R{{}} - If successful, returns Message type. Else returns GmailError.
}
function convertJsonMailToMessage(json sourceMailJsonObject) returns Message|GmailError {
    Message targetMessageType;
    targetMessageType.id = sourceMailJsonObject.id.toString();
    targetMessageType.threadId = sourceMailJsonObject.threadId.toString();
    match <json[]>sourceMailJsonObject.labelIds {
        json[] labelIds => {
            targetMessageType.labelIds = convertJSONArrayToStringArray(labelIds);
        }
        //No key named labelIds in the response.
        error err => log:printDebug("Mail response:" + targetMessageType.id + " does not contain any label Id.");
    }
    targetMessageType.raw = sourceMailJsonObject.raw.toString();
    targetMessageType.snippet = sourceMailJsonObject.snippet.toString();
    targetMessageType.historyId = sourceMailJsonObject.historyId.toString();
    targetMessageType.internalDate = sourceMailJsonObject.internalDate.toString();
    targetMessageType.sizeEstimate = sourceMailJsonObject.sizeEstimate.toString();
    targetMessageType.headers = sourceMailJsonObject.payload.headers != () ?
                          convertJsonHeadersToHeaderMap(sourceMailJsonObject.payload.headers):targetMessageType.headers;
    targetMessageType.headerTo = targetMessageType.headers.hasKey(TO) ? <string>targetMessageType.headers[TO] :
                                                                                                           EMPTY_STRING;
    targetMessageType.headerFrom = targetMessageType.headers.hasKey(FROM) ? <string>targetMessageType.headers[FROM] :
                                                                                                           EMPTY_STRING;
    targetMessageType.headerContentType = targetMessageType.headers.hasKey(CONTENT_TYPE) ?
                                                         <string>targetMessageType.headers[CONTENT_TYPE] : EMPTY_STRING;
    targetMessageType.headerBcc = targetMessageType.headers.hasKey(BCC) ?
                                                                  <string>targetMessageType.headers[BCC] : EMPTY_STRING;
    targetMessageType.headerCc = targetMessageType.headers.hasKey(CC) ?
                                                                   <string>targetMessageType.headers[CC] : EMPTY_STRING;
    targetMessageType.headerSubject = targetMessageType.headers.hasKey(SUBJECT) ?
                                                              <string>targetMessageType.headers[SUBJECT] : EMPTY_STRING;
    targetMessageType.headerDate = targetMessageType.headers.hasKey(DATE) ?
                                                                 <string>targetMessageType.headers[DATE] : EMPTY_STRING;
    targetMessageType.mimeType = sourceMailJsonObject.payload.mimeType.toString();
    string payloadMimeType = sourceMailJsonObject.payload.mimeType.toString();
    if (sourceMailJsonObject.payload != ()){
        match getMessageBodyPartFromPayloadByMimeType(sourceMailJsonObject.payload, TEXT_PLAIN){
            MessageBodyPart body => targetMessageType.plainTextBodyPart = body;
            GmailError gmailError => return gmailError;
        }
        match getMessageBodyPartFromPayloadByMimeType(sourceMailJsonObject.payload, TEXT_HTML){
            MessageBodyPart body => targetMessageType.htmlBodyPart = body;
            GmailError gmailError => return gmailError;
        }
        match getInlineImgPartsFromPayloadByMimeType(sourceMailJsonObject.payload, []){
            MessageBodyPart[] bodyParts => targetMessageType.inlineImgParts = bodyParts;
            GmailError gmailError => return gmailError;
        }
    }
    targetMessageType.msgAttachments = sourceMailJsonObject.payload != () ?
                                                   getAttachmentPartsFromPayload(sourceMailJsonObject.payload, []) : [];
    return targetMessageType;
}

documentation{Transforms MIME Message Part Json into MessageBody.
    P{{sourceMessagePartJsonObject}} - Json message part object
    R{{}} - If successful, returns MessageBodyPart type. Else returns GmailError.
}
function convertJsonMsgBodyPartToMsgBodyType(json sourceMessagePartJsonObject) returns MessageBodyPart|GmailError {
    MessageBodyPart targetMessageBodyType;
    if (sourceMessagePartJsonObject != ()){
        targetMessageBodyType.fileId = sourceMessagePartJsonObject.body.attachmentId.toString();
        match decodeMsgBodyData(sourceMessagePartJsonObject){
            string decodeBody => targetMessageBodyType.body = decodeBody;
            GmailError gmailError => return gmailError;
        }
        targetMessageBodyType.size = sourceMessagePartJsonObject.body.size.toString();
        targetMessageBodyType.mimeType = sourceMessagePartJsonObject.mimeType.toString();
        targetMessageBodyType.partId = sourceMessagePartJsonObject.partId.toString();
        targetMessageBodyType.fileName = sourceMessagePartJsonObject.filename.toString();
        targetMessageBodyType.bodyHeaders = sourceMessagePartJsonObject.headers != () ?
        convertJsonHeadersToHeaderMap(sourceMessagePartJsonObject.headers) :
        targetMessageBodyType.bodyHeaders;
    }
    return targetMessageBodyType;
}

documentation{Transforms MIME Message Part JSON into MessageAttachment.
    P{{sourceMessagePartJsonObject}} - Json message part object
    R{{}}- MessageAttachment type object
}
function convertJsonMsgPartToMsgAttachment(json sourceMessagePartJsonObject) returns MessageAttachment {
    MessageAttachment targetMessageAttachmentType;
    targetMessageAttachmentType.attachmentFileId = sourceMessagePartJsonObject.body.attachmentId.toString();
    targetMessageAttachmentType.attachmentBody = sourceMessagePartJsonObject.body.data.toString();
    targetMessageAttachmentType.size = sourceMessagePartJsonObject.body.size.toString();
    targetMessageAttachmentType.mimeType = sourceMessagePartJsonObject.mimeType.toString();
    targetMessageAttachmentType.partId = sourceMessagePartJsonObject.partId.toString();
    targetMessageAttachmentType.attachmentFileName = sourceMessagePartJsonObject.filename.toString();
    targetMessageAttachmentType.attachmentHeaders = sourceMessagePartJsonObject.headers != () ?
    convertJsonHeadersToHeaderMap(sourceMessagePartJsonObject.headers) : targetMessageAttachmentType.attachmentHeaders;
    return targetMessageAttachmentType;
}

documentation{Transforms single body of MIME Message part into MessageAttachment.
    P{{sourceMessageBodyJsonObject}} - Json message body object.
    R{{}} - Returns MessageAttachment type.
}
function convertJsonMessageBodyToMsgAttachment(json sourceMessageBodyJsonObject) returns MessageAttachment {
    MessageAttachment targetMessageAttachmentType;
    targetMessageAttachmentType.attachmentFileId = sourceMessageBodyJsonObject.attachmentId.toString();
    targetMessageAttachmentType.attachmentBody = sourceMessageBodyJsonObject.data.toString();
    targetMessageAttachmentType.size = sourceMessageBodyJsonObject.size.toString();
    return targetMessageAttachmentType;
}

documentation{Transforms mail thread Json object into Thread.
    P{{sourceThreadJsonObject}} - Json message thread object.
    R{{}} - If successful returns Thread type. Else returns GmailError.
}
function convertJsonThreadToThreadType(json sourceThreadJsonObject) returns Thread|GmailError {
    Thread targetThreadType;
    targetThreadType.id = sourceThreadJsonObject.id.toString();
    targetThreadType.historyId = sourceThreadJsonObject.historyId.toString();
    match <json[]>sourceThreadJsonObject.messages{
        json[] messages => {
            match (convertToMessageArray(messages)){
                Message[] msgs => targetThreadType.messages = msgs;
                GmailError gmailError => return gmailError;
            }
        }
        //No key named messages in the json response
        error err => log:printDebug("Thread response:" + targetThreadType.id + " does not contain any messages");
    }
    return targetThreadType;
}

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

documentation{Transforms user profile json object into UserProfile.
    P{{sourceUserProfileJsonObject}} - Json user profile object
    R{{}} - UserProfile type
}
function convertJsonProfileToUserProfileType(json sourceUserProfileJsonObject) returns UserProfile {
    UserProfile targetUserProfile;
    targetUserProfile.emailAddress = sourceUserProfileJsonObject.emailAddress.toString();
    targetUserProfile.threadsTotal = sourceUserProfileJsonObject.threadsTotal.toString();
    targetUserProfile.messagesTotal = sourceUserProfileJsonObject.messagesTotal.toString();
    targetUserProfile.historyId = sourceUserProfileJsonObject.historyId.toString();
    return targetUserProfile;
}

documentation{Transforms message list json object into MessageListPage.
    P{{sourceMsgListJsonObject}} - Json Messsage List object
    R{{}} - MessageListPage type
}
function convertJsonMsgListToMessageListPageType(json sourceMsgListJsonObject) returns MessageListPage {
    MessageListPage targetMsgListPage;
    targetMsgListPage.resultSizeEstimate = sourceMsgListJsonObject.resultSizeEstimate.toString();
    targetMsgListPage.nextPageToken = sourceMsgListJsonObject.nextPageToken.toString();
    //for each message resource in messages json array of the response
    foreach message in sourceMsgListJsonObject.messages {
        //Add the message map with Id and thread Id as keys to the array
        targetMsgListPage.messages[lengthof targetMsgListPage.messages] = {"messageId":message.id.toString(),
            "threadId":message.threadId.toString()};
    }
    return targetMsgListPage;
}

documentation{Transforms thread list json object into ThreadListPage.
    P{{sourceThreadListJsonObject}} - Json Thead List object
    R{{}} - ThreadListPage type
}
function convertJsonThreadListToThreadListPageType(json sourceThreadListJsonObject) returns ThreadListPage {
    ThreadListPage targetThreadListPage;
    targetThreadListPage.resultSizeEstimate = sourceThreadListJsonObject.resultSizeEstimate.toString();
    targetThreadListPage.nextPageToken = sourceThreadListJsonObject.nextPageToken.toString();
    //for each thread resource in threads json array of the response
    foreach thread in sourceThreadListJsonObject.threads {
        //Add the thread map with Id, snippet and history Id as keys to the array of thread maps
        targetThreadListPage.threads[lengthof targetThreadListPage.threads] = {"threadId":thread.id.toString(),
            "snippet":thread.snippet.toString(),
            "historyId":thread.historyId.toString()};
    }
    return targetThreadListPage;
}

documentation{Converts the message part header json array to headers.

    P{{jsonMsgPartHeaders}} - Json array of message part headers
    R{{}} - map of headers
}
function convertJsonHeadersToHeaderMap(json jsonMsgPartHeaders) returns map {
    map headers;
    foreach jsonHeader in jsonMsgPartHeaders {
        headers[jsonHeader.name.toString()] = jsonHeader.value.toString();
    }
    return headers;
}
