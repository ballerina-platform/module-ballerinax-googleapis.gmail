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

gmail:GmailConfiguration gmailConfig = {
    oauthClientConfig: {
        refreshUrl: gmail:REFRESH_URL,
        refreshToken: os:getEnv("REFRESH_TOKEN"),
        clientId: os:getEnv("CLIENT_ID"),
        clientSecret: os:getEnv("CLIENT_SECRET")
    }
};

gmail:Client gmailClient = check new(gmailConfig);
    
    log:printInfo("List the profile history");
    
    // TO get the history ID we have to get the history ID referring to message response.
    string sentMessageId = "<MESSAGE_ID>";

    // This operation returns history records after the specified `startHistoryId`. The supplied startHistoryId should be 
    // obtained from the historyId of a message, thread, or previous list response.
    string startHistoryId;
    var response = gmailClient->readMessage(sentMessageId);

    if (response is gmail:Message) {

        startHistoryId = response?.historyId is string ? <string>response?.historyId : "" ;
        
        // History types to be returned by the function
        string[] historyTypes = ["labelAdded", "labelRemoved", "messageAdded", "messageDeleted"];

        stream<gmail:History,error?>|error listHistoryResponse = gmailClient->listHistory(startHistoryId, 
                                                                                      historyTypes = historyTypes);

        if (listHistoryResponse is stream<gmail:History,error?>) {
            error? e = listHistoryResponse.forEach(function (gmail:History history) {
                log:printInfo(history.toString());
            });    
        } else {
            log:printError("Failed to list user profile history");
        }
    } else {
        log:printError("Failed to read message");
    }

    log:printInfo("End!");
}
