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
import ballerina/os;
import ballerina/test;

configurable string refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string sender = os:getEnv("SENDER");

configurable string userId = "me";

//---------------DO NOT change the following variables-----------------------//
//---------------Used in multiple tests-----------------------//
//Holds value for message id of text mail sent in testSendTextMessage()
string sentMessageId = "";
string insertMessageId = "";
string attachmentId = "";
string draftId = "";
string threadId = "";
string labelId = "";

ConnectionConfig gmailConfig = {
    auth: {
        refreshToken: refreshToken,
        clientId: clientId,
        clientSecret: clientSecret
    }
};

final Client gmailClient = check new (gmailConfig);

@test:Config {}
isolated function testGmailGetProfile() returns error? {
    Profile profile = check gmailClient->/users/me/profile();
    test:assertTrue(profile.emailAddress != "", msg = "/users/[userId]/profile failed. email address nil");
}

@test:Config {}
function testMessageInsert() returns error? {
    MessageRequest request = {
        'from: sender,
        subject: "Gmail insert test"
    };
    Message message = check gmailClient->/users/me/messages.post(request);
    test:assertTrue(message.id != "", msg = "/users/[userId]/messages/import failed");
    insertMessageId = message.id;
}

@test:Config {
    dependsOn: [testMessageInsert]
}
isolated function testListMessages() returns error? {
    MessageListPage msgPage = check gmailClient->/users/me/messages();
    test:assertTrue(msgPage.messages is Message[], msg = "/users/[userId]/messages failed");
}

@test:Config {
    dependsOn: [testListMessages]
}
function testMessageBatchModify() returns error? {
    check gmailClient->/users/me/messages/batchModify.post(
        {
            ids: [insertMessageId],
            addLabelIds: ["UNREAD"]
        }
    );
    Message message = check gmailClient->/users/me/messages/[insertMessageId];
    test:assertEquals(message.labelIds, ["UNREAD"],
                    msg = "/users/[userId]/messages/batchModify failed UNREAD label not added");
}

@test:Config {
    dependsOn: [testMessageBatchModify]
}
function testMessageBatchDelete() returns error? {
    check gmailClient->/users/me/messages/batchDelete.post({ids: [insertMessageId]});
    Message|error message = gmailClient->/users/me/messages/[insertMessageId];
    test:assertTrue(message is error, msg = "/users/[userId]/messages/batchDelete failed. Msg not deleted");
}

@test:Config {
    dependsOn: [testMessageBatchDelete]
}
function testPostMessage() returns error? {
    MessageRequest request = {
        to: [sender],
        subject: "Test Gmail Revamp",
        bodyInText: "This is text equivalent",
        bodyInHtml: "<html><body><h1> Welcome!</h1><div><img src=\"cid:ii_lonq0gzm1\" alt=\"Test_image.jpeg\"><br></div></body></html>",
        inlineImages: [
            {
                contentId: "ii_lonq0gzm1",
                mimeType: "image/jpeg",
                name: "Test_image.jpg",
                path: "tests/resources/Test_image.jpg"
            }
        ],
        attachments: [
            {
                mimeType: "text/plain",
                name: "test.txt",
                path: "tests/resources/test.txt"
            }

        ]
    };
    Message message = check gmailClient->/users/me/messages/send.post(request);
    test:assertTrue(message.id != "", msg = "/users/[userId]/messages/send failed");
    sentMessageId = message.id;
}

@test:Config {
    dependsOn: [testPostMessage]
}
function testGetMessageRawFormat() returns error? {
    Message message = check gmailClient->/users/me/messages/[sentMessageId](format = "raw");
    test:assertTrue(message.raw is string, msg = "/users/[userId]/messages/[id]");
}

@test:Config {
    dependsOn: [testGetMessageRawFormat]
}
function testGetMessageFullFormat() returns error? {
    Message message = check gmailClient->/users/me/messages/[sentMessageId](format = "full");
    test:assertTrue(message.to is string[], msg = "/users/[userId]/messages/[id failed");
    MessagePart[]? messagesParts = message.payload?.parts;
    if messagesParts is MessagePart[] {
        attachmentId = messagesParts[1].attachmentId ?: "";
        if attachmentId == "" {
            test:assertFail("Message part for attachment id is ()");
        }
    } else {
        test:assertFail("Message part for attachment not found");
    }
}

@test:Config {
    dependsOn: [testGetMessageFullFormat]
}
function testMessageModify() returns error? {
    Message message = check gmailClient->/users/me/messages/[sentMessageId]/modify.post(
        {
            addLabelIds: ["UNREAD"]
        }
    );
    test:assertTrue(message.labelIds != (), msg = "/users/[userId]/messages/[sentMessageId]/modify failed");
    Message getMessage = check gmailClient->/users/me/messages/[sentMessageId];
    test:assertEquals(getMessage.labelIds, ["UNREAD", "SENT"],
                    msg = "/users/[userId]/messages/[sentMessageId]/modify failed UNREAD label not added");
}

@test:Config {
    dependsOn: [testMessageModify]
}
function testMessageTrash() returns error? {
    _ = check gmailClient->/users/me/messages/[sentMessageId]/trash.post();
    Message getMessage = check gmailClient->/users/me/messages/[sentMessageId];
    test:assertEquals(getMessage.labelIds, ["UNREAD", "TRASH", "SENT"],
                    msg = "/users/[userId]/messages/[sentMessageId]/trash failed TRASH label not added");
}

@test:Config {
    dependsOn: [testMessageTrash]
}
function testMessageUntrash() returns error? {
    _ = check gmailClient->/users/me/messages/[sentMessageId]/untrash.post();
    Message getMessage = check gmailClient->/users/me/messages/[sentMessageId];
    test:assertEquals(getMessage.labelIds, ["UNREAD", "SENT"],
                    msg = "/users/[userId]/messages/[sentMessageId]/untrash failed TRASH label not removed");
}

@test:Config {
    dependsOn: [testMessageUntrash]
}
function testGetAttachment() returns error? {
    Attachment attachment = check gmailClient->/users/me/messages/[sentMessageId]/attachments/[attachmentId];
    test:assertTrue(attachment.data != "", msg = "/users/[userId]/messages/[sentMessageId]/attachments/[attachmentId] failed");
}

@test:Config {
    dependsOn: [testGetAttachment]
}
function testMessageDelete() returns error? {
    check gmailClient->/users/me/messages/[sentMessageId].delete();
    Message|error message = gmailClient->/users/me/messages/[sentMessageId];
    test:assertTrue(message is error, msg = "/users/[userId]/messages/[sentMessageId].delete failed. Msg not deleted");
}

@test:Config {}
isolated function testPayloadConversion() returns error? {
    json response = check io:fileReadJson("tests/resources/messagebody.json");
    oas:MessagePart internalPayload = check response.fromJsonWithType(oas:MessagePart);
    MessagePart convertedPayload = check convertOASMessagePartToMultipartMessageBody(internalPayload);
    MessagePart messagePart = {
        mimeType: "multipart/alternative",
        filename: "",
        headers: {
            "Content-Type": "multipart/alternative; boundary=001a1142e23c551e8e05200b4be0"
        },
        size: 0,
        partId: "",
        parts: [
            {
                mimeType: "multipart/alternative",
                filename: "",
                headers: {
                    "Content-Type": "multipart/alternative; boundary=001a1142e23c551e8e05200b4be0"
                },
                size: 0,
                partId: "",
                parts: [
                    {
                        partId: "0.0",
                        mimeType: "text/plain",
                        filename: "",
                        headers: {
                            "Content-Type": "text/plain; charset=UTF-8"
                        },
                        size: 9
                    },
                    {
                        partId: "0.1",
                        mimeType: "text/html",
                        filename: "",
                        headers: {
                            "Content-Type": "text/html; charset=UTF-8"
                        },
                        size: 30
                    }
                ]
            },
            {
                partId: "1",
                mimeType: "image/jpeg",
                filename: "feelthebern.jpg",
                headers: {
                    "Content-Type": "image/jpeg; name=\"feelthebern.jpg\"",
                    "Content-Disposition": "attachment; filename=\"feelthebern.jpg\"",
                    "Content-Transfer-Encoding": "base64",
                    "X-Attachment-Id": "f_ieq3ev0i0"
                },
                size: 100446
            }
        ]
    };
    test:assertEquals(convertedPayload, messagePart, msg = "Payload conversion failed");
}

@test:Config {
    dependsOn: [testMessageDelete]
}
function createDraft() returns error? {
    DraftRequest request = {
        message: {
            to: [sender],
            subject: "Gmail draft test",
            bodyInText: "This is a draft"
        }
    };
    Draft draft = check gmailClient->/users/me/drafts.post(request);
    test:assertTrue(draft.id != "", msg = "/users/[userId]/drafts failed");
    draftId = check draft.id.ensureType(string);
}

@test:Config {
    dependsOn: [createDraft]
}
isolated function testListDrafts() returns error? {
    DraftListPage draftListPage = check gmailClient->/users/me/drafts();
    test:assertTrue(draftListPage.drafts is Draft[], msg = "/users/[userId]/drafts failed");
}

@test:Config {
    dependsOn: [testListDrafts]
}
function testSendDraft() returns error? {
    DraftRequest request = {
        message: {
            to: [sender],
            subject: "Gmail draft test"
        }
    };
    Draft draft = check gmailClient->/users/me/drafts.post(request);
    test:assertTrue(draft.id != "", msg = "/users/[userId]/drafts failed");

    string id = check draft.id.ensureType(string);
    Message message = check gmailClient->/users/me/drafts/send.post({
        id: id
    });
    test:assertTrue(message.id != "", msg = "/users/[userId]/drafts/send failed");
}

@test:Config {
    dependsOn: [testSendDraft]
}
function testGetDraft() returns error? {
    Draft draft = check gmailClient->/users/me/drafts/[draftId];
    test:assertTrue(draft.id != "", msg = "/users/[userId]/drafts/[draftId] failed");
}

@test:Config {
    dependsOn: [testGetDraft]
}
function testPutDraft() returns error? {
    Draft updatedDraft = check gmailClient->/users/me/drafts/[draftId].put({
        id: draftId,
        message: {
            to: [sender],
            subject: "Gmail draft test updated"
        }
    });
    test:assertTrue(updatedDraft.id != "", msg = "/users/[userId]/drafts/[draftId] failed");
    Draft draft = check gmailClient->/users/me/drafts/[draftId];
    test:assertTrue(draft.message?.subject == "Gmail draft test updated", msg = "/users/[userId]/drafts/[draftId] failed");
}

@test:Config {
    dependsOn: [testPutDraft]
}
function testDeleteDraft() returns error? {
    check gmailClient->/users/me/drafts/[draftId].delete();
    Draft|error draft = gmailClient->/users/me/drafts/[draftId];
    test:assertTrue(draft is error, msg = "/users/[userId]/drafts/[draftId].delete failed. Draft not deleted");
}

@test:Config {
    dependsOn: [testDeleteDraft]
}
function testListMailThreads() returns error? {
    MessageRequest request = {
        to: [sender],
        subject: "Test Gmail Revamp Thread"
    };
    Message message = check gmailClient->/users/me/messages/send.post(request);
    test:assertTrue(message.id != "", msg = "/users/[userId]/messages/send failed");
    threadId = message.threadId;

    ThreadListPage threadListPage = check gmailClient->/users/me/threads();
    test:assertTrue(threadListPage.threads is MailThread[], msg = "/users/[userId]/threads failed");
}

@test:Config {
    dependsOn: [testListMailThreads]
}
function testGetMailThread() returns error? {
    MailThread mailThread = check gmailClient->/users/me/threads/[threadId];
    test:assertTrue(mailThread.id != "", msg = "/users/[userId]/threads/[threadId] failed");
}

@test:Config {
    dependsOn: [testGetMailThread]
}
function testModifyMailThread() returns error? {
    MailThread mailThread = check gmailClient->/users/me/threads/[threadId]/modify.post({
        addLabelIds: ["UNREAD"]
    });
    test:assertTrue(mailThread.historyId != (), msg = "/users/[userId]/threads/[threadId]/modify failed");
    MailThread getMailThread = check gmailClient->/users/me/threads/[threadId];
    Message[]? firstMesssage = getMailThread.messages;
    if firstMesssage is Message[] {
        test:assertEquals(firstMesssage[0].labelIds, ["UNREAD", "SENT"],
                    msg = "/users/[userId]/threads/[threadId]/modify failed UNREAD label not added");
    } else {
        test:assertFail("Message not found");
    }
}

@test:Config {
    dependsOn: [testModifyMailThread]
}
function testTrashMailThread() returns error? {
    MailThread mailThread = check gmailClient->/users/me/threads/[threadId]/trash.post();
    test:assertTrue(mailThread.historyId != (), msg = "/users/[userId]/threads/[threadId]/trash failed");
    MailThread getMailThread = check gmailClient->/users/me/threads/[threadId];
    Message[]? firstMesssage = getMailThread.messages;
    if firstMesssage is Message[] {
        test:assertEquals(firstMesssage[0].labelIds, ["UNREAD", "TRASH", "SENT"],
                    msg = "/users/[userId]/threads/[threadId]/trash failed TRASH label not added");
    } else {
        test:assertFail("Message not found");
    }
}

@test:Config {
    dependsOn: [testTrashMailThread]
}
function testUntrashMailThread() returns error? {
    MailThread mailThread = check gmailClient->/users/me/threads/[threadId]/untrash.post();
    test:assertTrue(mailThread.historyId != (), msg = "/users/[userId]/threads/[threadId]/untrash failed");
    MailThread getMailThread = check gmailClient->/users/me/threads/[threadId];
    Message[]? firstMesssage = getMailThread.messages;
    if firstMesssage is Message[] {
        test:assertEquals(firstMesssage[0].labelIds, ["UNREAD", "SENT"],
                    msg = "/users/[userId]/threads/[threadId]/untrash failed TRASH label not removed");
    } else {
        test:assertFail("Message not found");
    }
}

@test:Config {
    dependsOn: [testUntrashMailThread]
}
function testDeleteMailThread() returns error? {
    check gmailClient->/users/me/threads/[threadId].delete();
    MailThread|error mailThread = gmailClient->/users/me/threads/[threadId];
    test:assertTrue(mailThread is error, msg = "/users/[userId]/threads/[threadId].delete failed. Thread not deleted");
}

@test:Config {
    dependsOn: [testDeleteMailThread]
}
function testCreateNewLabel() returns error? {
    Label label = check gmailClient->/users/me/labels.post({
        name: "Test Label"
    });
    test:assertTrue(label.id != "", msg = "/users/[userId]/labels failed");
    labelId = label.id ?: "";
}

@test:Config {
    dependsOn: [testCreateNewLabel]
}
function testListAllLabels() returns error? {
    LabelListPage labelListPage = check gmailClient->/users/me/labels();
    test:assertTrue(labelListPage.labels is Label[], msg = "/users/[userId]/labels failed");
}

@test:Config {
    dependsOn: [testListAllLabels]
}
function testGetLabel() returns error? {
    Label label = check gmailClient->/users/me/labels/[labelId];
    test:assertTrue(label.id != "", msg = "/users/[userId]/labels/[label.id] failed");
}

@test:Config {
    dependsOn: [testGetLabel]
}
function testUpdateLabel() returns error? {
    Label label = check gmailClient->/users/me/labels/[labelId].put({
        id: labelId,
        name: "Test Label Updated"
    });
    test:assertTrue(label.id != "", msg = "/users/[userId]/labels/[label.id] failed");
    Label getLabel = check gmailClient->/users/me/labels/[labelId];
    test:assertTrue(getLabel.name == "Test Label Updated", msg = "/users/[userId]/labels/[label.id] failed");
}

@test:Config {
    dependsOn: [testUpdateLabel]
}
function testPatchLabel() returns error? {
    Label label = check gmailClient->/users/me/labels/[labelId].patch({
        id: labelId,
        name: "Test Label Patched"
    });
    test:assertTrue(label.id != "", msg = "/users/[userId]/labels/[label.id] failed");
    Label getLabel = check gmailClient->/users/me/labels/[labelId];
    test:assertTrue(getLabel.name == "Test Label Patched", msg = "/users/[userId]/labels/[label.id] failed");
}

@test:Config {
    dependsOn: [testPatchLabel]
}
function testDeleteLabel() returns error? {
    check gmailClient->/users/me/labels/[labelId].delete();
    Label|error label = gmailClient->/users/me/labels/[labelId];
    test:assertTrue(label is error, msg = "/users/[userId]/labels/[label.id].delete failed. Label not deleted");
}
