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

# Transforms JSON message object into Message Type Object.
# + sourceMessageJsonObject - `json` message object
# + return - Returns Message type object
function convertJSONToMessageType(json sourceMessageJsonObject) returns Message {
    Message targetMessageType = {};
    //Empty check is done since toString() returns "null" when accessing non existing keys of a json object
    targetMessageType.id = sourceMessageJsonObject.id != () ? sourceMessageJsonObject.id.toString() : EMPTY_STRING;
    targetMessageType.threadId = sourceMessageJsonObject.threadId != () ? sourceMessageJsonObject.threadId.toString()
                                                                                                         : EMPTY_STRING;
    targetMessageType.labelIds = sourceMessageJsonObject.labelIds != () ?
                                        convertJSONArrayToStringArray(<json[]>sourceMessageJsonObject.labelIds) : [];
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
        //Recursively go through the payload and get message attachment and inline image parts
        (MessageBodyPart[], MessageBodyPart[]) parts = getFilePartsFromPayload(sourceMessageJsonObject.payload, [], []);
        (targetMessageType.msgAttachments, targetMessageType.inlineImgParts) = parts;
    }
    return targetMessageType;
}

# Transforms MIME Message Part JSON into MessageBody.
# + sourceMessagePartJsonObject - `json` message part object
# + return - Returns MessageBodyPart type
function convertJSONToMsgBodyType(json sourceMessagePartJsonObject) returns MessageBodyPart {
    MessageBodyPart targetMessageBodyType = {};
    if (sourceMessagePartJsonObject != ()){
        //Empty check is done since toString() returns "null" when accessing non existing keys of a json object
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

# Transforms single body of MIME Message part into MessageBodyPart Attachment.
# + sourceMessageBodyJsonObject - `json` message body object
# + return - Returns MessageBodyPart type object
function convertJSONToMsgBodyAttachment(json sourceMessageBodyJsonObject) returns MessageBodyPart {
    MessageBodyPart targetMessageAttachment = {};
    //Empty check is done since toString() returns "null" when accessing non existing keys of a json object
    targetMessageAttachment.fileId = sourceMessageBodyJsonObject.attachmentId != () ?
                                                     sourceMessageBodyJsonObject.attachmentId.toString() : EMPTY_STRING;
    targetMessageAttachment.body = sourceMessageBodyJsonObject.data != () ?
                                                             sourceMessageBodyJsonObject.data.toString() : EMPTY_STRING;
    targetMessageAttachment.size = sourceMessageBodyJsonObject.size != () ?
                                                             sourceMessageBodyJsonObject.size.toString() : EMPTY_STRING;
    return targetMessageAttachment;
}

# Transforms mail thread JSON object into Thread.
# + sourceThreadJsonObject - `json` message thread object.
# + return - Returns Thread type.
function convertJSONToThreadType(json sourceThreadJsonObject) returns Thread {
    Thread targetThreadType = {};
    //Empty check is done since toString() returns "null" when accessing non existing keys of a json object
    targetThreadType.id = sourceThreadJsonObject.id != () ? sourceThreadJsonObject.id.toString() : EMPTY_STRING;
    targetThreadType.historyId = sourceThreadJsonObject.historyId != () ?
                                                             sourceThreadJsonObject.historyId.toString() : EMPTY_STRING;
    targetThreadType.messages = convertToMessageArray(<json[]> sourceThreadJsonObject.messages);
    return targetThreadType;
}

# Converts the JSON message array into Message type array.
# + sourceMessageArrayJsonObject - `json` message array object
# + return - Message type array
function convertToMessageArray(json[] sourceMessageArrayJsonObject) returns Message[] {
    Message[] messages = [];
    int i = 0;
    foreach json jsonMessage in sourceMessageArrayJsonObject {
        messages[i] = convertJSONToMessageType(jsonMessage);
        i = i + 1;
    }
    return messages;
}

# Transforms user profile JSON object into UserProfile.
# + sourceUserProfileJsonObject - `json` user profile object
# + return - UserProfile type
function convertJSONToUserProfileType(json sourceUserProfileJsonObject) returns UserProfile {
    UserProfile targetUserProfile = {};
    //Empty check is done since toString() returns "null" when accessing non existing keys of a json object
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

# Transforms message list JSON object into MessageListPage.
# + sourceMsgListJsonObject - `json` Messsage List object
# + return - MessageListPage type
function convertJSONToMessageListPageType(json sourceMsgListJsonObject) returns MessageListPage {
    MessageListPage targetMsgListPage = {};
    //Empty check is done since toString() returns "null" when accessing non existing keys of a json object
    targetMsgListPage.resultSizeEstimate = sourceMsgListJsonObject.resultSizeEstimate != () ?
                                                   sourceMsgListJsonObject.resultSizeEstimate.toString() : EMPTY_STRING;
    targetMsgListPage.nextPageToken = sourceMsgListJsonObject.nextPageToken != () ?
                                                        sourceMsgListJsonObject.nextPageToken.toString() : EMPTY_STRING;
    //Convert json object to json array object
    //for each message resource in messages json array of the response
    json[] messages = <json[]> sourceMsgListJsonObject.messages;
    int  i = 0;
    foreach json message in messages {
        //Create a map with message Id and thread Id as keys and add it to the array of messages
        //Assume message json field always has id and threadId as its subfields
        targetMsgListPage.messages[i] = { messageId: message.id.toString(),
                                          threadId: message.threadId.toString() };
        i = i + 1;
    }

    return targetMsgListPage;
}

# Transforms thread list JSON object into ThreadListPage.
# + sourceThreadListJsonObject - `json` Thead List object
# + return - ThreadListPage type
function convertJSONToThreadListPageType(json sourceThreadListJsonObject) returns ThreadListPage {
    ThreadListPage targetThreadListPage = {};
    //Empty check is done since toString() returns "null" when accessing non existing keys of a json object
    targetThreadListPage.resultSizeEstimate = sourceThreadListJsonObject.resultSizeEstimate != () ?
                                                sourceThreadListJsonObject.resultSizeEstimate.toString() : EMPTY_STRING;
    targetThreadListPage.nextPageToken = sourceThreadListJsonObject.nextPageToken != () ?
                                                     sourceThreadListJsonObject.nextPageToken.toString() : EMPTY_STRING;
    //for each thread resource in threads json array of the response
    json[] jsonThreads = <json[]>sourceThreadListJsonObject.threads;
    int  i = 0;
    foreach json thread in jsonThreads {
    //    //Create a map with thread Id, snippet and history Id as keys and add it to the array of threads
    //    //Assume thread json field always has thread.id and thread.snippet and thread.historyId as its subfields
        targetThreadListPage.threads[i] = {
                threadId: thread["id"].toString(), snippet: thread.snippet.toString(),
                                            historyId: thread.historyId.toString() };
        i = i + 1;
    }
    return targetThreadListPage;
}

# Converts the message part header JSON array to headers.
# + jsonMsgPartHeaders - `json` array of message part headers
# + return - Map of headers
function convertJSONToHeaderMap(json jsonMsgPartHeaders) returns map<string> {
    map<string> headers = {};
    json[] jsonHeaders = <json[]>jsonMsgPartHeaders;
    foreach json jsonHeader in jsonHeaders {
        headers[jsonHeader.name.toString()] = jsonHeader.value.toString();
    }
    return headers;
}

# Converts the JSON label resource to Label type.
# + sourceLabelJsonObject - `json` label
# + return - Label type object
function convertJSONToLabelType(json sourceLabelJsonObject) returns Label {
    Label targetLabel = {};
    //Empty check is done since toString() returns "null" when accessing non existing keys of a json object
    targetLabel.id = sourceLabelJsonObject.id != () ? sourceLabelJsonObject.id.toString() : EMPTY_STRING;
    targetLabel.name = sourceLabelJsonObject.name != () ? sourceLabelJsonObject.name.toString() : EMPTY_STRING;
    targetLabel.messageListVisibility = sourceLabelJsonObject.messageListVisibility != () ?
                                                  sourceLabelJsonObject.messageListVisibility.toString() : EMPTY_STRING;
    targetLabel.labelListVisibility = sourceLabelJsonObject.labelListVisibility != () ?
                                                    sourceLabelJsonObject.labelListVisibility.toString() : EMPTY_STRING;
    targetLabel.ownerType = sourceLabelJsonObject["type"] != () ? sourceLabelJsonObject["type"].toString()
                                                                                                         : EMPTY_STRING;
    targetLabel.messagesTotal = sourceLabelJsonObject.messagesTotal != () ?
                                    convertToInt(sourceLabelJsonObject.messagesTotal) : 0;

    targetLabel.messagesUnread = sourceLabelJsonObject.messagesUnread != () ?
                                    convertToInt(sourceLabelJsonObject.messagesUnread) : 0;

    targetLabel.threadsUnread = sourceLabelJsonObject.threadsUnread != () ?
                                    convertToInt(sourceLabelJsonObject.threadsUnread) : 0;

    targetLabel.threadsTotal = sourceLabelJsonObject.threadsTotal != () ?
                                    convertToInt(sourceLabelJsonObject.threadsTotal) : 0;

    targetLabel.textColor = sourceLabelJsonObject.color.textColor != () ?
                                                        sourceLabelJsonObject.color.textColor.toString() : EMPTY_STRING;
    targetLabel.backgroundColor = sourceLabelJsonObject.color.backgroundColor != () ?
                                                  sourceLabelJsonObject.color.backgroundColor.toString() : EMPTY_STRING;
    return targetLabel;
}

function convertToInt(json jsonVal) returns int {
    string stringVal = jsonVal.toString();
    if (stringVal != "") {
        var intVal = int.convert(stringVal);
    if (intVal is int) {
        return intVal;
    } else {
        error err = error(GMAIL_ERROR_CODE,
        { message: "Error occurred when converting " + stringVal + " to int"});
        panic err;
        }
    } else {
        return 0;
    }
}

# Convert JSON label list response to an array of Label type objects.
# + sourceJsonLabelList - Source `json` object
# + return - Returns an array of Label type objects
function convertJSONToLabelTypeList(json sourceJsonLabelList) returns Label[] {
    Label[] targetLabelList = [];
    //Convert json object to json array object
    json[] jsonLabelList = <json[]>sourceJsonLabelList.labels;
    int i = 0;
    foreach json label in jsonLabelList {
        targetLabelList[i] = convertJSONToLabelType(label);
        i = i + 1;
    }
    return targetLabelList;
}

# Converts JSON mailbox history to MailboxHistoryPage Type.
# + sourceJsonMailboxHistory - `json` mailbox history
# + return-  Returns MailboxHistoryPage Type object
function convertJSONToMailboxHistoryPage (json sourceJsonMailboxHistory) returns MailboxHistoryPage {
    MailboxHistoryPage targetMailboxHistoryPage = {};
    targetMailboxHistoryPage.nextPageToken = sourceJsonMailboxHistory.nextPageToken != () ?
                                                       sourceJsonMailboxHistory.nextPageToken.toString() : EMPTY_STRING;
    targetMailboxHistoryPage.historyId = sourceJsonMailboxHistory.historyId != () ?
                                                           sourceJsonMailboxHistory.historyId.toString() : EMPTY_STRING;
    json[] historyList = <json[]>sourceJsonMailboxHistory.history;
    int i = 0;
    foreach json history in historyList {
        targetMailboxHistoryPage.historyRecords[i] = convertJSONToHistoryType(history);
        i = i + 1;
    }

    return targetMailboxHistoryPage;
}

# Converts JSON list of messages to Message Type list.
# + messages - `json` list of messages
# + targetList - Message Type list to be returned
# + return - Returns Message Type list
function convertJSONToMsgTypeList(json[] messages, Message[] targetList) returns Message[] {
    int i = 0;
    foreach json msg in messages {
        targetList[i] = convertJSONToMessageType(msg);
        i = i + 1;
    }
    return targetList;
}

# Converts JSON history to History Type object.
# + sourceJsonHistory - Source `json` History
# + return - Returns History Type object
function convertJSONToHistoryType(json sourceJsonHistory) returns History {
    History targetHistory = {};
    targetHistory.id = sourceJsonHistory.id != () ? sourceJsonHistory.id.toString() : EMPTY_STRING;
    targetHistory.messages = sourceJsonHistory.messages != () ?
                            convertJSONToMsgTypeList(<json[]> sourceJsonHistory.messages, targetHistory.messages) : [];
    targetHistory.messages = sourceJsonHistory.messagesAdded != () ?
                            convertJSONToMsgTypeList(<json[]> sourceJsonHistory.messagesAdded, targetHistory.messages)
                            : [];
    targetHistory.messages = sourceJsonHistory.messagesDeleted != () ?
                            convertJSONToMsgTypeList(<json[]> sourceJsonHistory.messagesDeleted, targetHistory.messages)
                            : [];
    if(sourceJsonHistory.labelsAdded != ()) {
        json[] lbls = <json[]>sourceJsonHistory.labelsAdded;
        int i = 0;
        foreach json recordData in lbls {
            targetHistory.labelsAdded[i] = { message: convertJSONToMessageType(recordData.message) };
            targetHistory.labelsAdded[i] = { labelIds: convertJSONArrayToStringArray(< json[] > recordData.labelIds) };
            i = i + 1;
        }
    }
    if(sourceJsonHistory.labelsRemoved != ()) {
        json[] lblsRemoved = < json[]> sourceJsonHistory.labelsRemoved;
        int j =0;
        foreach json recordData in lblsRemoved {
            targetHistory.labelsRemoved[j] = { message: convertJSONToMessageType(recordData.message) };
            targetHistory.labelsRemoved[j] = { labelIds: convertJSONArrayToStringArray(< json[] > recordData.labelIds) };
            j = j +1;
        }
    }
    return targetHistory;
}

# Transforms drafts list JSON object into DraftListPage.
# + sourceDraftListJsonObject - `json` Draft List object
# + return - DraftListPage type
function convertJSONToDraftListPageType(json sourceDraftListJsonObject) returns DraftListPage {
    DraftListPage targetDraftListPage = {};
    targetDraftListPage.resultSizeEstimate = sourceDraftListJsonObject.resultSizeEstimate != () ?
                                                 sourceDraftListJsonObject.resultSizeEstimate.toString() : EMPTY_STRING;
    targetDraftListPage.nextPageToken = sourceDraftListJsonObject.nextPageToken != () ?
                                                      sourceDraftListJsonObject.nextPageToken.toString() : EMPTY_STRING;
    json[] drafts = <json[]>sourceDraftListJsonObject.drafts;
    //for each draft resource in drafts json array of the response
    int i = 0;
    foreach json draft in drafts {
        //Add the draft map with the Id and the message map with message Id and thread Id as keys, to the array
        targetDraftListPage.drafts[i] = { draftId: draft.id.toString(),
                                          messageId: draft.message.messageId.toString(),
                                          threadId: draft.message.threadId.toString() };
        i = i + 1;
    }
    return targetDraftListPage;
}

# Transform draft JSON object into Draft Type Object.
# + sourceDraftJsonObject - `json` Draft Object
# + return - If successful, returns Draft. Else returns error.
function convertJSONToDraftType(json sourceDraftJsonObject) returns Draft {
    Draft targetDraft = {};
    targetDraft.id = sourceDraftJsonObject.id != () ? sourceDraftJsonObject.id.toString() : EMPTY_STRING;
    targetDraft.message = sourceDraftJsonObject.message != () ?
                                                           convertJSONToMessageType(sourceDraftJsonObject.message) : {};
    return targetDraft;
}
