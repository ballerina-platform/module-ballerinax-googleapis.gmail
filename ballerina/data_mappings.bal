// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import googleapis.gmail.oas;

import ballerina/io;
import ballerina/uuid;

isolated function convertOASMessageToMessage(oas:Message response) returns Message|error {
    Message email = {
        threadId: response.threadId ?: EMPTY_STRING,
        id: response.id ?: EMPTY_STRING
    };

    string? rawMessage = response.raw;
    if rawMessage is string {
        email.raw = check base64UrlDecode(rawMessage);
    }

    email.labelIds = response.labelIds ?: email.labelIds;
    email.snippet = response.snippet ?: email.snippet;
    email.historyId = response.historyId ?: email.historyId;
    email.internalDate = response.internalDate ?: email.internalDate;
    email.sizeEstimate = response.sizeEstimate ?: email.sizeEstimate;

    oas:MessagePart? payload = response.payload;
    if payload is oas:MessagePart {
        email.payload = check convertOASMessagePartToMultipartMessageBody(payload);
        email.mimeType = response.payload?.mimeType;

        oas:MessagePartHeader[] headers = response.payload?.headers ?: [];
        map<string> headersMap = {};
        foreach oas:MessagePartHeader h in headers {
            string originalKey = h.name ?: EMPTY_STRING;
            headersMap[originalKey.toLowerAscii()] = h.value ?: EMPTY_STRING;
        }

        if headersMap.hasKey(TO) {
            email.to = re `,`.split(headersMap.get(TO));
        }

        if headersMap.hasKey(FROM) {
            email.'from = headersMap.get(FROM);
        }

        if headersMap.hasKey(CC) {
            email.cc = re `,`.split(headersMap.get(CC));
        }

        if headersMap.hasKey(BCC) {
            email.bcc = re `,`.split(headersMap.get(BCC));
        }

        if headersMap.hasKey(SUBJECT) {
            email.subject = headersMap.get(SUBJECT);
        }

        if headersMap.hasKey(DATE) {
            email.date = headersMap.get(DATE);
        }

        if headersMap.hasKey(CONTENT_TYPE) {
            email.contentType = headersMap.get(CONTENT_TYPE);
        }

    }
    return email;
}

isolated function convertOASMessagePartToMultipartMessageBody(oas:MessagePart response)
returns MessagePart|error {
    MessagePart messagePart = {
        partId: response.partId ?: EMPTY_STRING
    };
    messagePart.filename = response.filename ?: messagePart.filename;
    messagePart.mimeType = response.mimeType ?: messagePart.mimeType;

    oas:MessagePartHeader[] headers = response.headers ?: [];
    if response.headers is oas:MessagePartHeader[] {
        messagePart.headers = map from oas:MessagePartHeader h in headers
            select [h.name ?: EMPTY_STRING, h.value ?: EMPTY_STRING];
    }

    oas:MessagePartBody? body = response.body;
    if body is oas:MessagePartBody {
        messagePart.attachmentId = body.attachmentId ?: messagePart.attachmentId;
        messagePart.size = body.size ?: messagePart.size;
        if body.data is string {
            messagePart.data = check base64UrlDecode(body.data ?: EMPTY_STRING);
        }
    }

    oas:MessagePart[] parts = response.parts ?: [];
    if response.parts is oas:MessagePart[] {
        MessagePart[] processedParts = [];
        foreach oas:MessagePart part in parts {
            processedParts.push(check convertOASMessagePartToMultipartMessageBody(part).ensureType(MessagePart));
        }
        messagePart.parts = processedParts;
    }

    return messagePart;
}

isolated function convertMessageRequestToOASMessage(MessageRequest req) returns oas:Message|error {
    string message = check getRFC822MessageString(req);
    oas:Message apiMessage = {
        raw: base64UrlEncode(message)
    };
    return apiMessage;
}

isolated function getRFC822MessageString(MessageRequest req) returns string|error {
    //Raw string of message
    string messageString = EMPTY_STRING;

    //Set the general headers of the message
    string[]? to = req.to;
    if to is string[] && to.length() > 0 {
        messageString += TO + COLON + string:'join(",", ...to) + NEW_LINE;
    }
    if req.subject is string {
        messageString += SUBJECT + COLON + <string>req.subject + NEW_LINE;
    }

    if req.'from is string {
        messageString += FROM + COLON + <string>req.'from + NEW_LINE;
    }
    string[]? cc = req.cc;
    if cc is string[] && cc.length() > 0 {
        messageString += CC + COLON + string:'join(",", ...cc) + NEW_LINE;
    }
    string[]? bcc = req.bcc;
    if bcc is string[] && bcc.length() > 0 {
        messageString += BCC + COLON + string:'join(",", ...bcc) + NEW_LINE;
    }

    string bodyString = EMPTY_STRING;
    string bodyTextPlain = EMPTY_STRING;
    if req.bodyInText is string {
        bodyTextPlain += TEXT_PLAIN_HEADERS + NEW_LINE;
        bodyTextPlain += NEW_LINE + <string>req.bodyInText + NEW_LINE;
        bodyString += bodyTextPlain;
    }

    string bodyHtmlText = EMPTY_STRING;
    if req.bodyInHtml is string {
        bodyHtmlText += TEXT_HTML_HEADERS + NEW_LINE;
        bodyHtmlText += NEW_LINE + <string>req.bodyInHtml + NEW_LINE;
    }

    if bodyTextPlain != EMPTY_STRING && bodyHtmlText != EMPTY_STRING {
        bodyString = getMultipartMessageString(MULTIPART_ALTERNATE_HEADERS, bodyTextPlain, bodyHtmlText);
    } else if bodyHtmlText != EMPTY_STRING {
        bodyString += bodyHtmlText;
    }

    string[] inlineImageStrings = [];
    ImageFile[] inlineImages = req.inlineImages ?: [];
    foreach ImageFile image in inlineImages {
        inlineImageStrings.push(check getFileMessageString(image, INLINE));
    }

    if inlineImageStrings.length() > 0 {
        if bodyString != EMPTY_STRING {
            bodyString = getMultipartMessageString(MULTIPART_RELATED_HEADERS, bodyString, ...inlineImageStrings);
        } else {
            bodyString = getMultipartMessageString(MULTIPART_RELATED_HEADERS, ...inlineImageStrings);
        }
    }

    string[] attachmentsStrings = [];
    AttachmentFile[] attachments = req.attachments ?: [];
    foreach AttachmentFile attachment in attachments {
        attachmentsStrings.push(check getFileMessageString(attachment, ATTACHMENT));
    }

    if attachmentsStrings.length() > 0 {
        if bodyString != EMPTY_STRING {
            bodyString = getMultipartMessageString(MULTIPART_MIXED_HEADERS, bodyString, ...attachmentsStrings);
        } else {
            bodyString = getMultipartMessageString(MULTIPART_MIXED_HEADERS, ...attachmentsStrings);
        }
    }
    messageString += bodyString;
    return messageString;
}

isolated function getMultipartMessageString(string headers, string... parts) returns string {
    string boundary = uuid:createType4AsString();
    string messageString = headers + boundary + DOUBLE_QUOTE + NEW_LINE;
    foreach string part in parts {
        messageString += NEW_LINE + DASH + DASH + boundary + NEW_LINE;
        messageString += part + NEW_LINE;
    }
    messageString += NEW_LINE + DASH + DASH + boundary + DASH + DASH + NEW_LINE;
    return messageString;
}

isolated function getFileMessageString(AttachmentFile|ImageFile file, string embedType) returns string|error {
    string fileString =
        CONTENT_TYPE + COLON + file.mimeType + SEMICOLON + WHITE_SPACE +
        CONTENT_TYPE_NAME_ATTRIBUTE + file.name + DOUBLE_QUOTE + NEW_LINE +
        CONTENT_DISPOSITION + COLON + embedType + SEMICOLON + WHITE_SPACE +
        CONTENT_DISPOSITION_FILENAME_ATTRIBUTE + file.name + DOUBLE_QUOTE + NEW_LINE +
        CONTENT_TRANSFER_ENCODING + COLON + BASE_64 + NEW_LINE;
    if file is ImageFile {
        fileString += CONTENT_ID + COLON + file.contentId + NEW_LINE;
    }
    fileString += NEW_LINE + check getEncodedFileContent(file.path) + NEW_LINE;
    return fileString;
}

// todo check error usages
isolated function getEncodedFileContent(string filePath) returns string|error {
    io:ReadableByteChannel fileChannel = check io:openReadableFile(filePath);
    io:ReadableByteChannel fileContent = check fileChannel.base64Encode();
    io:ReadableByteChannel encodedFileChannel = fileContent;
    byte[] readChannel = check encodedFileChannel.read(100000000);
    return string:fromBytes(readChannel);
}

isolated function convertOASListMessagesResponseToListMessageResponse(oas:ListMessagesResponse response)
returns ListMessagesResponse {
    ListMessagesResponse messageListPage = {};
    oas:Message[]? messages = response.messages;
    if messages is oas:Message[] {
        Message[] processedMessages = [];
        foreach oas:Message msg in messages {
            // Only need to parse the ids as list response does not return any other info.
            Message email = {
                threadId: msg.threadId ?: EMPTY_STRING,
                id: msg.id ?: EMPTY_STRING
            };
            processedMessages.push(email);
        }
        messageListPage.messages = processedMessages;
    }
    messageListPage.nextPageToken = response.nextPageToken ?: messageListPage.nextPageToken;
    messageListPage.resultSizeEstimate = response.resultSizeEstimate ?: messageListPage.resultSizeEstimate;
    return messageListPage;
}

isolated function convertOASMessagePartBodyToAttachment(oas:MessagePartBody bodyPart) returns Attachment|error {
    Attachment attachment = {};
    attachment.attachmentId = bodyPart.attachmentId ?: attachment.attachmentId;
    attachment.size = bodyPart.size ?: attachment.size;
    string? data = bodyPart.data;
    if data is string {
        attachment.data = check base64UrlDecode(data);
    }
    return attachment;
}

isolated function convertOASListDraftsResponseToListDraftsResponse(oas:ListDraftsResponse response)
returns ListDraftsResponse|error {
    ListDraftsResponse draftListPage = {};
    oas:Draft[]? drafts = response.drafts;
    if drafts is oas:Draft[] {
        Draft[] processedDrafts = [];
        foreach oas:Draft draft in drafts {
            Draft draftEmail = {
                id: draft.id ?: EMPTY_STRING
            };
            oas:Message? message = draft.message;
            if message is oas:Message {
                draftEmail.message = {
                    // list response does not return any other info.
                    threadId: message.threadId ?: EMPTY_STRING,
                    id: message.id ?: EMPTY_STRING
                };
            }
            processedDrafts.push(draftEmail);
        }
        draftListPage.drafts = processedDrafts;
    }
    draftListPage.nextPageToken = response.nextPageToken ?: draftListPage.nextPageToken;
    draftListPage.resultSizeEstimate = response.resultSizeEstimate ?: draftListPage.resultSizeEstimate;
    return draftListPage;
}

isolated function convertOASDraftToDraft(oas:Draft oasDraft) returns Draft|error {
    Draft draft = {
        id: oasDraft.id ?: EMPTY_STRING
    };
    oas:Message? message = oasDraft.message;
    if message is oas:Message {
        draft.message = check convertOASMessageToMessage(message);
    }
    return draft;
}

isolated function convertDraftRequestToOASDraft(DraftRequest payload) returns oas:Draft|error {
    oas:Draft draft = {
        id: payload.id
    };
    MessageRequest? updatedDraft = payload.message;
    if updatedDraft is MessageRequest {
        draft.message = check convertMessageRequestToOASMessage(updatedDraft);
    }
    return draft;
}

isolated function convertOASListThreadsResponseToListThreadsResponse(oas:ListThreadsResponse response) returns ListThreadsResponse {
    ListThreadsResponse threadListPage = {};
    oas:MailThread[]? threads = response.threads;
    if threads is oas:MailThread[] {
        MailThread[] processedThreads = [];
        foreach oas:MailThread thread in threads {
            MailThread emailThread = {
                // list response does not return any other info.
                id: thread.id ?: EMPTY_STRING,
                historyId: thread.historyId ?: EMPTY_STRING
            };
            processedThreads.push(emailThread);
        }
        threadListPage.threads = processedThreads;
    }
    threadListPage.nextPageToken = response.nextPageToken ?: threadListPage.nextPageToken;
    threadListPage.resultSizeEstimate = response.resultSizeEstimate ?: threadListPage.resultSizeEstimate;
    return threadListPage;
}

isolated function convertOASMailThreadToMailThread(oas:MailThread oasThread) returns MailThread|error {
    MailThread thread = {
        id: oasThread.id ?: EMPTY_STRING,
        historyId: oasThread.historyId ?: EMPTY_STRING
    };
    oas:Message[]? messages = oasThread.messages;
    if messages is oas:Message[] {
        Message[] processedMessages = [];
        foreach oas:Message msg in messages {
            processedMessages.push(check convertOASMessageToMessage(msg));
        }
        thread.messages = processedMessages;
    }
    return thread;
}

isolated function convertOASListHistoryResponseToListHistoryResponse(oas:ListHistoryResponse response) returns ListHistoryResponse {
    ListHistoryResponse historyListPage = {};
    oas:History[]? histories = response.history;
    if histories is oas:History[] {
        History[] processedHistories = [];
        foreach oas:History history in histories {
            History emailHistory = {
                id: history.id ?: EMPTY_STRING
            };
            oas:Message[]? messages = history.messages;
            if messages is oas:Message[] {
                Message[] processedMessages = [];
                foreach oas:Message msg in messages {
                    processedMessages.push({
                        // list response does not return any other info.
                        threadId: msg.threadId ?: EMPTY_STRING,
                        id: msg.id ?: EMPTY_STRING
                    });
                }
                emailHistory.messages = processedMessages;
            }

            oas:HistoryLabelAdded[]? labelAddedMessages = history.labelsAdded;
            if labelAddedMessages is oas:HistoryLabelAdded[] {
                HistoryLabelAdded[] processedLabelAddedMessages = [];
                foreach oas:HistoryLabelAdded labelAddedMessage in labelAddedMessages {
                    processedLabelAddedMessages.push({
                        // list response does not return any other info.
                        labelIds: labelAddedMessage.labelIds ?: [],
                        message: {
                            threadId: labelAddedMessage.message?.threadId ?: EMPTY_STRING,
                            id: labelAddedMessage.message?.id ?: EMPTY_STRING
                        }
                    });
                }
                emailHistory.labelsAdded = processedLabelAddedMessages;
            }

            oas:HistoryLabelRemoved[]? labelRemovedMessages = history.labelsRemoved;
            if labelRemovedMessages is oas:HistoryLabelRemoved[] {
                HistoryLabelRemoved[] processedLabelRemovedMessages = [];
                foreach oas:HistoryLabelRemoved labelRemovedMessage in labelRemovedMessages {
                    processedLabelRemovedMessages.push({
                        // list response does not return any other info.
                        labelIds: labelRemovedMessage.labelIds ?: [],
                        message: {
                            threadId: labelRemovedMessage.message?.threadId ?: EMPTY_STRING,
                            id: labelRemovedMessage.message?.id ?: EMPTY_STRING
                        }
                    });
                }
                emailHistory.labelsRemoved = processedLabelRemovedMessages;
            }

            oas:HistoryMessageAdded[]? messageAddedMessages = history.messagesAdded;
            if messageAddedMessages is oas:HistoryMessageAdded[] {
                HistoryMessageAdded[] processedMessageAddedMessages = [];
                foreach oas:HistoryMessageAdded messageAddedMessage in messageAddedMessages {
                    processedMessageAddedMessages.push({
                        // list response does not return any other info.
                        message: {
                            threadId: messageAddedMessage.message?.threadId ?: EMPTY_STRING,
                            id: messageAddedMessage.message?.id ?: EMPTY_STRING
                        }
                    });
                }
                emailHistory.messagesAdded = processedMessageAddedMessages;
            }

            oas:HistoryMessageDeleted[]? messageDeletedMessages = history.messagesDeleted;
            if messageDeletedMessages is oas:HistoryMessageDeleted[] {
                HistoryMessageDeleted[] processedMessageDeletedMessages = [];
                foreach oas:HistoryMessageDeleted messageDeletedMessage in messageDeletedMessages {
                    processedMessageDeletedMessages.push({
                        // list response does not return any other info.
                        message: {
                            threadId: messageDeletedMessage.message?.threadId ?: EMPTY_STRING,
                            id: messageDeletedMessage.message?.id ?: EMPTY_STRING
                        }
                    });
                }
                emailHistory.messagesDeleted = processedMessageDeletedMessages;
            }

            processedHistories.push(emailHistory);
        }
        historyListPage.history = processedHistories;
    }
    historyListPage.historyId = response.historyId ?: historyListPage.historyId;
    historyListPage.nextPageToken = response.nextPageToken ?: historyListPage.nextPageToken;
    return historyListPage;
}
