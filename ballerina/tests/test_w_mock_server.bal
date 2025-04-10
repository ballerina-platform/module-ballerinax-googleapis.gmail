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
import googleapis.gmail.mock as _;
import googleapis.gmail.oas;

import ballerina/io;
import ballerina/log;
import ballerina/test;

Client gmailClientForMockServer = test:mock(Client);

@test:BeforeGroups {
    value: ["mock"]
}
function initializeClientsForMockServer() returns error? {
    log:printInfo("Initializing client for mock server");
    gmailClientForMockServer = check new ({
            timeout: 100000,
            auth: {
                refreshToken: "24f19603-8565-4b5f-a036-88a945e1f272",
                clientId: "FlfJYKBD2c925h4lkycqNZlC2l4a",
                clientSecret: "PJz0UhTJMrHOo68QQNpvnqAY_3Aa",
                refreshUrl: "http://localhost:9444/oauth2/token"
            }
        },
        serviceUrl = "http://localhost:9090/gmail/v1"
    );
}

@test:Config {
    groups: ["mock"]
}
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
    groups: ["mock"]
}
function testUrlDecodeFailure() returns error? {
    oas:Message receivedMsg = {
        threadId: "qweqweqdqd",
        id: "saDSASDASDA",
        raw: "ASDADSADADADADADAD"
    };
    Message|error result = convertOASMessageToMessage(receivedMsg);
    if result is error {
        test:assertEquals(result.message(), "Returned message raw field is not a valid Base64 URL encoded value.",
                msg = "Error decoding message");
    } else {
        test:assertFail("Expected decoded error");
    }
}

@test:Config {
    groups: ["mock"]
}
function testAttachmentSendFailure() returns error? {
    MessageRequest sendMsg = {
        attachments: [
            {
                name: "test.txt",
                path: "asdadsa",
                mimeType: "text/plain"
            }
        ]
    };
    oas:Message|error result = convertMessageRequestToOASMessage(sendMsg);
    if result is error {
        test:assertEquals(result.message(),
                "Unable to retrieve attachment: asdadsa", msg = "Error decoding message");
    } else {
        test:assertFail("Expected decoded error");
    }
}

@test:Config {
    groups: ["mock"]
}
function testGmailGetProfileMock() returns error? {
    Profile profile = check gmailClientForMockServer->/users/me/profile();
    test:assertTrue(profile.emailAddress != "", msg = "/users/[userId]/profile failed. email address nil");
}

@test:Config {
    groups: ["mock"]
}
function testMessageModifyMock() returns error? {
    Message msg = check gmailClientForMockServer->/users/me/messages/["123"]/modify.post(
        {
            addLabelIds: ["UNREAD"]
        }
    );
    test:assertTrue(msg.id != "", msg = "/users/[userId]/messages/[messageId]/modify failed UNREAD label not added");
}

@test:Config {
    groups: ["mock"]
}
function testMessageTrashMock() returns error? {
    Message msg = check gmailClientForMockServer->/users/me/messages/["123"]/trash.post();
    test:assertTrue(msg.historyId != "", msg = "/users/[userId]/messages/[messageId]/trash failed");
}

@test:Config {
    groups: ["mock"]
}
function testMessageUntrashMock() returns error? {
    Message msg = check gmailClientForMockServer->/users/me/messages/["123"]/untrash.post();
    test:assertTrue(msg.historyId != "", msg = "/users/[userId]/messages/[messageId]/untrash failed");
}

@test:Config {
    groups: ["mock"]
}
function testMessageInsertMock() returns error? {
    MessageRequest request = {
        'from: recipient, // Mail migration, mail received from recipient account
        subject: "Gmail insert test"
    };
    Message message = check gmailClientForMockServer->/users/me/messages.post(request);
    test:assertTrue(message.id != "", msg = "/users/[userId]/messages/import failed");
}

@test:Config {
    groups: ["mock"]
}
function testMessageImportMock() returns error? {
    MessageRequest request = {
        'from: recipient, // Mail migration, mail received from recipient account
        subject: "Gmail insert test"
    };
    Message message = check gmailClientForMockServer->/users/me/messages/'import.post(request);
    test:assertTrue(message.id != "", msg = "/users/[userId]/messages/import failed");
}

@test:Config {
    groups: ["mock"]
}
function testListMessagesMock() returns error? {
    ListMessagesResponse msgPage = check gmailClientForMockServer->/users/me/messages();
    test:assertTrue(msgPage.messages is Message[], msg = "/users/[userId]/messages failed");
}

@test:Config {
    groups: ["mock"]
}
function testGetMessagesMock() returns error? {
    Message msg = check gmailClientForMockServer->/users/me/messages/["qw1"]();
    test:assertTrue(msg.id != "", msg = "/users/[userId]/messages failed");
}

@test:Config {
    groups: ["mock"]
}
function testMessageBatchModifyMock() {
    error? msg = gmailClientForMockServer->/users/me/messages/batchModify.post(
        {
            ids: ["123"],
            addLabelIds: ["UNREAD"]
        }
    );
    test:assertTrue(msg is (), msg = "/users/[userId]/messages/batchModify failed");
}

@test:Config {
    groups: ["mock"]
}
function testMessageBatchDeleteMock() returns error? {
    error? result = gmailClientForMockServer->/users/me/messages/batchDelete.post({ids: ["123"]});
    test:assertTrue(result is (), msg = "/users/[userId]/messages/batchDelete failed");
}

@test:Config {
    groups: ["mock"]
}
function testPostMessageMock() returns error? {
    MessageRequest request = {
        to: ["test@gmail.com"],
        subject: "Test Gmail Revamp",
        bodyInText: "This is text equivalent",
        bodyInHtml: "<html><body><h1> Welcome!</h1><div><img src=\"cid:ii_lonq0gzm1\" alt=\"Test_image.jpeg\"><br></div></body></html>"
    };
    Message message = check gmailClientForMockServer->/users/me/messages/send.post(request);
    test:assertTrue(message.id != "", msg = "/users/[userId]/messages/send failed");
}

@test:Config {
    groups: ["mock"]
}
function testGetAttachmentMock() returns error? {
    Attachment attachment = check gmailClientForMockServer->/users/me/messages/["123"]/attachments/["123"];
    test:assertTrue(attachment.data != "", msg = "/users/[userId]/messages/[sentMessageId]/attachments/[attachmentId] failed");
}

@test:Config {
    groups: ["mock"]
}
function testMessageDeleteMock() returns error? {
    error? result = gmailClientForMockServer->/users/me/messages/["123"].delete();
    test:assertTrue(result is (), msg = "/users/[userId]/messages/import failed");
}

@test:Config {
    groups: ["mock"]
}
function createDraftMock() returns error? {
    DraftRequest request = {
        message: {
            to: ["test@gmail.com"],
            subject: "Gmail draft test",
            bodyInText: "This is a draft"
        }
    };
    Draft draft = check gmailClientForMockServer->/users/me/drafts.post(request);
    test:assertTrue(draft.id != "", msg = "/users/[userId]/drafts failed");
}

@test:Config {
    groups: ["mock"]
}
function testListDraftsMock() returns error? {
    ListDraftsResponse draftListPage = check gmailClientForMockServer->/users/me/drafts();
    test:assertTrue(draftListPage.drafts is Draft[], msg = "/users/[userId]/drafts failed");
}

@test:Config {
    groups: ["mock"]
}
function testSendDraftMock() returns error? {
    DraftRequest request = {
        message: {
            to: [recipient],
            subject: "Gmail draft test"
        }
    };
    Message message = check gmailClientForMockServer->/users/me/drafts/send.post(request);
    test:assertTrue(message.id != "", msg = "/users/[userId]/drafts failed");
}

@test:Config {
    groups: ["mock"]
}
function testGetDraftMock() returns error? {
    Draft draft = check gmailClientForMockServer->/users/me/drafts/["123"];
    test:assertTrue(draft.id != "", msg = "/users/[userId]/drafts/[draftId] failed");
}

@test:Config {
    groups: ["mock"]
}
function testPutDraftMock() returns error? {
    Draft updatedDraft = check gmailClientForMockServer->/users/me/drafts/["123"].put({
        id: "123",
        message: {
            to: [recipient],
            subject: "Gmail draft test updated"
        }
    });
    test:assertTrue(updatedDraft.id != "", msg = "/users/[userId]/drafts/[draftId] failed");
}

@test:Config {
    groups: ["mock"]
}
function testDeleteDraftMock() returns error? {
    error? result = gmailClientForMockServer->/users/me/drafts/["!23"].delete();
    test:assertTrue(result is (), msg = "/users/me/drafts/[draftId].delete failed");
}

@test:Config {
    groups: ["mock"]
}
function testListMailThreadsMock() returns error? {
    ListThreadsResponse message = check gmailClientForMockServer->/users/me/threads();
    test:assertTrue(message.nextPageToken != "", msg = "/users/[userId]/messages/send failed");
}

@test:Config {
    groups: ["mock"]
}
function testGetMailThreadMock() returns error? {
    MailThread mailThread = check gmailClientForMockServer->/users/me/threads/["123"];
    test:assertTrue(mailThread.id != "", msg = "/users/[userId]/threads/[threadId] failed");
}

@test:Config {
    groups: ["mock"]
}
function testModifyMailThreadMock() returns error? {
    MailThread mailThread = check gmailClientForMockServer->/users/me/threads/["123"]/modify.post({
        addLabelIds: ["UNREAD"]
    });
    test:assertTrue(mailThread.historyId != (), msg = "/users/[userId]/threads/[threadId]/modify failed");
}

@test:Config {
    groups: ["mock"]
}
function testTrashMailThreadMock() returns error? {
    MailThread mailThread = check gmailClientForMockServer->/users/me/threads/["123"]/trash.post();
    test:assertTrue(mailThread.historyId != (), msg = "/users/[userId]/threads/[threadId]/trash failed");
}

@test:Config {
    groups: ["mock"]
}
function testUntrashMailThreadMock() returns error? {
    MailThread mailThread = check gmailClientForMockServer->/users/me/threads/["123"]/untrash.post();
    test:assertTrue(mailThread.historyId != (), msg = "/users/[userId]/threads/[threadId]/untrash failed");
}

@test:Config {
    groups: ["mock"]
}
function testDeleteMailThreadMock() returns error? {
    error? result = gmailClientForMockServer->/users/me/threads/["123"].delete();
    test:assertTrue(result is (), msg = "/users/[userId]/threads/[threadId].delete failed");
}

@test:Config {
    groups: ["mock"]
}
function testCreateNewLabelMock() returns error? {
    Label label = check gmailClientForMockServer->/users/me/labels.post({
        name: "Test Label"
    });
    test:assertTrue(label.id != "", msg = "/users/[userId]/labels failed");
}

@test:Config {
    groups: ["mock"]
}
function testListAllLabelsMock() returns error? {
    ListLabelsResponse labelListPage = check gmailClientForMockServer->/users/me/labels();
    test:assertTrue(labelListPage.labels is Label[], msg = "/users/[userId]/labels failed");
}

@test:Config {
    groups: ["mock"]
}
function testGetLabelMock() returns error? {
    Label label = check gmailClientForMockServer->/users/me/labels/["123"];
    test:assertTrue(label.id != "", msg = "/users/[userId]/labels/[label.id] failed");
}

@test:Config {
    groups: ["mock"]
}
function testUpdateLabelMock() returns error? {
    Label label = check gmailClientForMockServer->/users/me/labels/["123"].put({
        id: labelId,
        name: "Test Label Updated"
    });
    test:assertTrue(label.id != "", msg = "/users/[userId]/labels/[label.id] failed");
}

@test:Config {
    groups: ["mock"]
}
function testPatchLabelMock() returns error? {
    Label label = check gmailClientForMockServer->/users/me/labels/["123"].patch({
        id: labelId,
        name: "Test Label Patched"
    });
    test:assertTrue(label.id != "", msg = "/users/[userId]/labels/[label.id] failed");
}

@test:Config {
    groups: ["mock"]
}
function testDeleteLabelMock() returns error? {
    check gmailClientForMockServer->/users/me/labels/["123"].delete();
}

@test:Config {
    groups: ["mock"]
}
function testListHistoryMock() returns error? {
    ListHistoryResponse historyListPage = check gmailClientForMockServer->/users/me/history(startHistoryId = "123");
    test:assertTrue(historyListPage.history is History[], msg = "/users/[userId]/history failed");
}
