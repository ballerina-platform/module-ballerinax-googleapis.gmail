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
import ballerina/test;
import ballerina/config;

//Create an endpoint to use Gmail Connector
endpoint Client gmailEP {
    clientConfig: {
        auth: {
            accessToken: config:getAsString("ACCESS_TOKEN"),
            clientId: config:getAsString("CLIENT_ID"),
            clientSecret: config:getAsString("CLIENT_SECRET"),
            refreshToken: config:getAsString("REFRESH_TOKEN")
        }
    }
};

//---------------Fill the following before running the tests-------------------//
string recipient = ""; //Example: "recipient@gmail.com"
string sender = ""; //Example: "sender@gmail.com"
string cc = ""; //Example: "cc@gmail.com"
string attachmentPath = ""; //Example: "/home/user/hello.txt"
string attachmentContentType = ""; //Example: "text/plain"
string inlineImagePath = ""; //Example: "/home/user/Picture2.jpg"
string inlineImageName = ""; //Example: "Picture2.jpg"
string imageContentType = ""; //Example: "image/jpeg"
//----------------------------------------------------------------//

//---------------Do not change the following variables-----------------------//
string userId = "me";
//Holds value for message id of text mail sent in testSendTextMessage()
string sentTextMessageId;
//Holds value for thread id of text mail sent in testSendTextMessage()
string sentTextMessageThreadId;
//Holds value for message id of the html mail sent in testSendHtmlMessage()
string sentHtmlMessageId;
//Holds value for attachment id of attachment sent in testSendHTMLMessage()
//Attachment id is set in testReadHTMLMessageWithAttachment()
string readAttachmentFileId;
//Holds value for label id of the label created in testCreateLabel()
string createdLabelId;
//Holds value for history id of the text message sent in testSendTextMessage()
//History id is set in testReadTextMessage()
string historyId;
//Holds value for draft id of the text message created in testCreateDraft()
string createdDraftId;
//-------------------------------------------------------------------------//

@test:Config {
    groups: ["textMessageTestGroup", "draftTestGroup"]
}
function testSendTextMessage() {
    MessageRequest messageRequest;
    messageRequest.recipient = recipient;
    messageRequest.sender = sender;
    messageRequest.cc = cc;
    messageRequest.subject = "Text-Email-Subject";
    //---Set Text Body---
    messageRequest.messageBody = "Text Message Body";
    messageRequest.contentType = TEXT_PLAIN;
    //---Set Attachments---
    AttachmentPath[] attachments = [{ attachmentPath: attachmentPath, mimeType: attachmentContentType }];
    messageRequest.attachmentPaths = attachments;
    log:printInfo("testSendTextMessage");
    //----Send the mail----
    var sendMessageResponse = gmailEP->sendMessage(userId, messageRequest);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string) sendStatus => {
            (messageId, threadId) = sendStatus;
            sentTextMessageId = messageId;
            sentTextMessageThreadId = threadId;
            test:assertTrue(messageId != "null" && threadId != "null", msg = "Send Text Message Failed");
        }
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    groups: ["htmlMessageTestGroup"]
}
function testSendHTMLMessage() {
    MessageRequest messageRequest;
    messageRequest.recipient = recipient;
    messageRequest.sender = sender;
    messageRequest.cc = cc;
    messageRequest.subject = "HTML-Email-Subject";
    //---Set HTML Body---
    string htmlBody = "<h1> Email Test HTML Body </h1> <br/> <img src=\"cid:image-" + inlineImageName + "\">";
    messageRequest.messageBody = htmlBody;
    messageRequest.contentType = TEXT_HTML;
    //---Set Inline Images---
    InlineImagePath[] inlineImages = [{ imagePath: inlineImagePath, mimeType: imageContentType }];
    messageRequest.inlineImagePaths = inlineImages;
    //---Set Attachments---
    AttachmentPath[] attachments = [{ attachmentPath: attachmentPath, mimeType: attachmentContentType }];
    messageRequest.attachmentPaths = attachments;
    log:printInfo("testSendHTMLMessage");
    //----Send the mail----
    var sendMessageResponse = gmailEP->sendMessage(userId, messageRequest);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string) sendStatus => {
            (messageId, threadId) = sendStatus;
            sentHtmlMessageId = messageId;
            test:assertTrue(messageId != "null" && threadId != "null", msg = "Send HTML message failed");
        }
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn: ["testSendHTMLMessage"],
    groups: ["htmlMessageTestGroup"]
}
function testModifyHTMLMessage() {
    //Modify labels of the message with message id which was sent in testSendHTMLMessage
    log:printInfo("testModifyHTMLMessage");
    var response = gmailEP->modifyMessage(userId, sentHtmlMessageId, ["INBOX"], []);
    match response {
        Message m => test:assertTrue(m.id == sentHtmlMessageId, msg = "Modify HTML message by adding new label failed");
        GmailError e => test:assertFail(msg = e.message);
    }
    response = gmailEP->modifyMessage(userId, sentHtmlMessageId, [], ["INBOX"]);
    match response {
        Message m => test:assertTrue(m.id == sentHtmlMessageId,
                                     msg = "Modify HTML message by removing existing label failed");
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config
function testListMessages() {
    //List All Messages with Label INBOX without including Spam and Trash
    log:printInfo("testListAllMessages");
    MsgSearchFilter searchFilter = { includeSpamTrash: false, labelIds: ["INBOX"] };
    var msgList = gmailEP->listMessages("me", filter = searchFilter);
    match msgList {
        MessageListPage list => {} //testListMessages successful
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn: ["testSendDraft"],
    groups: ["textMessageTestGroup"]
}
function testReadTextMessage() {
    //Read mail with message id which was sent in testSendSimpleMessage
    log:printInfo("testReadTextMessage");
    var response = gmailEP->readMessage(userId, sentTextMessageId);
    match response {
        Message m => {
            historyId = m.historyId;
            test:assertEquals(m.id, sentTextMessageId, msg = "Read text mail failed");
        }
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn: ["testModifyHTMLMessage"],
    groups: ["htmlMessageTestGroup"]
}
function testReadHTMLMessageWithAttachment() {
    //Read mail with message id which sent in testSendWithAttachment
    log:printInfo("testReadMessageWithAttachment");
    var response = gmailEP->readMessage(userId, sentHtmlMessageId);
    match response {
        Message m => {
            readAttachmentFileId = m.msgAttachments[0].attachmentFileId;
            test:assertEquals(m.id, sentHtmlMessageId, msg = "Read mail with attachment failed");
        }
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn: ["testReadHTMLMessageWithAttachment"],
    groups: ["htmlMessageTestGroup"]
}
function testgetAttachment() {
    log:printInfo("testgetAttachment");
    var attachment = gmailEP->getAttachment(userId, sentHtmlMessageId, readAttachmentFileId);
    match attachment {
        GmailError e => test:assertFail(msg = e.message);
        MessageAttachment attach => {
            boolean status = (attach.attachmentFileId == EMPTY_STRING && attach.attachmentBody == EMPTY_STRING)
                             ? false : true;
            test:assertTrue(status, msg = "Get Attachment failed");
        }
    }
}

@test:Config {
    dependsOn: ["testgetAttachment"],
    groups: ["htmlMessageTestGroup"]
}
function testTrashMessage() {
    log:printInfo("testTrashMessage");
    var trash = gmailEP->trashMessage(userId, sentHtmlMessageId);
    match trash {
        GmailError e => test:assertFail(msg = e.message);
        boolean success => test:assertTrue(success, msg = "Trash mail failed");
    }
}

@test:Config {
    dependsOn: ["testTrashMessage"],
    groups: ["htmlMessageTestGroup"]
}
function testUntrashMessage() {
    log:printInfo("testUntrashMessage");
    var untrash = gmailEP->untrashMessage(userId, sentHtmlMessageId);
    match untrash {
        GmailError e => test:assertFail(msg = e.message);
        boolean success => test:assertTrue(success, msg = "Untrash mail failed");
    }
}

@test:Config {
    dependsOn: ["testUntrashMessage"],
    groups: ["htmlMessageTestGroup"]
}
function testDeleteMessage() {
    log:printInfo("testDeleteMessage");
    var delete = gmailEP->deleteMessage(userId, sentHtmlMessageId);
    match delete {
        GmailError e => test:assertFail(msg = e.message);
        boolean success => test:assertTrue(success, msg = "Delete mail failed");
    }
}

@test:Config
function testListThreads() {
    log:printInfo("testListThreads");
    var threadList = gmailEP->listThreads(userId, filter = { includeSpamTrash: false, labelIds: ["INBOX"] });
    match threadList {
        ThreadListPage list => {} // testListThreads successful
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn: ["testReadTextMessage"],
    groups: ["textMessageTestGroup"]
}
function testReadThread() {
    log:printInfo("testReadThread");
    var thread = gmailEP->readThread(userId, sentTextMessageThreadId, format = FORMAT_METADATA,
                                     metadataHeaders = ["Subject"]);
    match thread {
        Thread t => test:assertEquals(t.id, sentTextMessageThreadId, msg = "Read thread failed");
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn: ["testReadThread"],
    groups: ["textMessageTestGroup"]
}
function testModifyThread() {
    //Modify labels of the thread with thread id which was sent in testSendTextMessage
    log:printInfo("testModifyThread");
    var response = gmailEP->modifyThread(userId, sentTextMessageThreadId, ["INBOX"], []);
    match response {
        Thread t => test:assertTrue(t.id == sentTextMessageThreadId, msg = "Modify thread by adding new label failed");
        GmailError e => test:assertFail(msg = e.message);
    }
    response = gmailEP->modifyThread(userId, sentTextMessageThreadId, [], ["INBOX"]);
    match response {
        Thread t => test:assertTrue(t.id == sentTextMessageThreadId,
                                    msg = "Modify thread by removing existing label failed");
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn: ["testModifyThread"],
    groups: ["textMessageTestGroup"]
}
function testTrashThread() {
    log:printInfo("testTrashThread");
    var trash = gmailEP->trashThread(userId, sentTextMessageThreadId);
    match trash {
        GmailError e => test:assertFail(msg = e.message);
        boolean success => test:assertTrue(success, msg = "Trash thread failed");
    }
}

@test:Config {
    dependsOn: ["testTrashThread"],
    groups: ["textMessageTestGroup"]
}
function testUnTrashThread() {
    log:printInfo("testUnTrashThread");
    var untrash = gmailEP->untrashThread(userId, sentTextMessageThreadId);
    match untrash {
        GmailError e => test:assertFail(msg = e.message);
        boolean success => test:assertTrue(success, msg = "Untrash thread failed");

    }
}

@test:Config {
    dependsOn: ["testUnTrashThread"],
    groups: ["textMessageTestGroup"]
}
function testDeleteThread() {
    log:printInfo("testDeleteThread");
    var delete = gmailEP->deleteThread(userId, sentTextMessageThreadId);
    match delete {
        GmailError e => test:assertFail(msg = e.message);
        boolean success => test:assertTrue(success, msg = "Delete thread failed");
    }
}

@test:Config {
    groups: ["userTestGroup"]
}
function testgetUserProfile() {
    log:printInfo("testgetUserProfile");
    var profile = gmailEP->getUserProfile(userId);
    match profile {
        UserProfile p => test:assertTrue(p.emailAddress != EMPTY_STRING, msg = "Get User Profile failed");
        GmailError e => test:assertFail(msg = e.message);
    }
}
@test:Config {
    dependsOn: ["testUpdateLabel"],
    groups: ["labelTestGroup"]
}
function testGetLabel() {
    log:printInfo("testgetLabel");
    var label = gmailEP->getLabel(userId, createdLabelId);
    match label {
        Label label => test:assertTrue(label.id != EMPTY_STRING, msg = "Get Label failed");
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    groups: ["labelTestGroup"]
}
function testCreateLabel() {
    log:printInfo("testCreateLabel");
    var createLabelResponse = gmailEP->createLabel(userId, "Test", "labelShow", "show");
    match createLabelResponse {
        string id => {
            createdLabelId = id;
            test:assertTrue(id != "null", msg = "Create Label failed");
        }
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    groups: ["labelTestGroup"]
}
function testListLabels() {
    log:printInfo("testListLabels");
    var listLabelResponse = gmailEP->listLabels(userId);
    match listLabelResponse {
        Label[] labels => {} //testListLabels successful
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn: ["testGetLabel"],
    groups: ["labelTestGroup"]
}
function testDeleteLabel() {
    log:printInfo("testDeleteLabel");
    var deleteLabelResponse = gmailEP->deleteLabel(userId, createdLabelId);
    match deleteLabelResponse {
        GmailError e => test:assertFail(msg = e.message);
        boolean success => test:assertTrue(success, msg = "Delete Label failed");
    }
}

@test:Config {
    dependsOn: ["testCreateLabel"],
    groups: ["labelTestGroup"]
}
function testUpdateLabel() {
    log:printInfo("testUpdateLabel");
    string updateName = "updateTest";
    string updateBgColor = "#16a766";
    string updateTxtColor = "#000000";
    var updateLabelResponse = gmailEP->updateLabel(userId, createdLabelId, name = updateName,
        backgroundColor = updateBgColor, textColor = updateTxtColor);
    match updateLabelResponse {
        GmailError e => test:assertFail(msg = e.message);
        Label label => test:assertTrue(label.name == updateName && label.backgroundColor == updateBgColor &&
                                       label.textColor == updateTxtColor, msg = "Update Label failed");
    }
}

@test:Config {
    dependsOn: ["testReadTextMessage"],
    groups: ["textMessageTestGroup"]
}
function testListHistory() {
    log:printInfo("testListTheHistory");
    string[] historyTypes = ["labelAdded", "labelRemoved", "messageAdded", "messageDeleted"];
    var listHistoryResponse = gmailEP->listHistory(userId, historyId, historyTypes = historyTypes);
    match listHistoryResponse {
        GmailError e => test:assertFail(msg = e.message);
        MailboxHistoryPage page => test:assertTrue(lengthof page.historyRecords != 0, msg = "List history failed");
    }
}

@test:Config
function testListDrafts() {
    //List maximum of ten results for Drafts without including Spam and Trash
    log:printInfo("testListDrafts");
    DraftSearchFilter searchFilter = { includeSpamTrash: false, maxResults: "10" };
    var msgList = gmailEP->listDrafts("me", filter = searchFilter);
    match msgList {
        DraftListPage list => {} //test list drafts success
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn: ["testSendTextMessage"],
    groups: ["draftTestGroup"]
}
function testCreateDraft() {
    log:printInfo("testCreateDraft");
    string messageBody = "Draft Text Message Body";
    MessageRequest messageRequest;
    messageRequest.recipient = recipient;
    messageRequest.sender = sender;
    messageRequest.cc = cc;
    messageRequest.messageBody = messageBody;
    messageRequest.contentType = TEXT_PLAIN;
    var draftResponse = gmailEP->createDraft(userId, messageRequest, threadId = sentTextMessageThreadId);
    match draftResponse {
        string id => {
            test:assertTrue(id != "null", msg = "Create Draft failed");
            createdDraftId = id;
        }
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn: ["testCreateDraft"],
    groups: ["draftTestGroup"]
}
function testUpdateDraft() {
    log:printInfo("testUpdateDraft");
    string messageBody = "Updated Draft Text Message Body";
    MessageRequest messageRequest;
    messageRequest.recipient = recipient;
    messageRequest.sender = sender;
    messageRequest.messageBody = messageBody;
    messageRequest.subject = "Update Draft Subject";
    messageRequest.contentType = TEXT_PLAIN;
    AttachmentPath[] attachments = [{ attachmentPath: attachmentPath, mimeType: attachmentContentType }];
    messageRequest.attachmentPaths = attachments;
    var draftResponse = gmailEP->updateDraft(userId, createdDraftId, messageRequest);
    match draftResponse {
        string id => test:assertTrue(id == createdDraftId, msg = "Update Draft failed");
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn: ["testUpdateDraft"],
    groups: ["draftTestGroup"]
}
function testReadDraft() {
    log:printInfo("testReadDraft");
    var draftResponse = gmailEP->readDraft(userId, createdDraftId);
    match draftResponse {
        Draft draft => test:assertTrue(draft.id == createdDraftId, msg = "Read Draft failed");
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn: ["testReadDraft"],
    groups: ["draftTestGroup"]
}
function testSendDraft() {
    log:printInfo("testSendDraft");
    var sendDraftResponse = gmailEP->sendDraft(userId, createdDraftId);
    string messageId;
    string threadId;
    match sendDraftResponse {
        (string, string) sendStatus => {
            (messageId, threadId) = sendStatus;
            test:assertTrue(messageId != "null" && threadId != "null", msg = "Send HTML message failed");
        }
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    groups: ["draftTestGroup"]
}
function testDeleteDraft() {
    log:printInfo("testDeleteDraft");
    //Create a draft first
    MessageRequest messageRequest;
    messageRequest.recipient = recipient;
    messageRequest.sender = sender;
    messageRequest.subject = "Draft To Delete";
    messageRequest.messageBody = "Draft Text Message Body To Delete";
    messageRequest.contentType = TEXT_PLAIN;
    var draftResponse = gmailEP->createDraft(userId, messageRequest, threadId = sentTextMessageThreadId);
    string draftIdToDelete;
    match draftResponse {
        string id => {
            test:assertTrue(id != "null", msg = "Create Draft failed");
            draftIdToDelete = id;
        }
        GmailError e => test:assertFail(msg = e.message);
    }
    //Delete the created draft
    var deleteResponse = gmailEP->deleteDraft(userId, draftIdToDelete);
    match deleteResponse {
        boolean status => test:assertTrue(status, msg = "Delete Draft Failed");
        GmailError e => test:assertFail(msg = e.message);
    }
}
