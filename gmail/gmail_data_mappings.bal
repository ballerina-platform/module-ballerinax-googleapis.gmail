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
    Transforms JSON message object into Message Type Object.

    P{{sourceMessageJsonObject}} Json message object
    R{{}} If successful, returns Message type object. Else returns GmailError.
}
function convertJSONToMessageType(json sourceMessageJsonObject) returns Message|GmailError {
    Message targetMessageType;
    //Empty check is done since toString() returns "null" when accessing non existing keys of a json object
    targetMessageType.id = sourceMessageJsonObject.id != () ? sourceMessageJsonObject.id.toString() : EMPTY_STRING;
    targetMessageType.threadId = sourceMessageJsonObject.threadId != () ? sourceMessageJsonObject.threadId.toString()
                                                                                                         : EMPTY_STRING;
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
                              convertJSONToHeaderMap(sourceMessageJsonObject.payload.headers):targetMessageType.headers;
    targetMessageType.headerDate = getValueForMapKey(targetMessageType.headers, DATE);
    targetMessageType.headerSubject = getValueForMapKey(targetMessageType.headers, SUBJECT);
    targetMessageType.headerTo = getValueForMapKey(targetMessageType.headers, TO);
    targetMessageType.headerFrom = getValueForMapKey(targetMessageType.headers, FROM);
    targetMessageType.headerContentType = getValueForMapKey(targetMessageType.headers, CONTENT_TYPE);
    targetMessageType.headerCc = getValueForMapKey(targetMessageType.headers, CC);
    targetMessageType.headerBcc = getValueForMapKey(targetMessageType.headers, BCC);
    targetMessageType.mimeType = sourceMessageJsonObject.payload.mimeType != () ?
                                                     sourceMessageJsonObject.payload.mimeType.toString() : EMPTY_STRING;
    string payloadMimeType = sourceMessageJsonObject.payload.mimeType != () ?
                                                     sourceMessageJsonObject.payload.mimeType.toString() : EMPTY_STRING;
    if (sourceMessageJsonObject.payload != ()){
        //Recursively go through the payload and get relevant message body part from content type
        targetMessageType.plainTextBodyPart =
                                   getMessageBodyPartFromPayloadByMimeType(sourceMessageJsonObject.payload, TEXT_PLAIN);
        targetMessageType.htmlBodyPart =
                                    getMessageBodyPartFromPayloadByMimeType(sourceMessageJsonObject.payload, TEXT_HTML);
        (MessageBodyPart[], MessageBodyPart[]) parts = getFilePartsFromPayload(sourceMessageJsonObject.payload, [], []);
        (targetMessageType.msgAttachments, targetMessageType.inlineImgParts) = parts;
    }
    return targetMessageType;
}

documentation{
    Transforms MIME Message Part Json into MessageBody.

    P{{sourceMessagePartJsonObject}} Json message part object
    R{{}} If successful, returns MessageBodyPart type. Else returns GmailError.
}
function convertJSONToMsgBodyType(json sourceMessagePartJsonObject) returns MessageBodyPart {
    MessageBodyPart targetMessageBodyType;
    if (sourceMessagePartJsonObject != ()){
        targetMessageBodyType.fileId = sourceMessagePartJsonObject.body.attachmentId != () ?
                                                sourceMessagePartJsonObject.body.attachmentId.toString() : EMPTY_STRING;
        targetMessageBodyType.body = sourceMessagePartJsonObject.body.data != () ?
                                                        sourceMessagePartJsonObject.body.data.toString() : EMPTY_STRING;
        targetMessageBodyType.size = sourceMessagePartJsonObject.body.size != () ?
                                                        sourceMessagePartJsonObject.body.size.toString() : EMPTY_STRING;
        targetMessageBodyType.mimeType = sourceMessagePartJsonObject.mimeType != () ?
                                                         sourceMessagePartJsonObject.mimeType.toString() : EMPTY_STRING;
        targetMessageBodyType.partId = sourceMessagePartJsonObject.partId != () ?
                                                           sourceMessagePartJsonObject.partId.toString() : EMPTY_STRING;
        targetMessageBodyType.fileName = sourceMessagePartJsonObject.filename != () ?
                                                         sourceMessagePartJsonObject.filename.toString() : EMPTY_STRING;
        targetMessageBodyType.bodyHeaders = sourceMessagePartJsonObject.headers != () ?
                        convertJSONToHeaderMap(sourceMessagePartJsonObject.headers) : targetMessageBodyType.bodyHeaders;
    }
    return targetMessageBodyType;
}

documentation{
    Transforms single body of MIME Message part into MessageBodyPart Attachment.

    P{{sourceMessageBodyJsonObject}} Json message body object.
    R{{}} Returns MessageBodyPart type.
}
function convertJsonMessageBodyToMsgAttachment(json sourceMessageBodyJsonObject) returns MessageBodyPart {
    MessageBodyPart targetMessageAttachment;
    targetMessageAttachment.fileId = sourceMessageBodyJsonObject.attachmentId != () ?
                                                     sourceMessageBodyJsonObject.attachmentId.toString() : EMPTY_STRING;
    targetMessageAttachment.body = sourceMessageBodyJsonObject.data != () ?
                                                             sourceMessageBodyJsonObject.data.toString() : EMPTY_STRING;
    targetMessageAttachment.size = sourceMessageBodyJsonObject.size != () ?
                                                             sourceMessageBodyJsonObject.size.toString() : EMPTY_STRING;
    return targetMessageAttachment;
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
        match (convertJSONToMessageType(jsonMessage)){
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
function convertJSONToMessageListPageType(json sourceMsgListJsonObject) returns MessageListPage {
    MessageListPage targetMsgListPage;
    //Empty check is done since toString() returns "null" when accessing non existing keys of a json object
    targetMsgListPage.resultSizeEstimate = sourceMsgListJsonObject.resultSizeEstimate != () ?
                                                   sourceMsgListJsonObject.resultSizeEstimate.toString() : EMPTY_STRING;
    targetMsgListPage.nextPageToken = sourceMsgListJsonObject.nextPageToken != () ?
                                                        sourceMsgListJsonObject.nextPageToken.toString() : EMPTY_STRING;
    //Convert json object to json array object
    match <json[]> sourceMsgListJsonObject.messages {
        json[] messages => {
            //for each message resource in messages json array of the response
            foreach i, message in messages {
                //Create a map with message Id and thread Id as keys and add it to the array of messages
                //Assume message json field always has id and threadId as its subfields
                targetMsgListPage.messages[i] = { messageId: message.id.toString(),
                                                  threadId: message.threadId.toString() };
            }
        } //If the key messages is not in response, fails and throws an error in conversion
        error err => log:printDebug("List messages reponse does not have an array of messages");
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
    match <json[]>sourceThreadListJsonObject.threads {
        json[] threads => {
            //for each thread resource in threads json array of the response
            foreach i, thread in threads {
                //Add the thread map with Id, snippet and history Id as keys to the array of thread maps
                targetThreadListPage.threads[i] = { threadId: thread.id.toString(), snippet: thread.snippet.toString(),
                                                    historyId: thread.historyId.toString() };
            }
        }
        error err => log:printDebug("List threads response does not have an array of threads");
    }
    return targetThreadListPage;
}

documentation{
    Converts the message part header json array to headers.

    P{{jsonMsgPartHeaders}} Json array of message part headers
    R{{}} Map of headers
}
function convertJSONToHeaderMap(json jsonMsgPartHeaders) returns map {
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

function convertJsonToMailboxHistoryPage (json sourceJsonMailboxHistory) returns MailboxHistoryPage|GmailError {
    MailboxHistoryPage targetMailboxHistoryPage;
    targetMailboxHistoryPage.nextPageToken = sourceJsonMailboxHistory.nextPageToken != () ?
                                                sourceJsonMailboxHistory.nextPageToken.toString() : EMPTY_STRING;
    targetMailboxHistoryPage.historyId = sourceJsonMailboxHistory.historyId != () ?
                                                sourceJsonMailboxHistory.historyId.toString() : EMPTY_STRING;
    match <json[]>sourceJsonMailboxHistory.history {
        json[] historyList => {
            foreach i, history in historyList {
                match converJsonHistoryToHistoryType(history) {
                    History hist => targetMailboxHistoryPage.historyRecords[i] = hist;
                    GmailError gmailError => return gmailError;
                }
            }
        }
        error err => log:printDebug("History response does not have any history records");
    }
    return targetMailboxHistoryPage;
}

function convertJsonMsgListToMsgTypeList (json[] messages, Message[] targetList) returns Message[]|GmailError {
    foreach i, msg in messages {
        match convertJSONToMessageType(msg) {
            Message m => targetList[i] = m;
            GmailError gmailError => return gmailError;
        }
    }
    return targetList;
}

function converJsonHistoryToHistoryType (json sourceJsonHistory) returns History|GmailError {
    History targetHistory;
    targetHistory.id = sourceJsonHistory.id != () ? sourceJsonHistory.id.toString() : EMPTY_STRING;
    match <json[]>sourceJsonHistory.messages {
        json[] messages => targetHistory.messages =
                                                check convertJsonMsgListToMsgTypeList(messages, targetHistory.messages);
        error err => log:printDebug("History record: " + targetHistory.id + "does not have a messages field");
    }
    match <json[]>sourceJsonHistory.messagesAdded {
        json[] messages => targetHistory.messagesAdded =
                                           check convertJsonMsgListToMsgTypeList(messages, targetHistory.messagesAdded);
        error err => log:printDebug("History record: " + targetHistory.id + "does not have a messagesAdded field");
    }
    match <json[]>sourceJsonHistory.messagesDeleted {
        json[] messages => targetHistory.messagesDeleted =
                                         check convertJsonMsgListToMsgTypeList(messages, targetHistory.messagesDeleted);
        error err => log:printDebug("History record: " + targetHistory.id + "does not have a messagesDeleted field");
    }
    match <json[]>sourceJsonHistory.labelsAdded {
        json[] lbls => {
            foreach i, record in lbls {
                targetHistory.labelsAdded[i] = { message: convertJSONToMessageType(record.message) };
                match <json[]>record.labelIds{
                    json[] labelIds => targetHistory.labelsAdded[i] =
                                                                  { labelIds: convertJSONArrayToStringArray(labelIds) };
                    error err => log:printDebug("History record: " + targetHistory.id
                                                                        + "does not have a labelsAdded.labelIds field");
                }
            }
        }
        error err => log:printDebug("History record: " + targetHistory.id + "does not have a labelsAdded field");
    }
    match <json[]>sourceJsonHistory.labelsRemoved {
        json[] lbls => {
            foreach i, record in lbls {
                targetHistory.labelsRemoved[i] = { message: convertJSONToMessageType(record.message) };
                match <json[]>record.labelIds{
                    json[] labelIds => targetHistory.labelsRemoved[i] =
                                                                 { labelIds: convertJSONArrayToStringArray(labelIds) };
                    error err => log:printDebug("History record: " + targetHistory.id
                                                                        + "does not have a labelsAdded.labelIds field");
                }
            }
        }
        error err => log:printDebug("History record: " + targetHistory.id + "does not have a labelsRemoved field");
    }
    return targetHistory;
}

documentation{
    Transforms drafts list json object into DraftListPage.

    P{{sourceDraftListJsonObject}} Json Draft List object
    R{{}} DraftListPage type
}
function convertJsonDraftListToDraftListPageType(json sourceDraftListJsonObject) returns DraftListPage {
    DraftListPage targetDraftListPage;
    targetDraftListPage.resultSizeEstimate = sourceDraftListJsonObject.resultSizeEstimate != () ?
                                                 sourceDraftListJsonObject.resultSizeEstimate.toString() : EMPTY_STRING;
    targetDraftListPage.nextPageToken = sourceDraftListJsonObject.nextPageToken != () ?
                                                      sourceDraftListJsonObject.nextPageToken.toString() : EMPTY_STRING;
    match <json[]>sourceDraftListJsonObject.drafts {
        json[] drafts => {
            //for each draft resource in drafts json array of the response
            foreach i, draft in drafts {
                //Add the draft map with the Id and the message map with message Id and thread Id as keys, to the array
                targetDraftListPage.drafts[i] = { draftId: draft.id.toString(),
                                                  messageId: draft.message.messageId.toString(),
                                                  threadId: draft.message.threadId.toString() };
            }
        }
        error err => log:printDebug("List drafts response does not contain an array of drafts");
    }
    return targetDraftListPage;
}

documentation{
    Transform draft json object into Draft Type Object.

    P{{sourceDraftJsonObject}} Json Draft Object
    R{{}} If successful, returns Draft. Else returns GmailError.
}
function convertJsonDraftToDraftType(json sourceDraftJsonObject) returns Draft|GmailError {
    Draft targetDraft;
    targetDraft.id = sourceDraftJsonObject.id != () ? sourceDraftJsonObject.id.toString() : EMPTY_STRING;
    targetDraft.message = sourceDraftJsonObject.message != () ?
                                                check convertJSONToMessageType(sourceDraftJsonObject.message) : {};
    return targetDraft;
}
