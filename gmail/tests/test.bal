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

endpoint Client gmailEP {
    clientConfig:{
        auth:{
            accessToken:config:getAsString("ACCESS_TOKEN"),
            clientId:config:getAsString("CLIENT_ID"),
            clientSecret:config:getAsString("CLIENT_SECRET"),
            refreshToken:config:getAsString("REFRESH_TOKEN")
        }
    }
};

//Needs to be filled by tester
string recipient = ""; //Example: "recipient@gmail.com"
string sender = ""; //Example: "sender@gmail.com"
string cc = ""; //Example: "cc@gmail.com"
string attachmentPath = ""; //Example: "/home/user/hello.txt"
string attachmentContentType = ""; //Example: "text/plain"
string inlineImagePath = ""; //Example: "/home/user/Picture2.jpg"
string inlineImageName = ""; //Example: "Picture2.jpg"
string imageContentType = ""; //Example: "image/jpeg"

string userId = "me";
//Message id of text mail which will be sent from testSendSimpleMessage()
string sentTextMessageId;
//Thread id of text mail which will be sent from testSendSimpleMessage()
string sentTextMessageThreadId;
//Message id of the html mail which will be sent from testSendHtml()
string sentHtmlMessageId;
//Attachment id of attachment which will be sent from testSendWithAttachment()
string readAttachmentFileId;
//Label id of the label which will be create from testCreateLabel()
string createdLabelId;

@test:Config {
    groups:["TextMessageTestGroup"]
}
function testSendTextMessage() {
    string subject = "Text-Email-Subject";
    string messageBody = "Text Message Body";
    MessageRequest messageRequest;
    messageRequest.recipient = recipient;
    messageRequest.sender = sender;
    messageRequest.cc = cc;
    messageRequest.subject = subject;
    messageRequest.messageBody = messageBody;
    messageRequest.contentType = TEXT_PLAIN;
    AttachmentPath[] attachments = [{attachmentPath:attachmentPath,mimeType:attachmentContentType}];
    messageRequest.attachmentPaths = attachments;
    log:printInfo("testSendTextMessage");
    var sendMessageResponse = gmailEP->sendMessage(userId, messageRequest);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string)sendStatus => {
            (messageId, threadId) = sendStatus;
            sentTextMessageId = messageId;
            sentTextMessageThreadId = threadId;
            test:assertTrue(messageId != "null" && threadId != "null", msg = "Send Text Message Failed");
        }
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    groups:["htmlMessageTestGroup"]
}
function testSendHTMLMessage() {
    string subject = "HTML-Email-Subject";
    string htmlBody = "<h1> Email Test HTML Body </h1> <br/> <img src=\"cid:image-" + inlineImageName + "\">";
    MessageRequest messageRequest;
    messageRequest.recipient = recipient;
    messageRequest.sender = sender;
    messageRequest.cc = cc;
    messageRequest.subject = subject;
    messageRequest.messageBody = htmlBody;
    messageRequest.contentType = TEXT_HTML;
    InlineImagePath[] inlineImages = [{imagePath:inlineImagePath, mimeType:imageContentType}];
    messageRequest.inlineImagePaths = inlineImages;
    AttachmentPath[] attachments = [{attachmentPath:attachmentPath, mimeType:attachmentContentType}];
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

@test:Config
function testListMessages() {
    //List All Messages with Label INBOX without including Spam and Trash with subject "Test subject - html mail"
    log:printInfo("testListAllMessages");
    SearchFilter searchFilter = {includeSpamTrash:false, labelIds:["INBOX"]};
    var msgList = gmailEP->listMessages("me", filter = searchFilter);
    match msgList {
        MessageListPage list => {} //test list messages success
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn:["testSendTextMessage"],
    groups:["TextMessageTestGroup"]
}
function testReadTextMessage() {
    //Read mail with message id which sent in testSendSimpleMessage
    log:printInfo("testReadTextMessage");
    var reponse = gmailEP->readMessage(userId, sentTextMessageId);
    match reponse {
        Message m => test:assertEquals(m.id, sentTextMessageId, msg = "Read text mail failed");
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn:["testSendHTMLMessage"],
    groups:["htmlMessageTestGroup"]
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
    dependsOn:["testReadHTMLMessageWithAttachment"],
    groups:["htmlMessageTestGroup"]
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
    dependsOn:["testgetAttachment"],
    groups:["htmlMessageTestGroup"]
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
    dependsOn:["testTrashMessage"],
    groups:["htmlMessageTestGroup"]
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
    dependsOn:["testUntrashMessage"],
    groups:["htmlMessageTestGroup"]
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
function testListAllThreads() {
    log:printInfo("testListAllThreads");
    var threadList = gmailEP->listThreads(userId, filter = {includeSpamTrash:false, labelIds:["INBOX"]});
    match threadList {
        ThreadListPage list => {} // test list threads success
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn:["testReadTextMessage"],
    groups:["TextMessageTestGroup"]
}
function testReadThread() {
    log:printInfo("testReadThread");
    var thread = gmailEP->readThread(userId, sentTextMessageThreadId,
                                                            format = FORMAT_METADATA, metadataHeaders = ["Subject"]);
    match thread{
        Thread t => test:assertEquals(t.id, sentTextMessageThreadId, msg = "Read thread failed");
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn:["testReadThread"],
    groups:["TextMessageTestGroup"]
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
    dependsOn:["testTrashThread"],
    groups:["TextMessageTestGroup"]
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
    dependsOn:["testUnTrashThread"],
    groups:["TextMessageTestGroup"]
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
    groups:["userTestGroup"]
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
    dependsOn:["testCreateLabel"],
    groups:["labelTestGroup"]
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
    groups:["labelTestGroup"]
}
function testCreateLabel() {
    log:printInfo("testCreateLabel");
    var createLabelResponse = gmailEP->createLabel(userId, "test", "labelShow", "show");
    match createLabelResponse {
        string id => {
            createdLabelId = id;
            test:assertTrue(id != "null", msg = "Create Label failed");
        }
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    groups:["labelTestGroup"]
}
function testListLabels() {
    log:printInfo("testListLabels");
    var listLabelResponse = gmailEP->listLabels(userId);
    match listLabelResponse {
        Label[] labels => {} //test list labels success
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn:["testGetLabel"],
    groups:["labelTestGroup"]
}
function testDeleteLabel(){
    log:printInfo("testDeleteLabel");
    var deleteLabelResponse = gmailEP->deleteLabel(userId, createdLabelId);
    match deleteLabelResponse {
        GmailError e => test:assertFail(msg = e.message);
        boolean success => test:assertTrue(success, msg = "Delete label failed");
    }
}
