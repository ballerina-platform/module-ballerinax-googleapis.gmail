// Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

# Ballerina Gmail connector provides the capability to access Gmail API.
# The connector let you to interact with users' Gmail inboxes through the Gmail REST API.
#
# + gmailClient - The HTTP Client
@display {label: "Gmail", iconPath: "icon.png"}
public isolated client class Client {
    private final http:Client gmailClient;

    # Initializes the connector. During initialization you can pass either http:BearerTokenConfig if you have a bearer
    # token or http:OAuth2RefreshTokenGrantConfig if you have Oauth tokens.
    # Create a Google account and obtain tokens following [this guide](https://developers.google.com/identity/protocols/oauth2). 
    #
    # + config - Configurations required to initialize the `Client` endpoint
    # + return - An error on failure of initialization or else `()`
    public isolated function init(ConnectionConfig config) returns error? {
        http:ClientConfiguration httpClientConfig = {
            auth: config.auth,
            httpVersion: config.httpVersion,
            http1Settings: config.http1Settings,
            http2Settings: config.http2Settings,
            timeout: config.timeout,
            forwarded: config.forwarded,
            poolConfig: config.poolConfig,
            cache: config.cache,
            compression: config.compression,
            circuitBreaker: config.circuitBreaker,
            retryConfig: config.retryConfig,
            responseLimits: config.responseLimits,
            secureSocket: config.secureSocket,
            proxy: config.proxy,
            validation: config.validation
        };
        self.gmailClient = check new (BASE_URL, httpClientConfig);
    }

    # Lists the messages in user's mailbox.
    #
    # + filter - Optional. MsgSearchFilter with optional query parameters to search messages.
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns stream<Message,error?>. Else returns error.
    @display {label: "List Messages"} 
    remote isolated function listMessages(@display {label: "Message Search Filter"} MsgSearchFilter? filter = (),
                                          @display {label: "Email Address"} string? userId = ()) returns @tainted 
                                          @display {label: "Message List"} stream<Message,error?>|error {

        MessageStream messageStream = check new MessageStream (self.gmailClient, userId is string ? userId : ME, 
                                                               filter);
        return new stream<Message,error?>(messageStream);
    }

    # Creates the raw base 64 encoded string of the whole message and send it as an email from the user's
    # mailbox to its recipient.
    #
    # + message - MessageRequest to send. Note: Here if any attachments included in the message, those attachments need
    #             to be less than 25MB.
    # + threadId - Optional. Required if message is expected to be send The ID of the thread the message belongs to.
    # (The Subject headers must match)
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns Message record of the successfully sent message. Else return error.
    @display {label: "Send Message"} 
    remote isolated function sendMessage(@display {label: "Send Message"} MessageRequest message,
                                         @display {label: "Thread ID"} string? threadId = (),
                                         @display {label: "Email Address"} string? userId = ())
                                         returns @tainted @display {label: "Sent Message Response"} Message|error {                           
        //Create the whole message as an encoded raw string. If unsuccessful throws and returns error.
        string encodedRequest = check createEncodedRawMessage(message);
        http:Request request = new;
        map<json> jsonPayload = {raw: encodedRequest};
        if (threadId is string) {
            jsonPayload["threadId"] = threadId;
        }
        string sendMessagePath = USER_RESOURCE + (userId is string ? userId : ME) + MESSAGE_SEND_RESOURCE;
        request.setJsonPayload(<@untainted>jsonPayload);
        
        http:Response httpResponse = <http:Response> check self.gmailClient->post(sendMessagePath, request);
        json jsonSendMessageResponse = check handleResponse(httpResponse);
        return check jsonSendMessageResponse.cloneWithType(Message);
    }

    # Reads the specified mail from users mailbox.
    #
    # + messageId - The ID of the message to retrieve
    # + format - Optional. The format to return the message in.
    #              Acceptable values for format for a get message request are defined as following constants
    #              in the module:
    #
    #               `FORMAT_FULL` : Returns the full email message data with body content parsed in the payload
    #                                field;the raw field is not used. (default)
    #
    #                `FORMAT_METADATA` : Returns only email message ID, labels, and email headers.
    #
    #                `FORMAT_MINIMAL` : Returns only email message ID and labels; does not return the email headers,
    #                                  body, or payload.
    #
    #               `FORMAT_RAW` : Returns the full email message data with body content in the raw field as a
    #                               base64url encoded string. (the payload field is not included in the response)
    # + metadataHeaders - Optional. The meta data headers array to include in the response when the format is given
    #                       as *FORMAT_METADATA*.
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns Message type object of the specified mail. Else returns error.
    @display {label: "Read Message"} 
    remote isolated function readMessage(@display {label: "Message ID"} string messageId,
                                         @display {label: "Message Format"} string? format = (), 
                                         @display {label: "Metadata Headers"} string[]? metadataHeaders = (),
                                         @display {label: "Email Address"} string? userId = ())
                                         returns @tainted @display {label: "Message"}Message|error {
        string uriParams = "";
        //Append format query parameter
        if (format is string) {
            uriParams = check appendEncodedURIParameter(uriParams, FORMAT, format);
        }
        if (metadataHeaders is string[]) {
            foreach string metaDataHeader in metadataHeaders {
                uriParams = check appendEncodedURIParameter(uriParams, METADATA_HEADERS, metaDataHeader);
            }
        }
        string readMessagePath = USER_RESOURCE + (userId is string ? userId : ME) + MESSAGE_RESOURCE +
                                 FORWARD_SLASH_SYMBOL + messageId + uriParams;
        http:Response httpResponse = <http:Response> check self.gmailClient->get(readMessagePath);
        json jsonreadMessageResponse = check handleResponse(httpResponse);
        return convertJSONToMessageType(<@untainted>jsonreadMessageResponse);
    }

    # Gets the specified message attachment from users mailbox.
    #
    # + messageId - The ID of the message to retrieve
    # + attachmentId - The ID of the attachment to retrieve
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns MessageBodyPart type object of the specified attachment. Else returns error.
    @display {label: "Get Attachment"} 
    remote isolated function getAttachment(@display {label: "Message ID"} string messageId,
                                           @display {label: "Attachment ID"} string attachmentId,
                                           @display {label: "Email Address"} string? userId = ()) returns @tainted 
                                           @display {label: "Message Body Part"} MessageBodyPart | error {
        string getAttachmentPath = USER_RESOURCE + (userId is string ? userId : ME) + MESSAGE_RESOURCE +
                                   FORWARD_SLASH_SYMBOL + messageId + ATTACHMENT_RESOURCE + attachmentId;
        http:Response httpResponse = <http:Response> check self.gmailClient->get(getAttachmentPath);
        json jsonAttachment = check handleResponse(httpResponse);
        MessageBodyPart receivedMessageBodyPart = check jsonAttachment.cloneWithType(MessageBodyPart);
        return getFormattedBase64MessageBodyPart(receivedMessageBodyPart);
    }

    # Moves the specified message to the trash.
    #
    # + messageId - The ID of the message to trash
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns trashed Message record. Else returns error.
    @display {label: "Trash Message"} 
    remote isolated function trashMessage(@display {label: "Message ID"} string messageId,
                                          @display {label: "Email Address"} string? userId = ()) 
                                          returns @tainted @display {label: "Trashed Message"} Message|error {
        http:Request request = new;
        string trashMessagePath = USER_RESOURCE + (userId is string ? userId : ME) + MESSAGE_RESOURCE +
                                  FORWARD_SLASH_SYMBOL + messageId + FORWARD_SLASH_SYMBOL + TRASH;
        http:Response httpResponse = <http:Response> check self.gmailClient->post(trashMessagePath, request);
        json jsonTrashMessageResponse = check handleResponse(httpResponse);
        return check jsonTrashMessageResponse.cloneWithType(Message);
    }

    # Removes the specified message from the trash.
    #
    # + messageId - The ID of the message to untrash
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns untrashed Message record. Else returns error.
    @display {label: "Untrash Message"} 
    remote isolated function untrashMessage(@display {label: "Message ID"} string messageId,
                                            @display {label: "Email Address"} string? userId = ()) 
                                            returns @tainted @display {label: "Untrashed Message"} Message|error {
        http:Request request = new;
        string untrashMessagePath = USER_RESOURCE + (userId is string ? userId : ME) + MESSAGE_RESOURCE +
                                    FORWARD_SLASH_SYMBOL + messageId + FORWARD_SLASH_SYMBOL + UNTRASH;
        http:Response httpResponse = <http:Response> check self.gmailClient->post(untrashMessagePath, request);
        json jsonUntrashMessageReponse = check handleResponse(httpResponse);
        return check jsonUntrashMessageReponse.cloneWithType(Message);
    }

    # Immediately and permanently deletes the specified message. This operation cannot be undone.
    #
    # + messageId - The ID of the message to delete
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns nothing. Else returns error.
    @display {label: "Delete Message"}
    remote isolated function deleteMessage(@display {label: "Message ID"} string messageId,
                                           @display {label: "Email Address"} string? userId = ()) 
                                           returns @tainted @display {label: "Status"} error? {
        http:Request request = new;
        string deleteMessagePath = USER_RESOURCE + (userId is string ? userId : ME) + MESSAGE_RESOURCE +
                                   FORWARD_SLASH_SYMBOL + messageId;
        http:Response httpResponse = <http:Response> check self.gmailClient->delete(deleteMessagePath, request);
        var handledResponse = handleResponse(httpResponse);
        if (handledResponse is error) {
            return handledResponse;
        }
    }

    # Modifies the labels on the specified message.
    #
    # + messageId - The ID of the message to modify
    # + addLabelIds - A list of Ids of labels to add to this message
    # + removeLabelIds - A list Ids of labels to remove from this message
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns modified Message type object in **minimal** format. Else returns error.
    @display {label: "Modify Message Labels"} 
    remote isolated function modifyMessage(@display {label: "Message ID"} string messageId, 
                                           @display {label: "Labels to Add"} string[] addLabelIds, 
                                           @display {label: "Labels to Remove"} string[] removeLabelIds,
                                           @display {label: "Email Address"} string? userId = ())
                                           returns @tainted @display {label: "Message"} Message|error {
        string modifyMsgPath = USER_RESOURCE + (userId is string ? userId : ME) + MESSAGE_RESOURCE +
                               FORWARD_SLASH_SYMBOL + messageId + MODIFY_RESOURCE;
        // When modifying message labels, at least one of the arrays from addLabelIds and removeLabelIds should not be 
        // empty.
        if (addLabelIds.length() == 0 && removeLabelIds.length() == 0) {
            error err = error(GMAIL_ERROR_CODE,
                message = "Both addLabelIds and removeLabelIds arrays cannot be empty when modifying" + " messageId: "
                + messageId);
            return err;
        }
        json jsonPayload = {
            addLabelIds: convertStringArrayToJSONArray(addLabelIds),
            removeLabelIds: convertStringArrayToJSONArray(removeLabelIds)
        };
        http:Request request = new;
        request.setJsonPayload(jsonPayload);
        http:Response httpResponse = <http:Response> check self.gmailClient->post(modifyMsgPath, request);
        return convertJSONToMessageType(<@untainted>check handleResponse(httpResponse));
    }

    # Lists the threads in user's mailbox.
    #
    # + filter - Optional. The MsgSearchFilter with optional query parameters to search a thread.
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns stream<MailThread,error?>. Else returns error.
    @display {label: "List Threads"} 
    remote isolated function listThreads(@display {label: "Message Search Filter"} MsgSearchFilter? filter = (),
                                         @display {label: "Email Address"} string? userId = ()) returns @tainted 
                                         @display {label: "Thread List"} stream<MailThread,error?>|error {

        ThreadStream threadStream = check new ThreadStream (self.gmailClient, userId is string ? userId : ME, filter);
        return new stream<MailThread,error?>(threadStream);
    }

    # Reads the specified mail thread from users mailbox.
    #
    # + threadId - The ID of the thread to retrieve
    # + format - Optional. The format to return the messages in.
    #              Acceptable values for format for a get thread request are defined as following constants
    #             in the module:
    #
    #                `FORMAT_FULL` : Returns the full email message data with body content parsed in the payload
    #                                field;the raw field is not used. (default)
    #
    #                `FORMAT_METADATA` : Returns only email message ID, labels, and email headers.
    #
    #                `FORMAT_MINIMAL` : Returns only email message ID and labels; does not return the email headers,
    #                                  body, or payload.
    #
    #                `FORMAT_RAW` : Returns the full email message data with body content in the raw field as a
    #                               base64url encoded string. (the payload field is not included in the response)
    # + metadataHeaders - Optional. The meta data headers array to include in the reponse when the format is given
    #                           as `FORMAT_METADATA`.
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns MailThread type of the specified mail thread. Else returns error.
    @display {label: "Read Thread"}
    remote isolated function readThread(@display {label: "Thread ID"} string threadId,
                                        @display {label: "Message Format"} string? format = (),
                                        @display {label: "Metadata Headers"} string[]? metadataHeaders = (),
                                        @display {label: "Email Address"} string? userId = ())
                                        returns @tainted @display {label: "Mail Thread"} MailThread|error {        
        string uriParams = "";
        if (format is string) {
            uriParams = check appendEncodedURIParameter(uriParams, FORMAT, format);
        }
        if (metadataHeaders is string[]) {
            //Append the optional meta data headers as query parameters
            foreach string metaDataHeader in metadataHeaders {
                uriParams = check appendEncodedURIParameter(uriParams, METADATA_HEADERS, metaDataHeader);
            }
        }
        string readThreadPath = USER_RESOURCE + (userId is string ? userId : ME) + THREAD_RESOURCE +
                                FORWARD_SLASH_SYMBOL + threadId + uriParams;
        http:Response httpResponse = <http:Response> check self.gmailClient->get(readThreadPath);
        json jsonReadThreadResponse = check handleResponse(httpResponse);
        return convertJSONToThreadType(<@untainted>jsonReadThreadResponse);
    }

    # Moves the specified mail thread to the trash.
    #
    # + threadId - The ID of the thread to trash
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns trashed MailThread record. Else returns error.
    @display {label: "Trash Thread"} 
    remote isolated function trashThread(@display {label: "Thread ID"} string threadId,
                                         @display {label: "Email Address"} string? userId = ()) 
                                         returns @tainted @display {label: "Trashed Thread"} MailThread|error {
        http:Request request = new;
        string trashThreadPath = USER_RESOURCE + (userId is string ? userId : ME) + THREAD_RESOURCE +
                                 FORWARD_SLASH_SYMBOL + threadId + FORWARD_SLASH_SYMBOL + TRASH;
        http:Response httpResponse = <http:Response> check self.gmailClient->post(trashThreadPath, request);
        json jsonTrashThreadResponse = check handleResponse(httpResponse);
        return check jsonTrashThreadResponse.cloneWithType(MailThread);
    }

    # Removes the specified mail thread from the trash.
    #
    # + threadId - The ID of the thread to untrash
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns boolean status of untrashing. Else returns error.
    @display {label: "Untrash Thread"} 
    remote isolated function untrashThread(@display {label: "Thread ID"} string threadId,
                                           @display {label: "Email Address"} string? userId = ()) 
                                           returns @tainted @display {label: "Untrashed Thread"} MailThread|error {
        http:Request request = new;
        string untrashThreadPath = USER_RESOURCE + (userId is string ? userId : ME) + THREAD_RESOURCE +
                                   FORWARD_SLASH_SYMBOL + threadId + FORWARD_SLASH_SYMBOL + UNTRASH;
        http:Response httpResponse = <http:Response> check self.gmailClient->post(untrashThreadPath, request);
        json jsonUntrashThreadResponse = check handleResponse(httpResponse);
        return check jsonUntrashThreadResponse.cloneWithType(MailThread);
    }

    # Immediately and permanently deletes the specified mail thread. This operation cannot be undone.
    #
    # + threadId - The ID of the thread to delete
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns nothing. Else returns error.
    @display {label: "Delete Thread"}
    remote isolated function deleteThread(@display {label: "Thread ID"} string threadId,
                                          @display {label: "Email Address"} string? userId = ()) 
                                          returns @tainted @display {label: "Status"} error? {
        http:Request request = new;
        string deleteThreadPath = USER_RESOURCE + (userId is string ? userId : ME) + THREAD_RESOURCE +
                                  FORWARD_SLASH_SYMBOL + threadId;
        http:Response httpResponse = <http:Response> check self.gmailClient->delete(deleteThreadPath, request);
        var handledResponse = handleResponse(httpResponse);
        if (handledResponse is error) {
            return handledResponse;
        }
    }

    # Modifies the labels on the specified thread.
    #
    # + threadId - The ID of the thread to modify
    # + addLabelIds - A list of IDs of labels to add to this thread
    # + removeLabelIds - A list IDs of labels to remove from this thread
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns modified MailThread type object. Else returns error.
    @display {label: "Modify Labels on Thread"}
    remote isolated function modifyThread(@display {label: "Thread ID"} string threadId, 
                                          @display {label: "Labels to Add"} string[] addLabelIds, 
                                          @display {label: "Labels to Remove"} string[] removeLabelIds,
                                          @display {label: "Email Address"} string? userId = ())
                                          returns @tainted @display {label: "Mail Thread"} MailThread|error {
        
        string modifyThreadPath = USER_RESOURCE + (userId is string ? userId : ME) + THREAD_RESOURCE +
                                  FORWARD_SLASH_SYMBOL + threadId + MODIFY_RESOURCE;
        if (addLabelIds.length() == 0 && removeLabelIds.length() == 0) {
            error gmailError = error(GMAIL_ERROR_CODE,
                message = "Both addLabelIds and removeLabelIds arrays cannot be empty when modifying" + " threadId: " 
                + threadId);
            return gmailError;
        }
        json jsonPayload = {
            addLabelIds: convertStringArrayToJSONArray(addLabelIds),
            removeLabelIds: convertStringArrayToJSONArray(removeLabelIds)
        };
        http:Request request = new;
        request.setJsonPayload(jsonPayload);
        http:Response httpResponse = <http:Response> check self.gmailClient->post(modifyThreadPath, request);
        return convertJSONToThreadType(<@untainted>check handleResponse(httpResponse));
    }

    # Gets the current user's Gmail Profile.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns UserProfile type. Else returns error.
    @display {label: "Get User Profile"}
    remote isolated function getUserProfile(@display {label: "Email Address"} string? userId = ())
                                            returns @tainted @display {label: "User Profile"} UserProfile|error {
        
        string getProfilePath = USER_RESOURCE + (userId is string ? userId : ME) + PROFILE_RESOURCE;
        http:Response httpResponse = <http:Response> check self.gmailClient->get(getProfilePath);
        json jsonProfileResponse = check handleResponse(httpResponse);
        return jsonProfileResponse.cloneWithType(UserProfile);
    }

    # Gets the label.
    #
    # + labelId - The label ID
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns Label type. Else returns error.
    @display {label: "Get Label"}
    remote isolated function getLabel(@display {label: "Label ID"} string labelId,
                                      @display {label: "Email Address"} string? userId = ()) 
                                      returns @tainted @display {label: "Label"} Label|error {
        
        string getLabelPath = USER_RESOURCE + (userId is string ? userId : ME) + LABEL_RESOURCE +
                              FORWARD_SLASH_SYMBOL + labelId;
        http:Response httpResponse = <http:Response> check self.gmailClient->get(getLabelPath);
        json jsonGetLabelResponse = check handleResponse(httpResponse);
        return jsonGetLabelResponse.cloneWithType(Label);
    }

    # Creates a new label.
    #
    # + name - The display name of the label
    # + labelListVisibility - The visibility of the label in the label list in the Gmail web interface.
    #                             Acceptable values are:
    #
    #                            `labelHide`: Do not show the label in the label list.
    #                            `labelShow`: Show the label in the label list.
    #                            `labelShowIfUnread`: Show the label if there are any unread messages with that label.
    # + messageListVisibility - The visibility of messages with this label in the message list in the Gmail web 
    #                               interface. Acceptable values are:
    #
    #                               `hide`: Do not show the label in the message list.
    #                               `show`: Show the label in the message list. (Default)
    # + backgroundColor - Optional. The background color represented as hex string #RRGGBB (ex #000000).
    #                         This field is required in order to set the color of a label.
    # + textColor - Optional. The text color of the label, represented as hex string. This field is required in order
    #                   to set the color of a label.
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns ID of the created label. If not, returns error.
    @display {label: "Create Label"}
    remote isolated function createLabel(@display {label: "Label Name"} string name,
                                         @display {label: "Label Visibility"} string labelListVisibility,
                                         @display {label: "Message List Visibility"} string messageListVisibility, 
                                         @display {label: "Background Color"} string? backgroundColor = (), 
                                         @display {label: "Text Color"} string? textColor = (),
                                         @display {label: "Email Address"} string? userId = ())
                                         returns @tainted @display {label: "Label"} Label|error {
        
        string createLabelPath = USER_RESOURCE + (userId is string ? userId : ME) + LABEL_RESOURCE;
        map<json> jsonPayload = {
            labelListVisibility: labelListVisibility,
            messageListVisibility: messageListVisibility,
            name: name
        };

        if (backgroundColor != ()) {
            jsonPayload["backgroundColor"] = backgroundColor;
        }
        if (textColor != ()) {
            jsonPayload["textColor"] = textColor;
        }
        http:Request request = new;
        request.setJsonPayload(jsonPayload);
        http:Response httpResponse = <http:Response> check self.gmailClient->post(createLabelPath, request);
        json jsonCreateLabelResponse = check handleResponse(httpResponse);
        return jsonCreateLabelResponse.cloneWithType(Label);
    }

    # Lists all labels in the user's mailbox.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns an array of Label type objects with values for a set of main fields only. (Use
    #            `getLabel` to get all the details for a specific label) If not successful, returns error.
    @display {label: "List Labels"}
    remote isolated function listLabels(@display {label: "Email Address"} string? userId = ())
                                        returns @tainted @display {label: "Labels"} LabelList|error {
        
        string listLabelsPath = USER_RESOURCE + (userId is string ? userId : ME) + LABEL_RESOURCE;
        http:Response httpResponse = <http:Response> check self.gmailClient->get(listLabelsPath);
        json jsonLabelListResponse = check handleResponse(httpResponse);
        return jsonLabelListResponse.cloneWithType(LabelList);
    }

    # Deletes a label.
    #
    # + labelId - The ID of the label to delete
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns nothing. Else returns error.
    @display {label: "Delete Label"}
    remote isolated function deleteLabel(@display {label: "Label ID"} string labelId,
                                         @display {label: "Email Address"} string? userId = ()) 
                                         returns @tainted @display {label: "Status"} error? {
        http:Request request = new;
        string deleteLabelPath = USER_RESOURCE + (userId is string ? userId : ME) + LABEL_RESOURCE +
                                 FORWARD_SLASH_SYMBOL + labelId;
        http:Response httpResponse = <http:Response> check self.gmailClient->delete(deleteLabelPath, request);
        var handledResponse = handleResponse(httpResponse);
        if (handledResponse is error) {
            return handledResponse;
        }
    }

    # Updates a label.
    #
    # + labelId - The ID of the label to update
    # + name - Optional. The display name of the label
    # + messageListVisibility - Optional. The visibility of messages with this label in the message list in the Gmail
    #                               web interface.
    #                               Acceptable values are:
    #
    #                               `hide`: Do not show the label in the message list
    #                               `show`: Show the label in the message list
    # + labelListVisibility - Optional. The visibility of the label in the label list in the Gmail web interface.
    #                             Acceptable values are:
    #
    #                             `labelHide`: Do not show the label in the label list
    #                             `labelShow`: Show the label in the label list
    #                             `labelShowIfUnread`: Show the label if there are any unread messages with that label
    # + backgroundColor - Optional. The background color represented as hex string #RRGGBB (ex #000000).
    # + textColor - Optional. The text color of the label, represented as hex string.
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns updated Label type object. Else returns error.
    @display {label: "Update Label"}
    remote isolated function updateLabel(@display {label: "Label ID"} string labelId, 
                                         @display {label: "Label Name"} string? name = (),
                                         @display {label: "Message List Visibility"} string? messageListVisibility =(),
                                         @display {label: "Label Visibility"} string? labelListVisibility = (), 
                                         @display {label: "Background Color"} string? backgroundColor = (), 
                                         @display {label: "Text Color"} string? textColor = (),
                                         @display {label: "Email Address"} string? userId = ()) 
                                         returns @tainted @display {label: "Label"} Label|error {

        string updateLabelPath = USER_RESOURCE + (userId is string ? userId : ME) + LABEL_RESOURCE +
                                 FORWARD_SLASH_SYMBOL + labelId;

        map<json> jsonPayload = {
            id: labelId
        };

        if (name is string) {
            jsonPayload["name"] = name;
        }
        if (messageListVisibility is string) {
            jsonPayload["messageListVisibility"] = messageListVisibility;
        }
        if (labelListVisibility is string) {
            jsonPayload["labelListVisibility"] = labelListVisibility;
        }

        map<json> color = {};
        if (backgroundColor is string) {
            color["backgroundColor"] = backgroundColor;
        }
        if (textColor is string) {
            color["textColor"] = textColor;
        }
        jsonPayload["color"] = color;

        http:Request request = new;
        request.setJsonPayload(jsonPayload);
        http:Response httpResponse = <http:Response> check self.gmailClient->patch(updateLabelPath, request);

        json jsonUpdateResponse = check handleResponse(httpResponse);
        return jsonUpdateResponse.cloneWithType(Label);
    }

    # Lists the history of all changes to the given mailbox. History results are returned in chronological order
    #   (increasing historyId).
    #
    # + startHistoryId -  Returns history records after the specified startHistoryId
    # + historyTypes - Optional. Array of history types to be returned by the function.
    #                      Acceptable values are:
    #
    #                        `labelAdded`
    #                        `labelRemoved`
    #                        `messageAdded`
    #                        `messageDeleted`
    # + labelId - Optional. Only return messages with a label matching the ID
    # + maxResults - Optional. The maximum number of history records to return
    # + pageToken - Optional. Page token to retrieve a specific page of results in the list
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns stream<History,error?>. Else returns error.
    @display {label: "List History"}
    remote isolated function listHistory(@display {label: "Start History ID"} string startHistoryId,
                                         @display {label: "History Type"} string[]? historyTypes = (),
                                         @display {label: "Label ID"} string? labelId = (),
                                         @display {label: "Maximum Records"} string? maxResults = (),
                                         @display {label: "Page Token"} string? pageToken = (),
                                         @display {label: "Email Address"} string? userId = ()) returns @tainted
                                         @display {label: "Mailbox History Page"}stream<History,error?>|error {
        
        MailboxHistoryStream mailboxHistoryStream = check new MailboxHistoryStream (self.gmailClient,
                                                                                    userId is string ? userId : ME,
                                                                                    startHistoryId, historyTypes,
                                                                                    labelId, maxResults, pageToken);
        return new stream<History,error?>(mailboxHistoryStream);
    }

    # Lists the drafts in user's mailbox.
    #
    # + filter - Optional. DraftSearchFilter with optional query parameters to search drafts.
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns stream<Draft,error?>. Else returns error.
    @display {label: "List Drafts"}
    remote isolated function listDrafts(@display {label: "Drafts Search Filter"} DraftSearchFilter? filter = (),
                                        @display {label: "Email Address"} string? userId = ()) 
                                        returns @tainted @display {label: "Drafts"} stream<Draft,error?>|error {
        
        DraftStream draftStream = check new DraftStream (self.gmailClient, userId is string ? userId : ME, filter);
        return new stream<Draft,error?>(draftStream);
    }

    # Reads the specified draft from users mailbox.
    #
    # + draftId - The ID of the draft to retrieve
    # + format - Optional. The format to return the draft in.
    #              Acceptable values for format for a get draft request are defined as following constants
    #              in the module:
    #
    #                `FORMAT_FULL` : Returns the full email message data with body content parsed in the payload
    #                                field;the raw field is not used. (default)
    #
    #                `FORMAT_METADATA` : Returns only email message ID, labels, and email headers.
    #
    #                `FORMAT_MINIMAL` : Returns only email message ID and labels; does not return the email headers,
    #                                  body, or payload.
    #
    #                `FORMAT_RAW` : Returns the full email message data with body content in the raw field as a
    #                               base64url encoded string. (the payload field is not included in the response)
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns Draft type of the specified draft. Else returns error.
    @display {label: "Read Draft"}
    remote isolated function readDraft(@display {label: "Draft ID"} string draftId,
                                       @display {label: "Draft Format"} string? format = (),
                                       @display {label: "Email Address"} string? userId = ()) 
                                       returns @tainted @display {label: "Draft"} Draft|error {
        string uriParams = "";
        //Append format query parameter
        if (format is string) {
            uriParams = check appendEncodedURIParameter(uriParams, FORMAT, format);
        }
        string readDraftPath = USER_RESOURCE + (userId is string ? userId : ME) + DRAFT_RESOURCE + FORWARD_SLASH_SYMBOL
                               + draftId + uriParams;
        http:Response httpResponse = <http:Response> check self.gmailClient->get(readDraftPath);
        json jsonReadDraftResponse = check handleResponse(httpResponse);
        return convertJSONToDraftType(<@untainted>jsonReadDraftResponse);
    }

    # Immediately and permanently deletes the specified draft.
    #
    # + draftId - The ID of the draft to delete
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns nothing. Else returns error.
    @display {label: "Delete Draft"}
    remote isolated function deleteDraft(@display {label: "Draft ID"} string draftId,
                                         @display {label: "Email Address"} string? userId = ()) 
                                         returns @tainted @display {label: "Status"} error? {
        http:Request request = new;
        string deleteDraftPath = USER_RESOURCE + (userId is string ? userId : ME) + DRAFT_RESOURCE +
                                 FORWARD_SLASH_SYMBOL + draftId;
        http:Response httpResponse = <http:Response> check self.gmailClient->delete(deleteDraftPath, request);
        var handledResponse = handleResponse(httpResponse);
        if (handledResponse is error) {
            return handledResponse;
        }
    }

    # Creates a new draft with the DRAFT label.
    #
    # + message - MessageRequest to create a draft
    # + threadId - Optional. Thread ID of the draft to reply
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns the draft ID of the created Draft. Else returns error.
    @display {label: "Create Draft"}
    remote isolated function createDraft(@display {label: "Message Request"} MessageRequest message,
                                         @display {label: "Thread ID"} string? threadId = (),
                                         @display {label: "Email Address"} string? userId = ())
                                         returns @tainted @display {label: "Draft ID"} string|error {

        string encodedRequest = check createEncodedRawMessage(message);
        http:Request request = new;

        map<json> jsonPayload = {};
        map<json> mssg = {
            raw: encodedRequest
        };

        if (threadId is string) {
            mssg["threadId"] = threadId;
        }
        jsonPayload["message"] = mssg;

        string createDraftPath = USER_RESOURCE + (userId is string ? userId : ME) + DRAFT_RESOURCE;
        request.setJsonPayload(<@untainted>jsonPayload);
        http:Response httpResponse = <http:Response> check self.gmailClient->post(createDraftPath, request);
        json jsonCreateDraftResponse = check handleResponse(httpResponse);
        return let var id = jsonCreateDraftResponse.id in id is string ? id : EMPTY_STRING;
    }

    # Replaces a draft's content.
    #
    # + draftId - The draft ID to update
    # + message - MessageRequest to update a draft
    # + threadId - Optional. Thread ID of the draft to reply
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns the draft ID of the updated Draft. Else returns error.
    @display {label: "Update Draft"}
    remote isolated function updateDraft(@display {label: "Draft ID"} string draftId, 
                                         @display {label: "Message Request"} MessageRequest message, 
                                         @display {label: "Thread ID"} string? threadId = (),
                                         @display {label: "Email Address"} string? userId = ())
                                         returns @tainted @display {label: "Draft ID"} string|error {
        
        string encodedRequest = check createEncodedRawMessage(message);
        http:Request request = new;

        map<json> jsonPayload = {};
        map<json> mssg = {
            raw: encodedRequest
        };

        if (threadId is string) {
            mssg["threadId"] = threadId;
        }
        jsonPayload["message"] = mssg;

        string updateDraftPath = USER_RESOURCE + (userId is string ? userId : ME) + DRAFT_RESOURCE +
                                 FORWARD_SLASH_SYMBOL + draftId;
        request.setJsonPayload(<@untainted>jsonPayload);
        http:Response httpResponse = <http:Response> check self.gmailClient->put(updateDraftPath, request);
        json jsonUpdateDraftResponse = check handleResponse(httpResponse);
        return let var id = jsonUpdateDraftResponse.id in id is string ? id : EMPTY_STRING;
    }

    # Sends the specified, existing draft to the recipients in the To, Cc, and Bcc headers.
    #
    # + draftId - The draft ID to send
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns Message record of the sent Draft. Else returns error.
    @display {label: "Send Draft"} 
    remote isolated function sendDraft(@display {label: "Draft ID"} string draftId,
                                       @display {label: "Email Address"} string? userId = ()) 
                                       returns @tainted @display {label: "Sent Message Response"} Message |error {
        http:Request request = new;
        json jsonPayload = {id: draftId};
        string updateDraftPath = USER_RESOURCE + (userId is string ? userId : ME) + DRAFT_SEND_RESOURCE;
        request.setJsonPayload(jsonPayload);
        http:Response httpResponse = <http:Response> check self.gmailClient->post(updateDraftPath, request);        
        json jsonSendDraftResponse = check handleResponse(httpResponse);
        return check jsonSendDraftResponse.cloneWithType(Message);
    }
}
