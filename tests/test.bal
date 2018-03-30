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
        accessToken:"ya29.GluOBS1ptaY0DOFJSbqyffj5jJobqe6ENdP4mKx8Giup5il2qqKPsnOMTIUzYqu6v7B5A5Jgmo5wsbbarMrGTxtHxxcd6YzC0LbMKrkxeRo22nazZqhIZonX6wYD",
        clientId:"297850098219-dju3ruvd8c7c11lluhjav55d1rr25asa.apps.googleusercontent.com",
        clientSecret:"CITYfRtibqMi0kndYsnIjJTL",
        refreshToken:"1/y-Xi70VN_oijQW5L38tOyLHIP8SIC2oQU1KU5WXg5PM",
        refreshTokenEP:gmail:REFRESH_TOKEN_EP,
        refreshTokenPath:gmail:REFRESH_TOKEN_PATH,
        baseUrl:gmail:BASE_URL,
        clientConfig:{}
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
        io:IOError ioError => io:println(ioError);
    }
    if (htmlSetStatus) {
        boolean imgInlineSetStatus;
        match message.setContent("/home/dushaniw/Picture2.jpg", "image/jpeg") {
            boolean b => imgInlineSetStatus = b;
            gmail:GmailError er => io:println(er);
            io:IOError ioError => io:println(ioError);
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
    var msgList = gmailEP -> listAllMails(userId,{includeSpamTrash:false,labelIds:["INBOX"],maxResults:"1",pageToken:"",q:""});
    //match msgList {
    //    gmail:MessageListPage list => { io:println("Msg List : ");
    //                              io:print(lengthof list.messages);
    //                              io:println("Next Page Toke : " + list.nextPageToken);
    //                              io:println("Estimated Size : " + list.resultSizeEstimate);
    //    }
    //    gmail:GmailError e => io:println(e);
    //
    //}
    io:println("---------Read mail Response---------");
    //gmail:GetMessageFilter filter = {format:"",metadataHeaders:[]};
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
}