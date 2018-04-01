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

package test;

import ballerina/io;
import ballerina/net.http;
import ballerina/test;
import ballerina/lang.system;

string userId = system:getEnv("USER_ID");
string accessToken = system:getEnv("ACCESS_TOKEN");
string refreshToken = system:getEnv("REFRESH_TOKEN");
string clientId = system:getEnv("CLIENT_ID");
string clientSecret = system:getEnv("CLIENT_SECRET");
string recipientAddress = system:getEnv("RECIPIENT_ADDRESS");

endpoint gmail:GmailEndpoint gmailEP {
    oauthClientConfig:{
                          accessToken:accessToken,
                          clientId:clientId,
                          clientSecret:clientSecret,
                          refreshToken:refreshToken,
                          refreshTokenEP:gmail:REFRESH_TOKEN_EP,
                          refreshTokenPath:gmail:REFRESH_TOKEN_PATH,
                          baseUrl:gmail:BASE_URL,
                          clientConfig:{}
                      }
};

@test:Config
function testCreateSimpleMail () {
    //Create a simple mail with text content
    io:println("gmailEP -> createMessage()");
    //-----Define the email parameters------
    string recipient = recipientAddress;
    string sender = userId;
    string cc = userId;
    string bcc = userId;
    string subject = "Test subject 1";
    string messageBody = "Test Message 1";
    string userId = "me";
    gmail:MessageOptions options = {};
    options.sender = sender;
    options.cc = cc;
    options.bcc = bcc;
    gmail:Message message = gmailEP -> createMessage(recipient, subject, messageBody, options);
    test:assertEquals(message.headerTo, {name:"To", value:recipient}, msg = "Create message failed");
    test:assertEquals(message.headerSubject, {name:"Subject", value:subject}, msg = "Create message failed");
    test:assertEquals(message.headerFrom, {name:"From", value:options.sender}, msg = "Create message failed");
    test:assertEquals(message.headerCc, {name:"cc", value:options.cc}, msg = "Create message failed");
    test:assertEquals(message.headerBcc, {name:"Bcc", value:options.bcc}, msg = "Create message failed");
}

@test:Config
function testSendSimpleMail () {
    //Send a simple mail with text content
    io:println("gmailEP -> createMessage()");
    //-----Define the email parameters------
    string recipient = recipientAddress;
    string sender = userId;
    string cc = userId;
    string bcc = userId;
    string subject = "Test subject 1";
    string messageBody = "Test Message 1";
    string userId = "me";
    gmail:MessageOptions options = {};
    options.sender = sender;
    options.cc = cc;
    options.bcc = bcc;
    gmail:Message message = gmailEP -> createMessage(recipient, subject, messageBody, options);
    //----Send the mail----
    io:println("gmailEP -> sendMessage()");
    var sendMessageResponse = gmailEP -> sendMessage(userId, message);
    match sendMessageResponse {
        (string, string) sendStatus => (messageId, threadId) = sendStatus;
        gmail:GmailError e => test:assertFail(msg = e.errorMessage);
    }
    test:assertTrue(messageId != null, msg = "Send Simple text Message Failed");
}
