# Specification: Ballerina Gmail Library

_Owners_: @niveathika \
_Reviewers_: @daneshk \
_Created_: 2022/10/31 \
_Updated_: 2023/10/31 \
_Edition_: Swan Lake 

## Introduction

This is the specification for the Gmail package of the [Ballerina language](https://ballerina.io), which provides client functionalities
to communicate with [Google Gmail API v1](https://developers.google.com/gmail/api/guides).

The Gmail library specification has evolved and may continue to evolve in the future. The released versions of the specification can be found under the relevant GitHub tag.

If you have any feedback or suggestions about the library, start a discussion via a [GitHub issue](https://github.com/ballerina-platform/ballerina-standard-library/issues) or in the [Discord server](https://discord.gg/ballerinalang). Based on the outcome of the discussion, the specification and implementation can be updated. Community feedback is always welcome. Any accepted proposal, which affects the specification is stored under `/docs/proposals`. Proposals under discussion can be found with the label `type/proposal` on GitHub.

The conforming implementation of the specification is released and included in the distribution. Any deviation from the specification is considered a bug.

## Contents

1. [Overview](#1-overview)
2. [Client](#2-client)
    * 2.1 [Initializing the Client](#21-initializing-the-client)
3. [`Profile` Resource](#3-profile-resource)
4. [`Message` Resource](#4-message-resource)
5. [`Draft` Resource](#5-draft-resource)
6. [`MailThread` Resource](#6-mailthread-resource)
7. [`Label` Resource](#7-label-resource)
8. [`History` Resource](#8-history-resource)
 
## 1. Overview

The Ballerina language provides first-class support for writing network-oriented programs. The Gmal package uses these language constructs and creates the programming model to consume Gmail REST API.

The Gmail package provides user friendly resource methods to invoke [Gmail API v1](https://gmail.googleapis.com/$discovery/rest?version=v1).

## 2. Client

This section describes the client of the Ballerina Gmail package. To use the Ballerina Gmail package, a user must import the Ballerina Gmail package first.

###### Example: Importing the Gmail Package

```ballerina
import ballerinax/googleapis.gmail;
```

The `gmail:Client` can be used to connect to the Gmail RESTful API. The client currently supports processing of `Profile`, `Message`, `Draft`, `Thread` and `Label` resources. The client uses HTTP as the underlying protocol to communicate with the API.

#### 2.1 Initializing the Client

The `gmail:Client` init method requires a valid authentication credential to initialize the client. 

```ballerina
gmail:Client gmailClient = check new gmail:Client (
        config = {
            auth: {
                refreshToken: refreshToken,
                clientId: clientId,
                clientSecret: clientSecret
            }
        }
    );
```

The `gmail:Client` uses `http:Client` as its underlying implementation; this `http:Client` can be configured by providing the `gmail:ConnectionConfig` as a parameter via the `gmail:Client` init method.

## 3. `Profile` Resource

The details of the authenticated user can be retried by using `/users/[userId]/profile()` resource method. The `Profile` record inclues,

```ballerina
public type Profile record {
    string emailAddress?;
    string historyId?;
    int:Signed32 messagesTotal?;
    int:Signed32 threadsTotal?;
};
```

###### Example: Retrieving Gmail profile 

```ballerina
Profile profile = check gmailClient->/users/me/profile();
```

## 4. `Message` Resource

An email message containing the sender, recipients, subject, and body. After a message has been created, a message cannot be changed. 

This resource can be retrieved and manipulated by methods such as,
| Method | Description |
|---|---|
| `/users/[userId]/messages()` | Lists the messages in the user's mailbox |
| `/users/[userId]/messages.post()` | Directly inserts a message into only this user's mailbox similar to `IMAP APPEND`, bypassing most scanning and classification. Does not send a message. |
| `/users/[userId]/messages/batchDelete.post()` | Deletes many messages by message ID |
| `/users/[userId]/messages/batchModify.post()` | Modifies the labels on the specified messages |
| `/users/[userId]/messages/'import.post()` | Imports a message into only this user's mailbox, with standard email delivery scanning and classification similar to receiving via SMTP. This method doesn't perform SPF checks, so it might not work for some spam messages, such as those attempting to perform domain spoofing. This method does not send a message. |
| `/users/[userId]/messages/send.post()` | Sends the specified message to the recipients in the `To`, `Cc`, and `Bcc` headers. |
| `/users/[userId]/messages/[messageId]()` | Gets the specified message. |
| `/users/[userId]/messages/[messageId].deleted()` | Immediately and permanently deletes the specified message |
| `/users/[userId]/messages/[messageId]/modify.post()` | Modifies the labels on the specified message |
| `/users/[userId]/messages/[messageId]/trash.post()` | Moves the specified message to the trash |
| `/users/[userId]/messages/[messageId]/untrash.post()` | Removes the specified message from the trash |
| `/users/[userId]/messages/[messageId]/attachments/[attachmentId]()` | Gets the specified message attachment |

## 5. `Draft` Resource

An unsent message. A message contained within the draft can be replaced. Sending a draft automatically deletes the draft and creates a message with the SENT system label.

This resource can be retrieved and manipulated by methods such as,
| Method | Description |
|---|---|
| `users/[userId]/drafts()` | Lists the drafts in the user's mailbox |
| `users/[userId]/drafts.post()` | Creates a new draft with the `DRAFT` label |
| `users/[userId]/drafts/send.post()` | Sends the specified, existing draft to the recipients in the `To`, `Cc`, and `Bcc` headers |
| `users/[userId]/drafts/[draftId]()` | Gets the specified draft |
| `users/[userId]/drafts/[draftId].put()` |  Replaces a draft's content |
| `users/[userId]/drafts/[draftId].delete()` | Immediately and permanently deletes the specified draft. Does not simply trash it |

## 6. `MailThread` Resource

A collection of related messages forming a conversation. In an email client app, a thread is formed when one or more recipients respond to a message with their own message.

This resource can be retrieved and manipulated by methods such as,
| Method | Description |
|---|---|
| `users/[userId]/threads()` | Lists the threads in the user's mailbox |
| `users/[userId]/threads/[threadId]()` | Gets the specified thread |
| `users/[userId]/threads/[threadId].delete()` | Immediately and permanently deletes the specified thread. Any messages that belong to the thread are also deleted. This operation cannot be undone. Prefer `threads.trash` instead |
| `users/[userId]/threads/[threadId].modify()` | Modifies the labels applied to the thread. This applies to all messages in the thread |
| `users/[userId]/threads/[threadId]/trash.post()` | Moves the specified thread to the trash. Any messages that belong to the thread are also moved to the trash |
| `users/[userId]/threads/[threadId]/untrash.post()` | Removes the specified thread from the trash. Any messages that belong to the thread are also removed from the trash |

## 7. `Label` Resource

A mechanism for organizing messages and threads. For example, the label "taxes" might be created and applied to all messages and threads having to do with a user's taxes. There are two types of labels:

1. System labels
    Internally-created labels, such as INBOX, TRASH, or SPAM. These labels cannot be deleted or modified. However, some system labels, such as INBOX can be applied to, or removed from, messages and threads.

2. User labels
    Labels created by a user. These labels can be deleted or modified by the user or an application. A user label is represented by a label resource.

This resource can be retrieved and manipulated by methods such as,
| Method | Description |
|---|---|
| `users/[userId]/labels()` | Lists all labels in the user's mailbox |
| `users/[userId]/labels.post()` | Creates a new label |
| `users/[userId]/labels/[labelId]()` | Gets the specified label |
| `users/[userId]/labels/[labelId].put()` | Updates the specified label |
| `users/[userId]/labels/[labelId].delete()` | Immediately and permanently deletes the specified label and removes it from any messages and threads that it is applied to |
| `users/[userId]/labels/[labelId].patch()` | Patch the specified label. Only requested fields are changed |

## 8. `History` Resource

The history of all changes to the given mailbox can be listed using `/users/[userId]/history()`. History results are returned in chronological order (increasing `historyId`)
