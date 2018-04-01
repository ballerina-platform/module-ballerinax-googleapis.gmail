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
import oauth2;

public function main (string[] args) {
    endpoint gmail:GmailEndpoint gmailEP {
        oauthClientConfig:{
                              accessToken:"ya29.GluQBQD3Ve0O1Eu5g1t0n6mBYsQ0zxcTkt2dAWoL00Q7gG-z-8fx3tRAFoSJQ0KM88N8s8coklYV8p0AC0s-NeSd0ukU3J1aLL93xTNg1zRZPdSz56voU8ev5yxM",
                              clientId:"297850098219-dju3ruvd8c7c11lluhjav55d1rr25asa.apps.googleusercontent.com",
                              clientSecret:"CITYfRtibqMi0kndYsnIjJTL",
                              refreshToken:"1/y-Xi70VN_oijQW5L38tOyLHIP8SIC2oQU1KU5WXg5PM",
                              refreshTokenEP:gmail:REFRESH_TOKEN_EP,
                              refreshTokenPath:gmail:REFRESH_TOKEN_PATH,
                              baseUrl:gmail:BASE_URL,
                              clientConfig:{}
                          }
    };
    //-----Define the email parameters------
    //string recipient = "recipient@gmail.com";
    //string sender = "sender@gmail.com";
    string recipient = "dushaniw@wso2.com";
    string sender = "dushaniwellappili@gmail.com";

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

    gmail:Message message = gmailEP -> createMessage(recipient, subject, messageBody, options);

    boolean htmlSetStatus;
    match message.setContent(htmlBody, "text/html") {
        boolean b => htmlSetStatus = b;
        gmail:GmailError er => io:println(er);
    }
    if (htmlSetStatus) {
        boolean imgInlineSetStatus;
        match message.setContent("/home/dushaniw/Picture2.jpg", "image/jpeg") {
            boolean b => imgInlineSetStatus = b;
            gmail:GmailError er => io:println(er);
        }
    }
    var attachStatus = message.addAttachment("/home/dushaniw/hello.txt", "text/plain");
    string messageId;
    string threadId;
    //var sendMessageResponse = gmailEP -> sendMessage(userId, message);
    //match sendMessageResponse {
    //    (string, string) sendStatus => (messageId, threadId) = sendStatus;
    //    gmail:GmailError e => io:println(e);
    //}
    io:println("---------Send Mail Response---------");
    io:println("Message Id : " + messageId);
    io:println("Thread Id : " + threadId);
    io:println("---------List All Mails with Label INBOX without including Spam and Trash---------");
    var msgList = gmailEP -> listAllMails(userId, {includeSpamTrash:false, labelIds:["INBOX"], maxResults:"1", pageToken:"", q:""});
    match msgList {
        gmail:MessageListPage list => { io:println("Msg List : ");
                                        io:print(lengthof list.messages);
                                        io:println("Next Page Toke : " + list.nextPageToken);
                                        io:println("Estimated Size : " + list.resultSizeEstimate);
        }
        gmail:GmailError e => io:println(e);

    }
    io:println("---------Read mail---------");
    //gmail:GetMessageThreadFilter filter = {format:"",metadataHeaders:[]};
    //var mail = gmailEP -> readMail(userId, "16260600f9edd702",filter);
    //match mail{
    //    gmail:Message m => {//io:println(m);
    //                        io:println(m.plainTextBodyPart.body);
    //                        io:println(m.htmlBodyPart.body);
    //                        //io:println(m.inlineImgParts);
    //                        //io:println(m.msgAttachments);
    //                        }
    //    gmail:GmailError e => io:println(e);
    //}
    io:println("---------Trash Mail------------");
    //var trash = gmailEP -> trashMail(userId, "1627f235d4600fe7");
    //match trash {
    //    gmail:GmailError e => io:println(e);
    //    boolean success => {io:println("Trash Message Success: ");
    //                        io:print(success);
    //    }
    //}
    io:println("---------UnTrash Mail------------");
    //var untrash = gmailEP -> untrashMail(userId, "1627f235d4600fe7");
    //match untrash {
    //    gmail:GmailError e => io:println(e);
    //    boolean success => {io:println("UnTrash Message Success: ");
    //                        io:print(success);
    //    }
    //}
    io:println("---------Delete Mail------------");
    //var delete = gmailEP -> deleteMail(userId, "16280d17b1678941");
    //match delete {
    //    gmail:GmailError e => io:println(e);
    //    boolean success => {io:println("Delete Message Success: ");
    //                        io:print(success);
    //    }
    //}
    io:println("----------Get Message Attachment----------");
    //var attachment = gmailEP -> getAttachment(userId, "16281ac6b5e5388d", "ANGjdJ-n7Wf1WGO2DnfDb_q0Vv9ZtZ5jo0VE5VzrSO9_hZNeqKQLS4GeNea5pf3lazFY4Jkmk0qRlPeAEVBUA_LUXWbX-k70co9kdsZsa0yZQO-RHuDGAWDf4mGGyQ7t4zFV2eEyvXwR2Dsf9bYYS3gK_Xcx9vqtIxr5Dg2cs5T1zzbODjjG6kqNzVwYyow8Axxhe1Fajk-RIGxnF2EStoz-o1cFCufHreDQz75sDq9sa6quHSQe8_xX5CpJn4NpXw7OBG1BKJ6vQLa_zmpnfvNY9vElQXTni10iZ7QVIy2jMbWSWG82lTQrBMn4EKcMXjdGRz4yKSIKR1s9TLTlQIIHoCOdk_kiFWCS3F5ElT-pn-AsxQjBPYg9zb9iscDTXVTAK9bZdgKukIWFjzT0");
    //match attachment {
    //    gmail:GmailError e => io:println(e);
    //    gmail:MessageAttachment attach => {io:println("Get Attachment: ");
    //                                       io:print(attach);
    //    }
    //}
    io:println("---------List All Threads with Label INBOX without including Spam and Trash---------");
    var threadList = gmailEP -> listThreads(userId, {includeSpamTrash:false, labelIds:["INBOX"], maxResults:"1", pageToken:"", q:"from:(dushaniw@wso2.com) subject:atttachment"});
    match threadList {
        gmail:ThreadListPage list => { io:println("Thread List : ");
                                        io:print(lengthof list.threads);
                                        io:println("Next Page Toke : " + list.nextPageToken);
                                        io:println("Estimated Size : " + list.resultSizeEstimate);
        }
        gmail:GmailError e => io:println(e);

    }
    io:println("---------Read Thread---------");
    gmail:GetMessageThreadFilter filter = {format:gmail:FORMAT_METADATA,metadataHeaders:["Authentication-Results"]};
    var thread = gmailEP -> readThread(userId, "16281ac6b5e5388d",filter);
    match thread{
        gmail:Thread t => io:println(t);
        gmail:GmailError e => io:println(e);
    }
    io:println("---------Trash Thread------------");
    //var trash = gmailEP -> trashThread(userId, "16281ac6b5e5388d");
    //match trash {
    //    gmail:GmailError e => io:println(e);
    //    boolean success => {io:println("Trash Thread Success: ");
    //                        io:print(success);
    //    }
    //}
    io:println("---------UnTrash Thread------------");
    //var untrash = gmailEP -> untrashThread(userId, "16281ac6b5e5388d");
    //match untrash {
    //    gmail:GmailError e => io:println(e);
    //    boolean success => {io:println("UnTrash Thread Success: ");
    //                        io:print(success);
    //    }
    //}
    io:println("---------Delete Thread------------");
    //var delete = gmailEP -> deleteThread(userId, "16281ac6b5e5388d");
    //match delete {
    //    gmail:GmailError e => io:println(e);
    //    boolean success => {io:println("Delete Thread Success: ");
    //                        io:print(success);
    //    }
    //}
    io:println("---------User Profile----------");
    var profile = gmailEP -> getUserProfile(userId);
    match profile {
        gmail:UserProfile p => io:println(p);
        gmail:GmailError e => io:println(e);
    }
}