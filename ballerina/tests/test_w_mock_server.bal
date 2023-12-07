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
function testMessageDeleteMock() returns error? {
    error? result = check gmailClientForMockServer->/users/me/messages/["123"].delete();
    test:assertTrue(result is (), msg = "/users/[userId]/messages/import failed");
}

@test:Config {
    groups: ["mock"]
}
function createDraftForMock() returns error? {
    DraftRequest request = {
        message: {
            to: [recipient],
            subject: "Gmail draft test",
            bodyInText: "This is a draft"
        }
    };
    Draft draft = check gmailClientForMockServer->/users/me/drafts.post(request);
    test:assertTrue(draft.id != "", msg = "/users/[userId]/drafts failed");
}
