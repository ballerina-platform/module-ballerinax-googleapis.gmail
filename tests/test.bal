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

package tests;

import ballerina/io;
import gmail;
import ballerina.user;

public function main (string[] args) {
    gmail:GmailClientConnector gs = {};
    gs.init(args[0], args[1], args[2], args[3]);
    //-----Define the email parameters------
    string recipient = "recipient@gmail.com";
    string sender = "sender@gmail.com";
    string cc = "cc@gmail.com";
    string subject = "Email-Subject";
    string messageBody = "";
    string userId = "me";
    //If you are sending an inline image, create a html body email and put the image into the body by using <img> tag.
    //Give the src value as "cid:image-<Your image name with extension>".
    string htmlBody = "<h1> Hello </h1> <br/> <img src=\"cid:image-Picture2.jpg\">";
    gmail:MessageOptions options = {};
    options.sender = sender;
    // options.cc = cc;
    gmail:Message message = gs.createMessage(recipient, subject, messageBody, options);
    boolean htmlSetStatus;
    match message.setContent(htmlBody, "text/html") {
        boolean b => htmlSetStatus = b;
        gmail:GmailError er => io:println(er);
        io:IOError ioError => io:println(ioError);
    }
    if (htmlSetStatus) {
        boolean imgInlineSetStatus;
        match message.setContent("/home/Picture2.jpg", "image/jpeg") {
            boolean b => imgInlineSetStatus = b;
            gmail:GmailError er => io:println(er);
            io:IOError ioError => io:println(ioError);
        }
    }
    var attachStatus = message.addAttachment("/home/hello.txt", "text/plain");
    string messageId;
    string threadId;
    match message.sendMessage(userId) {
        (string, string) sendStatus => (messageId, threadId) = sendStatus;
        gmail:GmailError e => io:println(e);
    }
    io:println("---------Send Mail Response---------");
    io:println("Message Id : " + messageId);
    io:println("Thread Id : " + threadId);
    io:println("---------List All Mails with Label INBOX without including Spam and Trash---------");
    json[] msgs;
    string token;
    string estimateSize;
    match gs.listAllMails(userId, "false", "INBOX", "", "", "") {
        (json[], string, string) response => {
            (msgs, token, estimateSize) = response;
            io:println("Msg List : ");
            io:println(msgs);
            io:println("Next Page Toke : " + token);
            io:println("Estimated Size : " + estimateSize);
        }
        gmail:GmailError e => io:println(e);
    }
}