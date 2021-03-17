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
import ballerina/lang.array;
import ballerinax/googleapis_gmail as gmail;

# Listener to observe changes in mailbox.   
public class Listener {
    private string startHistoryId = "";
    private string userId = ME;
    private json requestBody;
    private gmail:Client gmailClient;
    private http:Listener httpListener;

    public isolated function init(int port, gmail:Client gmailClient, json requestBody) {
        self.httpListener = checkpanic new (port);
        self.gmailClient = gmailClient;
        self.requestBody = requestBody;
    }

    public function attach(service object {} s, string[]|string? name = ()) returns error? {
        gmail:WatchResponse  response = check self.gmailClient->watch(self.userId, self.requestBody);
        self.startHistoryId = response.historyId;
        log:print("Starting History ID: "+ self.startHistoryId);
        return self.httpListener.attach(s, name);
    }

    public isolated function detach(service object {} s) returns error? {
        return self.httpListener.detach(s);
    }

    public isolated function 'start() returns error? {
        return self.httpListener.'start();
    }

    public function gracefulStop() returns error? {
        var response = check self.gmailClient->stop(self.userId);
        log:print("Watch Stopped = "+response.toString());
        return self.httpListener.gracefulStop();
    }

    public isolated function immediateStop() returns error? {
        return self.httpListener.immediateStop();
    }

    public function getMailboxChanges(http:Caller caller, http:Request request) returns gmail:MailboxHistoryPage| error {
        var payload = request.getJsonPayload();
        var response = caller->respond(http:STATUS_OK);
        var  mailboxHistoryPage =  self.gmailClient->listHistory(self.userId, self.startHistoryId);
        if(mailboxHistoryPage is gmail:MailboxHistoryPage) {
            self.startHistoryId = mailboxHistoryPage.historyId;
            log:print("Next History ID = "+self.startHistoryId);
        } else {
            log:printError("Error occured while getting history.",err= mailboxHistoryPage);
        }        
        return mailboxHistoryPage;
    }

    public function getNewEmail(gmail:MailboxHistoryPage mailboxHistoryPage) returns gmail:Message[] | error {
        gmail:Message[] messages = [];
        foreach var history in mailboxHistoryPage.historyRecords {
            gmail:HistoryChange[] messagesAdded = history.messagesAdded;
            if(messagesAdded.length()>0) {
                foreach var messageAdded in messagesAdded {                    
                    gmail:Message message = check self.gmailClient->readMessage(ME, messageAdded.message.id);
                    array:push(messages, message);
                }
            }
        }
        return messages;
    }

    public function getNewThread(gmail:MailboxHistoryPage mailboxHistoryPage) returns gmail:MailThread[] | error {
        gmail:MailThread[] threads = [];
        foreach var history in mailboxHistoryPage.historyRecords {
            gmail:HistoryChange[] messagesAdded = history.messagesAdded;
            if(messagesAdded.length()>0) {
                foreach var messageAdded in messagesAdded {    
                    if(messageAdded.message.id == messageAdded.message.threadId) {               
                        gmail:MailThread thread = check self.gmailClient->readThread(ME, messageAdded.message.threadId);
                        array:push(threads, thread);
                    }
                }
            }
        }
        return threads;
    }

    public function getNewLabeledEmail(gmail:MailboxHistoryPage mailboxHistoryPage) returns LabelChange[] | error {
        LabelChange[] labelchanges = [];
        foreach var history in mailboxHistoryPage.historyRecords {
            gmail:HistoryChange[] labelsAdded = history.labelsAdded;
            if(labelsAdded.length()>0) {
                foreach var labelAdded in labelsAdded {
                    LabelChange labelChangedMsg ={ message: {},changedLabelId: []};
                    labelChangedMsg.changedLabelId = labelAdded.labelIds;
                    gmail:Message message = check self.gmailClient->readMessage(ME, labelAdded.message.id);
                    labelChangedMsg.message = message;
                    array:push(labelchanges, labelChangedMsg);
                }
            }            
        }
        return labelchanges;
    }

    public function getNewStaredEmail(gmail:MailboxHistoryPage mailboxHistoryPage) returns gmail:Message[] | error {
        gmail:Message[] messages = [];
        foreach var history in mailboxHistoryPage.historyRecords {
            gmail:HistoryChange[] labelsAdded = history.labelsAdded;
            if(labelsAdded.length()>0) {
                foreach var labelAdded in labelsAdded {
                    foreach var label in labelAdded.labelIds {
                        match label{
                            STARRED =>{
                                gmail:Message message = check self.gmailClient->readMessage(ME, labelAdded.message.id);
                                array:push(messages, message);
                            }
                        }
                    }
                }
            }            
        }
        return messages;
    }

    public function getLabelRemovedEmail(gmail:MailboxHistoryPage mailboxHistoryPage) returns LabelChange[] | error {
        LabelChange[] labelchanges = [];
        foreach var history in mailboxHistoryPage.historyRecords {
            gmail:HistoryChange[] labelsRemoved = history.labelsRemoved;
            if(labelsRemoved.length()>0) {
                foreach var labelRemoved in labelsRemoved {
                    LabelChange labelChangedMsg ={ message: {},changedLabelId: []};
                    labelChangedMsg.changedLabelId = labelRemoved.labelIds;
                    gmail:Message message = check self.gmailClient->readMessage(ME, labelRemoved.message.id);
                    labelChangedMsg.message = message;
                    array:push(labelchanges, labelChangedMsg);
                }
            }            
        }
        return labelchanges;
    }    

    public function getStarRemovedEmail(gmail:MailboxHistoryPage mailboxHistoryPage) returns gmail:Message[] | error {
        gmail:Message[] messages = [];
        foreach var history in mailboxHistoryPage.historyRecords {
            gmail:HistoryChange[] labelsRemoved = history.labelsRemoved;
            if(labelsRemoved.length()>0) {
                foreach var labelRemoved in labelsRemoved {
                    foreach var label in labelRemoved.labelIds {
                        match label{
                            STARRED =>{
                                gmail:Message message = check self.gmailClient->readMessage(ME, labelRemoved.message.id);
                                array:push(messages, message);
                            }
                        }
                    }
                }
            }            
        }
        return messages;
    }
    
}
