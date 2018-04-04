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
import ballerina/test;
import gmail;

endpoint gmail:GmailEndpoint gmailEP {
    oauthClientConfig:{
        accessToken:"ya29.GluTBSRVT8tE0WPaKvMgk4j8h-vvSVzhoX9ekRb19MTYC0tA0a0i6_G4254rgc7-ot9yq9Cx3j3g3JiejD3E1w5bR6K_1qxeHHt9PQN1szxZgyu2AQ6G1utoSlm7",
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
//Message id of mail with attachment which will be sent from testSendWithAttachment()
string sentAttachmentMailId;
//Attachment id of attachment which will be sent from testSendWithAttachment()
string readAttachmentFileId;

function createMail() {
    message = {};
    //Create a simple mail with text content
    io:println("gmailEP -> createMessage()");
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
    before:"createMail"
}
function testSendSimpleMail() {
    //Send a simple mail with text content
    io:println("gmailEP -> sendMessage()");
    var sendMessageResponse = gmailEP -> sendMessage(userId, message);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string)sendStatus => {(messageId, threadId) = sendStatus;
        sentTextMailId = messageId;
        sentTextMailThreadId = threadId;
        test:assertTrue(messageId != null && threadId != null, msg = "Send Simple text Message Failed");
        }
        gmail:GmailError e => {io:println(e);test:assertFail(msg = e.errorMessage);}
    }

}

@test:Config {
    before:"createMail"
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
    io:println("gmailEP -> sendMessage()");
    string messageId;
    string threadId;
    var sendMessageResponse = gmailEP -> sendMessage(userId, message);
    match sendMessageResponse {
        (string, string)sendStatus => {(messageId, threadId) = sendStatus;
        test:assertTrue(messageId != null && threadId != null, msg = "Send HTML message failed");
        }
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    before:"createMail"
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
        boolean imgInlineSetStatus => test:assertTrue(imgInlineSetStatus, msg = "Set Html Content and inline image Failed");
        gmail:GmailError er => test:assertFail(msg = er.errorMessage);
    }
    //----Send the mail----
    io:println("gmailEP -> sendMessage()");
    var sendMessageResponse = gmailEP -> sendMessage(userId, message);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string)sendStatus => {(messageId, threadId) = sendStatus;
        test:assertTrue(messageId != null && threadId != null, msg = "Send HTML message failed");
        }
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    before:"createMail"
}
function testSendWithAttachment() {
    //Send a mail with text content and attachment
    //----Add Attachment----
    match message.addAttachment("/home/dushaniw/hello.txt", "text/plain") {
        boolean attachStatus => test:assertTrue(attachStatus, msg = "Add attachment Failed");
        io:IOError er => test:assertFail(msg = er.message);
    }
    //----Send the mail----
    io:println("gmailEP -> sendMessage()");
    var sendMessageResponse = gmailEP -> sendMessage(userId, message);
    string messageId;
    string threadId;
    match sendMessageResponse {
        (string, string)sendStatus => {(messageId, threadId) = sendStatus;
        sentAttachmentMailId = messageId;
        test:assertTrue(messageId != null && threadId != null, msg = "Send HTML message with attachment failed");
        }
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    before:"createMail"
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
    io:println("gmailEP -> sendMessage()");
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
    io:println("gmailEP -> listAllMails()");
    SearchFilter filter = {includeSpamTrash:false, labelIds:["INBOX"], maxResults:"", pageToken:"", q:""};
    var msgList = gmailEP -> listAllMails("me", filter);
    match msgList {
        gmail:MessageListPage list => test:assertTrue(lengthof list.messages != 0, msg = "List messages in inbox failed");
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    dependsOn:["testSendSimpleMail"]
}
function testReadTextMail() {
    //Read mail with message id which sent in testSendSimpleMail
    io:println("gmailEP -> ReadMail()");
    gmail:GetMessageThreadFilter filter = {format:gmail:FORMAT_FULL, metadataHeaders:[]};
    var mail = gmailEP -> readMail(userId, sentTextMailId, filter);
    match mail {
        gmail:Message m => test:assertEquals(m.id, sentTextMailId, msg = "Read text mail failed");
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    dependsOn:["testSendWithAttachment"]
}
function testReadMailWithAttachment() {
    //Read mail with message id which sent in testSendWithAttachment
    io:println("gmailEP -> ReadMail()");
    gmail:GetMessageThreadFilter filter = {format:gmail:FORMAT_FULL, metadataHeaders:[]};
    var mail = gmailEP -> readMail(userId, sentAttachmentMailId, filter);
    match mail {
        gmail:Message m => { readAttachmentFileId = m.msgAttachments[0].attachmentFileId;
                            test:assertEquals(m.id, sentAttachmentMailId, msg = "Read mail with attachment failed");
        }
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    dependsOn:["testReadMailWithAttachment"]
}
function testgetAttachment() {
    var attachment = gmailEP -> getAttachment(userId, sentAttachmentMailId, readAttachmentFileId);
    match attachment {
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
        gmail:MessageAttachment attach => test:assertEquals(attach.attachmentFileId, readAttachmentFileId, msg = "Get Attachment failed");

    }
}

@test:Config{
    dependsOn:["testReadTextMail"]
}
function testTrashMail () {
    //Trash mail with message id 1628c6e29f2fef47
    io:println("gmailEP -> TrashMail()");
    var trash = gmailEP -> trashMail(userId, sentTextMailId);
    match trash {
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
        boolean success => test:assertTrue(success, msg = "Trash mail failed");
    }
}

@test:Config {
    dependsOn:["testTrashMail"]
}
function testUntrashMail() {
    var untrash = gmailEP -> untrashMail(userId, sentTextMailId);
    match untrash {
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
        boolean success => test:assertTrue(success, msg = "Untrash mail failed");
    }
}

@test:Config {
    dependsOn:["testUntrashMail"]
}
function testDeleteMail() {
    var delete = gmailEP -> deleteMail(userId, sentTextMailId);
    match delete {
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
        boolean success => test:assertTrue(success, msg = "Delete mail failed");
    }
}

@test:Config
function testListAllThreads() {
    var threadList = gmailEP -> listThreads(userId, {includeSpamTrash:false, labelIds:["INBOX"], maxResults:"", pageToken:"", q:""});
    match threadList {
        gmail:ThreadListPage list => test:assertTrue(lengthof list.threads != 0, msg = "List threads in inbox failed");
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config
function testReadThread() {
    gmail:GetMessageThreadFilter filter = {format:gmail:FORMAT_METADATA, metadataHeaders:["Subject"]};
    var thread = gmailEP -> readThread(userId, sentTextMailThreadId, filter);
    match thread{
        gmail:Thread t => test:assertEquals(t.id, sentTextMailThreadId, msg = "Read thread failed");
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
    }
}

@test:Config {
    dependsOn:["testReadThread"]
}
function testTrashThread() {
    var trash = gmailEP -> trashThread(userId, sentTextMailThreadId);
    match trash {
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
        boolean success => test:assertTrue(success, msg = "Trash thread failed");
    }
}

@test:Config {
    dependsOn:["testTrashThread"]
}
function testUnTrashThread() {
    var untrash = gmailEP -> untrashThread(userId, sentTextMailThreadId);
    match untrash {
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
        boolean success => test:assertTrue(success, msg = "Untrash thread failed");

    }
}

@test:Config {
    dependsOn:["testUnTrashThread"]
}
function testDeleteThread() {
    var delete = gmailEP -> deleteThread(userId, sentTextMailThreadId);
    match delete {
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
        boolean success => test:assertTrue(success, msg = "Delete thread failed");
    }
}

@test:Config
function testgetUserProfile() {
    var profile = gmailEP -> getUserProfile(userId);
    match profile {
        gmail:UserProfile p => test:assertTrue(p.emailAddress != null, msg = "Get User Profile failed");
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
    }
}