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
import ballerina/lang.runtime;
import ballerina/log;
import ballerina/os;
import ballerina/test;

configurable string refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string recipient = os:getEnv("RECIPIENT");

//---------------DO NOT change the following variables-----------------------//
//---------------Used in multiple tests-----------------------//
//Holds value for message id of text mail sent in testSendTextMessage()
string sentMessageId = "";
string insertMessageId = "";
string attachmentId = "";
string draftId = "";
string threadId = "";
string labelId = "";
string historyId = "";

ConnectionConfig gmailConfig = {
    auth: {
        refreshToken,
        clientId,
        clientSecret
    }
};

Client gmailClient = test:mock(Client);

@test:BeforeGroups {
    value: ["gmail"]
}
function initializeClientsForGmailServer() returns error? {
    log:printInfo("Initializing client for gmail server");
    gmailClient = check new (gmailConfig);
}

@test:Config {
    groups: ["gmail"]
}
function testGmailGetProfile() returns error? {
    Profile profile = check gmailClient->/users/me/profile();
    test:assertTrue(profile.emailAddress != "", msg = "/users/[userId]/profile failed. email address nil");
    historyId = check profile.historyId.ensureType(string);
}

@test:Config {
    groups: ["gmail"]
}
function testMessageInsert() returns error? {
    MessageRequest request = {
        'from: recipient, // Mail migration, mail received from recipient account
        subject: "Gmail insert test"
    };
    Message message = check gmailClient->/users/me/messages.post(request);
    test:assertTrue(message.id != "", msg = "/users/[userId]/messages/import failed");
    insertMessageId = message.id ?: "";
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testMessageInsert]
}
function testListMessages() returns error? {
    ListMessagesResponse msgPage = check gmailClient->/users/me/messages();
    test:assertTrue(msgPage.messages is Message[], msg = "/users/[userId]/messages failed");
}

@test:Config {
    groups: ["gmail"],
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
    groups: ["gmail"],
    dependsOn: [testMessageBatchModify]
}
function testMessageBatchDelete() returns error? {
    check gmailClient->/users/me/messages/batchDelete.post({ids: [insertMessageId]});
    runtime:sleep(10);
    Message|error message = gmailClient->/users/me/messages/[insertMessageId];
    test:assertTrue(message is error, msg = "/users/[userId]/messages/batchDelete failed. Msg not deleted");
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testMessageBatchDelete]
}
function testPostMessage() returns error? {
    MessageRequest request = {
        to: [recipient],
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
    sentMessageId = message.id ?: "";
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testPostMessage]
}
function testGetMessageRawFormat() returns error? {
    Message message = check gmailClient->/users/me/messages/[sentMessageId](format = "raw");
    test:assertTrue(message.raw is string, msg = "/users/[userId]/messages/[id]");
}

@test:Config {
    groups: ["gmail"],
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
    groups: ["gmail"],
    dependsOn: [testGetMessageFullFormat]
}
function testMessageModify() returns error? {
    _ = check gmailClient->/users/me/messages/[sentMessageId]/modify.post(
        {
            addLabelIds: ["UNREAD"]
        }
    );
    Message getMessage = check gmailClient->/users/me/messages/[sentMessageId];
    string[]? labelIds = getMessage.labelIds;
    if labelIds is string[] {
        test:assertTrue(labelIds.filter(l => l == "UNREAD").length() > 0,
                msg = "/users/[userId]/messages/[sentMessageId]/modify failed");
    } else {
        test:assertFail("/users/[userId]/messages/[sentMessageId]/modify failed");
    }
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testMessageModify]
}
function testMessageTrash() returns error? {
    _ = check gmailClient->/users/me/messages/[sentMessageId]/trash.post();
    Message getMessage = check gmailClient->/users/me/messages/[sentMessageId];
    string[]? labelIds = getMessage.labelIds;
    if labelIds is string[] {
        test:assertTrue(labelIds.filter(l => l == "TRASH").length() > 0,
                msg = "/users/[userId]/messages/[sentMessageId]/trash failed TRASH label not added");
    } else {
        test:assertFail("/users/[userId]/messages/[sentMessageId]/trash failed");
    }
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testMessageTrash]
}
function testMessageUntrash() returns error? {
    _ = check gmailClient->/users/me/messages/[sentMessageId]/untrash.post();
    Message getMessage = check gmailClient->/users/me/messages/[sentMessageId];
    string[]? labelIds = getMessage.labelIds;
    if labelIds is string[] {
        test:assertTrue(labelIds.filter(l => l == "TRASH").length() == 0,
                msg = "/users/[userId]/messages/[sentMessageId]/untrash failed TRASH label not removed");
    } else {
        test:assertFail("/users/[userId]/messages/[sentMessageId]/untrash failed");
    }
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testMessageUntrash]
}
function testGetAttachment() returns error? {
    Attachment attachment = check gmailClient->/users/me/messages/[sentMessageId]/attachments/[attachmentId];
    test:assertTrue(attachment.data != "", msg = "/users/[userId]/messages/[sentMessageId]/attachments/[attachmentId] failed");
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testGetAttachment]
}
function testMessageDelete() returns error? {
    check gmailClient->/users/me/messages/[sentMessageId].delete();
    runtime:sleep(10);
    Message|error message = gmailClient->/users/me/messages/[sentMessageId];
    test:assertTrue(message is error, msg = "/users/[userId]/messages/[sentMessageId].delete failed. Msg not deleted");
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testMessageDelete]
}
function createDraft() returns error? {
    DraftRequest request = {
        message: {
            to: [recipient],
            subject: "Gmail draft test",
            bodyInText: "This is a draft"
        }
    };
    Draft draft = check gmailClient->/users/me/drafts.post(request);
    test:assertTrue(draft.id != "", msg = "/users/[userId]/drafts failed");
    draftId = check draft.id.ensureType(string);
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [createDraft]
}
function testListDrafts() returns error? {
    ListDraftsResponse draftListPage = check gmailClient->/users/me/drafts();
    test:assertTrue(draftListPage.drafts is Draft[], msg = "/users/[userId]/drafts failed");
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testListDrafts]
}
function testSendDraft() returns error? {
    DraftRequest request = {
        message: {
            to: [recipient],
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
    groups: ["gmail"],
    dependsOn: [testSendDraft]
}
function testGetDraft() returns error? {
    Draft draft = check gmailClient->/users/me/drafts/[draftId];
    test:assertTrue(draft.id != "", msg = "/users/[userId]/drafts/[draftId] failed");
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testGetDraft]
}
function testPutDraft() returns error? {
    Draft updatedDraft = check gmailClient->/users/me/drafts/[draftId].put({
        id: draftId,
        message: {
            to: [recipient],
            subject: "Gmail draft test updated"
        }
    });
    test:assertTrue(updatedDraft.id != "", msg = "/users/[userId]/drafts/[draftId] failed");
    Draft draft = check gmailClient->/users/me/drafts/[draftId](format = "raw");
    test:assertTrue(draft.message?.raw.toString().includes("subject:Gmail draft test updated"),
            msg = "/users/[userId]/drafts/[draftId] failed");
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testPutDraft]
}
function testDeleteDraft() returns error? {
    check gmailClient->/users/me/drafts/[draftId].delete();
    runtime:sleep(10);
    Draft|error draft = gmailClient->/users/me/drafts/[draftId];
    test:assertTrue(draft is error, msg = "/users/[userId]/drafts/[draftId].delete failed. Draft not deleted");
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testDeleteDraft]
}
function testListMailThreads() returns error? {
    MessageRequest request = {
        to: [recipient],
        subject: "Test Gmail Revamp Thread"
    };
    Message message = check gmailClient->/users/me/messages/send.post(request);
    test:assertTrue(message.id != "", msg = "/users/[userId]/messages/send failed");
    threadId = message.threadId ?: "";

    ListThreadsResponse threadListPage = check gmailClient->/users/me/threads();
    test:assertTrue(threadListPage.threads is MailThread[], msg = "/users/[userId]/threads failed");
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testListMailThreads]
}
function testGetMailThread() returns error? {
    MailThread mailThread = check gmailClient->/users/me/threads/[threadId];
    test:assertTrue(mailThread.id != "", msg = "/users/[userId]/threads/[threadId] failed");
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testGetMailThread]
}
function testModifyMailThread() returns error? {
    MailThread mailThread = check gmailClient->/users/me/threads/[threadId]/modify.post({
        addLabelIds: ["UNREAD"]
    });
    test:assertTrue(mailThread.historyId != (), msg = "/users/[userId]/threads/[threadId]/modify failed");
    MailThread getMailThread = check gmailClient->/users/me/threads/[threadId];
    Message[]? firstMessage = getMailThread.messages;
    if firstMessage is Message[] {
        string[]? labelIds = firstMessage[0].labelIds;
        if labelIds is string[] {
            test:assertTrue(labelIds.filter(l => l == "UNREAD").length() > 0,
                    msg = "/users/[userId]/threads/[threadId]/modify failed");
        } else {
            test:assertFail("/users/[userId]/threads/[threadId]/modify failed");
        }
    } else {
        test:assertFail("Message not found");
    }
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testModifyMailThread]
}
function testTrashMailThread() returns error? {
    MailThread mailThread = check gmailClient->/users/me/threads/[threadId]/trash.post();
    test:assertTrue(mailThread.historyId != (), msg = "/users/[userId]/threads/[threadId]/trash failed");
    MailThread getMailThread = check gmailClient->/users/me/threads/[threadId];
    Message[]? firstMessage = getMailThread.messages;
    if firstMessage is Message[] {
        string[]? labelIds = firstMessage[0].labelIds;
        if labelIds is string[] {
            test:assertTrue(labelIds.filter(l => l == "TRASH").length() > 0,
                    msg = "/users/[userId]/threads/[threadId]/trash failed TRASH label not added");
        } else {
            test:assertFail("/users/[userId]/threads/[threadId]/trash failed");
        }
    } else {
        test:assertFail("Message not found");
    }
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testTrashMailThread]
}
function testUntrashMailThread() returns error? {
    MailThread mailThread = check gmailClient->/users/me/threads/[threadId]/untrash.post();
    test:assertTrue(mailThread.historyId != (), msg = "/users/[userId]/threads/[threadId]/untrash failed");
    MailThread getMailThread = check gmailClient->/users/me/threads/[threadId];
    Message[]? firstMessage = getMailThread.messages;
    if firstMessage is Message[] {
        string[]? labelIds = firstMessage[0].labelIds;
        if labelIds is string[] {
            test:assertTrue(labelIds.filter(l => l == "TRASH").length() == 0,
                    msg = "/users/[userId]/threads/[threadId]/untrash failed TRASH label not removed");
        } else {
            test:assertFail("/users/[userId]/threads/[threadId]/untrash failed");
        }
    } else {
        test:assertFail("Message not found");
    }
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testUntrashMailThread]
}
function testDeleteMailThread() returns error? {
    check gmailClient->/users/me/threads/[threadId].delete();
    runtime:sleep(10);
    MailThread|error mailThread = gmailClient->/users/me/threads/[threadId];
    test:assertTrue(mailThread is error, msg = "/users/[userId]/threads/[threadId].delete failed. Thread not deleted");
}

@test:Config {
    groups: ["gmail"],
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
    groups: ["gmail"],
    dependsOn: [testCreateNewLabel]
}
function testListAllLabels() returns error? {
    ListLabelsResponse labelListPage = check gmailClient->/users/me/labels();
    test:assertTrue(labelListPage.labels is Label[], msg = "/users/[userId]/labels failed");
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testListAllLabels]
}
function testGetLabel() returns error? {
    Label label = check gmailClient->/users/me/labels/[labelId];
    test:assertTrue(label.id != "", msg = "/users/[userId]/labels/[label.id] failed");
}

@test:Config {
    groups: ["gmail"],
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
    groups: ["gmail"],
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
    groups: ["gmail"],
    dependsOn: [testPatchLabel]
}
function testDeleteLabel() returns error? {
    check gmailClient->/users/me/labels/[labelId].delete();
    runtime:sleep(10);
    Label|error label = gmailClient->/users/me/labels/[labelId];
    test:assertTrue(label is error, msg = "/users/[userId]/labels/[label.id].delete failed. Label not deleted");
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testDeleteLabel, testGmailGetProfile]
}
function testListHistory() returns error? {
    ListHistoryResponse historyListPage = check gmailClient->/users/me/history(startHistoryId = historyId);
    test:assertTrue(historyListPage.history is History[], msg = "/users/[userId]/history failed");
}

@test:Config {
    groups: ["gmail"],
    dependsOn: [testListHistory]
}
function testReplyTo() returns error? {
    MessageRequest request = {
        to: [recipient],
        subject: "Test Gmail Reply To",
        bodyInText: "This is text equivalent",
        bodyInHtml: "<html><body><h1> Welcome!</h1></body></html>"
    };
    Message message = check gmailClient->/users/me/messages/send.post(request);

    runtime:sleep(10);

    Message completeMsg = check gmailClient->/users/me/messages/[message.id ?: ""](format = "metadata");

    // Create a new MessageRequest for the reply
    MessageRequest replyRequest = {
        to: [recipient],
        subject: "Test Gmail Reply To",
        bodyInText: "This is a reply",
        bodyInHtml: "<html><body><h1> This is a reply </h1></body></html>",
        threadId: message.threadId,
        initialMessageId: completeMsg.messageId,
        references: [completeMsg.messageId ?: EMPTY_STRING]
    };

    // Send the reply
    Message replyMessage = check gmailClient->/users/me/messages/send.post(replyRequest);
    runtime:sleep(10);

    // Get the message thread
    MailThread mailThread = check gmailClient->/users/me/threads/[replyMessage.threadId ?: ""];

    Message[]? threadMessages = mailThread.messages;

    if threadMessages is Message[] {
        test:assertTrue(threadMessages.length() == 2, "Mail thread should contain two messages");
        test:assertTrue(threadMessages[0].id == message.id, "Mail thread should contain message with ID <message1-id>");
        test:assertTrue(threadMessages[1].id == replyMessage.id, "Mail thread should contain message with ID <message2-id>");
    } else {
        test:assertFail("Message not found");
    }
    check gmailClient->/users/me/threads/[replyMessage.threadId ?: ""].delete();
}
