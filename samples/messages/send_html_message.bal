// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import ballerina/os;
import ballerinax/googleapis_gmail as gmail;

gmail:GmailConfiguration gmailConfig = {
    oauthClientConfig: {
        refreshUrl: gmail:REFRESH_URL,
        refreshToken: os:getEnv("REFRESH_TOKEN"),
        clientId: os:getEnv("CLIENT_ID"),
        clientSecret: os:getEnv("CLIENT_SECRET")
    }
};

gmail:Client gmailClient = new(gmailConfig);

public function main(string... args) {
    
    log:print("Send a HTML message");
    // The user's email address. The special value **me** can be used to indicate the authenticated user.
    string userId = "me";

    gmail:MessageRequest messageRequest = {};
    messageRequest.recipient = os:getEnv("RECIPIENT"); // Recipient's email address
    messageRequest.sender = os:getEnv("SENDER"); // Sender's email address
    messageRequest.cc = os:getEnv("CC"); // Email address to carbon copy
    messageRequest.subject = "HTML-Email-Subject";
    
    string inlineImagePath = "../resources/test_image.png";
    string inlineImageName = "test_image.png";
    string imageContentType = "image/png";

    string testAttachmentPath = "../resources/test_document.txt";
    string attachmentContentType = "text/plain";
    
    // Set HTML Body
    string htmlBody = "<h1> Email Test HTML Body </h1> <br/> <img src=\"cid:image-" + inlineImageName + "\">";
    messageRequest.messageBody = htmlBody;
    // Set the content type of the mail as TEXT_HTML.
    messageRequest.contentType = gmail:TEXT_HTML;

    // Set Inline Images if exists
    gmail:InlineImagePath[] inlineImages = [{imagePath: inlineImagePath, mimeType: imageContentType}];
    messageRequest.inlineImagePaths = inlineImages;

    // Set Attachments if exists
    gmail:AttachmentPath[] attachments = [{attachmentPath: testAttachmentPath, mimeType: attachmentContentType}];
    messageRequest.attachmentPaths = attachments;

    [string, string]|error sendMessageResponse = gmailClient->sendMessage(userId, messageRequest);
    if (sendMessageResponse is [string, string]) {
        // If successful, print the message ID and thread ID.
        [string, string] [messageId, threadId] = sendMessageResponse;
        log:print("Sent Message ID: ", messageid = messageId);
        log:print("Sent Thread ID: ", threadId = threadId);
    } else {
        // If unsuccessful, print the error returned.
        log:printError("Error: ", err = sendMessageResponse);
    }
    log:print("End!");
}
