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

endpoint Client gMailEP {
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
string sentHtmlMailId;
//Attachment id of attachment which will be sent from testSendWithAttachment()
string readAttachmentFileId;

@test:Config {
    groups:["TextMailTestGroup"]
}
function testSendTextMail() {
    string subject = "Text-Email-Subject";
    string messageBody = "Text Message Body";
    MessageOptions options = {};
    options.sender = sender;
    options.cc = cc;
    Message m = new Message();
    log:printInfo("testSendHTMLMail");
    log:printInfo("createTextMessage()");
    m.createTextMessage(recipient, subject, messageBody, options);
    log:printInfo("addAttachment()");
    match m.addAttachment(attachmentPath, attachmentContentType) {
        GMailError e => test:assertFail(msg = e.errorMessage);
        () => {
            log:printInfo("gMailEP -> sendMessage()");
            var sendMessageResponse = gMailEP -> sendMessage(userId, m);
            string messageId;
            string threadId;
            match sendMessageResponse {
                (string, string)sendStatus => {
                    (messageId, threadId) = sendStatus;
                    sentTextMailId = messageId;
                    sentTextMailThreadId = threadId;
                    test:assertTrue(messageId != () && threadId != (), msg = "Send Text Message Failed");
                }
                GMailError e => test:assertFail(msg = e.errorMessage);
            }
        }
    }
}

@test:Config {
    groups:["htmlMailTestGroup"]
}
function testSendHTMLMail() {
    string subject = "HTML-Email-Subject";
    MessageOptions options = {};
    options.sender = sender;
    options.cc = cc;
    Message m = new Message();
    string htmlBody = "<h1> Email Test HTML Body </h1> <br/> <img src=\"cid:image-" + inlineImageName + "\">";
    InlineImage[] images = [{imagePath:inlineImagePath, contentType:imageContentType}];
    log:printInfo("testSendHTMLMail");
    log:printInfo("createHTMLMessage()");
    match m.createHTMLMessage(recipient, subject, htmlBody, options, images){
        GMailError e => test:assertFail(msg = e.errorMessage);
        () => {
            log:printInfo("addAttachment()");
            match m.addAttachment(attachmentPath, attachmentContentType) {
                GMailError e => test:assertFail(msg = e.errorMessage);
                () => {
                    //----Send the mail----
                    log:printInfo("gMailEP -> sendMessage()");
                    var sendMessageResponse = gMailEP -> sendMessage(userId, m);
                    string messageId;
                    string threadId;
                    match sendMessageResponse {
                        (string, string)sendStatus => {
                            (messageId, threadId) = sendStatus;
                            sentHtmlMailId = messageId;
                            test:assertTrue(messageId != () && threadId != (), msg = "Send HTML message failed");
                        }
                        GMailError e => test:assertFail(msg = e.errorMessage);
                    }
                }
            }
        }
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
    dependsOn:["testSendTextMail"],
    groups:["TextMailTestGroup"]
}
function testReadTextMail() {
    //Read mail with message id which sent in testSendSimpleMail
    log:printInfo("testReadTextMail");
    log:printInfo("gMailEP -> readMail()");
    GetMessageThreadFilter filter = {format:FORMAT_FULL, metadataHeaders:[]};
    var reponse = gMailEP -> readMail(userId, sentHtmlMailId, filter);
    match reponse {
        Message m => test:assertEquals(m.id, sentHtmlMailId, msg = "Read text mail failed");
        GMailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    dependsOn:["testSendHTMLMail"],
    groups:["htmlMailTestGroup"]
}
function testReadHTMLMailWithAttachment() {
    //Read mail with message id which sent in testSendWithAttachment
    log:printInfo("testReadMailWithAttachment");
    log:printInfo("gMailEP -> readMail()");
    GetMessageThreadFilter filter = {format:FORMAT_FULL, metadataHeaders:[]};
    var response = gMailEP -> readMail(userId, sentHtmlMailId, filter);
    match response {
        Message m => {
            readAttachmentFileId = m.msgAttachments[0].attachmentFileId;
            test:assertEquals(m.id, sentHtmlMailId, msg = "Read mail with attachment failed");
        }
        GMailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    dependsOn:["testReadHTMLMailWithAttachment"],
    groups:["htmlMailTestGroup"]
}
function testgetAttachment() {
    log:printInfo("testgetAttachment");
    log:printInfo("gMailEP -> getAttachment()");
    var attachment = gMailEP -> getAttachment(userId, sentHtmlMailId, readAttachmentFileId);
    match attachment {
        GMailError e => test:assertFail(msg = e.errorMessage);
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
    groups:["TextMailTestGroup"]
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
    groups:["TextMailTestGroup"]
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
    groups:["TextMailTestGroup"]
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
    groups:["TextMailTestGroup"]
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
        UserProfile p => test:assertTrue(p.emailAddress != (), msg = "Get User Profile failed");
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
