// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/config;
import ballerina/log;
import ballerina/test;



//Create an endpoint to use Gmail Connector
GmailConfiguration gmailConfig = {
    oauthClientConfig: {
        accessToken: config:getAsString("ACCESS_TOKEN"),
        refreshConfig: {
            refreshUrl: REFRESH_URL,
            refreshToken: config:getAsString("REFRESH_TOKEN"),
            clientId: config:getAsString("CLIENT_ID"),
            clientSecret: config:getAsString("CLIENT_SECRET")
        }
    }
};

Client gmailClient = new (gmailConfig);

//---------------Provide the following in the conf file before running the tests-------------------//
string testRecipient = config:getAsString("RECIPIENT"); //Example: "recipient@gmail.com"
string testSender = config:getAsString("SENDER"); //Example: "sender@gmail.com"
string testCc = config:getAsString("CC"); //Example: "cc@gmail.com"
string testAttachmentPath = config:getAsString("ATTACHMENT_PATH"); //Example: "/home/user/hello.txt"
string attachmentContentType = config:getAsString("ATTACHMENT_CONTENT_TYPE"); //Example: "text/plain"
string inlineImagePath = config:getAsString("INLINE_IMAGE_PATH"); //Example: "/home/user/Picture2.jpg"
string inlineImageName = config:getAsString("INLINE_IMAGE_NAME"); //Example: "Picture2.jpg"
string imageContentType = config:getAsString("IMAGE_CONTENT_TYPE"); //Example: "image/jpeg"

//---------------Do not change the following variables-----------------------//
string testUserId = "me";
//Holds value for message id of text mail sent in testSendTextMessage()
string sentTextMessageId = "";
//Holds value for thread id of text mail sent in testSendTextMessage()
string sentTextMessageThreadId = "";
//Holds value for message id of the html mail sent in testSendHtmlMessage()
string sentHtmlMessageId = "";
//Holds value for attachment id of attachment sent in testSendHTMLMessage()
//Attachment id is set in testReadHTMLMessageWithAttachment()
string readAttachmentFileId = "";
//Holds value for label id of the label created in testCreateLabel()
string createdLabelId = "";
//Holds value for history id of the text message sent in testSendTextMessage()
//History id is set in testReadTextMessage()
string testHistoryId = "";
//Holds value for draft id of the text message created in testCreateDraft()
string createdDraftId = "";

@test:Config {
    groups: ["textMessageTestGroup", "draftTestGroup"]
}
function testSendTextMessage() {
    MessageRequest messageRequest = {};
    messageRequest.recipient = testRecipient;
    messageRequest.sender = testSender;
    messageRequest.cc = testCc;
    messageRequest.subject = "Text-Email-Subject";
    //---Set Text Body---
    messageRequest.messageBody = "Text Message Body";
    messageRequest.contentType = TEXT_PLAIN;
    //---Set Attachments---
    AttachmentPath[] attachments = [{attachmentPath: testAttachmentPath, mimeType: attachmentContentType}];
    messageRequest.attachmentPaths = attachments;
    log:printInfo("testSendTextMessage");
    //----Send the mail----
    var sendMessageResponse = gmailClient->sendMessage(testUserId, messageRequest);
    
    if (sendMessageResponse is [string, string]) {
        [string, string][messageId, threadId] = sendMessageResponse;
        sentTextMessageId = <@untainted>messageId;
        sentTextMessageThreadId = <@untainted>threadId;
        test:assertTrue(messageId != "null" && threadId != "null", msg = "Send Text Message Failed");
    } else {
        test:assertFail(msg = sendMessageResponse.message());
    }
}

@test:Config {
    groups: ["htmlMessageTestGroup"]
}
function testSendHTMLMessage() {
    MessageRequest messageRequest = {};
    messageRequest.recipient = testRecipient;
    messageRequest.sender = testSender;
    messageRequest.cc = testCc;
    messageRequest.subject = "HTML-Email-Subject";
    //---Set HTML Body---
    string htmlBody = "<h1> Email Test HTML Body </h1> <br/> <img src=\"cid:image-" + inlineImageName + "\">";
    messageRequest.messageBody = htmlBody;
    messageRequest.contentType = TEXT_HTML;
    //---Set Inline Images---
    InlineImagePath[] inlineImages = [{imagePath: inlineImagePath, mimeType: imageContentType}];
    messageRequest.inlineImagePaths = inlineImages;
    //---Set Attachments---
    AttachmentPath[] attachments = [{attachmentPath: testAttachmentPath, mimeType: attachmentContentType}];
    messageRequest.attachmentPaths = attachments;
    log:printInfo("testSendHTMLMessage");
    //----Send the mail----
    var sendMessageResponse = gmailClient->sendMessage(testUserId, messageRequest);
    string messageId = "";
    string threadId = "";
    if (sendMessageResponse is error) {
        test:assertFail(msg = sendMessageResponse.message());
    } else {
        [messageId, threadId] = sendMessageResponse;
        sentHtmlMessageId = <@untainted>messageId;
        test:assertTrue(messageId != "null" && threadId != "null", msg = "Send HTML message failed");
    }
}

@test:Config {
    dependsOn: ["testSendHTMLMessage"],
    groups: ["htmlMessageTestGroup"]
}
function testModifyHTMLMessage() {
    //Modify labels of the message with message id which was sent in testSendHTMLMessage
    log:printInfo("testModifyHTMLMessage");
    var response = gmailClient->modifyMessage(testUserId, sentHtmlMessageId, ["INBOX"], []);
    if (response is Message) {
        test:assertTrue(response.id == sentHtmlMessageId, msg = "Modify HTML message by adding new label failed");
    } else {
        test:assertFail(msg = response.message());
    }
    response = gmailClient->modifyMessage(testUserId, sentHtmlMessageId, [], ["INBOX"]);
    if (response is Message) {
        test:assertTrue(response.id == sentHtmlMessageId,
        msg = "Modify HTML message by removing existing label failed");
    } else {
        test:assertFail(msg = response.message());
    }
}

@test:Config {

}
function testListMessages() {
    //List All Messages with Label INBOX without including Spam and Trash
    log:printInfo("testListAllMessages");
    MsgSearchFilter searchFilter = {includeSpamTrash: false, labelIds: ["INBOX"]};
    var msgList = gmailClient->listMessages("me", filter = searchFilter);
    if msgList is error {
        test:assertFail(msg = msgList.message());
    }
}

@test:Config {
    dependsOn: ["testSendDraft"],
    groups: ["textMessageTestGroup"]
}
function testReadTextMessage() {
    //Read mail with message id which was sent in testSendSimpleMessage
    log:printInfo("testReadTextMessage");
    var response = gmailClient->readMessage(testUserId, sentTextMessageId);
    if (response is Message) {
        testHistoryId = <@untainted>response.historyId;
        test:assertEquals(response.id, sentTextMessageId, msg = "Read text mail failed");
    } else {
        test:assertFail(msg = response.message());
    }
}

@test:Config {
    dependsOn: ["testModifyHTMLMessage"],
    groups: ["htmlMessageTestGroup"]
}
function testReadHTMLMessageWithAttachment() {
    //Read mail with message id which sent in testSendWithAttachment
    log:printInfo("testReadMessageWithAttachment");
    var response = gmailClient->readMessage(testUserId, sentHtmlMessageId);
    if (response is Message) {
        readAttachmentFileId = <@untainted>response.msgAttachments[0].fileId;
        test:assertEquals(response.id, sentHtmlMessageId, msg = "Read mail with attachment failed");
    } else {
        test:assertFail(msg = response.message());
    }
}

@test:Config {
    dependsOn: ["testReadHTMLMessageWithAttachment"],
    groups: ["htmlMessageTestGroup"]
}
function testgetAttachment() {
    log:printInfo("testgetAttachment");
    var response = gmailClient->getAttachment(testUserId, sentHtmlMessageId, readAttachmentFileId);
    if (response is error) {
        test:assertFail(msg = response.message());
    } else {
        boolean status = (response.fileId == EMPTY_STRING && response.body == EMPTY_STRING) ? false : true;
        test:assertTrue(status, msg = "Get Attachment failed");
    }
}

@test:Config {
    dependsOn: ["testgetAttachment"],
    groups: ["htmlMessageTestGroup"]
}
function testTrashMessage() {
    log:printInfo("testTrashMessage");
    var trash = gmailClient->trashMessage(testUserId, sentHtmlMessageId);
    if (trash is error) {
        test:assertFail(msg = trash.message());
    } else {
        test:assertTrue(trash, msg = "Trash mail failed");
    }
}

@test:Config {
    dependsOn: ["testTrashMessage"],
    groups: ["htmlMessageTestGroup"]
}
function testUntrashMessage() {
    log:printInfo("testUntrashMessage");
    var untrash = gmailClient->untrashMessage(testUserId, sentHtmlMessageId);
    if (untrash is error) {
        test:assertFail(msg = untrash.message());
    } else {
        test:assertTrue(untrash, msg = "Trash mail failed");
    }
}

@test:Config {
    dependsOn: ["testUntrashMessage"],
    groups: ["htmlMessageTestGroup"]
}
function testDeleteMessage() {
    log:printInfo("testDeleteMessage");
    var delete = gmailClient->deleteMessage(testUserId, sentHtmlMessageId);
    if (delete is error) {
        test:assertFail(msg = delete.message());
    } else {
        test:assertTrue(delete, msg = "Trash mail failed");
    }
}

@test:Config {

}
function testListThreads() {
    log:printInfo("testListThreads");
    var threadList = gmailClient->listThreads(testUserId, filter = {includeSpamTrash: false, labelIds: ["INBOX"]});
    if (threadList is error) {
        test:assertFail(msg = threadList.message());
    }
}

@test:Config {
    dependsOn: ["testReadTextMessage"],
    groups: ["textMessageTestGroup"]
}
function testReadThread() {
    log:printInfo("testReadThread");
    var thread = gmailClient->readThread(testUserId, sentTextMessageThreadId, format = FORMAT_METADATA,
        metadataHeaders = ["Subject"]);
    if (thread is MailThread) {
        test:assertEquals(thread.id, sentTextMessageThreadId, msg = "Read thread failed");
    } else {
        test:assertFail(msg = thread.message());
    }
}

@test:Config {
    dependsOn: ["testReadThread"],
    groups: ["textMessageTestGroup"]
}
function testModifyThread() {
    //Modify labels of the thread with thread id which was sent in testSendTextMessage
    log:printInfo("testModifyThread");
    var response = gmailClient->modifyThread(testUserId, sentTextMessageThreadId, ["INBOX"], []);
    if (response is MailThread) {
        test:assertTrue(response.id == sentTextMessageThreadId, msg = "Modify thread by adding new label failed");
    } else {
        test:assertFail(msg = response.message());
    }
    response = gmailClient->modifyThread(testUserId, sentTextMessageThreadId, [], ["INBOX"]);
    if (response is MailThread) {
        test:assertTrue(response.id == sentTextMessageThreadId,
            msg = "Modify thread by removing existing label failed");
    } else {
        test:assertFail(msg = response.message());
    }
}

@test:Config {
    dependsOn: ["testModifyThread"],
    groups: ["textMessageTestGroup"]
}
function testTrashThread() {
    log:printInfo("testTrashThread");
    var trash = gmailClient->trashThread(testUserId, sentTextMessageThreadId);
    if (trash is error) {
        test:assertFail(msg = trash.message());
    } else {
        test:assertTrue(trash, msg = "Trash thread failed");
    }
}

@test:Config {
    dependsOn: ["testTrashThread"],
    groups: ["textMessageTestGroup"]
}
function testUnTrashThread() {
    log:printInfo("testUnTrashThread");
    var untrash = gmailClient->untrashThread(testUserId, sentTextMessageThreadId);
    if (untrash is error) {
        test:assertFail(msg = untrash.message());
    } else {
        test:assertTrue(untrash, msg = "Untrash thread failed");
    }
}

@test:Config {
    enable: true,
    dependsOn: ["testUnTrashThread"],
    groups: ["textMessageTestGroup"]
}
function testDeleteThread() {
    log:printInfo("testDeleteThread");
    var delete = gmailClient->deleteThread(testUserId, sentTextMessageThreadId);
    if (delete is error) {
        test:assertFail(msg = delete.message());
    } else {
        test:assertTrue(delete, msg = "Delete thread failed");
    }
}

@test:Config {
    groups: ["userTestGroup"]
}
function testgetUserProfile() {
    log:printInfo("testgetUserProfile");
    var profile = gmailClient->getUserProfile(testUserId);
    if (profile is UserProfile) {
        test:assertTrue(profile.emailAddress != EMPTY_STRING, msg = "Get User Profile failed");
    } else {
        test:assertFail(msg = profile.message());
    }
}
@test:Config {
    dependsOn: ["testUpdateLabel"],
    groups: ["labelTestGroup"]
}
function testGetLabel() {
    log:printInfo("testgetLabel");
    var response = gmailClient->getLabel(testUserId, createdLabelId);
    if (response is Label) {
        test:assertTrue(response.id != EMPTY_STRING, msg = "Get Label failed");
    } else {
        test:assertFail(msg = response.message());
    }
}

@test:Config {
    groups: ["labelTestGroup"]
}
function testCreateLabel() {
    log:printInfo("testCreateLabel");
    var createLabelResponse = gmailClient->createLabel(testUserId, "Test", "labelShow", "show");
    if (createLabelResponse is string) {
        createdLabelId = <@untainted>createLabelResponse;
        test:assertTrue(createdLabelId != "null", msg = "Create Label failed");
    } else {
        test:assertFail(msg = createLabelResponse.message());
    }
}

@test:Config {
    groups: ["labelTestGroup"]
}
function testListLabels() {
    log:printInfo("testListLabels");
    var listLabelResponse = gmailClient->listLabels(testUserId);
    if (listLabelResponse is error) {
        test:assertFail(msg = listLabelResponse.message());
    }
}

@test:Config {
    dependsOn: ["testGetLabel"],
    groups: ["labelTestGroup"]
}
function testDeleteLabel() {
    log:printInfo("testDeleteLabel");
    var deleteLabelResponse = gmailClient->deleteLabel(testUserId, createdLabelId);
    if (deleteLabelResponse is error) {
        test:assertFail(msg = deleteLabelResponse.message());
    } else {
        test:assertTrue(deleteLabelResponse, msg = "Delete Label failed");
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
    var updateLabelResponse = gmailClient->updateLabel(testUserId, createdLabelId, name = updateName,
    backgroundColor = updateBgColor, textColor = updateTxtColor);
    if (updateLabelResponse is error) {
        test:assertFail(msg = updateLabelResponse.message());
    } else {
        test:assertTrue(updateLabelResponse.name == updateName &&
        updateLabelResponse.backgroundColor == updateBgColor &&
        updateLabelResponse.textColor == updateTxtColor, msg = "Update Label failed");
    }
}

@test:Config {
    dependsOn: ["testReadTextMessage"],
    groups: ["textMessageTestGroup"]
}
function testListHistory() {
    log:printInfo("testListTheHistory");
    string[] historyTypes = ["labelAdded", "labelRemoved", "messageAdded", "messageDeleted"];
    var listHistoryResponse = gmailClient->listHistory(testUserId, testHistoryId, historyTypes = historyTypes);
    if (listHistoryResponse is error) {
        test:assertFail(msg = listHistoryResponse.message());
    } else {
        test:assertTrue(listHistoryResponse.historyRecords.length() != 0, msg = "List history failed");
    }
}

@test:Config {

}
function testListDrafts() {
    //List maximum of ten results for Drafts without including Spam and Trash
    log:printInfo("testListDrafts");
    DraftSearchFilter searchFilter = {includeSpamTrash: false, maxResults: "10"};
    var msgList = gmailClient->listDrafts("me", filter = searchFilter);
    if (msgList is error) {
        test:assertFail(msg = msgList.message());
    }
}

@test:Config {
    dependsOn: ["testSendTextMessage"],
    groups: ["draftTestGroup"]
}
function testCreateDraft() {
    log:printInfo("testCreateDraft");
    string messageBody = "Draft Text Message Body";
    MessageRequest messageRequest = {};
    messageRequest.recipient = testRecipient;
    messageRequest.sender = testSender;
    messageRequest.cc = testCc;
    messageRequest.messageBody = messageBody;
    messageRequest.contentType = TEXT_PLAIN;
    var draftResponse = gmailClient->createDraft(testUserId, messageRequest, threadId = sentTextMessageThreadId);
    if (draftResponse is string) {
        test:assertTrue(draftResponse != "null", msg = "Create Draft failed");
        createdDraftId = <@untainted>draftResponse;
    } else {
        test:assertFail(msg = draftResponse.message());
    }
}

@test:Config {
    dependsOn: ["testCreateDraft"],
    groups: ["draftTestGroup"]
}
function testUpdateDraft() {
    log:printInfo("testUpdateDraft");
    string messageBody = "Updated Draft Text Message Body";
    MessageRequest messageRequest = {};
    messageRequest.recipient = testRecipient;
    messageRequest.sender = testSender;
    messageRequest.messageBody = messageBody;
    messageRequest.subject = "Update Draft Subject";
    messageRequest.contentType = TEXT_PLAIN;
    AttachmentPath[] attachments = [{attachmentPath: testAttachmentPath, mimeType: attachmentContentType}];
    messageRequest.attachmentPaths = attachments;
    var draftResponse = gmailClient->updateDraft(testUserId, createdDraftId, messageRequest);
    if (draftResponse is string) {
        test:assertTrue(draftResponse == createdDraftId, msg = "Update Draft failed");
    } else {
        test:assertFail(msg = draftResponse.message());
    }
}

@test:Config {
    dependsOn: ["testUpdateDraft"],
    groups: ["draftTestGroup"]
}
function testReadDraft() {
    log:printInfo("testReadDraft");
    var draftResponse = gmailClient->readDraft(testUserId, createdDraftId);
    if (draftResponse is Draft) {
        test:assertTrue(draftResponse.id == createdDraftId, msg = "Read Draft failed");
    } else {
        test:assertFail(msg = draftResponse.message());
    }
}

@test:Config {
    dependsOn: ["testReadDraft"],
    groups: ["draftTestGroup"]
}
function testSendDraft() {
    log:printInfo("testSendDraft");
    var sendDraftResponse = gmailClient->sendDraft(testUserId, createdDraftId);
    if (sendDraftResponse is error) {
        test:assertFail(msg = sendDraftResponse.message());
    } else {
        [string, string][messageId, threadId] = sendDraftResponse;
        test:assertTrue(messageId != "null" && threadId != "null", msg = "Send HTML message failed");
    }
}

@test:Config {
    groups: ["draftTestGroup"]
}
function testDeleteDraft() {
    log:printInfo("testDeleteDraft");
    //Create a new draft first
    MessageRequest messageRequest = {};
    messageRequest.recipient = testRecipient;
    messageRequest.sender = testSender;
    messageRequest.subject = "Draft To Delete";
    messageRequest.messageBody = "Draft Text Message Body To Delete";
    messageRequest.contentType = TEXT_PLAIN;
    var draftResponse = gmailClient->createDraft(testUserId, messageRequest);
    string draftIdToDelete = "";
    if (draftResponse is string) {
        test:assertTrue(draftResponse != "null", msg = "Create Draft failed");
        draftIdToDelete = <@untainted>draftResponse;
    } else {
        test:assertFail(msg = draftResponse.message());
    }
    //Delete the created draft
    var deleteResponse = gmailClient->deleteDraft(testUserId, draftIdToDelete);
    if (deleteResponse is boolean) {
        test:assertTrue(deleteResponse, msg = "Delete Draft Failed");
    } else {
        test:assertFail(msg = deleteResponse.message());
    }
}
