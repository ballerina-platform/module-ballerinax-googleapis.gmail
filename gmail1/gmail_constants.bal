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

package gmail1;

public const string BASE_URL = "https://www.googleapis.com/gmail";
public const string REFRESH_TOKEN_EP =  "https://www.googleapis.com";
public const string REFRESH_TOKEN_PATH = "/oauth2/v3/token";
public const string USER_RESOURCE = "/v1/users/";
public const string MESSAGE_RESOURCE = "/messages";
public const string MESSAGE_SEND_RESOURCE = "/messages/send";
public const string ATTACHMENT_RESOURCE = "/attachments/";
public const string THREAD_RESOURCE = "/threads";
public const string PROFILE_RESOURCE = "/profile";

public const string EMPTY_STRING = "";
public const string NEW_LINE = "\n";

public const string INCLUDE_SPAMTRASH = "?includeSpamTrash=";
public const string LABEL_IDS = "&labelIds=";
public const string MAX_RESULTS = "&maxResults=";
public const string PAGE_TOKEN ="&pageToken=";
public const string QUERY = "&q=";
public const string FORMAT = "&format=";
public const string METADATA_HEADERS = "&metadataHeaders=";

public const string ERROR_CONNECTOR_NOT_INITALIZED = "Connector is not initalized. Invoke init method first.";
public const string ERROR_CONTENT_TYPE_UNSUPPORTED = "The given content type is unsupported to add to the body.";
public const int STATUS_CODE_200_OK = 200;
public const int STATUS_CODE_204_NO_CONTENT = 204;
public const string APPLICATION_JSON =  "Application/json";
public const string CONTENT_TYPE = "Content-Type";
public const string CONTENT_DISPOSITION = "Content-Disposition";
public const string CONTENT_TRANSFER_ENCODING = "Content-Transfer-Encoding";
public const string CONTENT_ID = "Content-ID";
public const string BOUNDARY = "boundary";
public const string BOUNDARY_STRING = "boundaryString";
public const string BOUNDARY_STRING_1 = "boundaryString1";
public const string BOUNDARY_STRING_2 = "boundaryString2";
public const string MULTIPART_ANY = "multipart/*";
public const string MULTIPART_MIXED = "multipart/mixed";
public const string MULTIPART_ALTERNATIVE = "multipart/alternative";
public const string MULTIPART_RELATED = "multipart/related";
public const string TEXT_PLAIN = "text/plain";
public const string TEXT_HTML = "text/html";
public const string TEXT_ANY = "text/*";
public const string IMAGE_ANY = "image/*";
public const string CHARSET = "charset";
public const string BASE_64 = "base64";
public const string INLINE = "inline";
public const string ATTACHMENT = "attachment";
public const string FILE_NAME = "filename";
public const string NAME = "name";
public const string INLINE_IMAGE_CONTENT_ID_PREFIX = "image-";
public const string UTF_8 = "UTF-8";
public const int BYTES_CHUNK = 100000000;

public const string TO = "To";
public const string FROM = "From";
public const string CC = "Cc";
public const string BCC = "Bcc";
public const string SUBJECT = "Subject";
public const string DATE = "Date";

public const string FORMAT_FULL = "full";
public const string FORMAT_METADATA = "metadata";
public const string FORMAT_MINIMAL = "minimal";
public const string FORMAT_RAW = "raw";
