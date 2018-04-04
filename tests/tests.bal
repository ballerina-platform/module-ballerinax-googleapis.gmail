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

package gmail;

import ballerina/io;
import ballerina/http;
import ballerina/log;
import ballerina/test;
import gmail;

endpoint gmail:GmailEndpoint gmailEP {
    oauthClientConfig:{
        accessToken:"ya29.GluTBVFn8kDVYGvYq5Bx-kUWKqtBHLME8g5qbwn_E44WbmUkuTfQujLpSPDOvXytUtF57ZzSf7aJT1qVx631gx33cIuqKPiZAzlZFw7u4AfqpTZongt0N0pQZezC",
        clientId:"297850098219-dju3ruvd8c7c11lluhjav55d1rr25asa.apps.googleusercontent.com",
        clientSecret:"CITYfRtibqMi0kndYsnIjJTL",
        refreshToken:"1/y-Xi70VN_oijQW5L38tOyLHIP8SIC2oQU1KU5WXg5PM",
        refreshTokenEP:gmail:REFRESH_TOKEN_EP,
        refreshTokenPath:gmail:REFRESH_TOKEN_PATH,
        baseUrl:gmail:BASE_URL,
        clientConfig:{}
    }
};

string userId = "me";
gmail:Message message = {};
//Message id of text mail which will be sent from testSendSimpleMail()
string sentTextMailId;
//Thread id of text mail which will be sent from testSendSimpleMail()
string sentTextMailThreadId;
//Mail id of the html mail which will be sent from testSendHtml()
string sentHtmlMailId;
//Message id of mail with attachment which will be sent from testSendWithAttachment()
string sentAttachmentMailId;
//Attachment id of attachment which will be sent from testSendWithAttachment()
string readAttachmentFileId;

function createMail() {
    message = {};
    //Create a simple mail with text content
    log:printInfo("createMessage()");
    //-----Define the email parameters------
    string recipient = "dushaniw@wso2.com";
    string sender = "dushaniwellappili@gmail.com";
    string subject = "Email-Subject";
    string messageBody = "Email Test Body";
    string userId = "me";
    gmail:MessageOptions options = {};
    options.sender = "dushaniwellappili@gmail.com";
    options.cc = "dushani.13@cse.mrt.ac.lk";
    message.createMessage(recipient, subject, messageBody, options);
}

@test:Config {
    before:"createMail",
    groups:["sendMailTestGroup", "simpleTextMailTestGroup"]
}
function testSendSimpleMail() {
    //Send a simple mail with text content
    log:printInfo("testSendSimpleMail");
    log:printInfo("gmailEP -> sendMessage()");
    var sendMessageResponse = gmailEP -> sendMessage(userId, message);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string)sendStatus => {
            (messageId, threadId) = sendStatus;
            sentTextMailId = messageId;
            sentTextMailThreadId = threadId;
            test:assertTrue(messageId != null && threadId != null, msg = "Send Simple text Message Failed");
        }
        gmail:GmailError e => {io:println(e);test:assertFail(msg = e.errorMessage);}
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
    match message.setContent(htmlBody, "text/html") {
        boolean htmlSetStatus => test:assertTrue(htmlSetStatus, msg = "Set Html Content Failed");
        gmail:GmailError er => test:assertFail(msg = er.errorMessage);
    }
    //----Send the mail----
    log:printInfo("testSendHtml");
    log:printInfo("gmailEP -> sendMessage()");
    string messageId;
    string threadId;
    var sendMessageResponse = gmailEP -> sendMessage(userId, message);
    match sendMessageResponse {
        (string, string)sendStatus => {
            (messageId, threadId) = sendStatus;
            sentHtmlMailId = messageId;
            test:assertTrue(messageId != null && threadId != null, msg = "Send HTML message failed");
        }
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
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
    string htmlBody = "<h1> Email Test HTML Body </h1> <br/> <img src=\"cid:image-Picture2.jpg\">";
    match message.setContent(htmlBody, "text/html") {
        boolean htmlSetStatus => test:assertTrue(htmlSetStatus, msg = "Set Html Content Failed");
        gmail:GmailError er => test:assertFail(msg = er.errorMessage);
    }

    match message.setContent("/home/dushaniw/Picture2.jpg", "image/jpeg") {
        boolean imgInlineSetStatus => test:assertTrue(imgInlineSetStatus,
            msg = "Set Html Content and inline image Failed");
        gmail:GmailError er => test:assertFail(msg = er.errorMessage);
    }
    //----Send the mail----
    log:printInfo("testSendHtmlInlineImage");
    log:printInfo("gmailEP -> sendMessage()");
    var sendMessageResponse = gmailEP -> sendMessage(userId, message);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string)sendStatus => {
            (messageId, threadId) = sendStatus;
            test:assertTrue(messageId != null && threadId != null, msg = "Send HTML message failed");
        }
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    before:"createMail",
    groups:["sendMailTestGroup", "mailWithAttachmentTestGroup"]
}
function testSendWithAttachment() {
    //Send a mail with text content and attachment
    //----Add Attachment----
    match message.addAttachment("/home/dushaniw/hello.txt", "text/plain") {
        boolean attachStatus => test:assertTrue(attachStatus, msg = "Add attachment Failed");
        io:IOError er => test:assertFail(msg = er.message);
    }
    //----Send the mail----
    log:printInfo("testSendWithAttachment");
    log:printInfo("gmailEP -> sendMessage()");
    var sendMessageResponse = gmailEP -> sendMessage(userId, message);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string)sendStatus => {
            (messageId, threadId) = sendStatus;
            sentAttachmentMailId = messageId;
            test:assertTrue(messageId != null && threadId != null, msg = "Send HTML message with attachment failed");
        }
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
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
    match message.setContent(htmlBody, "text/html") {
        boolean htmlSetStatus => test:assertTrue(htmlSetStatus, msg = "Set Html Content Failed");
        gmail:GmailError er => test:assertFail(msg = er.errorMessage);
    }
    //----Add Attachment----
    match message.addAttachment("/home/dushaniw/hello.txt", "text/plain") {
        boolean attachStatus => test:assertTrue(attachStatus, msg = "Add attachment Failed");
        io:IOError er => test:assertFail(msg = er.message);
    }
    //----Send the mail----
    log:printInfo("testSendHtmlWithAttachment");
    log:printInfo("gmailEP -> sendMessage()");
    var sendMessageResponse = gmailEP -> sendMessage(userId, message);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string)sendStatus => {(messageId, threadId) = sendStatus;
        test:assertTrue(messageId != null && threadId != null, msg = "Send HTML message with attachment failed");
        }
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config
function testListAllMails() {
    //List All Mails with Label INBOX without including Spam and Trash with subject "Test subject - html mail"
    log:printInfo("testListAllMails");
    log:printInfo("gmaiEP -> listAllMails()");
    gmail:SearchFilter filter = {includeSpamTrash:false, labelIds:["INBOX"], maxResults:"", pageToken:"", q:""};
    var msgList = gmailEP -> listAllMails("me", filter);
    match msgList {
        gmail:MessageListPage list => test:assertTrue(lengthof list.messages != 0,
                                                        msg = "List messages in inbox failed");
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
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
    gmail:GetMessageThreadFilter filter = {format:gmail:FORMAT_FULL, metadataHeaders:[]};
    var mail = gmailEP -> readMail(userId, sentTextMailId, filter);
    match mail {
        gmail:Message m => test:assertEquals(m.id, sentTextMailId, msg = "Read text mail failed");
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
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
    gmail:GetMessageThreadFilter filter = {format:gmail:FORMAT_FULL, metadataHeaders:[]};
    var mail = gmailEP -> readMail(userId, sentAttachmentMailId, filter);
    match mail {
        gmail:Message m => {
            readAttachmentFileId = m.msgAttachments[0].attachmentFileId;
            test:assertEquals(m.id, sentAttachmentMailId, msg = "Read mail with attachment failed");
        }
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
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
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
        gmail:MessageAttachment attach => {
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
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
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
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
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
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
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
        gmail:ThreadListPage list => test:assertTrue(lengthof list.threads != 0, msg = "List threads in inbox failed");
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    dependsOn:["testReadTextMail"],
    groups:["simpleTextMailTestGroup"]
}
function testReadThread() {
    log:printInfo("testReadThread");
    log:printInfo("gmailEP -> readThread()");
    gmail:GetMessageThreadFilter filter = {format:gmail:FORMAT_METADATA, metadataHeaders:["Subject"]};
    var thread = gmailEP -> readThread(userId, sentTextMailThreadId, filter);
    match thread{
        gmail:Thread t => test:assertEquals(t.id, sentTextMailThreadId, msg = "Read thread failed");
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
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
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
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
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
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
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
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
        gmail:UserProfile p => test:assertTrue(p.emailAddress != null, msg = "Get User Profile failed");
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
    }
}
