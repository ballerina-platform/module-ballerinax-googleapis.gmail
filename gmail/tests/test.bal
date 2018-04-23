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
//Message id of text mail which will be sent from testSendSimpleMail()
string sentTextMailId;
//Thread id of text mail which will be sent from testSendSimpleMail()
string sentTextMailThreadId;
//Mail id of the html mail which will be sent from testSendHtml()
string sentHtmlMailId;
//Attachment id of attachment which will be sent from testSendWithAttachment()
string readAttachmentFileId;

@test:Config {
    groups:["TextMailTestGroup"]
}
function testSendTextMail() {
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
    log:printInfo("testSendTextMail");
    var sendMessageResponse = gmailEP -> sendMessage(userId, messageRequest);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string)sendStatus => {
            (messageId, threadId) = sendStatus;
            sentTextMailId = messageId;
            sentTextMailThreadId = threadId;
            test:assertTrue(messageId != "" && threadId != "", msg = "Send Text Message Failed");
        }
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    groups:["htmlMailTestGroup"]
}
function testSendHTMLMail() {
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
    log:printInfo("testSendHTMLMail");
    //----Send the mail----
    var sendMessageResponse = gmailEP -> sendMessage(userId, messageRequest);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string) sendStatus => {
            (messageId, threadId) = sendStatus;
            sentHtmlMailId = messageId;
            test:assertTrue(messageId != "" && threadId != "", msg = "Send HTML message failed");
        }
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config
function testListMails() {
    //List All Mails with Label INBOX without including Spam and Trash with subject "Test subject - html mail"
    log:printInfo("testListAllMails");
    SearchFilter searchFilter = {includeSpamTrash:false, labelIds:["INBOX"], maxResults:"", pageToken:"", q:""};
    var msgList = gmailEP -> listMessages("me", filter = searchFilter);
    match msgList {
        MessageListPage list => {
            test:assertTrue(lengthof list.messages != 0, msg = "Failed due to empty inbox");
        }
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn:["testSendTextMail"],
    groups:["TextMailTestGroup"]
}
function testReadTextMail() {
    //Read mail with message id which sent in testSendSimpleMail
    log:printInfo("testReadTextMail");
    var reponse = gmailEP -> readMessage(userId, sentTextMailId);
    match reponse {
        Message m => test:assertEquals(m.id, sentTextMailId, msg = "Read text mail failed");
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn:["testSendHTMLMail"],
    groups:["htmlMailTestGroup"]
}
function testReadHTMLMailWithAttachment() {
    //Read mail with message id which sent in testSendWithAttachment
    log:printInfo("testReadMessageWithAttachment");
    var response = gmailEP -> readMessage(userId, sentHtmlMailId);
    match response {
        Message m => {
            readAttachmentFileId = m.msgAttachments[0].attachmentFileId;
            test:assertEquals(m.id, sentHtmlMailId, msg = "Read mail with attachment failed");
        }
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn:["testReadHTMLMailWithAttachment"],
    groups:["htmlMailTestGroup"]
}
function testgetAttachment() {
    log:printInfo("testgetAttachment");
    var attachment = gmailEP -> getAttachment(userId, sentHtmlMailId, readAttachmentFileId);
    match attachment {
        GmailError e => test:assertFail(msg = e.message);
        MessageAttachment attach => {
            boolean status = (attach.attachmentFileId == "" && attach.attachmentBody == "") ? false : true;
            test:assertTrue(status, msg = "Get Attachment failed");
        }
    }
}

@test:Config {
    dependsOn:["testgetAttachment"],
    groups:["htmlMailTestGroup"]
}
function testTrashMail() {
    //Trash mail with message id 1628c6e29f2fef47
    log:printInfo("testTrashMail");
    var trash = gmailEP -> trashMail(userId, sentHtmlMailId);
    match trash {
        GmailError e => test:assertFail(msg = e.message);
        boolean success => test:assertTrue(success, msg = "Trash mail failed");
    }
}

@test:Config {
    dependsOn:["testTrashMail"],
    groups:["htmlMailTestGroup"]
}
function testUntrashMail() {
    log:printInfo("testUntrashMail");
    var untrash = gmailEP -> untrashMail(userId, sentHtmlMailId);
    match untrash {
        GmailError e => test:assertFail(msg = e.message);
        boolean success => test:assertTrue(success, msg = "Untrash mail failed");
    }
}

@test:Config {
    dependsOn:["testUntrashMail"],
    groups:["htmlMailTestGroup"]
}
function testDeleteMail() {
    log:printInfo("testDeleteMail");
    var delete = gmailEP -> deleteMail(userId, sentHtmlMailId);
    match delete {
        GmailError e => test:assertFail(msg = e.message);
        boolean success => test:assertTrue(success, msg = "Delete mail failed");
    }
}

@test:Config
function testListAllThreads() {
    log:printInfo("testListAllThreads");
    var threadList = gmailEP -> listThreads(userId, filter = {includeSpamTrash:false, labelIds:["INBOX"],
                                                                                    maxResults:"", pageToken:"", q:""});
    match threadList {
        ThreadListPage list => test:assertTrue(lengthof list.threads != 0, msg = "List threads in inbox failed");
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn:["testReadTextMail"],
    groups:["TextMailTestGroup"]
}
function testReadThread() {
    log:printInfo("testReadThread");
    var thread = gmailEP -> readThread(userId, sentTextMailThreadId,
                                                            format = FORMAT_METADATA, metadataHeaders = ["Subject"]);
    match thread{
        Thread t => test:assertEquals(t.id, sentTextMailThreadId, msg = "Read thread failed");
        GmailError e => test:assertFail(msg = e.message);
    }
}

@test:Config {
    dependsOn:["testReadThread"],
    groups:["TextMailTestGroup"]
}
function testTrashThread() {
    log:printInfo("testTrashThread");
    var trash = gmailEP -> trashThread(userId, sentTextMailThreadId);
    match trash {
        GmailError e => test:assertFail(msg = e.message);
        boolean success => test:assertTrue(success, msg = "Trash thread failed");
    }
}

@test:Config {
    dependsOn:["testTrashThread"],
    groups:["TextMailTestGroup"]
}
function testUnTrashThread() {
    log:printInfo("testUnTrashThread");
    var untrash = gmailEP -> untrashThread(userId, sentTextMailThreadId);
    match untrash {
        GmailError e => test:assertFail(msg = e.message);
        boolean success => test:assertTrue(success, msg = "Untrash thread failed");

    }
}

@test:Config {
    dependsOn:["testUnTrashThread"],
    groups:["TextMailTestGroup"]
}
function testDeleteThread() {
    log:printInfo("testDeleteThread");
    var delete = gmailEP -> deleteThread(userId, sentTextMailThreadId);
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
    var profile = gmailEP -> getUserProfile(userId);
    match profile {
        UserProfile p => test:assertTrue(p.emailAddress != "", msg = "Get User Profile failed");
        GmailError e => test:assertFail(msg = e.message);
    }
}
