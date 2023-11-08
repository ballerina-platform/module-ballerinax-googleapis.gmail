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
    returns MessageListPage|error {
        oas:ListMessagesResponse response = check self.genClient->/users/[userId]/messages(xgafv, access_token, alt,
            callback, fields, 'key, oauth_token, prettyPrint, quotaUser, upload_protocol, uploadType, includeSpamTrash,
            labelIds, maxResults, pageToken, q
        );
        return convertListMessagesResponseToMessageListPage(response);
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

}
