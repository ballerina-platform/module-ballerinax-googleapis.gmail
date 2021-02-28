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

    log:print("Read one thread");
    // The user's email address. The special value **me** can be used to indicate the authenticated user.
    string userId = "me";
    string sentTextMessageThreadId = "1771425e9e59ea6b";

    // When given and format is METADATA, only include headers specified. Here, it will specify "Subject"
    gmail:MailThread|error thread = gmailClient->readThread(userId, sentTextMessageThreadId, 
        format = gmail:FORMAT_METADATA, metadataHeaders = ["Subject"]);
        
    if (thread is gmail:MailThread) {
        log:print("Thread obtained: ", status = thread.id == sentTextMessageThreadId);
    } else {
        log:print("Failed to get thread");
    }

    log:print("End!");
}
