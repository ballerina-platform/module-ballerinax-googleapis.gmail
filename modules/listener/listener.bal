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

# Listener for Gmail Connector.   
public class Listener {
    private string startHistoryId = "";
    private string userId = ME;
    private json requestBody;
    private gmail:Client gmailClient;
    private http:Listener httpListener;

    public isolated function init(int port, gmail:Client gmailClient, string topicName) {
        self.httpListener = checkpanic new (port);
        self.gmailClient = gmailClient;
        self.requestBody = { labelIds: [INBOX], topicName:topicName};
    }

    public isolated function attach(service object {} s, string[]|string? name = ()) returns @tainted error? {
        gmail:WatchResponse  response = check self.gmailClient->watch(self.userId, self.requestBody);
        self.startHistoryId = response.historyId;
        log:printInfo("Starting History ID: "+ self.startHistoryId);
        return self.httpListener.attach(s, name);
    }

    public isolated function detach(service object {} s) returns error? {
        return self.httpListener.detach(s);
    }

    public isolated function 'start() returns error? {
        return self.httpListener.'start();
    }

    public isolated function gracefulStop() returns @tainted error? {
        var response = check self.gmailClient->stop(self.userId);
        log:printInfo("Watch Stopped = "+response.toString());
        return self.httpListener.gracefulStop();
    }

    public isolated function immediateStop() returns error? {
        return self.httpListener.immediateStop();
    }

    # Returns MailboxHistoryPage when a change happens in Gmail mailbox.
    # 
    # + caller - http:Caller for acknowleding to the request received
    # + request - http:Request that contains event related data
    # + return - If success, returns MailboxHistoryPage record, else error
    public function onMailboxChanges(http:Caller caller, http:Request request) 
                                        returns @tainted gmail:MailboxHistoryPage| error {
        check caller->respond(http:STATUS_OK);
        var  mailboxHistoryPage =  self.gmailClient->listHistory(self.userId, self.startHistoryId);
        if(mailboxHistoryPage is gmail:MailboxHistoryPage) {
            self.startHistoryId = mailboxHistoryPage.historyId;
            log:printInfo("Next History ID = "+self.startHistoryId);
        } else {
            log:printError("Error occured while getting history.", 'error= mailboxHistoryPage);
        }        
        return mailboxHistoryPage;
    }

    # Returns new messages which are received in Gmail mailbox.
    #
    # + mailboxHistoryPage - MailboxHistoryPage record which is returened in a mailbox change
    # + return - If success, returns array of gmail:Message record, else error
    public function onNewEmail(gmail:MailboxHistoryPage mailboxHistoryPage) returns @tainted gmail:Message[] | error {
        gmail:Message[] messages = [];
        foreach var history in mailboxHistoryPage.historyRecords {
            gmail:HistoryEvent[] messagesAdded = history.messagesAdded;
            if(messagesAdded.length()>0) {
                foreach var messageAdded in messagesAdded {                    
                    gmail:Message message = check self.gmailClient->readMessage(ME, messageAdded.message.id);
                    array:push(messages, message);
                }
            }
        }
        return messages;
    }

    # Returns new mail threads which are received in Gmail mailbox.
    #
    # + mailboxHistoryPage - MailboxHistoryPage record which is returened in a mailbox change
    # + return - If success, returns array of gmail:MailThread record, else error
    public function onNewThread(gmail:MailboxHistoryPage mailboxHistoryPage) returns @tainted gmail:MailThread[] | error {
        gmail:MailThread[] threads = [];
        foreach var history in mailboxHistoryPage.historyRecords {
            gmail:HistoryEvent[] messagesAdded = history.messagesAdded;
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

    # Returns messages when a new label is added to messages.
    #
    # + mailboxHistoryPage - MailboxHistoryPage record which is returened in a mailbox change
    # + return - If success, returns array of ChangedLabel record, else error
    public function onNewLabeledEmail(gmail:MailboxHistoryPage mailboxHistoryPage) returns @tainted ChangedLabel[] | error {
        ChangedLabel[] changedLabels = [];
        foreach var history in mailboxHistoryPage.historyRecords {
            gmail:HistoryEvent[] labelsAdded = history.labelsAdded;
            if(labelsAdded.length()>0) {
                foreach var labelAdded in labelsAdded {
                    ChangedLabel changedLabeldMsg ={ message: {},changedLabelId: []};
                    changedLabeldMsg.changedLabelId = labelAdded.labelIds;
                    gmail:Message message = check self.gmailClient->readMessage(ME, labelAdded.message.id);
                    changedLabeldMsg.message = message;
                    array:push(changedLabels, changedLabeldMsg);
                }
            }            
        }
        return changedLabels;
    }

    # Returns messages when a new star is added to messages.
    #
    # + mailboxHistoryPage - MailboxHistoryPage record which is returened in a mailbox change
    # + return - If success, returns array of gmail:Message record, else error
    public function onNewStaredEmail(gmail:MailboxHistoryPage mailboxHistoryPage) returns @tainted gmail:Message[] | error {
        gmail:Message[] messages = [];
        foreach var history in mailboxHistoryPage.historyRecords {
            gmail:HistoryEvent[] labelsAdded = history.labelsAdded;
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

    # Returns messages when a label is removed from messages.
    #
    # + mailboxHistoryPage - MailboxHistoryPage record which is returened in a mailbox change
    # + return - If success, returns array of ChangedLabel record, else error
    public function onLabelRemovedEmail(gmail:MailboxHistoryPage mailboxHistoryPage) returns @tainted ChangedLabel[] | error {
        ChangedLabel[] changedLabels = [];
        foreach var history in mailboxHistoryPage.historyRecords {
            gmail:HistoryEvent[] labelsRemoved = history.labelsRemoved;
            if(labelsRemoved.length()>0) {
                foreach var labelRemoved in labelsRemoved {
                    ChangedLabel changedLabeldMsg ={ message: {},changedLabelId: []};
                    changedLabeldMsg.changedLabelId = labelRemoved.labelIds;
                    gmail:Message message = check self.gmailClient->readMessage(ME, labelRemoved.message.id);
                    changedLabeldMsg.message = message;
                    array:push(changedLabels, changedLabeldMsg);
                }
            }            
        }
        return changedLabels;
    }    

    # Returns messages when a star is removed from messages.
    #
    # + mailboxHistoryPage - MailboxHistoryPage record which is returened in a mailbox change
    # + return - If success, returns array of gmail:Message record, else error
    public function onStarRemovedEmail(gmail:MailboxHistoryPage mailboxHistoryPage) returns @tainted gmail:Message[] | error {
        gmail:Message[] messages = [];
        foreach var history in mailboxHistoryPage.historyRecords {
            gmail:HistoryEvent[] labelsRemoved = history.labelsRemoved;
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

    # Returns Attchment details when a new attachment is recieved to mailbox.
    #
    # + mailboxHistoryPage - MailboxHistoryPage record which is returened in a mailbox change
    # + return - If success, returns array of gmail:MessageBodyPart record, else error
    public function onNewAttachment(gmail:MailboxHistoryPage mailboxHistoryPage) 
                                        returns @tainted gmail:MessageBodyPart[] |error {
        gmail:MessageBodyPart[] attachments = [];                                  
        var messages = self.onNewEmail(mailboxHistoryPage);        
        if(messages is gmail: Message[]) {
            foreach var message in messages {
                foreach var msgAttachment in message.msgAttachments {
                    gmail:MessageBodyPart attachment = check self.gmailClient->getAttachment(self.userId, <@untainted>message.id,
                       <@untainted>msgAttachment.fileId);
                    array:push(attachments, attachment);
                }
            }
        }
        return attachments;
    }
    
}
