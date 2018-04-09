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

@final public string BASE_URL = "https://www.googleapis.com/gmail";
@final public string REFRESH_TOKEN_EP =  "https://www.googleapis.com";
@final public string REFRESH_TOKEN_PATH = "/oauth2/v3/token";
@final public string USER_RESOURCE = "/v1/users/";
@final public string MESSAGE_RESOURCE = "/messages";
@final public string MESSAGE_SEND_RESOURCE = "/messages/send";
@final public string ATTACHMENT_RESOURCE = "/attachments/";
@final public string THREAD_RESOURCE = "/threads";
@final public string PROFILE_RESOURCE = "/profile";

@final public string EMPTY_STRING = "";
@final public string NEW_LINE = "\n";

@final public string INCLUDE_SPAMTRASH = "?includeSpamTrash=";
@final public string LABEL_IDS = "&labelIds=";
@final public string MAX_RESULTS = "&maxResults=";
@final public string PAGE_TOKEN ="&pageToken=";
@final public string QUERY = "&q=";
@final public string FORMAT = "&format=";
@final public string METADATA_HEADERS = "&metadataHeaders=";

@final public string ERROR_CONNECTOR_NOT_INITALIZED = "Connector is not initalized. Invoke init method first.";
@final public string ERROR_CONTENT_TYPE_UNSUPPORTED = "The given content type is unsupported to add to the body.";
@final public int STATUS_CODE_200_OK = 200;
@final public int STATUS_CODE_204_NO_CONTENT = 204;
@final public string APPLICATION_JSON =  "Application/json";
@final public string CONTENT_TYPE = "Content-Type";
@final public string CONTENT_DISPOSITION = "Content-Disposition";
@final public string CONTENT_TRANSFER_ENCODING = "Content-Transfer-Encoding";
@final public string CONTENT_ID = "Content-ID";
@final public string BOUNDARY = "boundary";
@final public string BOUNDARY_STRING = "boundaryString";
@final public string BOUNDARY_STRING_1 = "boundaryString1";
@final public string BOUNDARY_STRING_2 = "boundaryString2";
@final public string MULTIPART_ANY = "multipart/*";
@final public string MULTIPART_MIXED = "multipart/mixed";
@final public string MULTIPART_ALTERNATIVE = "multipart/alternative";
@final public string MULTIPART_RELATED = "multipart/related";
@final public string TEXT_PLAIN = "text/plain";
@final public string TEXT_HTML = "text/html";
@final public string TEXT_ANY = "text/*";
@final public string IMAGE_ANY = "image/*";
@final public string CHARSET = "charset";
@final public string BASE_64 = "base64";
@final public string INLINE = "inline";
@final public string ATTACHMENT = "attachment";
@final public string FILE_NAME = "filename";
@final public string NAME = "name";
@final public string INLINE_IMAGE_CONTENT_ID_PREFIX = "image-";
@final public string UTF_8 = "UTF-8";
@final public int BYTES_CHUNK = 100000000;

@final public string TO = "To";
@final public string FROM = "From";
@final public string CC = "Cc";
@final public string BCC = "Bcc";
@final public string SUBJECT = "Subject";
@final public string DATE = "Date";

@final public string FORMAT_FULL = "full";
@final public string FORMAT_METADATA = "metadata";
@final public string FORMAT_MINIMAL = "minimal";
@final public string FORMAT_RAW = "raw";
