// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import ballerina/mime;
import ballerina/log;

documentation{
    Represents the Gmail Client Connector.

    F{{client}} HTTP Client used in Gmail connector
}
public type GmailConnector object {
    public {
        http:Client client;
    }

    documentation{
        List the messages in user's mailbox.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{filter}} Optional. MsgSearchFilter with optional query parameters to search emails.
        R{{}} If successful, returns MessageListPage. Else returns GmailError.
    }
    public function listMessages(string userId, MsgSearchFilter? filter = ()) returns MessageListPage|GmailError;

    documentation{
        Create the raw base 64 encoded string of the whole message and send it as an email from the user's
        mailbox to its recipient.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{message}} MessageRequest to send
        R{{}} If successful, returns (message id, thread id) of the successfully sent message. Else
                returns GmailError.
    }
    public function sendMessage(string userId, MessageRequest message) returns (string, string)|GmailError;

    documentation{
        Read the specified mail from users mailbox.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} The id of the message to retrieve
        P{{format}} Optional. The format to return the messages in.
                  Acceptable values for format for a get message request are defined as following constants
                  in the package:

                    *FORMAT_FULL* : Returns the full email message data with body content parsed in the payload
                                    field;the raw field is not used. (default)

                    *FORMAT_METADATA* : Returns only email message ID, labels, and email headers.

                    *FORMAT_MINIMAL* : Returns only email message ID and labels; does not return the email headers,
                                      body, or payload.

                    *FORMAT_RAW* : Returns the full email message data with body content in the raw field as a
                                   base64url encoded string. (the payload field is not included in the response)
        P{{metadataHeaders}} The meta data headers array to include in the reponse when the format is given
                               as *FORMAT_METADATA*.
        R{{}} If successful, returns Message type of the specified mail. Else returns GmailError.
    }
    public function readMessage(string userId, string messageId, string? format = (), string[]? metadataHeaders = ())
                        returns Message|GmailError;

    documentation{
        Gets the specified message attachment from users mailbox.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} The id of  the message to retrieve
        P{{attachmentId}} The id of the attachment to retrieve
        R{{}} If successful, returns MessageAttachment type object of the specified attachment. Else returns
                GmailError.
    }
    public function getAttachment(string userId, string messageId, string attachmentId)
                        returns MessageAttachment|GmailError;

    documentation{
        Move the specified message to the trash.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} The id of the message to trash
        R{{}} If successful, returns boolean specifying the status of trashing. Else returns GmailError.
    }
    public function trashMessage(string userId, string messageId) returns boolean|GmailError;

    documentation{
        Removes the specified message from the trash.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} The id of the message to untrash
        R{{}} If successful, returns boolean specifying the status of untrashing. Else returns GmailError.
    }
    public function untrashMessage(string userId, string messageId) returns boolean|GmailError;

    documentation{
        Immediately and permanently deletes the specified message. This operation cannot be undone.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} The id of the message to delete
        R{{}} If successful, returns boolean status of deletion. Else returns GmailError.
    }
    public function deleteMessage(string userId, string messageId) returns boolean|GmailError;

    documentation{
        Modifies the labels on the specified message.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{messageId}} The id of the message to modify
        P{{addLabelIds}} A list of IDs of labels to add to this message
        P{{removeLabelIds}} A list IDs of labels to remove from this message
        R{{}} If successful, returns modified Message type object in **minimal** format. Else returns GmailError.
    }
    public function modifyMessage(string userId, string messageId, string[] addLabelIds, string[] removeLabelIds)
                        returns Message|GmailError;

    documentation{
        List the threads in user's mailbox.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{filter}} Optional. The MsgSearchFilter with optional query parameters to search a thread.
        R{{}} If successful, returns ThreadListPage type. Else returns GmailError.
    }
    public function listThreads(string userId, MsgSearchFilter? filter = ()) returns ThreadListPage|GmailError;

    documentation{
        Read the specified mail thread from users mailbox.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{threadId}} The id of the thread to retrieve
        P{{format}} Optional. The format to return the messages in.
                  Acceptable values for format for a get thread request are defined as following constants
                  in the package:

                    *FORMAT_FULL* : Returns the full email message data with body content parsed in the payload
                                    field;the raw field is not used. (default)

                    *FORMAT_METADATA* : Returns only email message ID, labels, and email headers.

                    *FORMAT_MINIMAL* : Returns only email message ID and labels; does not return the email headers,
                                      body, or payload.

                    *FORMAT_RAW* : Returns the full email message data with body content in the raw field as a
                                   base64url encoded string. (the payload field is not included in the response)
        P{{metadataHeaders}} Optional. The meta data headers array to include in the reponse when the format is given
                               as *FORMAT_METADATA*.
        R{{}} If successful, returns Thread type of the specified mail thread. Else returns GmailError.
    }
    public function readThread(string userId, string threadId, string? format = (), string[]? metadataHeaders = ())
                        returns Thread|GmailError;

    documentation{
        Move the specified mail thread to the trash.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{threadId}} The id of the thread to trash
        R{{}} If successful, returns boolean status of trashing. Else returns GmailError.
    }
    public function trashThread(string userId, string threadId) returns boolean|GmailError;

    documentation{
        Removes the specified mail thread from the trash.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{threadId}} The id of the thread to untrash
        R{{}} If successful, returns boolean status of untrashing. Else returns GmailError.
    }
    public function untrashThread(string userId, string threadId) returns boolean|GmailError;

    documentation{
        Immediately and permanently deletes the specified mail thread. This operation cannot be undone.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{threadId}} The id of the thread to delete
        R{{}} If successful, returns boolean status of deletion. Else returns GmailError.
    }
    public function deleteThread(string userId, string threadId) returns boolean|GmailError;

    documentation{
        Modifies the labels on the specified thread.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{threadId}} The id of the thread to modify
        P{{addLabelIds}} A list of IDs of labels to add to this thread
        P{{removeLabelIds}} A list IDs of labels to remove from this thread
        R{{}} If successful, returns modified Message type object in **minimal** format. Else returns GmailError.
    }
    public function modifyThread(string userId, string threadId, string[] addLabelIds, string[] removeLabelIds)
                        returns Thread|GmailError;

    documentation{
        Get the current user's Gmail Profile.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        R{{}} If successful, returns UserProfile type. Else returns GmailError.
    }
    public function getUserProfile(string userId) returns UserProfile|GmailError;

    documentation{
        Get the label.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{labelId}} The label Id
        R{{}} If successful, returns Label type. Else returns GmailError.
    }
    public function getLabel(string userId, string labelId) returns Label|GmailError;

    documentation{
        Create a new label.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{name}} The display name of the label
        P{{labelListVisibility}} The visibility of the label in the label list in the Gmail web interface.
                                 Acceptable values are:

                                *labelHide*: Do not show the label in the label list.
                                *labelShow*: Show the label in the label list.
                                *labelShowIfUnread*: Show the label if there are any unread messages with that label.
        P{{messageListVisibility}} The visibility of messages with this label in the message list in the Gmail web interface.
                                   Acceptable values are:

                                   *hide*: Do not show the label in the message list.
                                   *show*: Show the label in the message list. (Default)
        P{{backgroundColor}} Optional. The background color represented as hex string #RRGGBB (ex #000000).
                             This field is required in order to set the color of a label.
        P{{textColor}} Optional. The text color of the label, represented as hex string. This field is required in order
                       to set the color of a label.
        R{{}} If successful, returns id of the created label. If not, returns GmailError.
    }
    public function createLabel(string userId, string name, string labelListVisibility, string messageListVisibility,
                                string? backgroundColor = (), string? textColor = ()) returns string|GmailError;

    documentation{
        Lists all labels in the user's mailbox.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        R{{}} If successful, returns an array of Label type objects with values for a set of main fields only. (Use
              `getLabel` to get all the details for a specific label) If not successful, returns GmailError.
    }
    public function listLabels(string userId) returns Label[]|GmailError;

    documentation{
        Delete a label.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{labelId}} The id of the label to delete
        R{{}} If successful, returns boolean status of deletion. Else returns GmailError.
    }
    public function deleteLabel(string userId, string labelId) returns boolean|GmailError;

    documentation{
        Update a label.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{labelId}} The id of the label to update
        P{{name}} Optional. The display name of the label
        P{{messageListVisibility}} Optional. The visibility of messages with this label in the message list in the Gmail
                                   web interface.
                                   Acceptable values are:

                                   *hide*: Do not show the label in the message list
                                   *show*: Show the label in the message list
        P{{labelListVisibility}} Optional. The visibility of the label in the label list in the Gmail web interface.
                                 Acceptable values are:

                                 *labelHide*: Do not show the label in the label list
                                 *labelShow*: Show the label in the label list
                                 *labelShowIfUnread*: Show the label if there are any unread messages with that label
        P{{backgroundColor}} Optional. The background color represented as hex string #RRGGBB (ex #000000).
        P{{textColor}} Optional. The text color of the label, represented as hex string.
        R{{}} If successful, returns updated Label type object. Else returns GmailError.
    }
    public function updateLabel(string userId, string labelId, string? name = (), string? messageListVisibility = (),
                                string? labelListVisibility = (), string? backgroundColor = (), string? textColor = ())
                                returns Label|GmailError;

    public function listHistory(string userId, string startHistoryId, string[]? historyTypes = (),
                                   string? labelId = (), string? maxResults = (), string? pageToken =())
                                   returns MailboxHistoryPage|GmailError;

    documentation{
        List the drafts in user's mailbox.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{filter}} Optional. DraftSearchFilter with optional query parameters to search drafts.
        R{{}} If successful, returns DraftListPage. Else returns GmailError.
    }
    public function listDrafts(string userId, DraftSearchFilter? filter = ()) returns DraftListPage|GmailError;

    documentation{
        Read the specified draft from users mailbox.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{draftId}} The id of the draft to retrieve
        P{{format}} Optional. The format to return the draft in.
                  Acceptable values for format for a get draft request are defined as following constants
                  in the package:

                    *FORMAT_FULL* : Returns the full email message data with body content parsed in the payload
                                    field;the raw field is not used. (default)

                    *FORMAT_METADATA* : Returns only email message ID, labels, and email headers.

                    *FORMAT_MINIMAL* : Returns only email message ID and labels; does not return the email headers,
                                      body, or payload.

                    *FORMAT_RAW* : Returns the full email message data with body content in the raw field as a
                                   base64url encoded string. (the payload field is not included in the response)
        R{{}} If successful, returns Draft type of the specified draft. Else returns GmailError.
    }
    public function readDraft(string userId, string draftId, string? format = ()) returns Draft|GmailError;

    documentation{
        Immediately and permanently deletes the specified draft.

        P{{userId}} The user's email address. The special value **me** can be used to indicate the authenticated user.
        P{{draftId}} The id of the draft to delete
        R{{}} If successful, returns boolean status of deletion. Else returns GmailError.
    }
    public function deleteDraft(string userId, string draftId) returns boolean|GmailError;

    public function createDraft(string userId, MessageRequest message, string? threadId = ()) returns string|GmailError;

    public function updateDraft(string userId, string draftId, MessageRequest message, string? threadId = ())
                                                                                              returns string|GmailError;

    public function sendDraft(string userId, string draftId) returns (string, string)|GmailError;
};

public function GmailConnector::listMessages(string userId, MsgSearchFilter? filter = ()) returns MessageListPage|
            GmailError {
    endpoint http:Client httpClient = self.client;
    string getListMessagesPath = USER_RESOURCE + userId + MESSAGE_RESOURCE;
    match filter {
        MsgSearchFilter searchFilter => {
            string uriParams;
            //The default value for include spam trash query parameter of the api call is false
            uriParams = check appendEncodedURIParameter(uriParams, INCLUDE_SPAMTRASH, <string>searchFilter.
                includeSpamTrash);
            //Add optional query parameters
            foreach labelId in searchFilter.labelIds {
                uriParams = check appendEncodedURIParameter(uriParams, LABEL_IDS, labelId);
            }
            uriParams = searchFilter.maxResults != EMPTY_STRING                              ?
            check appendEncodedURIParameter(uriParams, MAX_RESULTS, searchFilter.maxResults) : uriParams;
            uriParams = searchFilter.pageToken != EMPTY_STRING                             ?
            check appendEncodedURIParameter(uriParams, PAGE_TOKEN, searchFilter.pageToken) : uriParams;
            uriParams = searchFilter.q != EMPTY_STRING                        ?
            check appendEncodedURIParameter(uriParams, QUERY, searchFilter.q) : uriParams;
            getListMessagesPath += uriParams;
        }
        () => {}
    }
    var httpResponse = httpClient->get(getListMessagesPath);
    match handleResponse(httpResponse) {
        json jsonlistMsgResponse => return convertJsonMsgListToMessageListPageType(jsonlistMsgResponse);
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::sendMessage(string userId, MessageRequest message) returns (string, string)|GmailError {
    endpoint http:Client httpClient = self.client;
    string encodedRequest = check createEncodedRawMessage(message);
    http:Request request = new;
    json jsonPayload = { raw: encodedRequest };
    string sendMessagePath = USER_RESOURCE + userId + MESSAGE_SEND_RESOURCE;
    request.setJsonPayload(jsonPayload);
    var httpResponse = httpClient->post(sendMessagePath, request = request);
    match handleResponse(httpResponse) {
        json jsonSendMessageResponse => return (jsonSendMessageResponse.id.toString(),
        jsonSendMessageResponse.threadId.toString());
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::readMessage(string userId, string messageId, string? format = (),
                                            string[]? metadataHeaders = ()) returns Message|GmailError {
    endpoint http:Client httpClient = self.client;
    string uriParams;
    //Add format query parameter
    match format {
        string messageFormat => uriParams = check appendEncodedURIParameter(uriParams, FORMAT, messageFormat);
        () => {}
    }
    match metadataHeaders {
        string[] messageMetadataHeaders => {
            //Add the optional meta data headers as query parameters
            foreach metaDataHeader in messageMetadataHeaders {
                uriParams = check appendEncodedURIParameter(uriParams, METADATA_HEADERS, metaDataHeader);
            }
        }
        () => {}
    }
    string readMessagePath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId;
    readMessagePath += uriParams;
    var httpResponse = httpClient->get(readMessagePath);
    match handleResponse(httpResponse) {
        json jsonreadMessageResponse => {
            //Transform the json mail response from Gmail API to Message type
            match (convertJsonMessageToMessage(jsonreadMessageResponse)){
                Message message => return message;
                GmailError gmailError => return gmailError;
            }
        }
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::getAttachment(string userId, string messageId, string attachmentId)
                                    returns MessageAttachment|GmailError {
    endpoint http:Client httpClient = self.client;
    string getAttachmentPath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId
        + ATTACHMENT_RESOURCE + attachmentId;
    var httpResponse = httpClient->get(getAttachmentPath);
    match handleResponse(httpResponse) {
        json jsonAttachment => {
            //Transform the json mail response from Gmail API to MessageAttachment type
            return convertJsonMessageBodyToMsgAttachment(jsonAttachment);
        }
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::trashMessage(string userId, string messageId) returns boolean|GmailError {
    endpoint http:Client httpClient = self.client;
    string trashMessagePath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId
        + FORWARD_SLASH_SYMBOL + TRASH;
    var httpResponse = httpClient->post(trashMessagePath);
    match handleResponse(httpResponse) {
        json jsonTrashMessageResponse => return true;
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::untrashMessage(string userId, string messageId) returns boolean|GmailError {
    endpoint http:Client httpClient = self.client;
    string untrashMessagePath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId
        + FORWARD_SLASH_SYMBOL + UNTRASH;
    var httpResponse = httpClient->post(untrashMessagePath);
    match handleResponse(httpResponse) {
        json jsonUntrashMessageReponse => return true;
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::deleteMessage(string userId, string messageId) returns boolean|GmailError {
    endpoint http:Client httpClient = self.client;
    string deleteMessagePath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId;
    var httpResponse = httpClient->delete(deleteMessagePath);
    match handleResponse(httpResponse) {
        json jsonDeleteMessageResponse => return true;
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::listThreads(string userId, MsgSearchFilter? filter = ()) returns ThreadListPage|GmailError
{
    endpoint http:Client httpClient = self.client;
    string getListThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE;
    match filter {
        MsgSearchFilter searchFilter => {
            string uriParams;
            //The default value for include spam trash query parameter of the api call is false
            uriParams = check appendEncodedURIParameter(uriParams, INCLUDE_SPAMTRASH,
                <string>searchFilter.includeSpamTrash);
            //Add optional query parameters
            foreach labelId in searchFilter.labelIds {
                uriParams = check appendEncodedURIParameter(uriParams, LABEL_IDS, labelId);
            }
            uriParams = searchFilter.maxResults != EMPTY_STRING                              ?
            check appendEncodedURIParameter(uriParams, MAX_RESULTS, searchFilter.maxResults) : uriParams;
            uriParams = searchFilter.pageToken != EMPTY_STRING                             ?
            check appendEncodedURIParameter(uriParams, PAGE_TOKEN, searchFilter.pageToken) : uriParams;
            uriParams = searchFilter.q != EMPTY_STRING                        ?
            check appendEncodedURIParameter(uriParams, QUERY, searchFilter.q) : uriParams;
            getListThreadPath += uriParams;
        }
        () => {}
    }
    var httpResponse = httpClient->get(getListThreadPath);
    match handleResponse(httpResponse) {
        json jsonListThreadResponse => return convertJsonThreadListToThreadListPageType(jsonListThreadResponse);
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::readThread(string userId, string threadId, string? format = (),
                                           string[]? metadataHeaders = ()) returns Thread|GmailError {
    endpoint http:Client httpClient = self.client;
    string uriParams;
    match format { //Add format optional query parameter
        string messageFormat => uriParams = check appendEncodedURIParameter(uriParams, FORMAT, messageFormat);
        () => {}
    }
    match metadataHeaders {
        string[] messageMetadataHeaders => { //Add the optional meta data headers as query parameters
            foreach metaDataHeader in messageMetadataHeaders {
                uriParams = check appendEncodedURIParameter(uriParams, METADATA_HEADERS, metaDataHeader);
            }
        }
        () => {}
    }
    string readThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId + uriParams;
    var httpResponse = httpClient->get(readThreadPath);
    match handleResponse(httpResponse) {
        json jsonReadThreadResponse => {
            //Transform the json mail response from Gmail API to Thread type
            match convertJsonThreadToThreadType(jsonReadThreadResponse) {
                Thread thread => return thread;
                GmailError gmailError => return gmailError;
            }
        }
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::trashThread(string userId, string threadId) returns boolean|GmailError {
    endpoint http:Client httpClient = self.client;
    string trashThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId
        + FORWARD_SLASH_SYMBOL + TRASH;
    var httpResponse = httpClient->post(trashThreadPath);
    match handleResponse(httpResponse) {
        json jsonTrashThreadResponse => return true;
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::untrashThread(string userId, string threadId) returns boolean|GmailError {
    endpoint http:Client httpClient = self.client;
    string untrashThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId
        + FORWARD_SLASH_SYMBOL + UNTRASH;
    var httpResponse = httpClient->post(untrashThreadPath);
    match handleResponse(httpResponse) {
        json jsonUntrashThreadResponse => return true;
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::deleteThread(string userId, string threadId) returns boolean|GmailError {
    endpoint http:Client httpClient = self.client;
    string deleteThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId;
    var httpResponse = httpClient->delete(deleteThreadPath);
    match handleResponse(httpResponse) {
        json jsonDeleteThreadResponse => return true;
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::getUserProfile(string userId) returns UserProfile|GmailError {
    endpoint http:Client httpClient = self.client;
    string getProfilePath = USER_RESOURCE + userId + PROFILE_RESOURCE;
    var httpResponse = httpClient->get(getProfilePath);
    match handleResponse(httpResponse) {
        json jsonProfileResponse => {
            //Transform the json profile response from Gmail API to User Profile type
            return convertJsonProfileToUserProfileType(jsonProfileResponse);
        }
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::getLabel(string userId, string labelId) returns Label|GmailError {
    endpoint http:Client httpClient = self.client;
    string getLabelPath = USER_RESOURCE + userId + LABEL_RESOURCE + FORWARD_SLASH_SYMBOL + labelId;
    var httpResponse = httpClient->get(getLabelPath);
    match handleResponse(httpResponse) {
        json jsonGetLabelResponse => return convertJsonLabelToLabelType(jsonGetLabelResponse);
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::createLabel(string userId, string name, string labelListVisibility,
                                            string messageListVisibility, string? backgroundColor = (),
                                            string? textColor = ()) returns string|GmailError {
    endpoint http:Client httpClient = self.client;
    string createLabelPath = USER_RESOURCE + userId + LABEL_RESOURCE;
    json jsonPayload = { labelListVisibility: labelListVisibility, messageListVisibility: messageListVisibility,
        name: name };
    if (backgroundColor != ()){
        jsonPayload.backgroundColor = backgroundColor;
    }
    if (textColor != ()){
        jsonPayload.textColor = textColor;
    }
    http:Request request = new;
    request.setJsonPayload(jsonPayload);
    var httpResponse = httpClient->post(createLabelPath, request = request);
    match handleResponse(httpResponse) {
        json jsonCreateLabelResponse => return jsonCreateLabelResponse.id.toString();
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::listLabels(string userId) returns Label[]|GmailError {
    endpoint http:Client httpClient = self.client;
    string listLabelsPath = USER_RESOURCE + userId + LABEL_RESOURCE;
    var httpResponse = httpClient->get(listLabelsPath);
    match handleResponse(httpResponse) {
        json jsonLabelListResponse => return convertJsonLabelListToLabelTypeList(jsonLabelListResponse);
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::deleteLabel(string userId, string labelId) returns boolean|GmailError {
    endpoint http:Client httpClient = self.client;
    string deleteLabelPath = USER_RESOURCE + userId + LABEL_RESOURCE + FORWARD_SLASH_SYMBOL + labelId;
    var httpResponse = httpClient->delete(deleteLabelPath);
    match handleResponse(httpResponse) {
        json jsonDeleteMessageResponse => return true;
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::updateLabel(string userId, string labelId, string? name = (),
                                            string? messageListVisibility = (), string? labelListVisibility = (),
                                            string? backgroundColor = (), string? textColor = ())
                                            returns Label|GmailError {
    endpoint http:Client httpClient = self.client;
    string updateLabelPath = USER_RESOURCE + userId + LABEL_RESOURCE + FORWARD_SLASH_SYMBOL + labelId;
    json jsonPayload = { id: labelId };
    match name {
        string labelName => jsonPayload.name = labelName;
        () => {}
    }
    match messageListVisibility {
        string msgListVisibility => jsonPayload.messageListVisibility = msgListVisibility;
        () => {}
    }
    match labelListVisibility {
        string lblListVisibility => jsonPayload.labelListVisibility = lblListVisibility;
        () => {}
    }
    match backgroundColor {
        string bgColor => jsonPayload.color.backgroundColor = bgColor;
        () => {}
    }
    match textColor {
        string txtColor => jsonPayload.color.textColor = txtColor;
        () => {}
    }
    http:Request request = new;
    request.setJsonPayload(jsonPayload);
    var httpResponse = httpClient->patch(updateLabelPath, request = request);
    match handleResponse(httpResponse) {
        json jsonUpdateResponse => return convertJsonLabelToLabelType(jsonUpdateResponse);
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::modifyMessage(string userId, string messageId, string[] addLabelIds,
                                              string[] removeLabelIds) returns Message|GmailError {
    endpoint http:Client httpClient = self.client;
    string modifyMsgPath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId
                           + MODIFY_RESOURCE;
    if (lengthof addLabelIds == 0 && lengthof removeLabelIds == 0) {
        GmailError err = { message: "Both addLabelIds and removeLabelIds arrays cannot be empty when modifying"
                                    + " messageId: " + messageId };
        return err;
    }
    json jsonPayload;
    jsonPayload.addLabelIds = convertStringArrayToJSONArray(addLabelIds);
    jsonPayload.removeLabelIds = convertStringArrayToJSONArray(removeLabelIds);
    http:Request request = new;
    request.setJsonPayload(jsonPayload);
    var httpResponse = httpClient->post(modifyMsgPath, request = request);
    match handleResponse(httpResponse) {
        json jsonMessageResponse => {
            //Transform the json mail response from Gmail API to Message type in minimal format
            match (convertJsonMessageToMessage(jsonMessageResponse)){
                Message message => return message;
                GmailError gmailError => return gmailError;
            }
        }
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::modifyThread(string userId, string threadId, string[] addLabelIds,
                                             string[] removeLabelIds) returns Thread|GmailError {
    endpoint http:Client httpClient = self.client;
    string modifyThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId
                            + MODIFY_RESOURCE;
    if (lengthof addLabelIds == 0 && lengthof removeLabelIds == 0) {
        GmailError err = { message: "Both addLabelIds and removeLabelIds arrays cannot be empty when modifying"
            + " threadId: " + threadId };
        return err;
    }
    json jsonPayload;
    jsonPayload.addLabelIds = convertStringArrayToJSONArray(addLabelIds);
    jsonPayload.removeLabelIds = convertStringArrayToJSONArray(removeLabelIds);
    http:Request request = new;
    request.setJsonPayload(jsonPayload);
    var httpResponse = httpClient->post(modifyThreadPath, request = request);
    match handleResponse(httpResponse) {
        json jsonThreadResponse => {
            //Transform the json thread response from Gmail API to Message type in minimal format
            match (convertJsonThreadToThreadType(jsonThreadResponse)){
                Thread thread => return thread;
                GmailError gmailError => return gmailError;
            }
        }
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::listHistory(string userId, string startHistoryId, string[]? historyTypes = (),
                                               string? labelId = (), string? maxResults = (), string? pageToken =())
                                               returns MailboxHistoryPage|GmailError{
    endpoint http:Client httpClient = self.client;
    string listHistoryPath = USER_RESOURCE + userId + HISTORY_RESOURCE;
    string uriParams;
    uriParams = check appendEncodedURIParameter(uriParams, START_HISTORY_ID, startHistoryId);
    match historyTypes {
        string[] types => {
            //Add optional query parameter history types to be returned
            foreach historyType in types {
                uriParams = check appendEncodedURIParameter(uriParams, HISTORY_TYPES, historyType);
            }
        }
        () => {}
    }
    match labelId {
        string id => uriParams = check appendEncodedURIParameter(uriParams, LABEL_ID, id);
        () => {}
    }
    match maxResults {
        string max => uriParams = check appendEncodedURIParameter(uriParams, MAX_RESULTS, max);
        () => {}
    }
    match pageToken {
        string token => uriParams = check appendEncodedURIParameter(uriParams, PAGE_TOKEN, token);
        () => {}
    }
    listHistoryPath += uriParams;
    var httpResponse = httpClient->get(listHistoryPath);
    match handleResponse(httpResponse) {
        json jsonHistoryResponse => {
            //Transform the json history response from Gmail API to Mailbox History Page type
            match (convertJsonToMailboxHistoryPage(jsonHistoryResponse)){
                MailboxHistoryPage page => return page;
                GmailError gmailError => return gmailError;
            }
        }
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::listDrafts(string userId, DraftSearchFilter? filter = ())
                                                                                      returns DraftListPage|GmailError {
    endpoint http:Client httpClient = self.client;
    string getListDraftsPath = USER_RESOURCE + userId + DRAFT_RESOURCE;
    match filter {
        DraftSearchFilter searchFilter => {
            string uriParams;
            //The default value for include spam trash query parameter of the api call is false
            uriParams = check appendEncodedURIParameter(uriParams, INCLUDE_SPAMTRASH, <string>searchFilter.
                                                        includeSpamTrash);
            uriParams = searchFilter.maxResults != EMPTY_STRING                              ?
                           check appendEncodedURIParameter(uriParams, MAX_RESULTS, searchFilter.maxResults) : uriParams;
            uriParams = searchFilter.pageToken != EMPTY_STRING                             ?
                             check appendEncodedURIParameter(uriParams, PAGE_TOKEN, searchFilter.pageToken) : uriParams;
            uriParams = searchFilter.q != EMPTY_STRING                        ?
                                          check appendEncodedURIParameter(uriParams, QUERY, searchFilter.q) : uriParams;
            getListDraftsPath += uriParams;
        }
        () => {}
    }
    var httpResponse = httpClient->get(getListDraftsPath);
    match handleResponse(httpResponse) {
        json jsonListDraftResponse => return convertJsonDraftListToDraftListPageType(jsonListDraftResponse);
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::readDraft(string userId, string draftId, string? format = ()) returns Draft|GmailError {
    endpoint http:Client httpClient = self.client;
    string uriParams;
    //Add format query parameter
    match format {
        string messageFormat => uriParams = check appendEncodedURIParameter(uriParams, FORMAT, messageFormat);
        () => {}
    }
    string readDraftPath = USER_RESOURCE + userId + DRAFT_RESOURCE + FORWARD_SLASH_SYMBOL + draftId + uriParams;
    var httpResponse = httpClient->get(readDraftPath);
    match handleResponse(httpResponse) {
        json jsonreadDraftResponse => {
            //Transform the json draft response from Gmail API to Draft type
            match (convertJsonDraftToDraftType(jsonreadDraftResponse)){
                Draft draft => return draft;
                GmailError gmailError => return gmailError;
            }
        }
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::deleteDraft(string userId, string draftId) returns boolean|GmailError {
    endpoint http:Client httpClient = self.client;
    string deleteDraftPath = USER_RESOURCE + userId + DRAFT_RESOURCE + FORWARD_SLASH_SYMBOL + draftId;
    var httpResponse = httpClient->delete(deleteDraftPath);
    match handleResponse(httpResponse) {
        json jsonDeleteDraftResponse => return true;
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::createDraft(string userId, MessageRequest message, string? threadId = ())
                                                                                            returns string|GmailError {
    endpoint http:Client httpClient = self.client;
    string encodedRequest = check createEncodedRawMessage(message);
    http:Request request = new;
    json jsonPayload = { message: { raw: encodedRequest } };
    match threadId {
        string tId => jsonPayload.message.threadId = tId;
        () => {}
    }
    string createDraftPath = USER_RESOURCE + userId + DRAFT_RESOURCE;
    request.setJsonPayload(jsonPayload);
    var httpResponse = httpClient->post(createDraftPath, request = request);
    match handleResponse(httpResponse) {
        json jsonCreateDraftResponse => return jsonCreateDraftResponse.id.toString();
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::updateDraft(string userId, string draftId, MessageRequest message,
                                            string? threadId = ()) returns string|GmailError {
    endpoint http:Client httpClient = self.client;
    string encodedRequest = check createEncodedRawMessage(message);
    http:Request request = new;
    json jsonPayload = { message: { raw: encodedRequest } };
    match threadId {
        string tId => jsonPayload.message.threadId = tId;
        () => {}
    }
    string updateDraftPath = USER_RESOURCE + userId + DRAFT_RESOURCE + FORWARD_SLASH_SYMBOL + draftId;
    request.setJsonPayload(jsonPayload);
    var httpResponse = httpClient->put(updateDraftPath, request = request);
    match handleResponse(httpResponse) {
        json jsonUpdateDraftResponse => return jsonUpdateDraftResponse.id.toString();
        GmailError gmailError => return gmailError;
    }
}

public function GmailConnector::sendDraft(string userId, string draftId) returns (string, string)|GmailError {
    endpoint http:Client httpClient = self.client;
    http:Request request = new;
    json jsonPayload = { id: draftId };
    string updateDraftPath = USER_RESOURCE + userId + DRAFT_SEND_RESOURCE;
    request.setJsonPayload(jsonPayload);
    var httpResponse = httpClient->post(updateDraftPath, request = request);
    match handleResponse(httpResponse) {
        json jsonSendDraftResponse => return (jsonSendDraftResponse.id.toString(),
                                              jsonSendDraftResponse.threadId.toString());
        GmailError gmailError => return gmailError;
    }
}
