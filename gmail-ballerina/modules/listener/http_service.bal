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

service class HttpService {

    private boolean isOnMailboxChanges = false;
    private boolean isOnNewEmail = false;
    private boolean isOnNewThread = false;
    private boolean isOnNewLabeledEmail = false;
    private boolean isOnNewStaredEmail = false;
    private boolean isOnLabelRemovedEmail = false;
    private boolean isOnStarRemovedEmail = false;
    private boolean isOnNewAttachment = false;

    private SimpleHttpService httpService;
    private gmail:Client gmailClient;
    public  string startHistoryId = "";
    private string userId = ME;

    public isolated function init(SimpleHttpService|HttpService httpService, gmail:Client gmailClient, 
        string historyId) {
        self.httpService = httpService;
        self.gmailClient = gmailClient;
        self.startHistoryId = historyId;
        string[] methodNames = getServiceMethodNames(httpService);

        foreach var methodName in methodNames {
            match methodName {
                "onMailboxChanges" => {
                    self.isOnMailboxChanges = true;
                }
                "onNewEmail" => {
                    self.isOnNewEmail = true;
                }
                "onNewThread" => {
                    self.isOnNewThread = true;
                }
                "onNewLabeledEmail" => {
                    self.isOnNewLabeledEmail = true;
                }
                "onNewStaredEmail" => {
                    self.isOnNewStaredEmail = true;
                }
                "onLabelRemovedEmail" => {
                    self.isOnLabelRemovedEmail = true;
                }
                "onStarRemovedEmail" => {
                    self.isOnStarRemovedEmail = true;
                }
                "onNewAttachment" => {
                    self.isOnNewAttachment = true;
                }
                _ => {
                    log:printError("Unrecognized method [" + methodName + "] found in the implementation");
                }
            }
        }
    }

    resource function post mailboxChanges(http:Caller caller, http:Request request) returns @tainted error? {
        check caller->respond(http:STATUS_OK);
        var  mailboxHistoryPage =  self.gmailClient->listHistory(<@untainted>self.userId, self.startHistoryId);
        
        if (mailboxHistoryPage is gmail:MailboxHistoryPage) {
            self.startHistoryId = mailboxHistoryPage.historyId;
            log:printInfo("Next History ID = "+self.startHistoryId);
            if (self.isOnMailboxChanges) {
                check callOnMailboxChanges(self.httpService, mailboxHistoryPage);
            }
            
            foreach var history in mailboxHistoryPage.historyRecords {
                gmail:HistoryEvent[] newMessages = history.messagesAdded;
                if (newMessages.length()>0) {
                    foreach var newMessage in newMessages {                    
                        gmail:Message message = check self.gmailClient->readMessage(ME,<@untainted>newMessage.message.id);
                        if (self.isOnNewEmail) {
                            check callOnNewEmail(self.httpService, message);
                        }
                        foreach var msgAttachment in message.msgAttachments {
                            gmail:MessageBodyPart attachment = check self.gmailClient->getAttachment(<@untainted>self.userId, 
                                                                <@untainted>message.id, <@untainted>msgAttachment.fileId);
                            if (self.isOnNewAttachment) {
                                check callOnNewAttachment(self.httpService, attachment);
                            }
                        }
                    }
                }
            }
            
            foreach var history in mailboxHistoryPage.historyRecords {
                gmail:HistoryEvent[] newMessages = history.messagesAdded;
                if (newMessages.length()>0) {
                    foreach var newMessage in newMessages {    
                        if(newMessage.message.id == newMessage.message.threadId) {               
                            gmail:MailThread thread = check self.gmailClient->readThread(ME, <@untainted>newMessage.message.threadId);
                            if (self.isOnNewThread) {
                                check callOnNewThread(self.httpService, thread);
                            }
                        }
                    }
                }
            }

            foreach var history in mailboxHistoryPage.historyRecords {
                gmail:HistoryEvent[] addedlabels = history.labelsAdded;
                if (addedlabels.length()>0) {
                    foreach var addedlabel in addedlabels {
                        ChangedLabel changedLabeldMsg ={ message: {},changedLabelId: []};
                        changedLabeldMsg.changedLabelId = addedlabel.labelIds;
                        gmail:Message message = check self.gmailClient->readMessage(ME, <@untainted>addedlabel.message.id);
                        changedLabeldMsg.message = message;
                        if (self.isOnNewLabeledEmail) {
                            check callOnNewLabeledEmail(self.httpService, changedLabeldMsg);
                        }
                    }
                }            
            }

            foreach var history in mailboxHistoryPage.historyRecords {
                gmail:HistoryEvent[] addedlabels = history.labelsAdded;
                if (addedlabels.length()>0) {
                    foreach var addedlabel in addedlabels {
                        foreach var label in addedlabel.labelIds {
                            match label{
                                STARRED =>{
                                    gmail:Message message = check self.gmailClient->readMessage(ME, <@untainted>addedlabel.message.id);
                                    if (self.isOnNewStaredEmail) {
                                        check callOnNewStaredEmail(self.httpService, message);
                                    }
                                }
                            }
                        }
                    }
                }            
            }
            
            foreach var history in mailboxHistoryPage.historyRecords {
                gmail:HistoryEvent[] removedLabels = history.labelsRemoved;
                if (removedLabels.length()>0) {
                    foreach var removedLabel in removedLabels {
                        ChangedLabel changedLabeldMsg ={ message: {},changedLabelId: []};
                        changedLabeldMsg.changedLabelId = removedLabel.labelIds;
                        gmail:Message message = check self.gmailClient->readMessage(ME, <@untainted>removedLabel.message.id);
                        changedLabeldMsg.message = message;
                        if (self.isOnLabelRemovedEmail) {
                            check callOnLabelRemovedEmail(self.httpService, changedLabeldMsg);
                        }
                    }
                }            
            }

            foreach var history in mailboxHistoryPage.historyRecords {
                gmail:HistoryEvent[] removedLabels = history.labelsRemoved;
                if (removedLabels.length()>0) {
                    foreach var removedLabel in removedLabels {
                        foreach var label in removedLabel.labelIds {
                            match label{
                                STARRED =>{
                                    gmail:Message message = check self.gmailClient->readMessage(ME, <@untainted>removedLabel.message.id);
                                    if (self.isOnStarRemovedEmail) {
                                        check callOnStarRemovedEmail(self.httpService, message);
                                    }
                                }
                            }
                        }
                    }
                }            
            }                             
        } else {
            log:printError("Error occured while getting history.", 'error= mailboxHistoryPage);
        }
    }

    public isolated function setStartHistoryId(string startHistoryId) {
        self.startHistoryId = startHistoryId;
    }
}