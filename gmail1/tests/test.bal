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
import ballerina/config;

string url = setConfParams(config:getAsString("ENDPOINT"));
string accessToken = setConfParams(config:getAsString("ACCESS_TOKEN"));
string clientId = setConfParams(config:getAsString("CLIENT_ID"));
string clientSecret = setConfParams(config:getAsString("CLIENT_SECRET"));
string refreshToken = setConfParams(config:getAsString("REFRESH_TOKEN"));
string refreshTokenEndpoint = setConfParams(config:getAsString("REFRESH_TOKEN_ENDPOINT"));
string refreshTokenPath = setConfParams(config:getAsString("REFRESH_TOKEN_PATH"));

endpoint GMailClient gMailEP {
    oAuth2ClientConfig:{
        accessToken:accessToken,
        baseUrl:url,
        clientId:clientId,
        clientSecret:clientSecret,
        refreshToken:refreshToken,
        refreshTokenEP:refreshTokenEndpoint,
        refreshTokenPath:refreshTokenPath,
        clientConfig:{}
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
    log:printInfo("gMailEP -> sendMessage()");
    var sendMessageResponse = gMailEP -> sendMessage(userId, mail);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string)sendStatus => {
            (messageId, threadId) = sendStatus;
            sentTextMailId = messageId;
            sentTextMailThreadId = threadId;
            test:assertTrue(messageId != null && threadId != null, msg = "Send Simple text Message Failed");
        }
        GMailError e => test:assertFail(msg = e.errorMessage);
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
        GMailError er => test:assertFail(msg = er.errorMessage);
    }
    //----Send the mail----
    log:printInfo("testSendHtml");
    log:printInfo("gMailEP -> sendMessage()");
    string messageId;
    string threadId;
    var sendMessageResponse = gMailEP -> sendMessage(userId, mail);
    match sendMessageResponse {
        (string, string)sendStatus => {
            (messageId, threadId) = sendStatus;
            sentHtmlMailId = messageId;
            test:assertTrue(messageId != null && threadId != null, msg = "Send HTML message failed");
        }
        GMailError e => test:assertFail(msg = e.errorMessage);
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
        GMailError er => test:assertFail(msg = er.errorMessage);
    }

    match mail.setContent(inlineImagePath, imageContentType) {
        boolean imgInlineSetStatus => test:assertTrue(imgInlineSetStatus,
                                                            msg = "Set Html Content and inline image Failed");
        GMailError er => test:assertFail(msg = er.errorMessage);
    }
    //----Send the mail----
    log:printInfo("testSendHtmlInlineImage");
    log:printInfo("gMailEP -> sendMessage()");
    var sendMessageResponse = gMailEP -> sendMessage(userId, mail);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string)sendStatus => {
            (messageId, threadId) = sendStatus;
            test:assertTrue(messageId != null && threadId != null, msg = "Send HTML message failed");
        }
        GMailError e => test:assertFail(msg = e.errorMessage);
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
        GMailError e => test:assertFail(msg = e.errorMessage);
    }
    //----Send the mail----
    log:printInfo("testSendWithAttachment");
    log:printInfo("gMailEP -> sendMessage()");
    var sendMessageResponse = gMailEP -> sendMessage(userId, mail);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string)sendStatus => {
            (messageId, threadId) = sendStatus;
            sentAttachmentMailId = messageId;
            test:assertTrue(messageId != null && threadId != null, msg = "Send HTML message with attachment failed");
        }
        GMailError e => test:assertFail(msg = e.errorMessage);
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
        GMailError er => test:assertFail(msg = er.errorMessage);
    }
    //----Add Attachment----
    match mail.addAttachment(attachmentPath, attachmentContentType) {
        boolean attachStatus => test:assertTrue(attachStatus, msg = "Add attachment Failed");
        GMailError er => test:assertFail(msg = er.errorMessage);
    }
    //----Send the mail----
    log:printInfo("testSendHtmlWithAttachment");
    log:printInfo("gMailEP -> sendMessage()");
    var sendMessageResponse = gMailEP -> sendMessage(userId, mail);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string)sendStatus => {(messageId, threadId) = sendStatus;
        test:assertTrue(messageId != null && threadId != null, msg = "Send HTML message with attachment failed");
        }
        GMailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config
function testListAllMails() {
    //List All Mails with Label INBOX without including Spam and Trash with subject "Test subject - html mail"
    log:printInfo("testListAllMails");
    log:printInfo("gmaiEP -> listAllMails()");
    SearchFilter filter = {includeSpamTrash:false, labelIds:["INBOX"], maxResults:"", pageToken:"", q:""};
    var msgList = gMailEP -> listAllMails("me", filter);
    match msgList {
        MessageListPage list => test:assertTrue(lengthof list.messages != 0, msg = "List messages in inbox failed");
        GMailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    dependsOn:["testSendSimpleMail"],
    groups:["simpleTextMailTestGroup"]
}
function testReadTextMail() {
    //Read mail with message id which sent in testSendSimpleMail
    log:printInfo("testReadTextMail");
    log:printInfo("gMailEP -> readMail()");
    GetMessageThreadFilter filter = {format:FORMAT_FULL, metadataHeaders:[]};
    var reponse = gMailEP -> readMail(userId, sentTextMailId, filter);
    match reponse {
        Message m => test:assertEquals(m.id, sentTextMailId, msg = "Read text mail failed");
        GMailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    dependsOn:["testSendWithAttachment"],
    groups:["mailWithAttachmentTestGroup"]
}
function testReadMailWithAttachment() {
    //Read mail with message id which sent in testSendWithAttachment
    log:printInfo("testReadMailWithAttachment");
    log:printInfo("gMailEP -> readMail()");
    GetMessageThreadFilter filter = {format:FORMAT_FULL, metadataHeaders:[]};
    var response = gMailEP -> readMail(userId, sentAttachmentMailId, filter);
    match response {
        Message m => {
            readAttachmentFileId = m.msgAttachments[0].attachmentFileId;
            test:assertEquals(m.id, sentAttachmentMailId, msg = "Read mail with attachment failed");
        }
        GMailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    dependsOn:["testReadMailWithAttachment"],
    groups:["mailWithAttachmentTestGroup"]
}
function testgetAttachment() {
    log:printInfo("testgetAttachment");
    log:printInfo("gMailEP -> getAttachment()");
    var attachment = gMailEP -> getAttachment(userId, sentAttachmentMailId, readAttachmentFileId);
    match attachment {
        GMailError e => test:assertFail(msg = e.errorMessage);
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
    log:printInfo("gMailEP -> trashMail()");
    var trash = gMailEP -> trashMail(userId, sentHtmlMailId);
    match trash {
        GMailError e => test:assertFail(msg = e.errorMessage);
        boolean success => test:assertTrue(success, msg = "Trash mail failed");
    }
}

@test:Config {
    dependsOn:["testTrashMail"],
    groups:["htmlMailTestGroup"]
}
function testUntrashMail() {
    log:printInfo("testUntrashMail");
    log:printInfo("gMailEP -> untrashMail()");
    var untrash = gMailEP -> untrashMail(userId, sentHtmlMailId);
    match untrash {
        GMailError e => test:assertFail(msg = e.errorMessage);
        boolean success => test:assertTrue(success, msg = "Untrash mail failed");
    }
}

@test:Config {
    dependsOn:["testUntrashMail"],
    groups:["htmlMailTestGroup"]
}
function testDeleteMail() {
    log:printInfo("testDeleteMail");
    log:printInfo("gMailEP -> deleteMail()");
    var delete = gMailEP -> deleteMail(userId, sentHtmlMailId);
    match delete {
        GMailError e => test:assertFail(msg = e.errorMessage);
        boolean success => test:assertTrue(success, msg = "Delete mail failed");
    }
}

@test:Config
function testListAllThreads() {
    log:printInfo("testListAllThreads");
    log:printInfo("gMailEP -> listThreads()");
    var threadList = gMailEP -> listThreads(userId, {includeSpamTrash:false, labelIds:["INBOX"],
            maxResults:"", pageToken:"", q:""});
    match threadList {
        ThreadListPage list => test:assertTrue(lengthof list.threads != 0, msg = "List threads in inbox failed");
        GMailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    dependsOn:["testReadTextMail"],
    groups:["simpleTextMailTestGroup"]
}
function testReadThread() {
    log:printInfo("testReadThread");
    log:printInfo("gMailEP -> readThread()");
    GetMessageThreadFilter filter = {format:FORMAT_METADATA, metadataHeaders:["Subject"]};
    var thread = gMailEP -> readThread(userId, sentTextMailThreadId, filter);
    match thread{
        Thread t => test:assertEquals(t.id, sentTextMailThreadId, msg = "Read thread failed");
        GMailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    dependsOn:["testReadThread"],
    groups:["simpleTextMailTestGroup"]
}
function testTrashThread() {
    log:printInfo("testTrashThread");
    log:printInfo("gMailEP -> trashThread()");
    var trash = gMailEP -> trashThread(userId, sentTextMailThreadId);
    match trash {
        GMailError e => test:assertFail(msg = e.errorMessage);
        boolean success => test:assertTrue(success, msg = "Trash thread failed");
    }
}

@test:Config {
    dependsOn:["testTrashThread"],
    groups:["simpleTextMailTestGroup"]
}
function testUnTrashThread() {
    log:printInfo("testUnTrashThread");
    log:printInfo("gMailEP -> untrashThread()");
    var untrash = gMailEP -> untrashThread(userId, sentTextMailThreadId);
    match untrash {
        GMailError e => test:assertFail(msg = e.errorMessage);
        boolean success => test:assertTrue(success, msg = "Untrash thread failed");

    }
}

@test:Config {
    dependsOn:["testUnTrashThread"],
    groups:["simpleTextMailTestGroup"]
}
function testDeleteThread() {
    log:printInfo("testDeleteThread");
    log:printInfo("gMailEP -> deleteThread()");
    var delete = gMailEP -> deleteThread(userId, sentTextMailThreadId);
    match delete {
        GMailError e => test:assertFail(msg = e.errorMessage);
        boolean success => test:assertTrue(success, msg = "Delete thread failed");
    }
}

@test:Config {
    groups:["userTestGroup"]
}
function testgetUserProfile() {
    log:printInfo("testgetUserProfile");
    log:printInfo("gMailEP -> getUserProfile()");
    var profile = gMailEP -> getUserProfile(userId);
    match profile {
        UserProfile p => test:assertTrue(p.emailAddress != null, msg = "Get User Profile failed");
        GMailError e => test:assertFail(msg = e.errorMessage);
    }
}

function setConfParams(string|() confParam) returns string {
    match confParam {
        string param => {
            return param;
        }
        () => {
            log:printInfo("Empty value, found nil!!");
            return "";
        }
    }
}
