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

//All the transformers that transform required json to structs and vice versa

@Description {value:"Transform JSON Mail into Message struct"}
transformer <json sourceMailJsonObject, Message targetMessageStruct> convertJsonMailToMessage() {
    targetMessageStruct.id = sourceMailJsonObject.id != null ? sourceMailJsonObject.id.toString() : EMPTY_STRING;
    targetMessageStruct.threadId = sourceMailJsonObject.threadId != null ? sourceMailJsonObject.threadId.toString() : EMPTY_STRING;
    targetMessageStruct.labelIds = sourceMailJsonObject.labelIds != null ? convertJSONArrayToStringArray(sourceMailJsonObject.labelIds) : [];
    targetMessageStruct.raw = sourceMailJsonObject.raw != null ? sourceMailJsonObject.raw.toString() : EMPTY_STRING;
    targetMessageStruct.snippet = sourceMailJsonObject.snippet != null ? sourceMailJsonObject.snippet.toString() : EMPTY_STRING;
    targetMessageStruct.historyId = sourceMailJsonObject.historyId != null ? sourceMailJsonObject.historyId.toString() : EMPTY_STRING;
    targetMessageStruct.internalDate = sourceMailJsonObject.internalDate != null ? sourceMailJsonObject.internalDate.toString() : EMPTY_STRING;
    targetMessageStruct.sizeEstimate = sourceMailJsonObject.sizeEstimate != null ? sourceMailJsonObject.sizeEstimate.toString() : EMPTY_STRING;
    targetMessageStruct.headers = sourceMailJsonObject.payload.headers != null ? convertToMsgPartHeaders(sourceMailJsonObject.payload.headers) : [];
    targetMessageStruct.headerTo = sourceMailJsonObject.payload.headers != null ? getMsgPartHeaderTo(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageStruct.headerFrom = sourceMailJsonObject.payload.headers != null ? getMsgPartHeaderFrom(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageStruct.headerCc = sourceMailJsonObject.payload.headers != null ? getMsgPartHeaderCc(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageStruct.headerBcc = sourceMailJsonObject.payload.headers != null ? getMsgPartHeaderBcc(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageStruct.headerSubject = sourceMailJsonObject.payload.headers != null ? getMsgPartHeaderSubject(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageStruct.headerDate = sourceMailJsonObject.payload.headers != null ? getMsgPartHeaderDate(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageStruct.headerContentType = sourceMailJsonObject.payload.headers != null ? getMsgPartHeaderContentType(convertToMsgPartHeaders(sourceMailJsonObject.payload.headers)) : {};
    targetMessageStruct.mimeType = sourceMailJsonObject.payload.mimeType != null ? sourceMailJsonObject.payload.mimeType.toString() : EMPTY_STRING;
    targetMessageStruct.isMultipart = sourceMailJsonObject.payload.mimeType != null ? isMimeType(sourceMailJsonObject.payload.mimeType.toString(), MULTIPART_ANY) : false;
    targetMessageStruct.plainTextBodyPart = sourceMailJsonObject.payload != null ? getMessageBodyPartFromPayloadByMimeType(TEXT_PLAIN, sourceMailJsonObject.payload) : {};
    targetMessageStruct.htmlBodyPart = sourceMailJsonObject.payload != null ? getMessageBodyPartFromPayloadByMimeType(TEXT_HTML, sourceMailJsonObject.payload) : {};
    targetMessageStruct.inlineImgParts = sourceMailJsonObject.payload != null ? getInlineImgPartsFromPayloadByMimeType(sourceMailJsonObject.payload, []) : [];
    targetMessageStruct.msgAttachments = sourceMailJsonObject.payload != null ? getAttachmentPartsFromPayload(sourceMailJsonObject.payload, []) : [];
}

@Description {value:"Transform MIME Message Part JSON into MessageBody struct"}
transformer <json sourceMessagePartJsonObject, MessageBodyPart targetMessageBodyStruct> convertJsonMsgBodyPartToMsgBodyStruct() {
    targetMessageBodyStruct.fileId = sourceMessagePartJsonObject.body.attachmentId != null ? sourceMessagePartJsonObject.body.attachmentId.toString() : EMPTY_STRING;
    targetMessageBodyStruct.body = sourceMessagePartJsonObject.body.data != null ? decodeMsgBodyData(sourceMessagePartJsonObject) : EMPTY_STRING;
    targetMessageBodyStruct.size = sourceMessagePartJsonObject.body.size != null ? sourceMessagePartJsonObject.body.size.toString() : EMPTY_STRING;
    targetMessageBodyStruct.mimeType = sourceMessagePartJsonObject.mimeType != null ? sourceMessagePartJsonObject.mimeType.toString() : EMPTY_STRING;
    targetMessageBodyStruct.partId = sourceMessagePartJsonObject.partId != null ? sourceMessagePartJsonObject.partId.toString() : EMPTY_STRING;
    targetMessageBodyStruct.fileName = sourceMessagePartJsonObject.filename != null ? sourceMessagePartJsonObject.filename.toString() : EMPTY_STRING;
    targetMessageBodyStruct.bodyHeaders = sourceMessagePartJsonObject.headers != null ? convertToMsgPartHeaders(sourceMessagePartJsonObject.headers) : [];
}

@Description {value:"Transform MIME Message Part JSON into MessageAttachment struct"}
transformer <json sourceMessagePartJsonObject, MessageAttachment targetMessageAttachmentStruct> convertJsonMsgPartToMsgAttachment() {
    targetMessageAttachmentStruct.attachmentFileId = sourceMessagePartJsonObject.body.attachmentId != null ? sourceMessagePartJsonObject.body.attachmentId.toString() : EMPTY_STRING;
    targetMessageAttachmentStruct.attachmentBody = sourceMessagePartJsonObject.body.data != null ? sourceMessagePartJsonObject.body.data.toString() : EMPTY_STRING;
    targetMessageAttachmentStruct.size = sourceMessagePartJsonObject.body.size != null ? sourceMessagePartJsonObject.body.size.toString() : EMPTY_STRING;
    targetMessageAttachmentStruct.mimeType = sourceMessagePartJsonObject.mimeType != null ? sourceMessagePartJsonObject.mimeType.toString() : EMPTY_STRING;
    targetMessageAttachmentStruct.partId = sourceMessagePartJsonObject.partId != null ? sourceMessagePartJsonObject.partId.toString() : EMPTY_STRING;
    targetMessageAttachmentStruct.attachmentFileName = sourceMessagePartJsonObject.filename != null ? sourceMessagePartJsonObject.filename.toString() : EMPTY_STRING;
    targetMessageAttachmentStruct.attachmentHeaders = sourceMessagePartJsonObject.headers != null ? convertToMsgPartHeaders(sourceMessagePartJsonObject.headers) : [];
}

@Description {value:"Transform MIME Message Part Header into MessagePartHeader struct"}
transformer <json sourceMessagePartHeader, MessagePartHeader targetMessagePartHeader> convertJsonToMesagePartHeader() {
    targetMessagePartHeader.name = sourceMessagePartHeader.name != null ? sourceMessagePartHeader.name.toString() : EMPTY_STRING;
    targetMessagePartHeader.value = sourceMessagePartHeader.value != null ? sourceMessagePartHeader.value.toString() : EMPTY_STRING;
}


@Description {value:"Transform single body of MIME Message part into MessageAttachment struct"}
transformer <json sourceMessageBodyJsonObject, MessageAttachment targetMessageAttachmentStruct> convertJsonMessageBodyToMsgAttachment() {
    targetMessageAttachmentStruct.attachmentFileId = sourceMessageBodyJsonObject.attachmentId != null ? sourceMessageBodyJsonObject.attachmentId.toString() : EMPTY_STRING;
    targetMessageAttachmentStruct.attachmentBody = sourceMessageBodyJsonObject.data != null ? sourceMessageBodyJsonObject.data.toString() : EMPTY_STRING;
    targetMessageAttachmentStruct.size = sourceMessageBodyJsonObject.size != null ? sourceMessageBodyJsonObject.size.toString() : EMPTY_STRING;
}

@Description {value:"Transform thread JSON object into Thread struct"}
transformer <json sourceThreadJsonObject, Thread targetThreadStruct> convertJsonThreadToThreadStruct() {
    targetThreadStruct.id = sourceThreadJsonObject.id != null ? sourceThreadJsonObject.id.toString() : EMPTY_STRING;
    targetThreadStruct.historyId = sourceThreadJsonObject.historyId != null ? sourceThreadJsonObject.historyId.toString() : EMPTY_STRING;
    targetThreadStruct.messages = sourceThreadJsonObject.messages != null ? convertToMessageArray(sourceThreadJsonObject.messages) : [];
}

@Description {value:"Transform user profile JSON object into UserProfile struct"}
transformer <json sourceUserProfileJsonObject, UserProfile targetUserProfile> convertJsonProfileToUserProfileStruct() {
    targetUserProfile.emailAddress = sourceUserProfileJsonObject.emailAddress != null ? sourceUserProfileJsonObject.emailAddress.toString() : EMPTY_STRING;
    targetUserProfile.threadsTotal = sourceUserProfileJsonObject.threadsTotal != null ? sourceUserProfileJsonObject.threadsTotal.toString() : EMPTY_STRING;
    targetUserProfile.messagesTotal = sourceUserProfileJsonObject.messagesTotal != null ? sourceUserProfileJsonObject.messagesTotal.toString() : EMPTY_STRING;
    targetUserProfile.historyId = sourceUserProfileJsonObject.historyId != null ? sourceUserProfileJsonObject.historyId.toString() : EMPTY_STRING;
}