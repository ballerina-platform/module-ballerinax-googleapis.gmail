// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import ballerina/io;
import ballerina/os;
import ballerinax/googleapis.gmail;

configurable string refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");

public function main() returns error? {
    gmail:Client gmailClient = check new gmail:Client({
        auth: {
            refreshToken: refreshToken,
            clientId: clientId,
            clientSecret: clientSecret
        }
    });

    gmail:MessageListPage messageList = check gmailClient->/users/me/messages(q = "label:INBOX is:unread");

    // Results from list messages only contains id and threadId.
    gmail:Message[] messageIds = messageList.messages ?: [];

    string[] ids = [];
    gmail:Message[] completeMessages = [];
    foreach gmail:Message message in messageIds {
        gmail:Message completeMsg = check gmailClient->/users/me/messages/[message.id](format = "full");
        ids.push(message.id);
        completeMessages.push(completeMsg);
    }

    string[][] processedData = from gmail:Message message in completeMessages
        select [message.'from ?: "No From Address", message.subject ?: "No Subject"];

    // Write the data to a csv file.
    check io:fileWriteCsv("feedback.csv", processedData, io:APPEND);

    // Mark the messages as read.
    check gmailClient->/users/me/messages/batchModify.post({
        ids: ids,
        removeLabelIds: ["UNREAD"]
    });
}
