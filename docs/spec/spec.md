# Specification: Ballerina Gmail Library

_Owners_: @niveathika \
_Reviewers_: @daneshk \
_Created_: 2022/10/31 \
_Updated_: 2023/10/31 \
_Edition_: Swan Lake 

## Introduction

This is the specification for the Gmail package of the [Ballerina language](https://ballerina.io). This package provides client functionalities to interact with the [Google Gmail API v1](https://developers.google.com/gmail/api/guides).

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

Ballerina language offers first-class support for writing network-oriented programs. The Gmail package leverages these language features to create a programming model for consuming the Gmail REST API.

The Gmail package offers intuitive resource methods to interact with the [Gmail API v1](https://gmail.googleapis.com/$discovery/rest?version=v1).

## 2. Client

This section outlines the client of the Ballerina Gmail package. To utilize the Ballerina Gmail package, a user must first import it.

###### Example: Importing the Gmail Package

```ballerina
import ballerinax/googleapis.gmail;
```

The `gmail:Client` allows you to connect to the Gmail RESTful API. The client currently supports processing of `Profile`, `Message`, `Draft`, `Thread`, and `Label` resources. The client employs HTTP as the underlying protocol for communication with the API.

#### 2.1 Initializing the Client

The `gmail:Client` initialization method requires valid authentication credentials.

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

The `gmail:Client` uses `http:Client` as its underlying implementation. You can configure this `http:Client` by providing the `gmail:ConnectionConfig` as a parameter during the `gmail:Client` initialization.

## 3. `Profile` Resource

You can retrieve the details of the authenticated user using the `/users/[userId]/profile()` resource method. The `Profile` record includes the following fields:

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

In this example, the getProfile method retrieves the profile of the authenticated user. The "me" parameter represents the authenticated user.

## 4. `Message` Resource

The `Message` resource represents an email message, which includes the sender, recipients, subject, and body. Once a message is created, it cannot be modified. 

This resource can be accessed and manipulated using the following methods:

| Method | Description |
|---|---|
| `/users/[userId]/messages()` | Lists all messages in the user's mailbox. |
| `/users/[userId]/messages.post()` | Directly inserts a message into the user's mailbox, similar to `IMAP APPEND`. This bypasses most scanning and classification processes. Note that this does not send the message. |
| `/users/[userId]/messages/batchDelete.post()` | Deletes multiple messages using their message IDs. |
| `/users/[userId]/messages/batchModify.post()` | Modifies the labels on the specified messages. |
| `/users/[userId]/messages/import.post()` | Imports a message into the user's mailbox with standard email delivery scanning and classification, similar to receiving via SMTP. Note that this method does not perform SPF checks and does not send the message. |
| `/users/[userId]/messages/send.post()` | Sends the specified message to the recipients in the `To`, `Cc`, and `Bcc` headers. |
| `/users/[userId]/messages/[messageId]()` | Retrieves the specified message. |
| `/users/[userId]/messages/[messageId].delete()` | Permanently deletes the specified message immediately. |
| `/users/[userId]/messages/[messageId]/modify.post()` | Modifies the labels on the specified message. |
| `/users/[userId]/messages/[messageId]/trash.post()` | Moves the specified message to the trash. |
| `/users/[userId]/messages/[messageId]/untrash.post()` | Removes the specified message from the trash. |
| `/users/[userId]/messages/[messageId]/attachments/[attachmentId]()` | Retrieves the specified message attachment. |

## 5. `Draft` Resource

A `Draft` represents an unsent message. You can replace the message contained within the draft. When you send a draft, it automatically deletes the draft and creates a message with the `SENT` system label.

You can access and manipulate this resource using the following methods:
| Method | Description |
|---|---|
| `users/[userId]/drafts()` | Lists all drafts in the user's mailbox. |
| `users/[userId]/drafts.post()` | Creates a new draft with the `DRAFT` system label. |
| `users/[userId]/drafts/send.post()` | Sends the specified draft to the recipients in the `To`, `Cc`, and `Bcc` headers. This action deletes the draft and creates a message with the `SENT` system label. |
| `users/[userId]/drafts/[draftId]()` | Retrieves the specified draft. |
| `users/[userId]/drafts/[draftId].put()` | Replaces the content of the specified draft. |
| `users/[userId]/drafts/[draftId].delete()` | Permanently deletes the specified draft immediately. This action does not move the draft to the trash. |

## 6. `MailThread` Resource

A `MailThread` represents a conversation, which is a collection of related messages. In an email client app, a thread is formed when one or more recipients respond to a message with their own message.

You can access and manipulate this resource using the following methods:

| Method | Description |
|---|---|
| `users/[userId]/threads()` | Lists all threads in the user's mailbox. |
| `users/[userId]/threads/[threadId]()` | Retrieves the specified thread. |
| `users/[userId]/threads/[threadId].delete()` | Permanently deletes the specified thread, including all messages within the thread. This operation cannot be undone. Consider using `threads.trash` instead. |
| `users/[userId]/threads/[threadId].modify()` | Modifies the labels applied to the thread. This affects all messages in the thread. |
| `users/[userId]/threads/[threadId]/trash.post()` | Moves the specified thread to the trash, including all messages within the thread. |
| `users/[userId]/threads/[threadId]/untrash.post()` | Removes the specified thread from the trash, including all messages within the thread. |

## 7. `Label` Resource

Labels are a mechanism for categorizing and organizing messages and threads. For instance, you might create a label "taxes" and apply it to all messages and threads related to your taxes. There are two types of labels:

1. **System labels**: These are internally-created labels, such as `INBOX`, `TRASH`, or `SPAM`. These labels cannot be deleted or modified. However, some system labels, such as `INBOX`, can be applied to or removed from messages and threads.

2. **User labels**: These are labels created by a user. These labels can be deleted or modified by the user or an application. A user label is represented by a label resource.

You can access and manipulate this resource using the following methods:
| Method | Description |
|---|---|
| `users/[userId]/labels()` | Lists all labels in the user's mailbox. |
| `users/[userId]/labels.post()` | Creates a new label. |
| `users/[userId]/labels/[labelId]()` | Retrieves the specified label. |
| `users/[userId]/labels/[labelId].put()` | Updates the specified label. |
| `users/[userId]/labels/[labelId].delete()` | Permanently deletes the specified label and removes it from any messages and threads that it is applied to. |
| `users/[userId]/labels/[labelId].patch()` | Partially updates the specified label. Only the fields specified in the request are changed. |

## 8. `History` Resource

The `History` resource allows you to track all changes made to a specific mailbox. You can retrieve a list of these changes using the `/users/[userId]/history()` method. The results are returned in chronological order, with the `historyId` increasing over time. This allows you to easily track the sequence of events and changes made to the mailbox.
