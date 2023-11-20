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

    gmail:Client gmailClient = check new gmail:Client(
        config = {
            auth: {
                refreshToken,
                clientId,
                clientSecret
            }
        }
    );

    // Search query string
    string query = "setup database";

    gmail:ListThreadsResponse threadListPage = check gmailClient->/users/me/threads(q = query, maxResults = 10);

    // List of threads only has id and threadId. To get the messages, we need to get the thread details.
    gmail:MailThread[]? resultThreads = threadListPage.threads;
    if resultThreads is gmail:MailThread[] {
        string[] threadIds = from gmail:MailThread thread in resultThreads
            select thread.id ?: "";

        foreach string threadId in threadIds {
            gmail:MailThread mailThread = check gmailClient->/users/me/threads/[threadId]();
            gmail:Message[] messages = mailThread.messages ?: [];
            if messages.length() > 0 {
                io:println(string `Subject: ${messages[0].subject ?: ""}`);
                io:println(string `Snippet: ${messages[0].snippet ?: ""}`);
            }
        }
    }
}

