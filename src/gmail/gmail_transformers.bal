// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

package src.gmail;

transformer <json jsonUserProfile, UserProfile userProfile> userProfileTrans() {
    userProfile.emailAddress = jsonUserProfile.emailAddress.toString();
    userProfile.messagesTotal, _ = <int>jsonUserProfile.messagesTotal.toString();
    userProfile.threadsTotal, _ = <int>jsonUserProfile.threadsTotal.toString();
    userProfile.historyId = jsonUserProfile.historyId.toString();
}

transformer <json jsonMessage, Options options> optionsTrans() {
    options.htmlBody = jsonMessage.htmlBody.toString();
    options.from = jsonMessage.from.toString();
    options.cc = jsonMessage.cc.toString();
    options.bcc = jsonMessage.bcc.toString();
    options.xmlFilePath = jsonMessage.xmlFilePath.toString();
    options.xmlFileName = jsonMessage.xmlFileName.toString();
    options.imageFilePath = jsonMessage.imageFilePath.toString();
    options.imageFileName = jsonMessage.imageFileName.toString();
    options.pdfFilePath = jsonMessage.pdfFilePath.toString();
    options.pdfFileName = jsonMessage.pdfFileName.toString();
}

transformer <json jsonDraft, Draft draft> draftTrans() {
    draft.id = jsonDraft.id.toString();
    draft.message = jsonDraft.message != null?<Message, messageTrans()>jsonDraft.message:{};
}

transformer <json jsonHeader, Header header> headerTrans() {
    header.name = jsonHeader.name.toString();
    header.value = jsonHeader.value.toString();
}

transformer <json jsonParts, Parts parts> partsTrans() {
    parts.partId = jsonParts.partId.toString();
    parts.mimeType = jsonParts.mimeType.toString();
    parts.filename = jsonParts.filename.toString();
    parts.headers = jsonParts.headers != null?getHeaders(jsonParts.headers):[];
    parts.body = jsonParts.body != null?<Body, bodyTrans()>jsonParts.body:{};
}

transformer <json jsonBody, Body body> bodyTrans() {
    body.attachmentId = jsonBody.attachmentId.toString();
    body.size, _ = <int>jsonBody.size.toString();
    body.data = jsonBody.data.toString();
}

transformer <json jsonMessagePayload, MessagePayload messagePayload> messagePayloadTrans() {
    messagePayload.partId = jsonMessagePayload.partId.toString();
    messagePayload.mimeType = jsonMessagePayload.mimeType.toString();
    messagePayload.filename = jsonMessagePayload.filename.toString();
    messagePayload.headers = jsonMessagePayload.headers != null?getHeaders(jsonMessagePayload.headers):[];
    messagePayload.body = jsonMessagePayload.body != null?<Body, bodyTrans()>jsonMessagePayload.body:{};
    messagePayload.parts = jsonMessagePayload.parts != null?getParts(jsonMessagePayload.parts):[];
}

transformer <json jsonMessage, Message message> messageTrans() {
    message.id = jsonMessage.id.toString();
    message.threadId = jsonMessage.threadId.toString();
    message.labelIds = jsonMessage.labelIds != null?getLabelIds(jsonMessage.labelIds):[];
    message.snippet = jsonMessage.snippet != null?jsonMessage.snippet.toString():null;
    message.historyId = jsonMessage.historyId != null?jsonMessage.historyId.toString():null;
    message.internalDate = jsonMessage.internalDate != null?jsonMessage.internalDate.toString():null;
    message.payload = jsonMessage.payload != null?<MessagePayload, messagePayloadTrans()>jsonMessage.payload:{};
    message.sizeEstimate = jsonMessage.sizeEstimate != null?<int, convertToInt()>jsonMessage.sizeEstimate:0;
}

transformer <json jsonDrafts, Drafts drafts> draftsTrans() {
    drafts.drafts = getDrafts(jsonDrafts.drafts);// Todo: use map (low)
    drafts.resultSizeEstimate = jsonDrafts.resultSizeEstimate != null?<int, convertToInt()>jsonDrafts.resultSizeEstimate:0;
    drafts.nextPageToken = jsonDrafts.nextPageToken != null?jsonDrafts.nextPageToken.toString():null;
}

transformer <json jsonDraftsListFilter, DraftsListFilter draftsListFilter> draftsListFilterTrans() {
    draftsListFilter.includeSpamTrash = jsonDraftsListFilter.includeSpamTrash != null?jsonDraftsListFilter.includeSpamTrash.toString():null;
    draftsListFilter.maxResults = jsonDraftsListFilter.maxResults != null?jsonDraftsListFilter.maxResults.toString():null;
    draftsListFilter.pageToken = jsonDraftsListFilter.pageToken != null?jsonDraftsListFilter.pageToken.toString():null;
    draftsListFilter.q = jsonDraftsListFilter.q != null?jsonDraftsListFilter.q.toString():null;
}

transformer <json jsonGmailError, GmailError gmailError> gmailErrorTrans() {
    gmailError.statusCode, _ = <int>jsonGmailError.statusCode.toString();
    gmailError.errorMessage = jsonGmailError.reasonPhrase.toString();
}

transformer <json jsonVal, int intVal> convertToInt() {
    intVal, _ = (int)jsonVal;
}
