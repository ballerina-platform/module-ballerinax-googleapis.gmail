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
import googleapis.gmail.oas;

# The Gmail API lets you view and manage Gmail mailbox data like threads, messages, and labels.
public isolated client class Client {
    final oas:Client genClient;

    # Gets invoked to initialize the `connector`.
    #
    # + config - The configurations to be used when initializing the `connector` 
    # + serviceUrl - URL of the target service 
    # + return - An error if connector initialization failed 
    public isolated function init(ConnectionConfig config, string serviceUrl = "https://gmail.googleapis.com/gmail/v1")
    returns error? {
        oas:Client genClient = check new oas:Client(config, serviceUrl);
        self.genClient = genClient;
        return;
    }

    # Lists the drafts in the user's mailbox.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function get users/[string userId]/drafts(map<string|string[]> headers = {}, *GmailUsersDraftsListQueries queries) returns ListDraftsResponse|error {
        oas:ListDraftsResponse draftList = check self.genClient->/users/[userId]/drafts(headers, queries);
        return convertOASListDraftsResponseToListDraftsResponse(draftList);
    }

    # Creates a new draft with the `DRAFT` label.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + payload - The draft to create 
    # + return - Successful response 
    resource isolated function post users/[string userId]/drafts(DraftRequest payload, map<string|string[]> headers = {}, *GmailUsersDraftsCreateQueries queries) returns Draft|error {
        oas:Draft newDraft = check convertDraftRequestToOASDraft(payload);
        oas:Draft response = check self.genClient->/users/[userId]/drafts.post(newDraft, headers, queries);
        return convertOASDraftToDraft(response);
    }

    # Sends the specified, existing draft to the recipients in the `To`, `Cc`, and `Bcc` headers.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + payload - The ID of the existing draft to send. (Optional) Updated draft if necessary 
    # + return - Successful response 
    resource isolated function post users/[string userId]/drafts/send(DraftRequest payload, map<string|string[]> headers = {}, *GmailUsersDraftsSendQueries queries) returns Message|error {
        oas:Draft updatedDraft = check convertDraftRequestToOASDraft(payload);
        oas:Message response = check self.genClient->/users/[userId]/drafts/send.post(updatedDraft, headers, queries);
        return convertOASMessageToMessage(response);
    }

    # Gets the specified draft.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + id - The ID of the draft to retrieve
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function get users/[string userId]/drafts/[string id](map<string|string[]> headers = {}, *GmailUsersDraftsGetQueries queries) returns Draft|error {
        oas:Draft response = check self.genClient->/users/[userId]/drafts/[id](headers, queries);
        return convertOASDraftToDraft(response);
    }

    # Replaces a draft's content.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + id - The ID of the draft to update
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + payload - The updated draft to update 
    # + return - Successful response 
    resource isolated function put users/[string userId]/drafts/[string id](DraftRequest payload, map<string|string[]> headers = {}, *GmailUsersDraftsUpdateQueries queries) returns Draft|error {
        oas:Draft updatedDraft = check convertDraftRequestToOASDraft(payload);
        oas:Draft response = check self.genClient->/users/[userId]/drafts/[id].put(updatedDraft, headers, queries);
        return convertOASDraftToDraft(response);
    }

    # Immediately and permanently deletes the specified draft. Does not simply trash it.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + id - The ID of the draft to delete
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function delete users/[string userId]/drafts/[string id](map<string|string[]> headers = {}, *GmailUsersDraftsDeleteQueries queries) returns error? {
        return self.genClient->/users/[userId]/drafts/[id].delete(headers, queries);
    }

    # Lists the history of all changes to the given mailbox. History results are returned in chronological order (increasing `historyId`).
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function get users/[string userId]/history(map<string|string[]> headers = {}, *GmailUsersHistoryListQueries queries) returns ListHistoryResponse|error {
        oas:ListHistoryResponse historyList = check self.genClient->/users/[userId]/history(headers, queries);
        return convertOASListHistoryResponseToListHistoryResponse(historyList);
    }

    # Lists all labels in the user's mailbox.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function get users/[string userId]/labels(map<string|string[]> headers = {}, *GmailUsersLabelsListQueries queries) returns ListLabelsResponse|error {
        return self.genClient->/users/[userId]/labels(headers, queries);
    }

    # Creates a new label.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + payload - The label to create 
    # + return - Successful response 
    resource isolated function post users/[string userId]/labels(Label payload, map<string|string[]> headers = {}, *GmailUsersLabelsCreateQueries queries) returns Label|error {
        return self.genClient->/users/[userId]/labels.post(payload, headers, queries);
    }

    # Gets the specified label.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + id - The ID of the label to retrieve
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function get users/[string userId]/labels/[string id](map<string|string[]> headers = {}, *GmailUsersLabelsGetQueries queries) returns Label|error {
        return self.genClient->/users/[userId]/labels/[id](headers, queries);
    }

    # Updates the specified label.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + id - The ID of the label to update
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + payload - The updated label to update 
    # + return - Successful response 
    resource isolated function put users/[string userId]/labels/[string id](Label payload, map<string|string[]> headers = {}, *GmailUsersLabelsUpdateQueries queries) returns Label|error {
        return self.genClient->/users/[userId]/labels/[id].put(payload, headers, queries);
    }

    # Immediately and permanently deletes the specified label and removes it from any messages and threads that it is applied to.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + id - The ID of the label to delete
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function delete users/[string userId]/labels/[string id](map<string|string[]> headers = {}, *GmailUsersLabelsDeleteQueries queries) returns error? {
        return self.genClient->/users/[userId]/labels/[id].delete(headers, queries);
    }

    # Patch the specified label.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + id - The ID of the label to update
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + payload - The updated label to update 
    # + return - Successful response 
    resource isolated function patch users/[string userId]/labels/[string id](Label payload, map<string|string[]> headers = {}, *GmailUsersLabelsPatchQueries queries) returns Label|error {
        return self.genClient->/users/[userId]/labels/[id].patch(payload, headers, queries);
    }

    # Lists the messages in the user's mailbox.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function get users/[string userId]/messages(map<string|string[]> headers = {}, *GmailUsersMessagesListQueries queries) returns ListMessagesResponse|error {
        oas:ListMessagesResponse response = check self.genClient->/users/[userId]/messages(headers, queries);
        return convertOASListMessagesResponseToListMessageResponse(response);
    }

    # Directly inserts a message into only this user's mailbox similar to `IMAP APPEND`, bypassing most scanning and classification. Does not send a message.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + payload - The message to be inserted 
    # + return - Successful response 
    resource isolated function post users/[string userId]/messages(MessageRequest payload, map<string|string[]> headers = {}, *GmailUsersMessagesInsertQueries queries) returns Message|error {
        oas:Message message = check convertMessageRequestToOASMessage(payload);
        oas:Message response = check self.genClient->/users/[userId]/messages.post(message, headers, queries);
        return convertOASMessageToMessage(response);
    }

    # Deletes many messages by message ID. Provides no guarantees that messages were not already deleted or even existed at all.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + payload - The IDs of the messages to delete 
    # + return - Successful response 
    resource isolated function post users/[string userId]/messages/batchDelete(BatchDeleteMessagesRequest payload, map<string|string[]> headers = {}, *GmailUsersMessagesBatchDeleteQueries queries) returns error? {
        return self.genClient->/users/[userId]/messages/batchDelete.post(payload, headers, queries);
    }

    # Modifies the labels on the specified messages.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + payload - A list of labels to add/remove in messages 
    # + return - Successful response 
    resource isolated function post users/[string userId]/messages/batchModify(BatchModifyMessagesRequest payload, map<string|string[]> headers = {}, *GmailUsersMessagesBatchModifyQueries queries) returns error? {
        return self.genClient->/users/[userId]/messages/batchModify.post(payload, headers, queries);
    }

    # Imports a message into only this user's mailbox, with standard email delivery scanning and classification similar to receiving via SMTP. This method doesn't perform SPF checks, so it might not work for some spam messages, such as those attempting to perform domain spoofing. This method does not send a message.
    #
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + payload - The message to be imported.
    # + return - Successful response 
    resource isolated function post users/[string userId]/messages/'import(MessageRequest payload, map<string|string[]> headers = {}, *GmailUsersMessagesImportQueries queries) returns Message|error {
        oas:Message request = check convertMessageRequestToOASMessage(payload);
        oas:Message response = check self.genClient->/users/[userId]/messages/'import.post(request, headers, queries);
        return convertOASMessageToMessage(response);
    }

    # Sends the specified message to the recipients in the `To`, `Cc`, and `Bcc` headers. For example usage, see [Sending email](https://developers.google.com/gmail/api/guides/sending).
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + payload - The message to be sent 
    # + return - Successful response 
    resource isolated function post users/[string userId]/messages/send(MessageRequest payload, map<string|string[]> headers = {}, *GmailUsersMessagesSendQueries queries) returns Message|error {
        oas:Message processedPayload = check convertMessageRequestToOASMessage(payload);
        oas:Message response = check self.genClient->/users/[userId]/messages/send.post(processedPayload, headers, queries);
        return convertOASMessageToMessage(response);
    }

    # Gets the specified message.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + id - The ID of the message to retrieve. This ID is usually retrieved using `messages.list`. The ID is also contained in the result when a message is inserted (`messages.insert`) or imported (`messages.import`)
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function get users/[string userId]/messages/[string id](map<string|string[]> headers = {}, *GmailUsersMessagesGetQueries queries) returns Message|error {
        oas:Message response = check self.genClient->/users/[userId]/messages/[id](headers, queries);
        return convertOASMessageToMessage(response);
    }

    # Immediately and permanently deletes the specified message. This operation cannot be undone. Prefer `messages.trash` instead.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + id - The ID of the message to delete
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function delete users/[string userId]/messages/[string id](map<string|string[]> headers = {}, *GmailUsersMessagesDeleteQueries queries) returns error? {
        return self.genClient->/users/[userId]/messages/[id].delete(headers, queries);
    }

    # Modifies the labels on the specified message.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + id - The ID of the message to modify
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + payload - A list of labels to add/remove on the message 
    # + return - Successful response 
    resource isolated function post users/[string userId]/messages/[string id]/modify(ModifyMessageRequest payload, map<string|string[]> headers = {}, *GmailUsersMessagesModifyQueries queries) returns Message|error {
        oas:Message response = check self.genClient->/users/[userId]/messages/[id]/modify.post(payload, headers, queries);
        return convertOASMessageToMessage(response);
    }

    # Moves the specified message to the trash.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + id - The ID of the message to Trash
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function post users/[string userId]/messages/[string id]/trash(map<string|string[]> headers = {}, *GmailUsersMessagesTrashQueries queries) returns Message|error {
        oas:Message response = check self.genClient->/users/[userId]/messages/[id]/trash.post(headers, queries);
        return convertOASMessageToMessage(response);
    }

    # Removes the specified message from the trash.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + id - The ID of the message to remove from Trash
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function post users/[string userId]/messages/[string id]/untrash(map<string|string[]> headers = {}, *GmailUsersMessagesUntrashQueries queries) returns Message|error {
        oas:Message response = check self.genClient->/users/[userId]/messages/[id]/untrash.post(headers, queries);
        return convertOASMessageToMessage(response);
    }

    # Gets the specified message attachment.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + messageId - The ID of the message containing the attachment
    # + id - The ID of the attachment
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function get users/[string userId]/messages/[string messageId]/attachments/[string id](map<string|string[]> headers = {}, *GmailUsersMessagesAttachmentsGetQueries queries) returns Attachment|error {
        oas:MessagePartBody response = check self.genClient->/users/[userId]/messages/[messageId]/attachments/[id](headers, queries);
        return convertOASMessagePartBodyToAttachment(response);
    }

    # Gets the current user's Gmail profile.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function get users/[string userId]/profile(map<string|string[]> headers = {}, *GmailUsersGetProfileQueries queries) returns Profile|error {
        return self.genClient->/users/[userId]/profile(headers, queries);
    }

    # Lists the threads in the user's mailbox.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function get users/[string userId]/threads(map<string|string[]> headers = {}, *GmailUsersThreadsListQueries queries) returns ListThreadsResponse|error {
        oas:ListThreadsResponse response = check self.genClient->/users/[userId]/threads(headers, queries);
        return convertOASListThreadsResponseToListThreadsResponse(response);
    }

    # Gets the specified thread.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + id - The ID of the thread to retrieve
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function get users/[string userId]/threads/[string id](map<string|string[]> headers = {}, *GmailUsersThreadsGetQueries queries) returns MailThread|error {
        oas:MailThread response = check self.genClient->/users/[userId]/threads/[id](headers, queries);
        return convertOASMailThreadToMailThread(response);
    }

    # Immediately and permanently deletes the specified thread. Any messages that belong to the thread are also deleted. This operation cannot be undone. Prefer `threads.trash` instead.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + id - ID of the Thread to delete
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function delete users/[string userId]/threads/[string id](map<string|string[]> headers = {}, *GmailUsersThreadsDeleteQueries queries) returns error? {
        return self.genClient->/users/[userId]/threads/[id].delete(headers, queries);
    }

    # Modifies the labels applied to the thread. This applies to all messages in the thread.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + id - The ID of the thread to modify
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + payload - A list labels to add/remove on the thread 
    # + return - Successful response 
    resource isolated function post users/[string userId]/threads/[string id]/modify(ModifyThreadRequest payload, map<string|string[]> headers = {}, *GmailUsersThreadsModifyQueries queries) returns MailThread|error {
        oas:MailThread response = check self.genClient->/users/[userId]/threads/[id]/modify.post(payload, headers, queries);
        return convertOASMailThreadToMailThread(response);
    }

    # Moves the specified thread to the trash. Any messages that belong to the thread are also moved to the trash.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + id - The ID of the thread to Trash
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function post users/[string userId]/threads/[string id]/trash(map<string|string[]> headers = {}, *GmailUsersThreadsTrashQueries queries) returns MailThread|error {
        oas:MailThread response = check self.genClient->/users/[userId]/threads/[id]/trash.post(headers, queries);
        return convertOASMailThreadToMailThread(response);
    }

    # Removes the specified thread from the trash. Any messages that belong to the thread are also removed from the trash.
    #
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user
    # + id - The ID of the thread to remove from Trash
    # + headers - Headers to be sent with the request 
    # + queries - Queries to be sent with the request 
    # + return - Successful response 
    resource isolated function post users/[string userId]/threads/[string id]/untrash(map<string|string[]> headers = {}, *GmailUsersThreadsUntrashQueries queries) returns MailThread|error {
        oas:MailThread response = check self.genClient->/users/[userId]/threads/[id]/untrash.post(headers, queries);
        return convertOASMailThreadToMailThread(response);
    }
}
