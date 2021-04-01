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

import ballerina/http;
import ballerina/log;
import ballerinax/googleapis_gmail as gmail;
import ballerinax/googleapis_gmail.'listener as gmailListener;

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable int port = ?;
configurable string topicName = ?;

gmail:GmailConfiguration gmailConfig = {
    oauthClientConfig: {
        refreshUrl: gmail:REFRESH_URL,
        refreshToken: refreshToken,
        clientId: clientId,
        clientSecret: clientSecret
        }
};

gmail:Client gmailClient = new (gmailConfig);

listener gmailListener:Listener gmailEventListener = new(port, gmailClient, topicName);

service / on gmailEventListener {
    resource function post web(http:Caller caller, http:Request req) {
        var payload = req.getJsonPayload();
        var response = gmailEventListener.onMailboxChanges(caller , req);
        if(response is gmail:MailboxHistoryPage) {
            var triggerResponse = gmailEventListener.onNewStaredEmail(response);
            if(triggerResponse is gmail:Message[]) {
                if (triggerResponse.length()>0){
                    //Write your logic here.....
                    foreach var msg in triggerResponse {
                        log:printInfo("Message ID: "+msg.id + " Thread ID: "+ msg.threadId+ " Snippet: "+msg.snippet);
                    }
                }
            }
        }
    }     
}
