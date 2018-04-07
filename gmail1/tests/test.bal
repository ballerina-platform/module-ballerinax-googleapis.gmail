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

import ballerina/io;
import ballerina/http;
import ballerina/log;
import ballerina/test;

endpoint GmailClient gmailEP {
    oauthClientConfig:{
        accessToken:"",
        clientId:"",
        clientSecret:"",
        refreshToken:"",
        refreshTokenEP:REFRESH_TOKEN_EP,
        refreshTokenPath:REFRESH_TOKEN_PATH,
        baseUrl:BASE_URL,
        clientConfig:{},
        useUriParams:true,
        setCredentialsInHeader:false
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
Message mail = new ();
//Message id of text mail which will be sent from testSendSimpleMail()
string sentTextMailId;
//Thread id of text mail which will be sent from testSendSimpleMail()
string sentTextMailThreadId;
//Mail id of the html mail which will be sent from testSendHtml()
string sentHtmlMailId = "";
//Message id of mail with attachment which will be sent from testSendWithAttachment()
string sentAttachmentMailId;
//Attachment id of attachment which will be sent from testSendWithAttachment()
string readAttachmentFileId;

function createMail() {
    mail = new ();
    //Create a simple mail with text content
    log:printInfo("createMessage()");
    //-----Define the email parameters------
    string subject = "Email-Subject";
    string messageBody = "Email Test Body";
    MessageOptions options = {};
    options.sender = sender;
    options.cc = cc;
    mail.createMessage(recipient, subject, messageBody, options);
}

@test:Config {
    before:"createMail",
    groups:["sendMailTestGroup", "simpleTextMailTestGroup"]
}
function testSendSimpleMail() {
    //Send a simple mail with text content
    log:printInfo("testSendSimpleMail");
    log:printInfo("gmailEP -> sendMessage()");
    var sendMessageResponse = gmailEP -> sendMessage(userId, mail);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string)sendStatus => {
            (messageId, threadId) = sendStatus;
            sentTextMailId = messageId;
            sentTextMailThreadId = threadId;
            test:assertTrue(messageId != null && threadId != null, msg = "Send Simple text Message Failed");
        }
        GmailError e => test:assertFail(msg = e.errorMessage);
    }

}

@test:Config {
    before:"createMail",
    groups:["sendMailTestGroup", "htmlMailTestGroup"]
}
function testSendHtml() {
    //Send a html mail with html content
    //----Set Html content----
    string htmlBody = "<h1> Email Test Html Body </h1>";
    match mail.setContent(htmlBody, "text/html") {
        boolean htmlSetStatus => test:assertTrue(htmlSetStatus, msg = "Set Html Content Failed");
        GmailError er => test:assertFail(msg = er.errorMessage);
    }
    //----Send the mail----
    log:printInfo("testSendHtml");
    log:printInfo("gmailEP -> sendMessage()");
    string messageId;
    string threadId;
    var sendMessageResponse = gmailEP -> sendMessage(userId, mail);
    match sendMessageResponse {
        (string, string)sendStatus => {
            (messageId, threadId) = sendStatus;
            sentHtmlMailId = messageId;
            test:assertTrue(messageId != null && threadId != null, msg = "Send HTML message failed");
        }
        GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    before:"createMail",
    groups:["sendMailTestGroup"]
}
function testSendHtmlInlineImage() {
    //Send a html mail with html content and inline image
    //----Set Html content----
    //If you are sending an inline image, create a html body email and put the image into the body by using <img> tag.
    //Give the src value as "cid:image-<Your image name with extension>".
    string htmlBody = "<h1> Email Test HTML Body </h1> <br/> <img src=\"cid:image-" + inlineImageName + "\">";
    match mail.setContent(htmlBody, "text/html") {
        boolean htmlSetStatus => test:assertTrue(htmlSetStatus, msg = "Set Html Content Failed");
        GmailError er => test:assertFail(msg = er.errorMessage);
    }

    match mail.setContent(inlineImagePath, imageContentType) {
        boolean imgInlineSetStatus => test:assertTrue(imgInlineSetStatus,
            msg = "Set Html Content and inline image Failed");
        GmailError er => test:assertFail(msg = er.errorMessage);
    }
    //----Send the mail----
    log:printInfo("testSendHtmlInlineImage");
    log:printInfo("gmailEP -> sendMessage()");
    var sendMessageResponse = gmailEP -> sendMessage(userId, mail);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string)sendStatus => {
            (messageId, threadId) = sendStatus;
            test:assertTrue(messageId != null && threadId != null, msg = "Send HTML message failed");
        }
        GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    before:"createMail",
    groups:["sendMailTestGroup", "mailWithAttachmentTestGroup"]
}
function testSendWithAttachment() {
    //Send a mail with text content and attachment
    //----Add Attachment----
    match mail.addAttachment(attachmentPath, attachmentContentType) {
        boolean attachStatus => test:assertTrue(attachStatus, msg = "Add attachment Failed");
        GmailError e => test:assertFail(msg = e.errorMessage);
    }
    //----Send the mail----
    log:printInfo("testSendWithAttachment");
    log:printInfo("gmailEP -> sendMessage()");
    var sendMessageResponse = gmailEP -> sendMessage(userId, mail);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string)sendStatus => {
            (messageId, threadId) = sendStatus;
            sentAttachmentMailId = messageId;
            test:assertTrue(messageId != null && threadId != null, msg = "Send HTML message with attachment failed");
        }
        GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    before:"createMail",
    groups:["sendMailTestGroup"]
}
function testSendHtmlWithAttachment() {
    //Send a html mail with html content and attachment
    //----Set Html content----
    string htmlBody = "<h1> Email Test Html Body </h1>";
    match mail.setContent(htmlBody, "text/html") {
        boolean htmlSetStatus => test:assertTrue(htmlSetStatus, msg = "Set Html Content Failed");
        GmailError er => test:assertFail(msg = er.errorMessage);
    }
    //----Add Attachment----
    match mail.addAttachment(attachmentPath, attachmentContentType) {
        boolean attachStatus => test:assertTrue(attachStatus, msg = "Add attachment Failed");
        GmailError er => test:assertFail(msg = er.errorMessage);
    }
    //----Send the mail----
    log:printInfo("testSendHtmlWithAttachment");
    log:printInfo("gmailEP -> sendMessage()");
    var sendMessageResponse = gmailEP -> sendMessage(userId, mail);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string)sendStatus => {(messageId, threadId) = sendStatus;
        test:assertTrue(messageId != null && threadId != null, msg = "Send HTML message with attachment failed");
        }
        GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config
function testListAllMails() {
    //List All Mails with Label INBOX without including Spam and Trash with subject "Test subject - html mail"
    log:printInfo("testListAllMails");
    log:printInfo("gmaiEP -> listAllMails()");
    SearchFilter filter = {includeSpamTrash:false, labelIds:["INBOX"], maxResults:"", pageToken:"", q:""};
    var msgList = gmailEP -> listAllMails("me", filter);
    match msgList {
        MessageListPage list => test:assertTrue(lengthof list.messages != 0,
            msg = "List messages in inbox failed");
        GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    dependsOn:["testSendSimpleMail"],
    groups:["simpleTextMailTestGroup"]
}
function testReadTextMail() {
    //Read mail with message id which sent in testSendSimpleMail
    log:printInfo("testReadTextMail");
    log:printInfo("gmailEP -> readMail()");
    GetMessageThreadFilter filter = {format:FORMAT_FULL, metadataHeaders:[]};
    var reponse = gmailEP -> readMail(userId, sentTextMailId, filter);
    match reponse {
        Message m => test:assertEquals(m.id, sentTextMailId, msg = "Read text mail failed");
        GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    dependsOn:["testSendWithAttachment"],
    groups:["mailWithAttachmentTestGroup"]
}
function testReadMailWithAttachment() {
    //Read mail with message id which sent in testSendWithAttachment
    log:printInfo("testReadMailWithAttachment");
    log:printInfo("gmailEP -> readMail()");
    GetMessageThreadFilter filter = {format:FORMAT_FULL, metadataHeaders:[]};
    var response = gmailEP -> readMail(userId, sentAttachmentMailId, filter);
    match response {
        Message m => {
            readAttachmentFileId = m.msgAttachments[0].attachmentFileId;
            test:assertEquals(m.id, sentAttachmentMailId, msg = "Read mail with attachment failed");
        }
        GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    dependsOn:["testReadMailWithAttachment"],
    groups:["mailWithAttachmentTestGroup"]
}
function testgetAttachment() {
    log:printInfo("testgetAttachment");
    log:printInfo("gmailEP -> getAttachment()");
    var attachment = gmailEP -> getAttachment(userId, sentAttachmentMailId, readAttachmentFileId);
    match attachment {
        GmailError e => test:assertFail(msg = e.errorMessage);
        MessageAttachment attach => {
            boolean status = (attach.attachmentFileId == "" && attach.attachmentBody == "") ? false : true;
            test:assertTrue(status, msg = "Get Attachment failed");
        }
    }
}

@test:Config {
    dependsOn:["testSendHtml"],
    groups:["htmlMailTestGroup"]
}
function testTrashMail() {
    //Trash mail with message id 1628c6e29f2fef47
    log:printInfo("testTrashMail");
    log:printInfo("gmailEP -> trashMail()");
    var trash = gmailEP -> trashMail(userId, sentHtmlMailId);
    match trash {
        GmailError e => test:assertFail(msg = e.errorMessage);
        boolean success => test:assertTrue(success, msg = "Trash mail failed");
    }
}

@test:Config {
    dependsOn:["testTrashMail"],
    groups:["htmlMailTestGroup"]
}
function testUntrashMail() {
    log:printInfo("testUntrashMail");
    log:printInfo("gmailEP -> untrashMail()");
    var untrash = gmailEP -> untrashMail(userId, sentHtmlMailId);
    match untrash {
        GmailError e => test:assertFail(msg = e.errorMessage);
        boolean success => test:assertTrue(success, msg = "Untrash mail failed");
    }
}

@test:Config {
    dependsOn:["testUntrashMail"],
    groups:["htmlMailTestGroup"]
}
function testDeleteMail() {
    log:printInfo("testDeleteMail");
    log:printInfo("gmailEP -> deleteMail()");
    var delete = gmailEP -> deleteMail(userId, sentHtmlMailId);
    match delete {
        GmailError e => test:assertFail(msg = e.errorMessage);
        boolean success => test:assertTrue(success, msg = "Delete mail failed");
    }
}

@test:Config
function testListAllThreads() {
    log:printInfo("testListAllThreads");
    log:printInfo("gmailEP -> listThreads()");
    var threadList = gmailEP -> listThreads(userId, {includeSpamTrash:false, labelIds:["INBOX"],
            maxResults:"", pageToken:"", q:""});
    match threadList {
        ThreadListPage list => test:assertTrue(lengthof list.threads != 0, msg = "List threads in inbox failed");
        GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    dependsOn:["testReadTextMail"],
    groups:["simpleTextMailTestGroup"]
}
function testReadThread() {
    log:printInfo("testReadThread");
    log:printInfo("gmailEP -> readThread()");
    GetMessageThreadFilter filter = {format:FORMAT_METADATA, metadataHeaders:["Subject"]};
    var thread = gmailEP -> readThread(userId, sentTextMailThreadId, filter);
    match thread{
        Thread t => test:assertEquals(t.id, sentTextMailThreadId, msg = "Read thread failed");
        GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    dependsOn:["testReadThread"],
    groups:["simpleTextMailTestGroup"]
}
function testTrashThread() {
    log:printInfo("testTrashThread");
    log:printInfo("gmailEP -> trashThread()");
    var trash = gmailEP -> trashThread(userId, sentTextMailThreadId);
    match trash {
        GmailError e => test:assertFail(msg = e.errorMessage);
        boolean success => test:assertTrue(success, msg = "Trash thread failed");
    }
}

@test:Config {
    dependsOn:["testTrashThread"],
    groups:["simpleTextMailTestGroup"]
}
function testUnTrashThread() {
    log:printInfo("testUnTrashThread");
    log:printInfo("gmailEP -> untrashThread()");
    var untrash = gmailEP -> untrashThread(userId, sentTextMailThreadId);
    match untrash {
        GmailError e => test:assertFail(msg = e.errorMessage);
        boolean success => test:assertTrue(success, msg = "Untrash thread failed");

    }
}

@test:Config {
    dependsOn:["testUnTrashThread"],
    groups:["simpleTextMailTestGroup"]
}
function testDeleteThread() {
    log:printInfo("testDeleteThread");
    log:printInfo("gmailEP -> deleteThread()");
    var delete = gmailEP -> deleteThread(userId, sentTextMailThreadId);
    match delete {
        GmailError e => test:assertFail(msg = e.errorMessage);
        boolean success => test:assertTrue(success, msg = "Delete thread failed");
    }
}

@test:Config {
    groups:["userTestGroup"]
}
function testgetUserProfile() {
    log:printInfo("testgetUserProfile");
    log:printInfo("gmailEP -> getUserProfile()");
    var profile = gmailEP -> getUserProfile(userId);
    match profile {
        UserProfile p => test:assertTrue(p.emailAddress != null, msg = "Get User Profile failed");
        GmailError e => test:assertFail(msg = e.errorMessage);
    }
}
