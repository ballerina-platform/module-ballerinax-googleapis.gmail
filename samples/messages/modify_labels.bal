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

    log:print("Modify labels of a HTML message");
    // The user's email address. The special value **me** can be ussed to indicate the authenticated user.
    string userId = "me";
    string sentMessageId = "177dbb1f5fda1bd2";

    string[] labelsToAdd = ["INBOX"];
    string[] labelsToRemove = ["INBOX"];

    log:print("Add Labels");
    var response = gmailClient->modifyMessage(userId, sentMessageId, labelsToAdd, []);
    if (response is gmail:Message) {
        log:print("Is lablel modified: ", status = response.id == sentMessageId);
    } else {
        log:printError("Failed to modify the labels");
    }

    log:print("Remove Labels");
    response = gmailClient->modifyMessage(userId, sentMessageId, [], labelsToRemove);
    if (response is gmail:Message) {
        log:print("Is lablel modified: ", ststus = response.id == sentMessageId);
    } else {
        log:printError("Failed to modify the labels");
    }
    log:print("End!");
}
