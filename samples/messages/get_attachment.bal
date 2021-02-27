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

    log:print("Get an attachment in a sent message");
    // The user's email address. The special value **me** can be ussed to indicate the authenticated user.
    string userId = "me";
    string sentHtmlMessageId = "177dbb1f5fda1bd2";
    string readAttachmentFileId;

    // To read the attachment you should first obtain the attachment file ID 
    gmail:Message|error readResponse = gmailClient->readMessage(userId, sentHtmlMessageId);
    
    if (readResponse is gmail:Message) {
       if (readResponse.msgAttachments.length() >= 1) {
            log:print("Meesage information retrived");
            readAttachmentFileId = readResponse.msgAttachments[0]?.fileId;

            // Now we can fetch the attachment using the above attachment ID
            gmail:MessageBodyPart|error response = gmailClient->getAttachment(userId, sentHtmlMessageId, 
                readAttachmentFileId);
            if (response is gmail:MessageBodyPart) {
                boolean status = (response.fileId == "" && response.body == "") ? false : true;
                log:print("Attachment retrived ", status = status);
            } else {
                log:printError("Failed to get the attachments");
            }
       } else {
            log:print("No attachment exists for this message");
       }
    } else {
        log:print("Failed to get the message");
    }

    
    log:print("End!");
}
