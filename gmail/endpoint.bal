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

# Gmail Client object.
#
# + gmailClient - The HTTP Client
@display {label: "Gmail Client", iconPath: "GmailLogo.png"}
public client class Client {
    http:Client gmailClient;

    public isolated  function init(GmailConfiguration gmailConfig) {
        // Create OAuth2 provider.
        http:ClientSecureSocket? socketConfig = gmailConfig?.secureSocketConfig;

        // Create gmail http client.
        if (socketConfig is http:ClientSecureSocket) {
            self.gmailClient = checkpanic new (BASE_URL, {
                auth: gmailConfig.oauthClientConfig,
                secureSocket: socketConfig
            });
        } else {
            self.gmailClient = checkpanic new (BASE_URL, {
                auth: gmailConfig.oauthClientConfig
            });
        }
    }

    # List the messages in user's mailbox.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + filter - Optional. MsgSearchFilter with optional query parameters to search messages.
    # + return - If successful, returns MessageListPage. Else returns error.
    @display {label: "List messages"} 
    remote isolated  function listMessages(@display {label: "Mail address of user"} string userId, 
                                           @display {label: "Message search filter"} MsgSearchFilter? filter = ())
                                           returns @tainted @display {label: "Message list page"} MessageListPage|error {
        string getListMessagesPath = USER_RESOURCE + userId + MESSAGE_RESOURCE;
        if (filter is MsgSearchFilter) {
            string uriParams = "";
            //The default value for include spam trash query parameter of the api call is false
            //If append unsuccessful throws and returns error
            uriParams = filter?.includeSpamTrash is boolean ? check appendEncodedURIParameter(uriParams, INCLUDE_SPAMTRASH,
                string `${<boolean>filter?.includeSpamTrash}`) : uriParams;
            //---Append other optional URI query parameters---
            if (filter?.labelIds is string[]) {
                foreach string labelId in <string[]>filter?.labelIds {
                    uriParams = check appendEncodedURIParameter(uriParams, LABEL_IDS, labelId);
                }
            }
            //Empty check is done since these parameters are optional to be filled in MsgSearchFilter Type object
            uriParams = filter?.maxResults is int ? check appendEncodedURIParameter(uriParams, MAX_RESULTS, 
                filter?.maxResults.toString()) : uriParams;
            uriParams = filter?.pageToken is string ? check appendEncodedURIParameter(uriParams, PAGE_TOKEN, 
                <string>filter?.pageToken) : uriParams;
            uriParams = filter?.q is string ? check appendEncodedURIParameter(uriParams, QUERY, <string>filter?.q) : 
                uriParams;
            getListMessagesPath = getListMessagesPath + <@untainted>uriParams;
        }
        http:Response httpResponse = <http:Response> check self.gmailClient->get(getListMessagesPath);
        //Get json msg list reponse. If unsuccessful throws and returns error.
        json jsonlistMsgResponse = check handleResponse(httpResponse);
        return check jsonlistMsgResponse.cloneWithType(MessageListPage);
    }

    # Create the raw base 64 encoded string of the whole message and send it as an email from the user's
    # mailbox to its recipient.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + message - MessageRequest to send
    # + threadId - Optional. Required if message is expected to be send The ID of the thread the message belongs to.
    # (The Subject headers must match)
    # + return - If successful, returns Message record of the successfully sent message. Else return error.
    @display {label: "Send message"} 
    remote function sendMessage(@display {label: "Mail address of user"} string userId,
                                @display {label: "Message request to send"} MessageRequest message,
                                @display {label: "Thread id"} string? threadId = ())
                                returns @tainted @display {label: "Sent Message Response"} Message|error {
        //Create the whole message as an encoded raw string. If unsuccessful throws and returns error.
        string encodedRequest = check createEncodedRawMessage(message);
        http:Request request = new;
        map<json> jsonPayload = {raw: encodedRequest};
        //Thread Id is optional. If the messages is expected to be sent as a reply, thread Id is added to the payload.
        if (threadId is string) {
            jsonPayload["threadId"] = threadId;
        }
        string sendMessagePath = USER_RESOURCE + userId + MESSAGE_SEND_RESOURCE;
        request.setJsonPayload(<@untainted>jsonPayload);
        
        http:Response httpResponse = <http:Response> check self.gmailClient->post(sendMessagePath, request);
        //Get json sent msg response. If unsuccessful throws and returns error.
        json jsonSendMessageResponse = check handleResponse(httpResponse);
        return check jsonSendMessageResponse.cloneWithType(Message);
    }

    # Read the specified mail from users mailbox.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + messageId - The id of the message to retrieve
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
    # + return - If successful, returns Message type object of the specified mail. Else returns error.
    @display {label: "Read message"} 
    remote function readMessage(@display {label: "Mail address of user"} string userId,
                                @display {label: "Message id"} string messageId,
                                @display {label: "Message format"} string? format = (), 
                                @display {label: "Metadata headers"} string[]? metadataHeaders = ())
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
        string readMessagePath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId 
            + uriParams;
        http:Response httpResponse = <http:Response> check self.gmailClient->get(readMessagePath);
        //Get json message response. If unsuccessful, throws and returns error.
        json jsonreadMessageResponse = check handleResponse(httpResponse);
        //Transform the json mail response from Gmail API to Message type. If unsuccessful, throws and returns error.
        return convertJSONToMessageType(<@untainted>jsonreadMessageResponse);
    }

    # Gets the specified message attachment from users mailbox.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + messageId - The id of the message to retrieve
    # + attachmentId - The id of the attachment to retrieve
    # + return - If successful, returns MessageBodyPart type object of the specified attachment. Else returns error.
    @display {label: "Get attachment"} 
    remote isolated function getAttachment(@display {label: "Mail address of user"} string userId,
                                           @display {label: "Message id"} string messageId,
                                           @display {label: "Attachment id"} string attachmentId)
                                           returns @tainted @display {label: "Message body part"} MessageBodyPart | 
                                           error {
        string getAttachmentPath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId
            + ATTACHMENT_RESOURCE + attachmentId;
        http:Response httpResponse = <http:Response> check self.gmailClient->get(getAttachmentPath);
        //Get json attachment response. If unsuccessful, throws and returns error.
        json jsonAttachment = check handleResponse(httpResponse);
        //Transform the json attachment message body response from Gmail API to MessageBodyPart type.
        MessageBodyPart receivedMessageBodyPart = check jsonAttachment.cloneWithType(MessageBodyPart);
        return getFormattedBase64MessageBodyPart(receivedMessageBodyPart);
    }

    # Move the specified message to the trash.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + messageId - The id of the message to trash
    # + return - If successful, returns boolean specifying the status of trashing. Else returns error.
    @display {label: "Trash a message"} 
    remote isolated function trashMessage(@display {label: "Mail address of user"} string userId,
                                          @display {label: "Message id"} string messageId) 
                                          returns @tainted @display {label: "Status"} boolean|error {
        http:Request request = new;
        string trashMessagePath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId
            + FORWARD_SLASH_SYMBOL + TRASH;
        http:Response httpResponse = <http:Response> check self.gmailClient->post(trashMessagePath, request);
        //Get json trash response. If unsuccessful, throws and returns error.
        json jsonTrashMessageResponse = check handleResponse(httpResponse);
        //Return status of trashing message
        return let var id = jsonTrashMessageResponse.id in id is string ? id == messageId ? true : false : false;
    }

    # Removes the specified message from the trash.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + messageId - The id of the message to untrash
    # + return - If successful, returns boolean specifying the status of untrashing. Else returns error.
    @display {label: "Untrash a message"} 
    remote isolated function untrashMessage(@display {label: "Mail address of user"} string userId, 
                                            @display {label: "Message id"} string messageId) 
                                            returns @tainted @display {label: "Status"} boolean|error {
        http:Request request = new;
        string untrashMessagePath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId
            + FORWARD_SLASH_SYMBOL + UNTRASH;
        http:Response httpResponse = <http:Response> check self.gmailClient->post(untrashMessagePath, request);
        //Get json untrash response. If unsuccessful, throws and returns error.
        json jsonUntrashMessageReponse = check handleResponse(httpResponse);
        //Return status of untrashing message
        return let var id = jsonUntrashMessageReponse.id in id is string ? id == messageId ? true : false : false;
    }

    # Immediately and permanently deletes the specified message. This operation cannot be undone.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + messageId - The id of the message to delete
    # + return - If successful, returns boolean status of deletion. Else returns error.
    @display {label: "Delete a message"}
    remote isolated function deleteMessage(@display {label: "Mail address of user"} string userId,
                                           @display {label: "Message id"} string messageId) 
                                           returns @tainted @display {label: "Status"} boolean|error {
        http:Request request = new;
        string deleteMessagePath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId;
        http:Response httpResponse = <http:Response> check self.gmailClient->delete(deleteMessagePath, request);
        //Return boolean status of message deletion response. If unsuccessful, throws and returns error.
        return <boolean>check handleResponse(httpResponse);
    }

    # Modifies the labels on the specified message.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + messageId - The id of the message to modify
    # + addLabelIds - A list of Ids of labels to add to this message
    # + removeLabelIds - A list Ids of labels to remove from this message
    # + return - If successful, returns modified Message type object in **minimal** format. Else returns error.
    @display {label: "Modify message labels"} 
    remote function modifyMessage(@display {label: "Mail address of user"} string userId, 
                                  @display {label: "Message id"} string messageId, 
                                  @display {label: "Labels to add"} string[] addLabelIds, 
                                  @display {label: "Labels to remove"} string[] removeLabelIds)
                                  returns @tainted @display {label: "Message"} Message|error {
        string modifyMsgPath = USER_RESOURCE + userId + MESSAGE_RESOURCE + FORWARD_SLASH_SYMBOL + messageId
            + MODIFY_RESOURCE;
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
        //Transform the json mail response from Gmail API to Message type in minimal format. If unsuccessful throws and
        //returns error.
        return convertJSONToMessageType(<@untainted>check handleResponse(httpResponse));
    }

    # List the threads in user's mailbox.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + filter - Optional. The MsgSearchFilter with optional query parameters to search a thread.
    # + return - If successful, returns ThreadListPage type. Else returns error.
    @display {label: "List threads"} 
    remote isolated function listThreads(@display {label: "Mail address of user"} string userId,
                                         @display {label: "Message search filter"} MsgSearchFilter? filter = ()) 
                                         returns @tainted @display {label: "Thread list page"} ThreadListPage|error {
        string getListThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE;
        if (filter is MsgSearchFilter) {
            string uriParams = "";
            //The default value for include spam trash query parameter of the api call is false
            //If append unsuccessful throws and returns error
            uriParams = filter?.includeSpamTrash is boolean ? check appendEncodedURIParameter(uriParams, INCLUDE_SPAMTRASH,
                string `${<boolean>filter?.includeSpamTrash}`) : uriParams;
            //---Append other optional URI query parameters---
            if (filter?.labelIds is string[]){
                foreach string labelId in <string[]>filter?.labelIds {
                    uriParams = check appendEncodedURIParameter(uriParams, LABEL_IDS, labelId);
                }
            }
            //Empty check is done since these parameters are optional to be filled in MsgSearchFilter Type object
            uriParams = filter?.maxResults is int ? check appendEncodedURIParameter(uriParams, MAX_RESULTS, 
                filter?.maxResults.toString()) : uriParams;
            uriParams = filter?.pageToken is string ? check appendEncodedURIParameter(uriParams, PAGE_TOKEN, 
                <string>filter?.pageToken) : uriParams;
            uriParams = filter?.q is string ? check appendEncodedURIParameter(uriParams, QUERY, <string>filter?.q) : 
                uriParams;
            getListThreadPath = getListThreadPath + <@untainted>uriParams;
        }
        http:Response httpResponse = <http:Response> check self.gmailClient->get(getListThreadPath);
        //Get json thread list reponse. If unsuccessful throws and returns error.
        json jsonListThreadResponse = check handleResponse(httpResponse);
        return jsonListThreadResponse.cloneWithType(ThreadListPage);
    }

    # Read the specified mail thread from users mailbox.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + threadId - The id of the thread to retrieve
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
    # + return - If successful, returns MailThread type of the specified mail thread. Else returns error.
    @display {label: "Read thread"}
    remote function readThread(@display {label: "Mail address of user"} string userId,
                               @display {label: "Thread id"} string threadId,
                               @display {label: "Message format"} string? format = (),
                               @display {label: "Metadata headers"} string[]? metadataHeaders = ())
                               returns @tainted @display {label: "Mail thread"} MailThread|error {
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
        string readThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId + uriParams;
        http:Response httpResponse = <http:Response> check self.gmailClient->get(readThreadPath);
        //Get json thread response. If unsuccessful, throws and returns error.
        json jsonReadThreadResponse = check handleResponse(httpResponse);
        //Transform the json thread response from Gmail API to MailThread type. If unsuccessful, throws and returns error.
        return convertJSONToThreadType(<@untainted>jsonReadThreadResponse);
    }

    # Move the specified mail thread to the trash.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + threadId - The id of the thread to trash
    # + return - If successful, returns boolean status of trashing. Else returns error.
    @display {label: "Trash thread"} 
    remote isolated function trashThread(@display {label: "Mail address of user"} string userId,
                                         @display {label: "Thread id"} string threadId) 
                                         returns @tainted @display {label: "Status"} boolean|error {
        http:Request request = new;
        string trashThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId
            + FORWARD_SLASH_SYMBOL + TRASH;
        http:Response httpResponse = <http:Response> check self.gmailClient->post(trashThreadPath, request);
        //Get json trash response. If unsuccessful, throws and returns error.
        json jsonTrashThreadResponse = check handleResponse(httpResponse);
        //Return status of trashing thread
        return let var id = jsonTrashThreadResponse.id in id is string ? id == threadId ? true : false : false;
    }

    # Removes the specified mail thread from the trash.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + threadId - The id of the thread to untrash
    # + return - If successful, returns boolean status of untrashing. Else returns error.
    @display {label: "Untrash thread"} 
    remote isolated function untrashThread(@display {label: "Mail address of user"} string userId,
                                           @display {label: "Thread id"} string threadId) 
                                           returns @tainted @display {label: "Status"} boolean|error {
        http:Request request = new;
        string untrashThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId
            + FORWARD_SLASH_SYMBOL + UNTRASH;
        http:Response httpResponse = <http:Response> check self.gmailClient->post(untrashThreadPath, request);
        //Get json untrash response. If unsuccessful, throws and returns error.
        json jsonUntrashThreadResponse = check handleResponse(httpResponse);
        //Return status of untrashing thread
        return let var id = jsonUntrashThreadResponse.id in id is string ? id == threadId ? true : false : false;
    }

    # Immediately and permanently deletes the specified mail thread. This operation cannot be undone.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + threadId - The id of the thread to delete
    # + return - If successful, returns boolean status of deletion. Else returns error.
    @display {label: "Delete thread"}
    remote isolated function deleteThread(@display {label: "Mail address of user"} string userId,
                                          @display {label: "Thread id"} string threadId) 
                                          returns @tainted @display {label: "Status"} boolean|error {
        http:Request request = new;
        string deleteThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId;
        http:Response httpResponse = <http:Response> check self.gmailClient->delete(deleteThreadPath, request);
        //Return boolean status of thread deletion response. If unsuccessful, throws and returns error.
        return <boolean>check handleResponse(httpResponse);
    }

    # Modifies the labels on the specified thread.
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + threadId - The id of the thread to modify
    # + addLabelIds - A list of IDs of labels to add to this thread
    # + removeLabelIds - A list IDs of labels to remove from this thread
    # + return - If successful, returns modified MailThread type object. Else returns error.
    @display {label: "Modify labels on thread"}
    remote function modifyThread(@display {label: "Mail address of user"} string userId, 
                                 @display {label: "Thread id"} string threadId, 
                                 @display {label: "Labels to add"} string[] addLabelIds, 
                                 @display {label: "Labels to remove"} string[] removeLabelIds)
                                 returns @tainted @display {label: "Mail thread"} MailThread|error {
        string modifyThreadPath = USER_RESOURCE + userId + THREAD_RESOURCE + FORWARD_SLASH_SYMBOL + threadId
            + MODIFY_RESOURCE;
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
        //Transform the json thread response from Gmail API to MailThread type. If unsuccessful throws and returns error.
        return convertJSONToThreadType(<@untainted>check handleResponse(httpResponse));
    }

    # Get the current user's Gmail Profile.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns UserProfile type. Else returns error.
    @display {label: "Get user profile"}
    remote isolated function getUserProfile(@display {label: "Mail address of user"} string userId)
                                            returns @tainted @display {label: "User profile"} UserProfile|error {
        string getProfilePath = USER_RESOURCE + userId + PROFILE_RESOURCE;
        http:Response httpResponse = <http:Response> check self.gmailClient->get(getProfilePath);
        //Get json user profile response. If unsuccessful, throws and returns error.
        json jsonProfileResponse = check handleResponse(httpResponse);
        //Transform the json profile response from Gmail API to User Profile type.
        return jsonProfileResponse.cloneWithType(UserProfile);
    }

    # Get the label.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + labelId - The label Id
    # + return - If successful, returns Label type. Else returns error.
    @display {label: "Get label"}
    remote isolated function getLabel(@display {label: "Mail address of user"} string userId,
                                      @display {label: "Label id"} string labelId) 
                                      returns @tainted @display {label: "Label"} Label|error {
        string getLabelPath = USER_RESOURCE + userId + LABEL_RESOURCE + FORWARD_SLASH_SYMBOL + labelId;
        http:Response httpResponse = <http:Response> check self.gmailClient->get(getLabelPath);
        //Get json label response. If unsuccessful, throws and returns error.
        json jsonGetLabelResponse = check handleResponse(httpResponse);
        //Transform the json label response from Gmail API to Label type.
        return jsonGetLabelResponse.cloneWithType(Label);
    }

    # Create a new label.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + name - The display name of the label
    # + labelListVisibility - The visibility of the label in the label list in the Gmail web interface.
    #                             Acceptable values are:
    #
    #                            `labelHide`: Do not show the label in the label list.
    #                            `labelShow`: Show the label in the label list.
    #                            `labelShowIfUnread`: Show the label if there are any unread messages with that label.
    # + messageListVisibility - The visibility of messages with this label in the message list in the Gmail web interface.
    #                               Acceptable values are:
    #
    #                               `hide`: Do not show the label in the message list.
    #                               `show`: Show the label in the message list. (Default)
    # + backgroundColor - Optional. The background color represented as hex string #RRGGBB (ex #000000).
    #                         This field is required in order to set the color of a label.
    # + textColor - Optional. The text color of the label, represented as hex string. This field is required in order
    #                   to set the color of a label.
    # + return - If successful, returns id of the created label. If not, returns error.
    @display {label: "Create label"}
    remote isolated function createLabel(@display {label: "Mail address of user"} string userId,
                                         @display {label: "Label name"} string name,
                                         @display {label: "Label visibility"} string labelListVisibility,
                                         @display {label: "Message list visibility"} string messageListVisibility, 
                                         @display {label: "Background colour"} string? backgroundColor = (), 
                                         @display {label: "Text colour"} string? textColor = ())
                                         returns @tainted @display {label: "Label id"} Label|error {
        string createLabelPath = USER_RESOURCE + userId + LABEL_RESOURCE;
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
        //Get create label json response. If unsuccessful, throws and returns error.
        json jsonCreateLabelResponse = check handleResponse(httpResponse);
        //Returns the label id of the created label
        return jsonCreateLabelResponse.cloneWithType(Label);
    }

    # Lists all labels in the user's mailbox.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, returns an array of Label type objects with values for a set of main fields only. (Use
    #            `getLabel` to get all the details for a specific label) If not successful, returns error.
    @display {label: "List labels"}
    remote isolated function listLabels(@display {label: "Mail address of user"} string userId)
                                        returns @tainted @display {label: "Labels"} LabelList|error {
        string listLabelsPath = USER_RESOURCE + userId + LABEL_RESOURCE;
        http:Response httpResponse = <http:Response> check self.gmailClient->get(listLabelsPath);
        //Get list labels json response. If unsuccessful, throws and returns error.
        json jsonLabelListResponse = check handleResponse(httpResponse);
        return jsonLabelListResponse.cloneWithType(LabelList);
    }

    # Delete a label.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + labelId - The id of the label to delete
    # + return - If successful, returns boolean status of deletion. Else returns error.
    @display {label: "Delete label"}
    remote isolated function deleteLabel(@display {label: "Mail address of user"} string userId,
                                         @display {label: "Label id"} string labelId) 
                                         returns @tainted @display {label: "Status"} boolean|error {
        http:Request request = new;
        string deleteLabelPath = USER_RESOURCE + userId + LABEL_RESOURCE + FORWARD_SLASH_SYMBOL + labelId;
        http:Response httpResponse = <http:Response> check self.gmailClient->delete(deleteLabelPath, request);
        //Return boolean status of label deletion response. If unsuccessful, throws and returns error.
        return <boolean>check handleResponse(httpResponse);
    }

    # Update a label.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + labelId - The id of the label to update
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
    # + return - If successful, returns updated Label type object. Else returns error.
    @display {label: "Update label"}
    remote isolated function updateLabel(@display {label: "Mail address of user"} string userId,
                                         @display {label: "Label id"} string labelId, 
                                         @display {label: "Label name"} string? name = (),
                                         @display {label: "Message list visibility"} string? messageListVisibility =(),
                                         @display {label: "Label visibility"} string? labelListVisibility = (), 
                                         @display {label: "Background colour"} string? backgroundColor = (), 
                                         @display {label: "Text colour"} string? textColor = ()) 
                                         returns @tainted @display {label: "Label"} Label|error {
        string updateLabelPath = USER_RESOURCE + userId + LABEL_RESOURCE + FORWARD_SLASH_SYMBOL + labelId;

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
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
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
    # + return - If successful, returns MailboxHistoryPage. Else returns error.
    @display {label: "List history"}
    remote function listHistory(@display {label: "Mail address of user"} string userId,
                                @display {label: "Start history id"} string startHistoryId,
                                @display {label: "History type"} string[]? historyTypes = (),
                                @display {label: "Label id"} string? labelId = (),
                                @display {label: "Maximum records"} string? maxResults = (),
                                @display {label: "Page token"} string? pageToken = ()) 
                                returns @tainted @display {label: "Mail box history page"} MailboxHistoryPage|error {
        string uriParams = "";
        uriParams = check appendEncodedURIParameter(uriParams, START_HISTORY_ID, startHistoryId);
        if (historyTypes is string[]) {
            //Append optional query parameter history types to be returned
            foreach string historyType in historyTypes {
                uriParams = check appendEncodedURIParameter(uriParams, HISTORY_TYPES, historyType);
            }
        }
        if (labelId is string) {
            uriParams = check appendEncodedURIParameter(uriParams, LABEL_ID, labelId);
        }
        if (maxResults is string) {
            uriParams = check appendEncodedURIParameter(uriParams, MAX_RESULTS, maxResults);
        }
        if (pageToken is string) {
            uriParams = check appendEncodedURIParameter(uriParams, PAGE_TOKEN, pageToken);
        }
        string listHistoryPath = USER_RESOURCE + userId + HISTORY_RESOURCE + uriParams;
        http:Response httpResponse = <http:Response> check self.gmailClient->get(listHistoryPath);
        //Get json history reponse. If unsuccessful, throws and returns error.
        json jsonHistoryResponse = check handleResponse(httpResponse);
        //Transform the json history response from Gmail API to Mailbox History Page type.s
        return convertJSONToMailboxHistoryPage(<@untainted>jsonHistoryResponse);
    }

    # List the drafts in user's mailbox.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + filter - Optional. DraftSearchFilter with optional query parameters to search drafts.
    # + return - If successful, returns DraftListPage. Else returns error.
    @display {label: "List drafts"}
    remote isolated function listDrafts(@display {label: "Mail address of user"} string userId,
                                        @display {label: "Drafts search filter"} DraftSearchFilter? filter = ()) 
                                        returns @tainted @display {label: "Drafts list page"} DraftListPage|error {
        string getListDraftsPath = USER_RESOURCE + userId + DRAFT_RESOURCE;
        if (filter is DraftSearchFilter) {
            string uriParams = "";
            //The default value for include spam trash query parameter of the api call is false
            uriParams = filter?.includeSpamTrash is boolean ? check appendEncodedURIParameter(uriParams, INCLUDE_SPAMTRASH,
                string `${<boolean>filter?.includeSpamTrash}`) : uriParams;
            uriParams = filter?.maxResults is int ? check appendEncodedURIParameter(uriParams, MAX_RESULTS, 
                filter?.maxResults.toString()) : uriParams;
            uriParams = filter?.pageToken is string ? check appendEncodedURIParameter(uriParams, PAGE_TOKEN, 
                <string>filter?.pageToken) : uriParams;
            uriParams = filter?.q is string ? check appendEncodedURIParameter(uriParams, QUERY, <string>filter?.q) : 
                uriParams;
            getListDraftsPath += <@untainted>uriParams;
        }
        http:Response httpResponse = <http:Response> check self.gmailClient->get(getListDraftsPath);
        json jsonListDraftResponse = check handleResponse(httpResponse);
        return jsonListDraftResponse.cloneWithType(DraftListPage);
    }

    # Read the specified draft from users mailbox.
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + draftId - The id of the draft to retrieve
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
    # + return - If successful, returns Draft type of the specified draft. Else returns error.
    @display {label: "Read draft"}
    remote function readDraft(@display {label: "Mail address of user"} string userId, 
                              @display {label: "Draft id"} string draftId,
                              @display {label: "Draft format"} string? format = ()) 
                              returns @tainted @display {label: "Draft"} Draft|error {
        string uriParams = "";
        //Append format query parameter
        if (format is string) {
            uriParams = check appendEncodedURIParameter(uriParams, FORMAT, format);
        }
        string readDraftPath = USER_RESOURCE + userId + DRAFT_RESOURCE + FORWARD_SLASH_SYMBOL + draftId + uriParams;
        http:Response httpResponse = <http:Response> check self.gmailClient->get(readDraftPath);
        //Get json draft response. If unsuccessful, throws and returns error.
        json jsonReadDraftResponse = check handleResponse(httpResponse);
        //Transform the json draft response from Gmail API to Draft type. If unsuccessful, throws and returns error.
        return convertJSONToDraftType(<@untainted>jsonReadDraftResponse);
    }

    # Immediately and permanently deletes the specified draft.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + draftId - The id of the draft to delete
    # + return - If successful, returns boolean status of deletion. Else returns error.
    @display {label: "Delete draft"}
    remote isolated function deleteDraft(@display {label: "Mail address of user"} string userId, 
                                         @display {label: "Draft id"} string draftId) 
                                         returns @tainted @display {label: "Status"} boolean|error {
        http:Request request = new;
        string deleteDraftPath = USER_RESOURCE + userId + DRAFT_RESOURCE + FORWARD_SLASH_SYMBOL + draftId;
        http:Response httpResponse = <http:Response> check self.gmailClient->delete(deleteDraftPath, request);
        //Return boolean status of darft deletion response. If unsuccessful, throws and returns error.
        return <boolean>check handleResponse(httpResponse);
    }

    # Creates a new draft with the DRAFT label.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + message - MessageRequest to create a draft
    # + threadId - Optional. Thread Id of the draft to reply
    # + return - If successful, returns the draft Id of the created Draft. Else returns error.
    @display {label: "Create draft"}
    remote function createDraft(@display {label: "Mail address of user"} string userId,
                                @display {label: "Message request"} MessageRequest message,
                                @display {label: "Thread id"} string? threadId = ())
                                returns @tainted @display {label: "Draft id"} string|error {
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

        string createDraftPath = USER_RESOURCE + userId + DRAFT_RESOURCE;
        request.setJsonPayload(<@untainted>jsonPayload);
        http:Response httpResponse = <http:Response> check self.gmailClient->post(createDraftPath, request);
        json jsonCreateDraftResponse = check handleResponse(httpResponse);
        //Return draft id of the created draft
        return let var id = jsonCreateDraftResponse.id in id is string ? id : EMPTY_STRING;
    }

    # Replaces a draft's content.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + draftId - The draft Id to update
    # + message - MessageRequest to update a draft
    # + threadId - Optional. Thread Id of the draft to reply
    # + return - If successful, returns the draft Id of the updated Draft. Else returns error.
    @display {label: "Update draft"}
    remote function updateDraft(@display {label: "Mail address of user"} string userId, 
                                @display {label: "Draft id"} string draftId, 
                                @display {label: "Message request"} MessageRequest message, 
                                @display {label: "Thread id"} string? threadId = ())
                                returns @tainted @display {label: "Draft id"} string|error {
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

        string updateDraftPath = USER_RESOURCE + userId + DRAFT_RESOURCE + FORWARD_SLASH_SYMBOL + draftId;
        request.setJsonPayload(<@untainted>jsonPayload);
        http:Response httpResponse = <http:Response> check self.gmailClient->put(updateDraftPath, request);
        json jsonUpdateDraftResponse = check handleResponse(httpResponse);
        //Return draft id of the updated draft
        return let var id = jsonUpdateDraftResponse.id in id is string ? id : EMPTY_STRING;
    }

    # Sends the specified, existing draft to the recipients in the To, Cc, and Bcc headers.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + draftId - The draft Id to send
    # + return - If successful, returns Message record of the sent Draft. Else returns error.
    @display {label: "Send draft"} 
    remote isolated function sendDraft(@display {label: "Mail address of user"} string userId,
                                       @display {label: "Draft id"} string draftId) 
                                       returns @tainted @display {label: "Sent Message Response"} Message |
                                       error {
        http:Request request = new;
        json jsonPayload = {id: draftId};
        string updateDraftPath = USER_RESOURCE + userId + DRAFT_SEND_RESOURCE;
        request.setJsonPayload(jsonPayload);
        http:Response httpResponse = <http:Response> check self.gmailClient->post(updateDraftPath, request);        
        json jsonSendDraftResponse = check handleResponse(httpResponse);
        return check jsonSendDraftResponse.cloneWithType(Message);
    }

    # Set up or update a push notification watch on the given user mailbox.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + requestBody - The request body contains data with the following structure of JSON representation:
    #                   `{`
    #                   `   "labelIds": [`
    #                   `       string`
    #                   `    ],`
    #                   `    "labelFilterAction": enum (LabelFilterAction),`
    #                   `    "topicName": string`
    #                   `       }`
    # + return - If successful, returns WatchResponse. Else returns error.
    @display {label: "Watch mailbox changes"}
    remote isolated function watch(@display {label: "Mail address of user"} string userId, 
                                   @display {label: "The request body for subscription"} WatchRequestBody requestBody) 
                                   returns @tainted @display {label: "Watch result"} WatchResponse | error {
        http:Request request = new;
        string watchPath = USER_RESOURCE + userId + WATCH;
        request.setJsonPayload(requestBody.toJson());
        http:Response httpResponse = <http:Response> check self.gmailClient->post(watchPath, request);
        json jsonWatchResponse = check handleResponse(httpResponse);
        WatchResponse watchResponse = check jsonWatchResponse.cloneWithType(WatchResponse);
        return watchResponse;
    }

    # Set up or update a push notification watch on the given user mailbox.
    #
    # + userId - The user's email address. The special value **me** can be used to indicate the authenticated user.
    # + return - If successful, nothing will be returned. Else returns error.
    @display {label: "Stop watching mailbox changes"}
    remote isolated function stop(@display {label: "Mail address of user"} string userId) 
                                  returns @tainted @display {label: "Result"} error? {
        http:Request request = new;
        string stopPath = USER_RESOURCE + userId + STOP;
        http:Response httpResponse = <http:Response> check self.gmailClient->post(stopPath, request);
    }
}

# Holds the parameters used to create a `Client`.
#
# + oauthClientConfig - OAuth client configuration
# + secureSocketConfig - Secure socket configuration
public type GmailConfiguration record {
    http:BearerTokenConfig | http:OAuth2RefreshTokenGrantConfig oauthClientConfig;
    http:ClientSecureSocket secureSocketConfig?;
};
