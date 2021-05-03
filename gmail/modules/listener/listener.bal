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

# Listener for Gmail Connector.
@display {label: "Gmail Listener"} 
public class Listener {
    private string startHistoryId = "";
    private string topicResource = "";
    private string subscriptionResource = "";    
    private string userId = ME;
    private gmail:Client gmailClient;
    private http:Listener httpListener;
    private string project;
    private string pushEndpoint;

    private json requestBody;
    private HttpService httpService;
    http:Client pubSubClient;


    public isolated function init(int port, gmail:GmailConfiguration gmailConfig, string project, string pushEndpoint) 
                                  returns @tainted error? {

        http:ClientSecureSocket? socketConfig = gmailConfig?.secureSocketConfig;
        // Create pubsub http client.
        if (socketConfig is http:ClientSecureSocket) {
            self.pubSubClient = checkpanic new (PUBSUB_BASE_URL, {
                auth: gmailConfig.oauthClientConfig,
                secureSocket: socketConfig
            }); 
        } else {
            self.pubSubClient = checkpanic new (PUBSUB_BASE_URL, {
                auth: gmailConfig.oauthClientConfig
            });
        }                                  
        
        self.httpListener = check new (port);
        //Create gmail client.
        self.gmailClient = new (gmailConfig);     
        self.project = project;
        self.pushEndpoint = pushEndpoint;

        TopicSubscriptionDetail topicSubscriptionDetail = check createTopic(self.pubSubClient, project, pushEndpoint);        
        self.topicResource = topicSubscriptionDetail.topicResource;
        self.subscriptionResource = topicSubscriptionDetail.subscriptionResource;
        self.requestBody = { labelIds: [INBOX], topicName:self.topicResource};
    }

    public isolated function attach(service object {} s, string[]|string? name = ()) returns @tainted error? {
        self.httpService = new HttpService(s,  self.gmailClient,  self.startHistoryId);
        check self.watchMailbox();
        check self.httpListener.attach(self.httpService, name);
        Job job = new (self);
        check job.scheduleNextWatchRenewal();
    }

    public isolated function detach(service object {} s) returns error? {
        return self.httpListener.detach(s);
    }

    public isolated function 'start() returns error? {
        return self.httpListener.'start();
    }

    public isolated function gracefulStop() returns @tainted error? {
        json deleteSubscription = check deletePubsubTopic(self.pubSubClient,self.subscriptionResource);
        json deleteTopic = check deletePubsubTopic(self.pubSubClient, self.topicResource);
        var response = check self.gmailClient->stop(self.userId);
        log:printInfo("Watch Stopped = "+response.toString());
        return self.httpListener.gracefulStop();
    }

    public isolated function immediateStop() returns error? {
        return self.httpListener.immediateStop();
    }

    public isolated function watchMailbox() returns @tainted error? {
        gmail:WatchResponse  response = check self.gmailClient->watch(self.userId, self.requestBody);
        self.startHistoryId = response.historyId;
        log:printInfo("New History ID: "+ self.startHistoryId);
        self.httpService.startHistoryId = self.startHistoryId;
    }    
}
