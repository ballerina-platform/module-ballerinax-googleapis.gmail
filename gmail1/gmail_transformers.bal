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

package gmail1;

import ballerina/io;

//All the transformers that transform required json to structs and vice versa

@Description {value:"Transform JSON Mail into Message struct"}
@Param {value:"sourceMailJsonObject: json mail object"}
@Return {value:"Message struct object"}
function convertJsonMailToMessage(json sourceMailJsonObject) returns Message {
    Message targetMessageStruct = {};
    targetMessageStruct.id = sourceMailJsonObject.id != null ? sourceMailJsonObject.id.toString() : EMPTY_STRING;
    targetMessageStruct.threadId = sourceMailJsonObject.threadId != null ?
                                                                sourceMailJsonObject.threadId.toString() : EMPTY_STRING;
    targetMessageStruct.labelIds = sourceMailJsonObject.labelIds != null ?
                                                      convertJSONArrayToStringArray(sourceMailJsonObject.labelIds) : [];
    targetMessageStruct.raw = sourceMailJsonObject.raw != null ?
                                                        sourceMailJsonObject.raw.toString() : EMPTY_STRING;
    targetMessageStruct.snippet = sourceMailJsonObject.snippet != null ?
                                                                sourceMailJsonObject.snippet.toString() : EMPTY_STRING;
    targetMessageStruct.historyId = sourceMailJsonObject.historyId != null ?
                                                            sourceMailJsonObject.historyId.toString() : EMPTY_STRING;
    targetMessageStruct.internalDate = sourceMailJsonObject.internalDate != null ?
                                                            sourceMailJsonObject.internalDate.toString() : EMPTY_STRING;
    targetMessageStruct.sizeEstimate = sourceMailJsonObject.sizeEstimate != null ?
                                                            sourceMailJsonObject.sizeEstimate.toString() : EMPTY_STRING;
    targetMessageStruct.headers = sourceMailJsonObject.payload.headers != null ?
                                                convertToMsgPartHeaders(sourceMailJsonObject.payload.headers) : [];
    targetMessageStruct.headerTo = sourceMailJsonObject.payload.headers != null ?
                                getMsgPartHeaderTo(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageStruct.headerFrom = sourceMailJsonObject.payload.headers != null ?
                                getMsgPartHeaderFrom(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageStruct.headerCc = sourceMailJsonObject.payload.headers != null ?
                                getMsgPartHeaderCc(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageStruct.headerBcc = sourceMailJsonObject.payload.headers != null ?
                                getMsgPartHeaderBcc(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageStruct.headerSubject = sourceMailJsonObject.payload.headers != null ?
                            getMsgPartHeaderSubject(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageStruct.headerDate = sourceMailJsonObject.payload.headers != null ?
                                getMsgPartHeaderDate(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageStruct.headerContentType = sourceMailJsonObject.payload.headers != null ?
                        getMsgPartHeaderContentType(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageStruct.mimeType = sourceMailJsonObject.payload.mimeType != null ?
                                                        sourceMailJsonObject.payload.mimeType.toString() : EMPTY_STRING;
    targetMessageStruct.isMultipart = sourceMailJsonObject.payload.mimeType != null ?
                                    isMimeType(sourceMailJsonObject.payload.mimeType.toString(), MULTIPART_ANY) : false;
    targetMessageStruct.plainTextBodyPart = sourceMailJsonObject.payload != null ?
                                getMessageBodyPartFromPayloadByMimeType(TEXT_PLAIN, sourceMailJsonObject.payload) : {};
    targetMessageStruct.htmlBodyPart = sourceMailJsonObject.payload != null ?
                                getMessageBodyPartFromPayloadByMimeType(TEXT_HTML, sourceMailJsonObject.payload) : {};
    targetMessageStruct.inlineImgParts = sourceMailJsonObject.payload != null ?
                                        getInlineImgPartsFromPayloadByMimeType(sourceMailJsonObject.payload, []) : [];
    targetMessageStruct.msgAttachments = sourceMailJsonObject.payload != null ?
                                                getAttachmentPartsFromPayload(sourceMailJsonObject.payload, []) : [];
    return targetMessageStruct;
}

@Description {value:"Transform MIME Message Part JSON into MessageBody struct"}
@Param {value:"sourceMessagePartJsonObject: json message part object"}
@Return {value:"MessageBodyPart struct object"}
function convertJsonMsgBodyPartToMsgBodyStruct(json sourceMessagePartJsonObject) returns MessageBodyPart {
    MessageBodyPart targetMessageBodyStruct = {};
    targetMessageBodyStruct.fileId = sourceMessagePartJsonObject.body.attachmentId != null ?
                                                sourceMessagePartJsonObject.body.attachmentId.toString() : EMPTY_STRING;
    targetMessageBodyStruct.body = sourceMessagePartJsonObject.body.data != null ?
                                                            decodeMsgBodyData(sourceMessagePartJsonObject) : EMPTY_STRING;
    targetMessageBodyStruct.size = sourceMessagePartJsonObject.body.size != null ?
                                                        sourceMessagePartJsonObject.body.size.toString() : EMPTY_STRING;
    targetMessageBodyStruct.mimeType = sourceMessagePartJsonObject.mimeType != null ?
                                                        sourceMessagePartJsonObject.mimeType.toString() : EMPTY_STRING;
    targetMessageBodyStruct.partId = sourceMessagePartJsonObject.partId != null ?
                                                            sourceMessagePartJsonObject.partId.toString() : EMPTY_STRING;
    targetMessageBodyStruct.fileName = sourceMessagePartJsonObject.filename != null ?
                                                        sourceMessagePartJsonObject.filename.toString() : EMPTY_STRING;
    targetMessageBodyStruct.bodyHeaders = sourceMessagePartJsonObject.headers != null ?
                                                    convertToMsgPartHeaders(sourceMessagePartJsonObject.headers) : [];
    return targetMessageBodyStruct;
}

@Description {value:"Transform MIME Message Part JSON into MessageAttachment struct"}
@Param {value:"sourceMessagePartJsonObject: json message part object"}
@Return {value:"MessageAttachment struct object"}
function convertJsonMsgPartToMsgAttachment(json sourceMessagePartJsonObject) returns MessageAttachment {
    MessageAttachment targetMessageAttachmentStruct = {};
    targetMessageAttachmentStruct.attachmentFileId = sourceMessagePartJsonObject.body.attachmentId != null ?
                                                sourceMessagePartJsonObject.body.attachmentId.toString() : EMPTY_STRING;
    targetMessageAttachmentStruct.attachmentBody = sourceMessagePartJsonObject.body.data != null ?
                                                        sourceMessagePartJsonObject.body.data.toString() : EMPTY_STRING;
    targetMessageAttachmentStruct.size = sourceMessagePartJsonObject.body.size != null ?
                                                        sourceMessagePartJsonObject.body.size.toString() : EMPTY_STRING;
    targetMessageAttachmentStruct.mimeType = sourceMessagePartJsonObject.mimeType != null ?
                                                        sourceMessagePartJsonObject.mimeType.toString() : EMPTY_STRING;
    targetMessageAttachmentStruct.partId = sourceMessagePartJsonObject.partId != null ?
                                                            sourceMessagePartJsonObject.partId.toString() : EMPTY_STRING;
    targetMessageAttachmentStruct.attachmentFileName = sourceMessagePartJsonObject.filename != null ?
                                                        sourceMessagePartJsonObject.filename.toString() : EMPTY_STRING;
    targetMessageAttachmentStruct.attachmentHeaders = sourceMessagePartJsonObject.headers != null ?
                                                    convertToMsgPartHeaders(sourceMessagePartJsonObject.headers) : [];
    return targetMessageAttachmentStruct;
}

@Description {value:"Transform MIME Message Part Header into MessagePartHeader struct"}
@Param {value:"sourceMessagePartHeader: json message part header object"}
@Return {value:"MessagePartHeader struct object"}
function convertJsonToMesagePartHeader(json sourceMessagePartHeader) returns MessagePartHeader {
    MessagePartHeader targetMessagePartHeader = {};
    targetMessagePartHeader.name = sourceMessagePartHeader.name != null ?
                                                                sourceMessagePartHeader.name.toString() : EMPTY_STRING;
    targetMessagePartHeader.value = sourceMessagePartHeader.value != null ?
                                                                sourceMessagePartHeader.value.toString() : EMPTY_STRING;
    return targetMessagePartHeader;
}

@Description {value:"Transform single body of MIME Message part into MessageAttachment struct"}
@Param {value:"sourceMessageBodyJsonObject: json message body object"}
@Return {value:"MessageAttachment struct object"}
function convertJsonMessageBodyToMsgAttachment (json sourceMessageBodyJsonObject) returns MessageAttachment {
    MessageAttachment targetMessageAttachmentStruct = {};
    targetMessageAttachmentStruct.attachmentFileId = sourceMessageBodyJsonObject.attachmentId != null ?
                                                    sourceMessageBodyJsonObject.attachmentId.toString() : EMPTY_STRING;
    targetMessageAttachmentStruct.attachmentBody = sourceMessageBodyJsonObject.data != null ?
                                                            sourceMessageBodyJsonObject.data.toString() : EMPTY_STRING;
    targetMessageAttachmentStruct.size = sourceMessageBodyJsonObject.size != null ?
                                                            sourceMessageBodyJsonObject.size.toString() : EMPTY_STRING;
    return targetMessageAttachmentStruct;
}

@Description {value:"Transform thread JSON object into Thread struct"}
@Param {value:"sourceThreadJsonObject: json message thread object"}
@Return {value:"Thread struct object"}
function convertJsonThreadToThreadStruct (json sourceThreadJsonObject) returns Thread {
    Thread targetThreadStruct = {};
    targetThreadStruct.id = sourceThreadJsonObject.id != null ? sourceThreadJsonObject.id.toString() : EMPTY_STRING;
    targetThreadStruct.historyId = sourceThreadJsonObject.historyId != null ?
                                                            sourceThreadJsonObject.historyId.toString() : EMPTY_STRING;
    targetThreadStruct.messages = sourceThreadJsonObject.messages != null ?
                                                            convertToMessageArray(sourceThreadJsonObject.messages) : [];
    return targetThreadStruct;
}

@Description {value:"Transform user profile JSON object into UserProfile struct"}
@Param {value:"sourceUserProfileJsonObject: json user profile object"}
@Return {value:"UserProfile struct object"}
function convertJsonProfileToUserProfileStruct (json sourceUserProfileJsonObject) returns UserProfile {
    UserProfile targetUserProfile = {};
    targetUserProfile.emailAddress = sourceUserProfileJsonObject.emailAddress != null ?
                                                    sourceUserProfileJsonObject.emailAddress.toString() : EMPTY_STRING;
    targetUserProfile.threadsTotal = sourceUserProfileJsonObject.threadsTotal != null ?
                                                    sourceUserProfileJsonObject.threadsTotal.toString() : EMPTY_STRING;
    targetUserProfile.messagesTotal = sourceUserProfileJsonObject.messagesTotal != null ?
                                                    sourceUserProfileJsonObject.messagesTotal.toString() : EMPTY_STRING;
    targetUserProfile.historyId = sourceUserProfileJsonObject.historyId != null ?
                                                        sourceUserProfileJsonObject.historyId.toString() : EMPTY_STRING;
    return targetUserProfile;
}