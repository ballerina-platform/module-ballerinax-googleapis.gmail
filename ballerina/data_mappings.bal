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
        map<string> headersMap = map from oas:MessagePartHeader h in headers
            select [h.name ?: EMPTY_STRING, h.value ?: EMPTY_STRING];

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
    oas:Message apiMessage = {
        raw: base64UrlEncode(messageString)
    };
    return apiMessage;
}

isolated function getMultipartMessageString(string headers, string... parts) returns string {
    string boundry = uuid:createType4AsString();
    string messageString = headers + boundry + DOUBLE_QUOTE + NEW_LINE;
    foreach string part in parts {
        messageString += NEW_LINE + DASH + DASH + boundry + NEW_LINE;
        messageString += part + NEW_LINE;
    }
    messageString += NEW_LINE + DASH + DASH + boundry + DASH + DASH + NEW_LINE;
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
    io:ReadableByteChannel encodedfileChannel = fileContent;
    byte[] readChannel = check encodedfileChannel.read(100000000);
    return string:fromBytes(readChannel);
}

isolated function convertListMessagesResponseToMessageListPage(oas:ListMessagesResponse response)
returns MessageListPage {
    MessageListPage messageListPage = {};
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
