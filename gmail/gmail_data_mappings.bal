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

documentation{
    Transforms JSON mail object into Message.

    P{{sourceMessageJsonObject}} Json mail object
    R{{}} If successful, returns Message type. Else returns GmailError.
}
function convertJsonMessageToMessage(json sourceMessageJsonObject) returns Message|GmailError {
    Message targetMessageType;
    targetMessageType.id = sourceMessageJsonObject.id != () ? sourceMessageJsonObject.id.toString() : EMPTY_STRING;
    targetMessageType.threadId = sourceMessageJsonObject.threadId != () ? sourceMessageJsonObject.threadId.toString() :
                                                                                                          EMPTY_STRING;
    match <json[]>sourceMessageJsonObject.labelIds {
        json[] labelIds => {
            targetMessageType.labelIds = convertJSONArrayToStringArray(labelIds);
        }
        //No key named labelIds in the response.
        error err => log:printDebug("Message response:" + targetMessageType.id + " does not contain a label Id array.");
    }
    targetMessageType.raw = sourceMessageJsonObject.raw != () ? sourceMessageJsonObject.raw.toString() : EMPTY_STRING;
    targetMessageType.snippet = sourceMessageJsonObject.snippet != () ? sourceMessageJsonObject.snippet.toString()
                                                                                                        : EMPTY_STRING;
    targetMessageType.historyId = sourceMessageJsonObject.historyId != () ? sourceMessageJsonObject.historyId.toString()
                                                                                                        : EMPTY_STRING;
    targetMessageType.internalDate = sourceMessageJsonObject.internalDate != () ?
                                                        sourceMessageJsonObject.internalDate.toString() : EMPTY_STRING;
    targetMessageType.sizeEstimate = sourceMessageJsonObject.sizeEstimate != () ?
                                                        sourceMessageJsonObject.sizeEstimate.toString() : EMPTY_STRING;
    targetMessageType.headers = sourceMessageJsonObject.payload.headers != () ?
                       convertJsonHeadersToHeaderMap(sourceMessageJsonObject.payload.headers):targetMessageType.headers;
    targetMessageType.headerDate = getKeyValueFromMap(targetMessageType.headers, DATE);
    targetMessageType.headerSubject = getKeyValueFromMap(targetMessageType.headers, SUBJECT);
    targetMessageType.headerTo = getKeyValueFromMap(targetMessageType.headers, TO);
    targetMessageType.headerFrom = getKeyValueFromMap(targetMessageType.headers, FROM);
    targetMessageType.headerContentType = getKeyValueFromMap(targetMessageType.headers, CONTENT_TYPE);
    targetMessageType.headerCc = getKeyValueFromMap(targetMessageType.headers, CC);
    targetMessageType.headerBcc = getKeyValueFromMap(targetMessageType.headers, BCC);
    targetMessageType.mimeType = sourceMessageJsonObject.payload.mimeType != () ?
                                                     sourceMessageJsonObject.payload.mimeType.toString() : EMPTY_STRING;
    string payloadMimeType = sourceMessageJsonObject.payload.mimeType != () ?
                                                     sourceMessageJsonObject.payload.mimeType.toString() : EMPTY_STRING;
    if (sourceMessageJsonObject.payload != ()){
        match getMessageBodyPartFromPayloadByMimeType(sourceMessageJsonObject.payload, TEXT_PLAIN){
            MessageBodyPart body => targetMessageType.plainTextBodyPart = body;
            GmailError gmailError => return gmailError;
        }
        match getMessageBodyPartFromPayloadByMimeType(sourceMessageJsonObject.payload, TEXT_HTML){
            MessageBodyPart body => targetMessageType.htmlBodyPart = body;
            GmailError gmailError => return gmailError;
        }
        match getInlineImgPartsFromPayloadByMimeType(sourceMessageJsonObject.payload, []){
            MessageBodyPart[] bodyParts => targetMessageType.inlineImgParts = bodyParts;
            GmailError gmailError => return gmailError;
        }
    }
    targetMessageType.msgAttachments = sourceMessageJsonObject.payload != () ?
                                                getAttachmentPartsFromPayload(sourceMessageJsonObject.payload, []) : [];
    return targetMessageType;
}

documentation{
    Transforms MIME Message Part Json into MessageBody.

    P{{sourceMessagePartJsonObject}} Json message part object
    R{{}} If successful, returns MessageBodyPart type. Else returns GmailError.
}
function convertJsonMsgBodyPartToMsgBodyType(json sourceMessagePartJsonObject) returns MessageBodyPart|GmailError {
    MessageBodyPart targetMessageBodyType;
    if (sourceMessagePartJsonObject != ()){
        targetMessageBodyType.fileId = sourceMessagePartJsonObject.body.attachmentId != () ?
                                                sourceMessagePartJsonObject.body.attachmentId.toString() : EMPTY_STRING;
        match decodeMsgBodyData(sourceMessagePartJsonObject){
            string decodeBody => targetMessageBodyType.body = decodeBody;
            GmailError gmailError => return gmailError;
        }
        targetMessageBodyType.size = sourceMessagePartJsonObject.body.size != () ?
                                                        sourceMessagePartJsonObject.body.size.toString() : EMPTY_STRING;
        targetMessageBodyType.mimeType = sourceMessagePartJsonObject.mimeType != () ?
                                                         sourceMessagePartJsonObject.mimeType.toString() : EMPTY_STRING;
        targetMessageBodyType.partId = sourceMessagePartJsonObject.partId != () ?
                                                           sourceMessagePartJsonObject.partId.toString() : EMPTY_STRING;
        targetMessageBodyType.fileName = sourceMessagePartJsonObject.filename != () ?
                                                         sourceMessagePartJsonObject.filename.toString() : EMPTY_STRING;
        targetMessageBodyType.bodyHeaders = sourceMessagePartJsonObject.headers != () ?
                 convertJsonHeadersToHeaderMap(sourceMessagePartJsonObject.headers) : targetMessageBodyType.bodyHeaders;
    }
    return targetMessageBodyType;
}

documentation{
    Transforms MIME Message Part JSON into MessageAttachment.

    P{{sourceMessagePartJsonObject}} Json message part object
    R{{}} MessageAttachment type object
}
function convertJsonMsgPartToMsgAttachment(json sourceMessagePartJsonObject) returns MessageAttachment {
    MessageAttachment targetMessageAttachmentType;
    targetMessageAttachmentType.attachmentFileId = sourceMessagePartJsonObject.body.attachmentId != () ?
                                                sourceMessagePartJsonObject.body.attachmentId.toString() : EMPTY_STRING;
    targetMessageAttachmentType.attachmentBody = sourceMessagePartJsonObject.body.data != () ?
                                                        sourceMessagePartJsonObject.body.data.toString() : EMPTY_STRING;
    targetMessageAttachmentType.size = sourceMessagePartJsonObject.body.size != () ?
                                                        sourceMessagePartJsonObject.body.size.toString() : EMPTY_STRING;
    targetMessageAttachmentType.mimeType = sourceMessagePartJsonObject.mimeType != () ?
                                                         sourceMessagePartJsonObject.mimeType.toString() : EMPTY_STRING;
    targetMessageAttachmentType.partId = sourceMessagePartJsonObject.partId != () ?
                                                           sourceMessagePartJsonObject.partId.toString() : EMPTY_STRING;
    targetMessageAttachmentType.attachmentFileName = sourceMessagePartJsonObject.filename != () ?
                                                         sourceMessagePartJsonObject.filename.toString() : EMPTY_STRING;
    targetMessageAttachmentType.attachmentHeaders = sourceMessagePartJsonObject.headers != () ?
     convertJsonHeadersToHeaderMap(sourceMessagePartJsonObject.headers) : targetMessageAttachmentType.attachmentHeaders;
    return targetMessageAttachmentType;
}

documentation{
    Transforms single body of MIME Message part into MessageAttachment.

    P{{sourceMessageBodyJsonObject}} Json message body object.
    R{{}} Returns MessageAttachment type.
}
function convertJsonMessageBodyToMsgAttachment(json sourceMessageBodyJsonObject) returns MessageAttachment {
    MessageAttachment targetMessageAttachmentType;
    targetMessageAttachmentType.attachmentFileId = sourceMessageBodyJsonObject.attachmentId != () ?
                                                     sourceMessageBodyJsonObject.attachmentId.toString() : EMPTY_STRING;
    targetMessageAttachmentType.attachmentBody = sourceMessageBodyJsonObject.data != () ?
                                                             sourceMessageBodyJsonObject.data.toString() : EMPTY_STRING;
    targetMessageAttachmentType.size = sourceMessageBodyJsonObject.size != () ?
                                                             sourceMessageBodyJsonObject.size.toString() : EMPTY_STRING;
    return targetMessageAttachmentType;
}

documentation{
    Transforms mail thread Json object into Thread.

    P{{sourceThreadJsonObject}} Json message thread object.
    R{{}} If successful returns Thread type. Else returns GmailError.
}
function convertJsonThreadToThreadType(json sourceThreadJsonObject) returns Thread|GmailError {
    Thread targetThreadType;
    targetThreadType.id = sourceThreadJsonObject.id != () ? sourceThreadJsonObject.id.toString() : EMPTY_STRING;
    targetThreadType.historyId = sourceThreadJsonObject.historyId != () ?
                                                             sourceThreadJsonObject.historyId.toString() : EMPTY_STRING;
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

documentation{
    Converts the json message array into Message type array.

    P{{sourceMessageArrayJsonObject}} Json message array object
    R{{}} Message type array
    R{{}} GmailError if coversion is not successful.
}
function convertToMessageArray(json[] sourceMessageArrayJsonObject) returns Message[]|GmailError {
    Message[] messages = [];
    foreach i, jsonMessage in sourceMessageArrayJsonObject {
        match (convertJsonMessageToMessage(jsonMessage)){
            Message msg => {
                messages[i] = msg;
            }
            GmailError gmailError => return gmailError;
        }
    }
    return messages;
}

documentation{
    Transforms user profile json object into UserProfile.

    P{{sourceUserProfileJsonObject}} Json user profile object
    R{{}} UserProfile type
}
function convertJsonProfileToUserProfileType(json sourceUserProfileJsonObject) returns UserProfile {
    UserProfile targetUserProfile;
    targetUserProfile.emailAddress = sourceUserProfileJsonObject.emailAddress != () ?
                                                     sourceUserProfileJsonObject.emailAddress.toString() : EMPTY_STRING;
    targetUserProfile.threadsTotal = sourceUserProfileJsonObject.threadsTotal != () ?
                                                     sourceUserProfileJsonObject.threadsTotal.toString() : EMPTY_STRING;
    targetUserProfile.messagesTotal = sourceUserProfileJsonObject.messagesTotal != () ?
                                                    sourceUserProfileJsonObject.messagesTotal.toString() : EMPTY_STRING;
    targetUserProfile.historyId = sourceUserProfileJsonObject.historyId != () ?
                                                        sourceUserProfileJsonObject.historyId.toString() : EMPTY_STRING;
    return targetUserProfile;
}

documentation{
    Transforms message list json object into MessageListPage.

    P{{sourceMsgListJsonObject}} Json Messsage List object
    R{{}} MessageListPage type
}
function convertJsonMsgListToMessageListPageType(json sourceMsgListJsonObject) returns MessageListPage {
    MessageListPage targetMsgListPage;
    targetMsgListPage.resultSizeEstimate = sourceMsgListJsonObject.resultSizeEstimate != () ?
                                                   sourceMsgListJsonObject.resultSizeEstimate.toString() : EMPTY_STRING;
    targetMsgListPage.nextPageToken = sourceMsgListJsonObject.nextPageToken != () ?
                                                        sourceMsgListJsonObject.nextPageToken.toString() : EMPTY_STRING;
    //for each message resource in messages json array of the response
    foreach message in sourceMsgListJsonObject.messages {
        //Add the message map with Id and thread Id as keys to the array
        targetMsgListPage.messages[lengthof targetMsgListPage.messages] = { messageId: message.id.toString(),
            threadId: message.threadId.toString() };
    }
    return targetMsgListPage;
}

documentation{
    Transforms thread list json object into ThreadListPage.

    P{{sourceThreadListJsonObject}} Json Thead List object
    R{{}} ThreadListPage type
}
function convertJsonThreadListToThreadListPageType(json sourceThreadListJsonObject) returns ThreadListPage {
    ThreadListPage targetThreadListPage;
    targetThreadListPage.resultSizeEstimate = sourceThreadListJsonObject.resultSizeEstimate != () ?
                                                sourceThreadListJsonObject.resultSizeEstimate.toString() : EMPTY_STRING;
    targetThreadListPage.nextPageToken = sourceThreadListJsonObject.nextPageToken != () ?
                                                     sourceThreadListJsonObject.nextPageToken.toString() : EMPTY_STRING;
    //for each thread resource in threads json array of the response
    foreach thread in sourceThreadListJsonObject.threads {
        //Add the thread map with Id, snippet and history Id as keys to the array of thread maps
        targetThreadListPage.threads[lengthof targetThreadListPage.threads] = { threadId: thread.id.toString(),
            snippet: thread.snippet.toString(), historyId: thread.historyId.toString() };
    }
    return targetThreadListPage;
}

documentation{
    Converts the message part header json array to headers.

    P{{jsonMsgPartHeaders}} Json array of message part headers
    R{{}} Map of headers
}
function convertJsonHeadersToHeaderMap(json jsonMsgPartHeaders) returns map {
    map headers;
    foreach jsonHeader in jsonMsgPartHeaders {
        headers[jsonHeader.name.toString()] = jsonHeader.value.toString();
    }
    return headers;
}

documentation{
    Converts the json label resource to Label type.

    P{{sourceLabelJsonObject}} Json label
    R{{}} Label type object
}
function convertJsonLabelToLabelType(json sourceLabelJsonObject) returns Label {
    Label targetLabel;
    targetLabel.id = sourceLabelJsonObject.id != () ? sourceLabelJsonObject.id.toString() : EMPTY_STRING;
    targetLabel.name = sourceLabelJsonObject.name != () ? sourceLabelJsonObject.name.toString() : EMPTY_STRING;
    targetLabel.messageListVisibility = sourceLabelJsonObject.messageListVisibility != () ?
                                                  sourceLabelJsonObject.messageListVisibility.toString() : EMPTY_STRING;
    targetLabel.labelListVisibility = sourceLabelJsonObject.labelListVisibility != () ?
                                                    sourceLabelJsonObject.labelListVisibility.toString() : EMPTY_STRING;
    targetLabel.ownerType = sourceLabelJsonObject.^"type" != () ? sourceLabelJsonObject.^"type".toString()
                                                                                                         : EMPTY_STRING;
    match <int>sourceLabelJsonObject.messagesTotal {
        int msgTotal => targetLabel.messagesTotal = msgTotal;
        //No key named messagesTotal in the response
        error err => log:printDebug("Label response:" + targetLabel.id + " does not contain field messagesTotal.");
    }
    match <int>sourceLabelJsonObject.messagesUnread {
        int msgUnread => targetLabel.messagesUnread = msgUnread;
        //No key named messagesUnread in the response
        error err => log:printDebug("Label response:" + targetLabel.id + " does not contain field messagesUnread.");
    }
    match <int>sourceLabelJsonObject.threadsUnread {
        int threadsUnread => targetLabel.threadsUnread = threadsUnread;
        //No key named threadsUnread in the response
        error err => log:printDebug("Label response:" + targetLabel.id + " does not contain field threadsUnread.");
    }
    match <int>sourceLabelJsonObject.threadsTotal {
        int threadsTotal => targetLabel.threadsTotal = threadsTotal;
        //No key named threadsTotal in the response
        error err => log:printDebug("Label response:" + targetLabel.id + " does not contain field threadsTotal.");
    }
    targetLabel.textColor = sourceLabelJsonObject.color.textColor != () ?
                                                        sourceLabelJsonObject.color.textColor.toString() : EMPTY_STRING;
    targetLabel.backgroundColor = sourceLabelJsonObject.color.backgroundColor != () ?
                                                  sourceLabelJsonObject.color.backgroundColor.toString() : EMPTY_STRING;
    return targetLabel;
}

documentation {
    Convert Json label list response to an array of Label type objects.

    P{{sourceJsonLabelList}} Source json object
    R{{}} Returns an array of Label type objects
}
function convertJsonLabelListToLabelTypeList(json sourceJsonLabelList) returns Label[] {
    Label[] targetLabelList;
    match <json[]>sourceJsonLabelList.labels {
        json[] jsonLabelList => {
            foreach i, label in jsonLabelList {
                targetLabelList[i] = convertJsonLabelToLabelType(label);
            }
        }
        //No key named labels in the response
        error err => log:printDebug("Label list response does not contain a label array");
    }
    return targetLabelList;
}
