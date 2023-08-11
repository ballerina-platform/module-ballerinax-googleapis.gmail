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
import ballerinax/googleapis.gmail as gmail;

public function main() returns error? {

gmail:ConnectionConfig gmailConfig = {
    auth: {
        refreshUrl: gmail:REFRESH_URL,
        refreshToken: os:getEnv("REFRESH_TOKEN"),
        clientId: os:getEnv("CLIENT_ID"),
        clientSecret: os:getEnv("CLIENT_SECRET")
    }
};

gmail:Client gmailClient = check new(gmailConfig);

    log:printInfo("Get an attachment in a sent message");

    // ID of the message where the attachment belongs to.
    string sentHtmlMessageId = "<MESSAGE_ID>"; 

    // ID of the attachment
    string readAttachmentFileId;

    // To read the attachment you should first obtain the attachment file ID 
    gmail:Message|error readResponse = gmailClient->readMessage(sentHtmlMessageId);
    
    if (readResponse is gmail:Message) {
        log:printInfo("Meesage information retrieved");
        if (readResponse?.msgAttachments is gmail:MessageBodyPart[]) {
            gmail:MessageBodyPart[] msgAttachments = <gmail:MessageBodyPart[]>readResponse?.msgAttachments;
            readAttachmentFileId = msgAttachments[0]?.fileId is string ? <@untainted>(<string>msgAttachments[0]?.fileId)
                                    : readAttachmentFileId;
            gmail:MessageBodyPart|error response = gmailClient->getAttachment(sentHtmlMessageId, 
                readAttachmentFileId);
            if (response is gmail:MessageBodyPart) {
                log:printInfo("Attachment " + response.toString());
            } else {
                log:printError("Failed to get the attachments : "+ response.message());
            }
        } else {
            log:printInfo("No attachment exists for this message");
        }
    } else {
        log:printInfo("Failed to get the message");
    }

    
    log:printInfo("End!");
}
