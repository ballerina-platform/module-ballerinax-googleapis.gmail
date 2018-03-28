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

package gmail;

import ballerina/io;
import ballerina/mime;

@Description {value:"Get only the attachment messageParts from the json messagepart[] from message payload"}
@Param {value:"messageParts: json array of message parts in MIME Message"}
@Return {value:"Returns array of MessageAttachment"}
function getMessageParts (json messageParts) returns MessageAttachment[] {
    MessageAttachment[] mesgAttachments = [];
    if (lengthof messageParts != 0) {
        int i = 0;
        foreach part in messageParts {
            if (!isMimeType(part.mimeType.toString(), MULTIPART_ANY)) {
                mesgAttachments[i] = <MessageAttachment, convertJsonMsgPartToMsgAttachment()>part;
            }
            else {
                mesgAttachments = getMessageParts(part.parts);
                i = lengthof mesgAttachments - 1;
            }
            i++;
        }
    }
    return mesgAttachments;
}

@Description {value:"Get the message header To"}
@Param {value:"headers: array of MessagePart headers"}
@Return {value:"Returns message part header To"}
function getMsgPartHeaderTo (MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerTo = {};
    foreach header in headers {
        if (header.name == TO) {
            headerTo = header;
        }
    }
    return headerTo;
}

@Description {value:"Get the message header From"}
@Param {value:"headers: array of MessagePart headers"}
@Return {value:"Returns message part header From"}
function getMsgPartHeaderFrom (MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerFrom = {};
    foreach header in headers {
        if (header.name == FROM) {
            headerFrom = header;
        }
    }
    return headerFrom;
}

@Description {value:"Get the message header Cc"}
@Param {value:"headers: array of MessagePart headers"}
@Return {value:"Returns message part header Cc"}
function getMsgPartHeaderCc (MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerCc = {};
    foreach header in headers {
        if (header.name == CC) {
            headerCc = header;
        }
    }
    return headerCc;
}

@Description {value:"Get the message header Bcc"}
@Param {value:"headers: array of MessagePart headers"}
@Return {value:"Returns message part header Bcc"}
function getMsgPartHeaderBcc (MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerBcc = {};
    foreach header in headers {
        if (header.name == BCC) {
            headerBcc = header;
        }
    }
    return headerBcc;
}

@Description {value:"Get the message header Subject"}
@Param {value:"headers: array of MessagePart headers"}
@Return {value:"Returns message part header Subject"}
function getMsgPartHeaderSubject (MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerSubject = {};
    foreach header in headers {
        if (header.name == SUBJECT) {
            headerSubject = header;
        }
    }
    return headerSubject;
}

@Description {value:"Get the message header Date"}
@Param {value:"headers: array of MessagePart headers"}
@Return {value:"Returns message part header Date"}
function getMsgPartHeaderDate (MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerDate = {};
    foreach header in headers {
        if (header.name == DATE) {
            headerDate = header;
        }
    }
    return headerDate;
}

@Description {value:"Get the message header ContentType"}
@Param {value:"headers: array of MessagePart headers"}
@Return {value:"Returns message part header ContetnType"}
function getMsgPartHeaderContentType (MessagePartHeader[] headers) returns MessagePartHeader {
    MessagePartHeader headerContentType = {};
    foreach header in headers {
        if (header.name == CONTENT_TYPE) {
            headerContentType = header;
        }
    }
    return headerContentType;
}

@Description {value:"Convert the message part header json array to MessagePartHeader struct array"}
@Param {value:"jsonMsgPartHeaders: json array of message part headers"}
@Return {value:"Returns MessagePartHeader struct array"}
function convertToMsgPartHeaders (json jsonMsgPartHeaders) returns MessagePartHeader[] {
    MessagePartHeader[] msgPartHeaders = [];
    int i = 0;
    foreach jsonHeader in jsonMsgPartHeaders {
        msgPartHeaders[i] = <MessagePartHeader, convertJsonToMesagePartHeader()>jsonHeader;
        i++;
    }
    return msgPartHeaders;
}

@Description {value:"Convert json array to string array"}
@Param {value:"sourceJsonObject: json array"}
@Return {value:"Return string array"}
public function convertJSONArrayToStringArray (json sourceJsonObject) returns string[] {
    string[] targetStringArray = [];
    int i = 0;
    foreach element in sourceJsonObject {
        targetStringArray[i] = element.toString();
        i++;
    }
    return targetStringArray;
}

@Description {value:"Check whether mime type in the message part is same as the given the mime type"}
@Param {value:"msgMimeType: mime type of the message part"}
@Param {value:"mType: given mime type which you wants check against with"}
@Return {value:"Returns true or false whether mime types match"}
public function isMimeType (string msgMimeType, string mType) returns boolean {
    string[] msgTypes = msgMimeType.split("/");
    string msgPrimaryType = msgTypes[0];
    string msgSecondaryType = msgTypes[1];

    string[] requestmTypes = mType.split("/");
    string reqPrimaryType = requestmTypes[0];
    string reqSecondaryType = requestmTypes[1];

    if (!msgPrimaryType.equalsIgnoreCase(reqPrimaryType)) {
        return false;
    } else if ((reqSecondaryType.subString(0, 1) != "*") && (msgSecondaryType.subString(0, 1) != "*")) {
        return msgSecondaryType.equalsIgnoreCase(reqSecondaryType);
    } else {
        return true;
    }
}

@Description {value:"Encode a file into base 64 using MimeBase64Encoder"}
@Param {value:"filePath: string file path"}
@Return {value:"Returns the encoded string"}
@Return {value:"Returns IOError if there's any error while performaing I/O operation"}
function encodeFile (string filePath) returns string | io:IOError {
    io:ByteChannel fileChannel = getFileChannel(filePath, "r");
    int bytesChunk = BYTES_CHUNK;
    blob readContent;
    int readCount;
    match readBytes(fileChannel, bytesChunk) {
        (blob, int) readChannel => (readContent, readCount) = readChannel;
        io:IOError e => return e;
    }
    mime:MimeBase64Encoder encoder = {};
    blob blobEncode = encoder.encode(readContent);
    return blobEncode.toString(UTF_8);
}

@Description {value:"Get the file name from the given file path"}
@Param {value:"filePath: string file path (including the file name and extension at the end)"}
@Return {value:"string file name extracted from the file path"}
public function getFileNameFromPath(string filePath) returns string {
    string[] pathParts = filePath.split("/");
    return pathParts[lengthof pathParts -1];
}

@Description {value:"Open the file and return the byte channel"}
@Param {value:"filePath: string file path"}
@Param {value:"permission: string permission to open the file with, for example for read permission give as: r"}
@Return {value:"Return byte channel of the file"}
function getFileChannel (string filePath, string permission) returns (io:ByteChannel) {
    io:ByteChannel channel = io:openFile(filePath, permission);
    return channel;
}

@Description {value:"Get the blob content from the byte channel"}
@Param {value:"channel: ByteChannel of the file"}
@Param {value:"num: Number of bytes which should be read"}
@Return {value:"The bytes which were read"}
@Return {value:"Number of bytes read"}
@Return {value:"Returns if there's any error while performaing I/O operation"}
function readBytes (io:ByteChannel channel, int numberOfBytes) returns (blob, int)|io:IOError {
    blob bytes;
    int numberOfBytesRead;
    match channel.read(numberOfBytes) {
        (blob, int) readChannel => (bytes, numberOfBytesRead) = readChannel;
        io:IOError e => return e;
    }
    return (bytes, numberOfBytesRead);
}