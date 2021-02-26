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

    log:print("Trash and Untrash thread");
    // The user's email address. The special value **me** can be ussed to indicate the authenticated user.
    string userId = "me";
    string sentTextMessageThreadId = "1771425e9e59ea6b";

    log:print("Trash thread");
    var trash = gmailClient->trashThread(userId, sentTextMessageThreadId);
    if (trash is error) {
        log:printError("Failed to trash the thread");
    } else {
        log:print("Successfully trashed the message: ", result = trash);
    }

    log:print("Untrash thread");
    var untrash = gmailClient->untrashThread(userId, sentTextMessageThreadId);
    if (untrash is error) {
        log:printError("Failed to trash the thread");
    } else {
        log:print("Successfully untrashed the message: ", result = untrash);
    }
    
    log:print("End!");
}
