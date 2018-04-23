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
        error err => {
            //No key named labelIds in the response.
            targetMessageType.labelIds = [];
            log:printDebug("Mail response:" + sourceMailJsonObject.id.toString() + " does not contain any label Id");
        }
    }
    targetMessageType.raw = sourceMailJsonObject.raw.toString();
    targetMessageType.snippet = sourceMailJsonObject.snippet.toString();
    targetMessageType.historyId = sourceMailJsonObject.historyId.toString();
    targetMessageType.internalDate = sourceMailJsonObject.internalDate.toString();
    targetMessageType.sizeEstimate = sourceMailJsonObject.sizeEstimate.toString();
    match <json[]>sourceMailJsonObject.payload.headers {
        json[] headers => {
            targetMessageType.headers = convertToMsgPartHeaders(headers);
        }
        error err => {
            //No key named headers in the payload part of the response
            targetMessageType.headers = [];
            log:printDebug("Mail response:" + sourceMailJsonObject.id.toString()
                                                                             + "does not contain any payload headers");
        }
    }
    targetMessageType.headerTo = sourceMailJsonObject.payload.headers != () ?
                                                                     getMsgPartHeaderTo(targetMessageType.headers) : {};
    targetMessageType.headerFrom = sourceMailJsonObject.payload.headers != () ?
                                                                   getMsgPartHeaderFrom(targetMessageType.headers) : {};
    targetMessageType.headerCc = sourceMailJsonObject.payload.headers != () ?
                                                                     getMsgPartHeaderCc(targetMessageType.headers) : {};
    targetMessageType.headerBcc = sourceMailJsonObject.payload.headers != () ?
                                                                    getMsgPartHeaderBcc(targetMessageType.headers) : {};
    targetMessageType.headerSubject = sourceMailJsonObject.payload.headers != () ?
                                                                getMsgPartHeaderSubject(targetMessageType.headers) : {};
    targetMessageType.headerDate = sourceMailJsonObject.payload.headers != () ?
                                                                   getMsgPartHeaderDate(targetMessageType.headers) : {};
    targetMessageType.headerContentType = sourceMailJsonObject.payload.headers != () ?
                                                            getMsgPartHeaderContentType(targetMessageType.headers) : {};
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
                                                convertToMsgPartHeaders(check <json[]>sourceMessagePartJsonObject.headers) : [];
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
                                       convertToMsgPartHeaders(check <json[]>sourceMessagePartJsonObject.headers) : [];
    return targetMessageAttachmentType;
}

documentation{Transforms MIME Message Part Header into MessagePartHeader.

    P{{sourceMessagePartHeader}} - Json message part header object
    R{{}} - MessagePartHeader type
}
function convertJsonToMesagePartHeader(json sourceMessagePartHeader) returns MessagePartHeader {
    MessagePartHeader targetMessagePartHeader;
    targetMessagePartHeader.name = sourceMessagePartHeader.name.toString();
    targetMessagePartHeader.value = sourceMessagePartHeader.value.toString();
    return targetMessagePartHeader;
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
function convertJsonThreadToThreadType(json sourceThreadJsonObject) returns Thread|GmailError{
    Thread targetThreadType;
    targetThreadType.id = sourceThreadJsonObject.id.toString();
    targetThreadType.historyId = sourceThreadJsonObject.historyId.toString();
    if (sourceThreadJsonObject.messages != ()){
        json[]messages = check<json[]>sourceThreadJsonObject.messages;
        match (convertToMessageArray(messages)){
            Message[] msgs => targetThreadType.messages = msgs;
            GmailError gmailError => return gmailError;
        }
    }
    return targetThreadType;
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
        targetMsgListPage.messages[lengthof targetMsgListPage.messages] = {"messageId" : message.id.toString(),
                                                                            "threadId" : message.threadId.toString()};
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
