// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

package src.gmail;

@Description {value:"Struct to define the UserProfile."}
public struct UserProfile {
    string emailAddress;
    int messagesTotal;
    int threadsTotal;
    string historyId;
}

@Description {value:"Struct to define the optional parameters which are used to create a mail."}
public struct Options {
    string htmlBody;
    string from;
    string cc;
    string bcc;
    string xmlFilePath;
    string xmlFileName;
    string imageFilePath;
    string imageFileName;
    string pdfFilePath;
    string pdfFileName;
}

@Description {value:"Struct to define the draft."}
public struct Draft {
    string id;
    Message message;
}

@Description {value:"Struct to define the List of headers on this message part. For the top-level message part,
             representing the entire message payload, it will contain the standard RFC 2822 email headers
             such as To, From, and Subject."}
public struct Header {
    string name;
    string value;
}

@Description {value:"Struct to define the child MIME message parts of this part.
             This only applies to container MIME message parts, for example multipart/*.
             For non- container MIME message part types, such as text/plain, this field is empty"}
public struct Parts {
    string partId;
    string mimeType;
    string filename;
    Header[] headers;
    Body body;
}

@Description {value:"Struct to define the message part body for this part,
             which may be empty for container MIME message parts."}
public struct Body {
    string attachmentId;
    int size;
    string data;
}

@Description {value:"Struct to define the parsed email structure in the message parts."}
public struct MessagePayload {
    string partId;
    string mimeType;
    string filename;
    Header[] headers;
    Body body;
    Parts[] parts;
}

@Description {value:"Struct to define the whole message details."}
public struct Message {
    string id;
    string threadId;
    string[] labelIds;
    string snippet;
    string historyId;
    string internalDate;
    MessagePayload payload;
    int sizeEstimate;
}

@Description {value:"Struct to define the whole drafts details."}
public struct Drafts {
    Draft[] drafts;
    int resultSizeEstimate;
    string nextPageToken;
}

@Description {value:"Struct to define the filters uesd to get draft details."}
public struct DraftsListFilter {
    string includeSpamTrash;
    string maxResults;
    string pageToken;
    string q;
}

@Description {value:"Struct to define the error return from response."}
public struct GmailError {
    int statusCode;
    string errorMessage;
}
