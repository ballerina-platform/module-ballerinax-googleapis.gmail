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

    // The inbox contains customer feedback mail
    gmail:ListMessagesResponse messageList = check gmailClient->/users/me/messages(q = "label:INBOX is:unread");

    // Results from list messages only contains id and threadId.
    string[] ids = [];
    gmail:Message[] messageIds = messageList.messages ?: [];
    foreach gmail:Message message in messageIds {
        ids.push(message.id);

        // Get the full message details
        gmail:Message completeMsg = check gmailClient->/users/me/messages/[message.id](format = "metadata");

        // Get the details of the message
        string? fromAddress = completeMsg.'from;
        string? subject = completeMsg.subject;
        string? messageId = completeMsg.messageId;

        if fromAddress is string {
            // Prepare the thank you message
            gmail:MessageRequest thankYouMessage = {
                to: [fromAddress],
                subject: subject,
                bodyInText: "Dear Customer,\n\nThank you for your valuable feedback.\n\nBest Regards,\nChoreo Team",
                bodyInHtml: "<p>Dear Customer,</p><p>Thank you for your valuable feedback.</p><p>Best Regards,<br>Choreo Team</p>",
                threadId: message.threadId,
                initialMessageId: messageId,
                references: [messageId ?: ""]
            };

            // Send the thank you message
            _ = check gmailClient->/users/me/messages/send.post(thankYouMessage);
        }
    }

    // Mark the messages as read.
    check gmailClient->/users/me/messages/batchModify.post({
        ids: ids,
        removeLabelIds: ["UNREAD"]
    });
}
