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

//All the transformers that transform required json to types and vice versa

documentation{
    Transforms JSON mail object into Message type object.

    P{{sourceMailJsonObject}} - Json mail object
    R{{targetMessageType}} - Returns Message type object if the conversion successful.
    R{{gMailError}} - Returns GMailError if the conversion is unsuccessful.
}
function convertJsonMailToMessage(json sourceMailJsonObject) returns Message|GMailError {
    Message targetMessageType = new ();
    targetMessageType.id = sourceMailJsonObject.id.toString() but { () => EMPTY_STRING };
    targetMessageType.threadId = sourceMailJsonObject.threadId.toString() but { () => EMPTY_STRING };
    targetMessageType.labelIds = sourceMailJsonObject.labelIds != () ?
                                        convertJSONArrayToStringArray(sourceMailJsonObject.labelIds) : [];
    targetMessageType.raw = sourceMailJsonObject.raw.toString() but { () => EMPTY_STRING };
    targetMessageType.snippet = sourceMailJsonObject.snippet.toString() but { () => EMPTY_STRING };
    targetMessageType.historyId = sourceMailJsonObject.historyId.toString() but { () => EMPTY_STRING };
    targetMessageType.internalDate = sourceMailJsonObject.internalDate.toString() but { () => EMPTY_STRING };
    targetMessageType.sizeEstimate = sourceMailJsonObject.sizeEstimate.toString() but { () => EMPTY_STRING };
    targetMessageType.headers = sourceMailJsonObject.payload.headers != () ?
                                        convertToMsgPartHeaders(sourceMailJsonObject.payload.headers) : [];
    targetMessageType.headerTo = sourceMailJsonObject.payload.headers != () ?
                                getMsgPartHeaderTo(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageType.headerFrom = sourceMailJsonObject.payload.headers != () ?
                            getMsgPartHeaderFrom(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageType.headerCc = sourceMailJsonObject.payload.headers != () ?
                                getMsgPartHeaderCc(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageType.headerBcc = sourceMailJsonObject.payload.headers != () ?
                                getMsgPartHeaderBcc(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageType.headerSubject = sourceMailJsonObject.payload.headers != () ?
                            getMsgPartHeaderSubject(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageType.headerDate = sourceMailJsonObject.payload.headers != () ?
                            getMsgPartHeaderDate(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageType.headerContentType = sourceMailJsonObject.payload.headers != () ?
                        getMsgPartHeaderContentType(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageType.mimeType = sourceMailJsonObject.payload.mimeType.toString() but { () => EMPTY_STRING };
    string payloadMimeType = sourceMailJsonObject.payload.mimeType.toString() but { () => EMPTY_STRING };
    if (sourceMailJsonObject.payload != ()){
        match getMessageBodyPartFromPayloadByMimeType(sourceMailJsonObject.payload, TEXT_PLAIN){
            MessageBodyPart body => targetMessageType.plainTextBodyPart = body;
            GMailError gmailError => return gmailError;
        }
        match getMessageBodyPartFromPayloadByMimeType(sourceMailJsonObject.payload, TEXT_HTML){
            MessageBodyPart body => targetMessageType.htmlBodyPart = body;
            GMailError gmailError => return gmailError;
        }
        match getInlineImgPartsFromPayloadByMimeType(sourceMailJsonObject.payload, []){
            MessageBodyPart[] bodyParts => targetMessageType.inlineImgParts = bodyParts;
            GMailError gmailError => return gmailError;
        }
    }
    targetMessageType.msgAttachments = sourceMailJsonObject.payload != () ?
                                                getAttachmentPartsFromPayload(sourceMailJsonObject.payload, []) : [];
    return targetMessageType;
}

documentation{
    Transforms MIME Message Part Json into MessageBody type object.

    P{{sourceMessagePartJsonObject}} - Json message part object
    R{{targetMessageBodyType}} - Returns MessageBodyPart type object if the conversion successful.
    R{{gMailError}} - Returns GMailError if conversion unsuccesful.
}
function convertJsonMsgBodyPartToMsgBodyType(json sourceMessagePartJsonObject) returns MessageBodyPart|GMailError {
    MessageBodyPart targetMessageBodyType = new ();
    if (sourceMessagePartJsonObject != ()){
        targetMessageBodyType.fileId = sourceMessagePartJsonObject.body.attachmentId.toString() but { () => EMPTY_STRING };
        match decodeMsgBodyData(sourceMessagePartJsonObject){
            string decodeBody => targetMessageBodyType.body = decodeBody;
            GMailError gMailError => return gMailError;
        }
        targetMessageBodyType.size = sourceMessagePartJsonObject.body.size.toString() but { () => EMPTY_STRING };
        targetMessageBodyType.mimeType = sourceMessagePartJsonObject.mimeType.toString() but { () => EMPTY_STRING };
        targetMessageBodyType.partId = sourceMessagePartJsonObject.partId.toString() but { () => EMPTY_STRING };
        targetMessageBodyType.fileName = sourceMessagePartJsonObject.filename.toString() but { () => EMPTY_STRING };
        targetMessageBodyType.bodyHeaders = sourceMessagePartJsonObject.headers != () ?
                                                convertToMsgPartHeaders(sourceMessagePartJsonObject.headers) : [];
    }
    return targetMessageBodyType;
}

documentation{
    Transforms MIME Message Part JSON into MessageAttachment type object.

    P{{sourceMessagePartJsonObject}} - Json message part object
    R{{targetMessageAttachmentType}}- Returns MessageAttachment type object.
}
function convertJsonMsgPartToMsgAttachment(json sourceMessagePartJsonObject) returns MessageAttachment {
    MessageAttachment targetMessageAttachmentType = new ();
    targetMessageAttachmentType.attachmentFileId = sourceMessagePartJsonObject.body.attachmentId.toString() but {
                                                                                                () => EMPTY_STRING };
    targetMessageAttachmentType.attachmentBody = sourceMessagePartJsonObject.body.data.toString() but {
                                                                                                () => EMPTY_STRING };
    targetMessageAttachmentType.size = sourceMessagePartJsonObject.body.size.toString() but { () => EMPTY_STRING };
    targetMessageAttachmentType.mimeType = sourceMessagePartJsonObject.mimeType.toString() but { () => EMPTY_STRING };
    targetMessageAttachmentType.partId = sourceMessagePartJsonObject.partId.toString() but { () => EMPTY_STRING };
    targetMessageAttachmentType.attachmentFileName = sourceMessagePartJsonObject.filename.toString() but {
                                                                                                () => EMPTY_STRING };
    targetMessageAttachmentType.attachmentHeaders = sourceMessagePartJsonObject.headers != () ?
                                                    convertToMsgPartHeaders(sourceMessagePartJsonObject.headers) : [];
    return targetMessageAttachmentType;
}

documentation{
    Transforms MIME Message Part Header into MessagePartHeader type.

    P{{sourceMessagePartHeader}} - Json message part header object
    R{{targetMessagePartHeader}} - Returns MessagePartHeader type.
}
function convertJsonToMesagePartHeader(json sourceMessagePartHeader) returns MessagePartHeader {
    MessagePartHeader targetMessagePartHeader = {};
    targetMessagePartHeader.name = sourceMessagePartHeader.name.toString() but { () => EMPTY_STRING };
    targetMessagePartHeader.value = sourceMessagePartHeader.value.toString() but { () => EMPTY_STRING };
    return targetMessagePartHeader;
}

documentation{
    Transforms single body of MIME Message part into MessageAttachment type object.

    P{{sourceMessageBodyJsonObject}} - Json message body object
    R{{targetMessageAttachmentType}} - Returns MessageAttachment type object.
}
function convertJsonMessageBodyToMsgAttachment(json sourceMessageBodyJsonObject) returns MessageAttachment {
    MessageAttachment targetMessageAttachmentType = new ();
    targetMessageAttachmentType.attachmentFileId = sourceMessageBodyJsonObject.attachmentId.toString() but {
                                                                                                () => EMPTY_STRING };
    targetMessageAttachmentType.attachmentBody = sourceMessageBodyJsonObject.data.toString() but {
                                                                                                () => EMPTY_STRING };
    targetMessageAttachmentType.size = sourceMessageBodyJsonObject.size.toString() but { () => EMPTY_STRING };
    return targetMessageAttachmentType;
}

documentation{
    Transforms mail thread Json object into Thread type

    P{{sourceThreadJsonObject}} - Json message thread object
    R{{targetThreadType}} - Returns Thread type
    R{{gMailError}} - Returns GMailError if conversion is unsuccessful.
}
function convertJsonThreadToThreadType(json sourceThreadJsonObject) returns Thread|GMailError{
    Thread targetThreadType = {};
    targetThreadType.id = sourceThreadJsonObject.id.toString() but { () => EMPTY_STRING };
    targetThreadType.historyId = sourceThreadJsonObject.historyId.toString() but { () => EMPTY_STRING };
    if (sourceThreadJsonObject.messages != ()){
        match (convertToMessageArray(sourceThreadJsonObject.messages)){
            Message[] msgs => targetThreadType.messages = msgs;
            GMailError gMailError => return gMailError;
        }
    }
    return targetThreadType;
}

documentation{
    Transforms user profile json object into UserProfile type.

    P{{sourceUserProfileJsonObject}} - Json user profile object
    R{{targetUserProfile}} - UserProfile type
}
function convertJsonProfileToUserProfileType(json sourceUserProfileJsonObject) returns UserProfile {
    UserProfile targetUserProfile = {};
    targetUserProfile.emailAddress = sourceUserProfileJsonObject.emailAddress.toString() but { () => EMPTY_STRING };
    targetUserProfile.threadsTotal = sourceUserProfileJsonObject.threadsTotal.toString() but { () => EMPTY_STRING };
    targetUserProfile.messagesTotal = sourceUserProfileJsonObject.messagesTotal.toString() but { () => EMPTY_STRING };
    targetUserProfile.historyId = sourceUserProfileJsonObject.historyId.toString() but { () => EMPTY_STRING };
    return targetUserProfile;
}
