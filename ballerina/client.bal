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
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + includeSpamTrash - Include drafts from `SPAM` and `TRASH` in the results.
    # + maxResults - Maximum number of drafts to return. This field defaults to 100. The maximum allowed value for this field is 500.
    # + pageToken - Page token to retrieve a specific page of results in the list.
    # + q - Only return draft messages matching the specified query. Supports the same query format as the Gmail search box. For example, `"from:someuser@example.com rfc822msgid: is:unread"`.
    # + return - Successful response 
    resource isolated function get users/[string userId]/drafts(
            Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (), string? fields = (),
            string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (), string? quotaUser = (),
            string? upload_protocol = (), string? uploadType = (), boolean? includeSpamTrash = (), int? maxResults = (),
            string? pageToken = (), string? q = ())
    returns ListDraftsResponse|error {
        oas:ListDraftsResponse draftList = check self.genClient->/users/[userId]/drafts(xgafv, access_token, alt,
            callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType, includeSpamTrash,
            maxResults, pageToken, q
        );
        return convertOASListDraftsResponseToListDraftsResponse(draftList);
    }

    # Creates a new draft with the `DRAFT` label.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + payload - The draft to create.
    # + return - Successful response 
    resource isolated function post users/[string userId]/drafts(
            DraftRequest payload, Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (),
            string? fields = (), string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (),
            string? quotaUser = (), string? upload_protocol = (), string? uploadType = ())
    returns Draft|error {
        oas:Draft newDraft = check convertDraftRequestToOASDraft(payload);
        oas:Draft response = check self.genClient->/users/[userId]/drafts.post(newDraft, xgafv, access_token, alt,
            callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType
        );
        return convertOASDraftToDraft(response);
    }

    # Sends the specified, existing draft to the recipients in the `To`, `Cc`, and `Bcc` headers.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + payload - The ID of the existing draft to send. (Optional) Updated draft if necessary.
    # + return - Successful response 
    resource isolated function post users/[string userId]/drafts/send(
            DraftRequest payload, Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (),
            string? fields = (), string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (),
            string? quotaUser = (), string? upload_protocol = (), string? uploadType = ())
    returns Message|error {
        oas:Draft updatedDraft = check convertDraftRequestToOASDraft(payload);
        oas:Message response = check self.genClient->/users/[userId]/drafts/send.post(updatedDraft, xgafv, access_token,
            alt, callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType
        );
        return convertOASMessageToMessage(response);
    }

    # Gets the specified draft.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + id - The ID of the draft to retrieve.
    # + format - The format to return the draft in.
    # + return - Successful response 
    resource isolated function get users/[string userId]/drafts/[string id](
            Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (), string? fields = (),
            string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (), string? quotaUser = (),
            string? upload_protocol = (), string? uploadType = (), "minimal"|"full"|"raw"|"metadata"? format = ())
    returns Draft|error {
        oas:Draft response = check self.genClient->/users/[userId]/drafts/[id](xgafv, access_token, alt, callback,
            fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType, format
        );
        return convertOASDraftToDraft(response);
    }

    # Replaces a draft's content.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + id - The ID of the draft to update.
    # + payload - The updated draft to update.
    # + return - Successful response 
    resource isolated function put users/[string userId]/drafts/[string id](
            DraftRequest payload, Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (),
            string? fields = (), string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (),
            string? quotaUser = (), string? upload_protocol = (), string? uploadType = ())
    returns Draft|error {
        oas:Draft updatedDraft = check convertDraftRequestToOASDraft(payload);
        oas:Draft response = check self.genClient->/users/[userId]/drafts/[id].put(updatedDraft, xgafv, access_token,
            alt, callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType
        );
        return convertOASDraftToDraft(response);
    }

    # Immediately and permanently deletes the specified draft. Does not simply trash it.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + id - The ID of the draft to delete.
    # + return - Successful response 
    resource isolated function delete users/[string userId]/drafts/[string id](
            Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (), string? fields = (),
            string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (), string? quotaUser = (),
            string? upload_protocol = (), string? uploadType = ())
    returns error? {
        _ = check self.genClient->/users/[userId]/drafts/[id].delete(xgafv, access_token, alt, callback, fields,
            'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType
        );
    }

    # Lists the messages in the user's mailbox.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + includeSpamTrash - Include messages from `SPAM` and `TRASH` in the results.
    # + labelIds - Only return messages with labels that match all of the specified label IDs. Messages in a thread might have labels that other messages in the same thread don't have. To learn more, see [Manage labels on messages and threads](https://developers.google.com/gmail/api/guides/labels#manage_labels_on_messages_threads).
    # + maxResults - Maximum number of messages to return. This field defaults to 100. The maximum allowed value for this field is 500.
    # + pageToken - Page token to retrieve a specific page of results in the list.
    # + q - Only return messages matching the specified query. Supports the same query format as the Gmail search box. For example, `"from:someuser@example.com rfc822msgid: is:unread"`. Parameter cannot be used when accessing the api using the gmail.metadata scope.
    # + return - Successful response 
    resource isolated function get users/[string userId]/messages(
            Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (), string? fields = (),
            string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (), string? quotaUser = (),
            string? upload_protocol = (), string? uploadType = (), boolean? includeSpamTrash = (),
            string[]? labelIds = (), int? maxResults = (), string? pageToken = (), string? q = ())
    returns ListMessagesResponse|error {
        oas:ListMessagesResponse response = check self.genClient->/users/[userId]/messages(xgafv, access_token, alt,
            callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType, includeSpamTrash,
            labelIds, maxResults, pageToken, q
        );
        return convertOASListMessagesResponseToListMessageResponse(response);
    }

    # Directly inserts a message into only this user's mailbox similar to `IMAP APPEND`, bypassing most scanning and classification. Does not send a message.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + deleted - Mark the email as permanently deleted (not TRASH) and only visible in Google Vault to a Vault administrator. Only used for Google Workspace accounts.
    # + internalDateSource - Source for Gmail's internal date of the message.
    # + payload - The message to be inserted.
    # + return - Successful response 
    resource isolated function post users/[string userId]/messages(
            MessageRequest payload, Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (),
            string? fields = (), string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (),
            string? quotaUser = (), string? upload_protocol = (), string? uploadType = (), boolean? deleted = (),
            "receivedTime"|"dateHeader"? internalDateSource = ())
    returns Message|error {
        oas:Message message = check convertMessageRequestToOASMessage(payload);
        oas:Message response = check self.genClient->/users/[userId]/messages.post(message, xgafv, access_token,
            alt, callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType, deleted,
            internalDateSource
        );
        return convertOASMessageToMessage(response);
    }

    # Deletes many messages by message ID. Provides no guarantees that messages were not already deleted or even existed at all.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + payload - The IDs of the messages to delete.
    # + return - Successful response 
    resource isolated function post users/[string userId]/messages/batchDelete(
            BatchDeleteMessagesRequest payload, Xgafv? xgafv = (), string? access_token = (), Alt? alt = (),
            string? callback = (), string? fields = (), string? 'key = (), string? oauth_token = (),
            boolean? prettyPrint = (), string? quotaUser = (), string? upload_protocol = (), string? uploadType = ())
    returns error? {
        _ = check self.genClient->/users/[userId]/messages/batchDelete.post(payload, xgafv, access_token,
            alt, callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType
        );
    }

    # Modifies the labels on the specified messages.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + payload - A list of labels to add/remove in messages.
    # + return - Successful response 
    resource isolated function post users/[string userId]/messages/batchModify(
            BatchModifyMessagesRequest payload, Xgafv? xgafv = (), string? access_token = (), Alt? alt = (),
            string? callback = (), string? fields = (), string? 'key = (), string? oauth_token = (),
            boolean? prettyPrint = (), string? quotaUser = (), string? upload_protocol = (), string? uploadType = ())
    returns error? {
        _ = check self.genClient->/users/[userId]/messages/batchModify.post(payload, xgafv, access_token,
            alt, callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType
        );
    }

    # Imports a message into only this user's mailbox, with standard email delivery scanning and classification similar to receiving via SMTP. This method doesn't perform SPF checks, so it might not work for some spam messages, such as those attempting to perform domain spoofing. This method does not send a message.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + deleted - Mark the email as permanently deleted (not TRASH) and only visible in Google Vault to a Vault administrator. Only used for Google Workspace accounts.
    # + internalDateSource - Source for Gmail's internal date of the message.
    # + neverMarkSpam - Ignore the Gmail spam classifier decision and never mark this email as SPAM in the mailbox.
    # + processForCalendar - Process calendar invites in the email and add any extracted meetings to the Google Calendar for this user.
    # + payload - The message to be imported.
    # + return - Successful response 
    resource isolated function post users/[string userId]/messages/'import(
            MessageRequest payload, Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (),
            string? fields = (), string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (),
            string? quotaUser = (), string? upload_protocol = (), string? uploadType = (), boolean? deleted = (),
            "receivedTime"|"dateHeader"? internalDateSource = (), boolean? neverMarkSpam = (),
            boolean? processForCalendar = ())
    returns Message|error {
        oas:Message request = check convertMessageRequestToOASMessage(payload);
        oas:Message response = check self.genClient->/users/[userId]/messages/'import.post(request, xgafv, access_token,
            alt, callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType, deleted,
            internalDateSource, neverMarkSpam, processForCalendar
        );
        return convertOASMessageToMessage(response);
    }

    # Sends the specified message to the recipients in the `To`, `Cc`, and `Bcc` headers. For example usage, see [Sending email](https://developers.google.com/gmail/api/guides/sending).
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + payload - The message to be sent.
    # + return - Successful response 
    resource isolated function post users/[string userId]/messages/send(
            MessageRequest payload, Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (),
            string? fields = (), string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (),
            string? quotaUser = (), string? upload_protocol = (), string? uploadType = ())
        returns Message|error {
        oas:Message processedPayload = check convertMessageRequestToOASMessage(payload);
        oas:Message response = check self.genClient->/users/[userId]/messages/send.post(processedPayload, xgafv,
            access_token, alt, callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol,
            uploadType
        );
        return convertOASMessageToMessage(response);
    }

    # Gets the specified message.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + id - The ID of the message to retrieve. This ID is usually retrieved using `messages.list`. The ID is also contained in the result when a message is inserted (`messages.insert`) or imported (`messages.import`).
    # + format - The format to return the message in.
    # + metadataHeaders - When given and format is `METADATA`, only include headers specified.
    # + return - Successful response 
    resource isolated function get users/[string userId]/messages/[string id](
            Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (), string? fields = (),
            string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (), string? quotaUser = (),
            string? upload_protocol = (), string? uploadType = (), "minimal"|"full"|"raw"|"metadata"? format = (),
            string[]? metadataHeaders = ())
    returns Message|error {
        oas:Message response = check self.genClient->/users/[userId]/messages/[id](xgafv, access_token, alt,
            callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType, format,
            metadataHeaders
        );
        return convertOASMessageToMessage(response);
    }

    # Immediately and permanently deletes the specified message. This operation cannot be undone. Prefer `messages.trash` instead.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + id - The ID of the message to delete.
    # + return - Successful response 
    resource isolated function delete users/[string userId]/messages/[string id](
            Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (), string? fields = (),
            string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (), string? quotaUser = (),
            string? upload_protocol = (), string? uploadType = ())
    returns error? {
        _ = check self.genClient->/users/[userId]/messages/[id].delete(xgafv, access_token, alt, callback, fields,
            'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType
        );
    }

    # Modifies the labels on the specified message.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + id - The ID of the message to modify.
    # + payload - A list of labels to add/remove on the message.
    # + return - Successful response 
    resource isolated function post users/[string userId]/messages/[string id]/modify(
            ModifyMessageRequest payload, Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (),
            string? fields = (), string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (),
            string? quotaUser = (), string? upload_protocol = (), string? uploadType = ())
    returns Message|error {
        oas:Message response = check self.genClient->/users/[userId]/messages/[id]/modify.post(payload, xgafv,
            access_token, alt, callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType
        );
        return convertOASMessageToMessage(response);
    }

    # Moves the specified message to the trash.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + id - The ID of the message to Trash.
    # + return - Successful response 
    resource isolated function post users/[string userId]/messages/[string id]/trash(
            Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (), string? fields = (),
            string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (), string? quotaUser = (),
            string? upload_protocol = (), string? uploadType = ())
    returns Message|error {
        oas:Message response = check self.genClient->/users/[userId]/messages/[id]/trash.post(xgafv, access_token,
            alt, callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType
        );
        return convertOASMessageToMessage(response);
    }

    # Removes the specified message from the trash.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + id - The ID of the message to remove from Trash.
    # + return - Successful response 
    resource isolated function post users/[string userId]/messages/[string id]/untrash(
            Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (), string? fields = (),
            string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (), string? quotaUser = (),
            string? upload_protocol = (), string? uploadType = ())
    returns Message|error {
        oas:Message response = check self.genClient->/users/[userId]/messages/[id]/untrash.post(xgafv, access_token,
            alt, callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType
        );
        return convertOASMessageToMessage(response);
    }

    # Gets the specified message attachment.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + messageId - The ID of the message containing the attachment.
    # + id - The ID of the attachment.
    # + return - Successful response 
    resource isolated function get users/[string userId]/messages/[string messageId]/attachments/[string id](
            Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (), string? fields = (),
            string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (), string? quotaUser = (),
            string? upload_protocol = (), string? uploadType = ())
    returns Attachment|error {
        oas:MessagePartBody response = check self.genClient->/users/[userId]/messages/[messageId]/attachments/[id](
            xgafv, access_token, alt, callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol,
            uploadType
        );
        return convertOASMessagePartBodyToAttachment(response);
    }

    # Gets the current user's Gmail profile.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + return - Successful response 
    resource isolated function get users/[string userId]/profile(
            Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (), string? fields = (),
            string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (), string? quotaUser = (),
            string? upload_protocol = (), string? uploadType = ())
    returns Profile|error {
        return self.genClient->/users/[userId]/profile(xgafv, access_token, alt, callback, fields, 'key, oauth_token,
            prettyPrint, quotaUser, upload_protocol, uploadType
        );
    }

    # Lists the threads in the user's mailbox.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + includeSpamTrash - Include threads from `SPAM` and `TRASH` in the results.
    # + labelIds - Only return threads with labels that match all of the specified label IDs.
    # + maxResults - Maximum number of threads to return. This field defaults to 100. The maximum allowed value for this field is 500.
    # + pageToken - Page token to retrieve a specific page of results in the list.
    # + q - Only return threads matching the specified query. Supports the same query format as the Gmail search box. For example, `"from:someuser@example.com rfc822msgid: is:unread"`. Parameter cannot be used when accessing the api using the gmail.metadata scope.
    # + return - Successful response 
    resource isolated function get users/[string userId]/threads(
            Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (), string? fields = (),
            string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (), string? quotaUser = (),
            string? upload_protocol = (), string? uploadType = (), boolean? includeSpamTrash = (), string[]? labelIds = (),
            int? maxResults = (), string? pageToken = (), string? q = ()) returns ListThreadsResponse|error {
        oas:ListThreadsResponse response = check self.genClient->/users/[userId]/threads(xgafv, access_token, alt,
            callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType, includeSpamTrash,
            labelIds, maxResults, pageToken, q
        );
        return convertOASListThreadsResponseToListThreadsResponse(response);
    }

    # Gets the specified thread.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + id - The ID of the thread to retrieve.
    # + format - The format to return the messages in.
    # + metadataHeaders - When given and format is METADATA, only include headers specified.
    # + return - Successful response 
    resource isolated function get users/[string userId]/threads/[string id](
            Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (), string? fields = (),
            string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (), string? quotaUser = (),
            string? upload_protocol = (), string? uploadType = (), "full"|"metadata"|"minimal"? format = (),
            string[]? metadataHeaders = ())
    returns MailThread|error {
        oas:MailThread response = check self.genClient->/users/[userId]/threads/[id](xgafv, access_token, alt, callback,
            fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType, format, metadataHeaders
        );
        return convertOASMailThreadToMailThread(response);
    }

    # Immediately and permanently deletes the specified thread. Any messages that belong to the thread are also deleted. This operation cannot be undone. Prefer `threads.trash` instead.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + id - ID of the Thread to delete.
    # + return - Successful response 
    resource isolated function delete users/[string userId]/threads/[string id](
            Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (), string? fields = (),
            string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (), string? quotaUser = (),
            string? upload_protocol = (), string? uploadType = ())
    returns error? {
        _ = check self.genClient->/users/[userId]/threads/[id].delete(xgafv, access_token, alt, callback, fields,
            'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType
        );
    }

    # Modifies the labels applied to the thread. This applies to all messages in the thread.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + id - The ID of the thread to modify.
    # + payload - A list labels to add/remove on the thread.
    # + return - Successful response 
    resource isolated function post users/[string userId]/threads/[string id]/modify(
            ModifyThreadRequest payload, Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (),
            string? fields = (), string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (),
            string? quotaUser = (), string? upload_protocol = (), string? uploadType = ())
    returns MailThread|error {
        oas:MailThread response = check self.genClient->/users/[userId]/threads/[id]/modify.post(payload, xgafv,
            access_token, alt, callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType
        );
        return convertOASMailThreadToMailThread(response);
    }

    # Moves the specified thread to the trash. Any messages that belong to the thread are also moved to the trash.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + id - The ID of the thread to Trash.
    # + return - Successful response 
    resource isolated function post users/[string userId]/threads/[string id]/trash(
            Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (), string? fields = (),
            string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (), string? quotaUser = (),
            string? upload_protocol = (), string? uploadType = ())
    returns MailThread|error {
        oas:MailThread response = check self.genClient->/users/[userId]/threads/[id]/trash.post(xgafv, access_token,
            alt, callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType
        );
        return convertOASMailThreadToMailThread(response);
    }

    # Removes the specified thread from the trash. Any messages that belong to the thread are also removed from the trash.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + id - The ID of the thread to remove from Trash.
    # + return - Successful response 
    resource isolated function post users/[string userId]/threads/[string id]/untrash(
            Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (), string? fields = (),
            string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (), string? quotaUser = (),
            string? upload_protocol = (), string? uploadType = ())
    returns MailThread|error {
        oas:MailThread response = check self.genClient->/users/[userId]/threads/[id]/untrash.post(xgafv, access_token,
            alt, callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType
        );
        return convertOASMailThreadToMailThread(response);
    }
}
