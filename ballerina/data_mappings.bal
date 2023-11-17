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

    do {
        string? rawMessage = response.raw;
        if rawMessage is string {
            email.raw = check base64UrlDecode(rawMessage);
        }
    } on fail error err {
        return error InvalidEncodedValue(string `Returned message raw field${err.message()}`, err.cause());
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
        map<string> headersMap = map from oas:MessagePartHeader h in headers
            let string key = h.name ?: EMPTY_STRING
            select [key.toLowerAscii(), h.value ?: EMPTY_STRING];

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

        if headersMap.hasKey(MESSAGE_ID) {
            email.messageId = headersMap.get(MESSAGE_ID);
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
        do {
            string? data = body.data;
            if data is string {
                messagePart.data = check base64UrlDecode(data);
            }
        } on fail error err {
            check error InvalidEncodedValue(
                string `Returned message body part of id '${messagePart.partId}'${err.message()}`, err.cause());
        }
    }

    MessagePart[] processedParts = from oas:MessagePart part in response.parts ?: []
        select check convertOASMessagePartToMultipartMessageBody(part);
    if processedParts.length() > 0 {
        messagePart.parts = processedParts;
    }

    return messagePart;
}

isolated function convertMessageRequestToOASMessage(MessageRequest req) returns oas:Message|error {
    string message = check getRFC822MessageString(req);
    oas:Message apiMessage = {
        raw: base64UrlEncode(message)
    };
    apiMessage.threadId = req.threadId ?: apiMessage.threadId;
    return apiMessage;
}

isolated function getRFC822MessageString(MessageRequest req) returns string|error {
    //Raw string of message
    string messageString = EMPTY_STRING;

    //Set the general headers of the message
    string[]? to = req.to;
    if to is string[] && to.length() > 0 {
        messageString += TO + COLON + string:'join(COMMA, ...to) + NEW_LINE;
    }
    if req.subject is string {
        messageString += SUBJECT + COLON + <string>req.subject + NEW_LINE;
    }

    if req.'from is string {
        messageString += FROM + COLON + <string>req.'from + NEW_LINE;
    }
    string[]? cc = req.cc;
    if cc is string[] && cc.length() > 0 {
        messageString += CC + COLON + string:'join(COMMA, ...cc) + NEW_LINE;
    }
    string[]? bcc = req.bcc;
    if bcc is string[] && bcc.length() > 0 {
        messageString += BCC + COLON + string:'join(COMMA, ...bcc) + NEW_LINE;
    }

    string? messageId = req.initialMessageId;
    if messageId is string {
        messageString += IN_REPLY_TO + COLON + <string>messageId + NEW_LINE;
    }

    string[]? references = req.references;
    if references is string[] && references.length() > 0 {
        messageString += REFERENCES + COLON + string:'join(COMMA, ...references) + NEW_LINE;
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

    string[] inlineImageStrings = from ImageFile image in req.inlineImages ?: []
        select check getFileMessageString(image, INLINE);
    if inlineImageStrings.length() > 0 {
        if bodyString != EMPTY_STRING {
            bodyString = getMultipartMessageString(MULTIPART_RELATED_HEADERS, bodyString, ...inlineImageStrings);
        } else {
            bodyString = getMultipartMessageString(MULTIPART_RELATED_HEADERS, ...inlineImageStrings);
        }
    }

    string[] attachmentsStrings = from AttachmentFile attachment in req.attachments ?: []
        select check getFileMessageString(attachment, ATTACHMENT);

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
    fileString += NEW_LINE + check getEncodedFileContent(file.path, embedType) + NEW_LINE;
    return fileString;
}

// todo check error usages
isolated function getEncodedFileContent(string filePath, string embedType) returns string|error {
    do {
        io:ReadableByteChannel fileChannel = check io:openReadableFile(filePath);
        io:ReadableByteChannel fileContent = check fileChannel.base64Encode();
        io:ReadableByteChannel encodedFileChannel = fileContent;
        byte[] readChannel = check encodedFileChannel.read(100000000);
        return string:fromBytes(readChannel);
    } on fail error e {
        return error FileGenericError(
            string `Unable to retrieve ${embedType}: ${filePath}`, e);
    }
}

isolated function convertOASListMessagesResponseToListMessageResponse(oas:ListMessagesResponse response)
returns ListMessagesResponse {
    ListMessagesResponse messageListPage = {};
    Message[] processedMessages = from oas:Message msg in response.messages ?: []
        // Only need to parse the ids as list response does not return any other info.
        select {
            threadId: msg.threadId ?: EMPTY_STRING,
            id: msg.id ?: EMPTY_STRING
        };
    if processedMessages.length() > 0 {
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
    do {
        string? data = bodyPart.data;
        if data is string {
            attachment.data = check base64UrlDecode(data);
        }
    } on fail error err {
        return error InvalidEncodedValue(
                string `Returned attachment message body part of id '${attachment.attachmentId ?: EMPTY_STRING}'
                ${err.message()}`, err.cause());
    }
    return attachment;
}

isolated function convertOASListDraftsResponseToListDraftsResponse(oas:ListDraftsResponse response)
returns ListDraftsResponse|error {
    ListDraftsResponse draftListPage = {};
    Draft[] processedDrafts = [];
    from oas:Draft draft in response.drafts ?: []
    do {
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
    };
    if processedDrafts.length() > 0 {
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
    MailThread[] processedThreads = from oas:MailThread thread in response.threads ?: []
        select {
            // list response does not return any other info.
            id: thread.id ?: EMPTY_STRING,
            historyId: thread.historyId ?: EMPTY_STRING
        };
    if processedThreads.length() > 0 {
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
    Message[] processedMessages = from oas:Message message in oasThread.messages ?: []
        select check convertOASMessageToMessage(message);
    if processedMessages.length() > 0 {
        thread.messages = processedMessages;
    }
    return thread;
}

isolated function convertOASListHistoryResponseToListHistoryResponse(oas:ListHistoryResponse response) returns ListHistoryResponse {
    ListHistoryResponse historyListPage = {};

    History[] processedHistories = [];
    from oas:History history in response.history ?: []
    do {
        History emailHistory = {
            id: history.id ?: EMPTY_STRING
        };
        Message[] processedMessages = from oas:Message message in history.messages ?: []
            select {
                // list response does not return any other info.
                threadId: message.threadId ?: EMPTY_STRING,
                id: message.id ?: EMPTY_STRING
            };
        if processedMessages.length() > 0 {
            emailHistory.messages = processedMessages;
        }

        HistoryLabelAdded[] processedLabelAddedMessages = from oas:HistoryLabelAdded msg in history.labelsAdded ?: []
            select {
                // list response does not return any other info.
                labelIds: msg.labelIds ?: [],
                message: {
                    threadId: msg.message?.threadId ?: EMPTY_STRING,
                    id: msg.message?.id ?: EMPTY_STRING
                }
            };
        if processedLabelAddedMessages.length() > 0 {
            emailHistory.labelsAdded = processedLabelAddedMessages;
        }

        HistoryLabelRemoved[] processedLabelRemovedMessages = from oas:HistoryLabelRemoved msg in history.labelsRemoved ?: []
            select {
                // list response does not return any other info.
                labelIds: msg.labelIds ?: [],
                message: {
                    threadId: msg.message?.threadId ?: EMPTY_STRING,
                    id: msg.message?.id ?: EMPTY_STRING
                }
            };
        if processedLabelRemovedMessages.length() > 0 {
            emailHistory.labelsRemoved = processedLabelRemovedMessages;
        }

        HistoryMessageAdded[] processedMessageAddedMessages = from oas:HistoryMessageAdded msg in history.messagesAdded ?: []
            select {
                // list response does not return any other info.
                message: {
                    threadId: msg.message?.threadId ?: EMPTY_STRING,
                    id: msg.message?.id ?: EMPTY_STRING
                }
            };
        if processedMessageAddedMessages.length() > 0 {
            emailHistory.messagesAdded = processedMessageAddedMessages;
        }

        HistoryMessageDeleted[] processedMessageDeletedMessages = from oas:HistoryMessageDeleted msg in history.messagesDeleted ?: []
            select {
                // list response does not return any other info.
                message: {
                    threadId: msg.message?.threadId ?: EMPTY_STRING,
                    id: msg.message?.id ?: EMPTY_STRING
                }
            };
        if processedMessageDeletedMessages.length() > 0 {
            emailHistory.messagesDeleted = processedMessageDeletedMessages;
        }

        processedHistories.push(emailHistory);
    };
    if processedHistories.length() > 0 {
        historyListPage.history = processedHistories;
    }
    historyListPage.historyId = response.historyId ?: historyListPage.historyId;
    historyListPage.nextPageToken = response.nextPageToken ?: historyListPage.nextPageToken;
    return historyListPage;
}
