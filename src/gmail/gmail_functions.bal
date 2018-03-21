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

import ballerina.io;
import ballerina.mime;

function getHeaders (json jsonHeaders) (Header[]) {
    int i = 0;
    Header[] headers = [];
    foreach jsonHeader in jsonHeaders {
        headers[i] = <Header, headerTrans()>jsonHeader;
        i = i + 1;
    }
    return headers;
}

function getParts (json jsonParts) (Parts[]) {
    int i = 0;
    Parts[] parts = [];
    foreach jsonPart in jsonParts {
        parts[i] = <Parts, partsTrans()>jsonPart;
        i = i + 1;
    }
    return parts;
}

function getLabelIds (json allLabelIds) (string[]) {
    int i = 0;
    string[] labelIds = [];
    foreach aLabelId in allLabelIds {
        labelIds[i] = aLabelId.toString();
        i = i + 1;
    }
    return labelIds;
}

function getDrafts (json jsonDrafts) (Draft[]) {
    int i = 0;
    Draft[] drafts = [];
    foreach jsonDraft in jsonDrafts {
        drafts[i] = <Draft, draftTrans()>jsonDraft;
        i = i + 1;
    }
    return drafts;
}

function getFileChannel (string filePath, string permission) (io:ByteChannel) {
    io:ByteChannel channel = io:openFile(filePath, permission);
    return channel;
}

function readBytes (io:ByteChannel channel, int numberOfBytes) (blob, int) {
    blob bytes;
    int numberOfBytesRead;

    bytes, numberOfBytesRead = channel.readBytes(numberOfBytes);
    return bytes, numberOfBytesRead;
}

function encodeFile (string filePath) (string) {
    io:ByteChannel fileChannel = getFileChannel(filePath, "r");
    int bytesChunk = 100000000;
    blob readContent;
    int readCount = -1;
    readContent, readCount = readBytes(fileChannel, bytesChunk);
    mime:MimeBase64Encoder encoding = {};
    blob blobEncode = encoding.encode(readContent);
    return blobEncode.toString("UTF-8");
}
