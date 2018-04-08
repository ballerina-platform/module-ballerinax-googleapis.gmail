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

@Description {value:"Transform JSON Mail into Message type"}
@Param {value:"sourceMailJsonObject: json mail object"}
@Return {value:"Message type object"}
@Return {value:"Returns GMailError if conversion unsuccesful"}
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
                                            targetMessageType.isMultipart = isMimeType(payloadMimeType, MULTIPART_ANY);
    if (sourceMailJsonObject.payload != ()){
        match getMessageBodyPartFromPayloadByMimeType(TEXT_PLAIN, sourceMailJsonObject.payload){
            MessageBodyPart body => targetMessageType.plainTextBodyPart = body;
            GMailError err => return err;
        }
        match getMessageBodyPartFromPayloadByMimeType(TEXT_HTML, sourceMailJsonObject.payload){
            MessageBodyPart body => targetMessageType.htmlBodyPart = body;
            GMailError err => return err;
        }
        match getInlineImgPartsFromPayloadByMimeType(sourceMailJsonObject.payload, []){
            MessageBodyPart[] bodyParts => targetMessageType.inlineImgParts = bodyParts;
            GMailError err => return err;
        }
    }
    targetMessageType.msgAttachments = sourceMailJsonObject.payload != () ?
                                                getAttachmentPartsFromPayload(sourceMailJsonObject.payload, []) : [];
    return targetMessageType;
}

@Description {value:"Transform MIME Message Part JSON into MessageBody type"}
@Param {value:"sourceMessagePartJsonObject: json message part object"}
@Return {value:"MessageBodyPart type object"}
@Return {value:"Returns GMailError if conversion unsuccesful"}
function convertJsonMsgBodyPartToMsgBodyType(json sourceMessagePartJsonObject) returns MessageBodyPart|GMailError {
    MessageBodyPart targetMessageBodyType = new ();
    if (sourceMessagePartJsonObject != ()){
        targetMessageBodyType.fileId = sourceMessagePartJsonObject.body.attachmentId.toString() but { () => EMPTY_STRING };
        match decodeMsgBodyData(sourceMessagePartJsonObject){
            string decodeBody => targetMessageBodyType.body = decodeBody;
            GMailError err => return err;
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

@Description {value:"Transform MIME Message Part JSON into MessageAttachment type"}
@Param {value:"sourceMessagePartJsonObject: json message part object"}
@Return {value:"MessageAttachment type object"}
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

@Description {value:"Transform MIME Message Part Header into MessagePartHeader type"}
@Param {value:"sourceMessagePartHeader: json message part header object"}
@Return {value:"MessagePartHeader type object"}
function convertJsonToMesagePartHeader(json sourceMessagePartHeader) returns MessagePartHeader {
    MessagePartHeader targetMessagePartHeader = {};
    targetMessagePartHeader.name = sourceMessagePartHeader.name.toString() but { () => EMPTY_STRING };
    targetMessagePartHeader.value = sourceMessagePartHeader.value.toString() but { () => EMPTY_STRING };
    return targetMessagePartHeader;
}

@Description {value:"Transform single body of MIME Message part into MessageAttachment type"}
@Param {value:"sourceMessageBodyJsonObject: json message body object"}
@Return {value:"MessageAttachment type object"}
function convertJsonMessageBodyToMsgAttachment(json sourceMessageBodyJsonObject) returns MessageAttachment {
    MessageAttachment targetMessageAttachmentType = new ();
    targetMessageAttachmentType.attachmentFileId = sourceMessageBodyJsonObject.attachmentId.toString() but {
                                                                                                () => EMPTY_STRING };
    targetMessageAttachmentType.attachmentBody = sourceMessageBodyJsonObject.data.toString() but {
                                                                                                () => EMPTY_STRING };
    targetMessageAttachmentType.size = sourceMessageBodyJsonObject.size.toString() but { () => EMPTY_STRING };
    return targetMessageAttachmentType;
}

@Description {value:"Transform thread JSON object into Thread type"}
@Param {value:"sourceThreadJsonObject: json message thread object"}
@Return {value:"Thread type object"}
@Return {value:"Returns GMailError if conversion unsuccesful"}
function convertJsonThreadToThreadType(json sourceThreadJsonObject) returns Thread|GMailError{
    Thread targetThreadType = {};
    targetThreadType.id = sourceThreadJsonObject.id.toString() but { () => EMPTY_STRING };
    targetThreadType.historyId = sourceThreadJsonObject.historyId.toString() but { () => EMPTY_STRING };
    if (sourceThreadJsonObject.messages != ()){
        match (convertToMessageArray(sourceThreadJsonObject.messages)){
            Message[] msgs => targetThreadType.messages = msgs;
            GMailError err => return err;
        }
    }
    return targetThreadType;
}

@Description {value:"Transform user profile JSON object into UserProfile type"}
@Param {value:"sourceUserProfileJsonObject: json user profile object"}
@Return {value:"UserProfile type object"}
function convertJsonProfileToUserProfileType(json sourceUserProfileJsonObject) returns UserProfile {
    UserProfile targetUserProfile = {};
    targetUserProfile.emailAddress = sourceUserProfileJsonObject.emailAddress.toString() but { () => EMPTY_STRING };
    targetUserProfile.threadsTotal = sourceUserProfileJsonObject.threadsTotal.toString() but { () => EMPTY_STRING };
    targetUserProfile.messagesTotal = sourceUserProfileJsonObject.messagesTotal.toString() but { () => EMPTY_STRING };
    targetUserProfile.historyId = sourceUserProfileJsonObject.historyId.toString() but { () => EMPTY_STRING };
    return targetUserProfile;
}
