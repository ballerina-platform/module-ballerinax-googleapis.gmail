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

documentation {Holds the value for base url of gmail api}
@final string BASE_URL = "https://www.googleapis.com/gmail";
documentation {Holds the value for url of refresh token end point}
@final string REFRESH_TOKEN_EP = "https://www.googleapis.com/oauth2/v3/token";
documentation {Holds the value for oauth scheme}
@final string OAUTH = "oauth";

documentation {Holds the value for user resource path}
@final string USER_RESOURCE = "/v1/users/";
documentation {Holds the value for messages resource path}
@final string MESSAGE_RESOURCE = "/messages";
documentation {Holds the value for send messages resource}
@final string MESSAGE_SEND_RESOURCE = "/messages/send";
documentation {Holds the value for attachments resource path}
@final string ATTACHMENT_RESOURCE = "/attachments/";
documentation {Holds the value for threads resoure path}
@final string THREAD_RESOURCE = "/threads";
documentation {Holds the value for profile resource path}
@final string PROFILE_RESOURCE = "/profile";
documentation {Holds the value for label resource path}
@final string LABEL_RESOURCE = "/labels";

documentation {Holds the value for empty string}
@final string EMPTY_STRING = "";
documentation {Holds the value for new line string}
@final string NEW_LINE = "\n";
documentation {Holds the value for ";" string}
@final string WHITE_SPACE = " ";
documentation {Holds the value for ":" string}
@final string COLON_SYMBOL = ":";
documentation {Holds the value for "-" string}
@final string DASH_SYMBOL = "-";
documentation {Holds the value for "/" string}
@final string FORWARD_SLASH_SYMBOL = "/";
documentation {Holds the value for "+" string}
@final string PLUS_SYMBOL = "+";
documentation {Holds the value for "_" string}
@final string UNDERSCORE_SYMBOL = "_";
documentation {Holds the value for ";" string}
@final string SEMICOLON_SYMBOL = ";";
documentation {Holds the value for "=" string}
@final string EQUAL_SYMBOL = "=";
documentation {Holds the value for "\"" string}
@final string APOSTROPHE_SYMBOL = "\"";
documentation {Holds the value for "?" string}
@final string QUESTION_MARK_SYMBOL = "?";
documentation {Holds the value for "&" string}
@final string AMPERSAND_SYMBOL = "&";
documentation {Holds the value for ">" string}
@final string GREATER_THAN_SYMBOL = ">";
documentation {Holds the value for "<" string}
@final string LESS_THAN_SYMBOL = "<";
documentation {Holds the value for "*" string}
@final string STAR_SYMBOL = "*";

documentation {Holds the value for optional parameter name 'includeSpamTrash'}
@final string INCLUDE_SPAMTRASH = "includeSpamTrash";
documentation {Holds the value for optional parameter name 'labelIds'}
@final string LABEL_IDS = "labelIds";
documentation {Holds the value for optional parameter name 'maxResults'}
@final string MAX_RESULTS = "maxResults";
documentation {Holds the value fo optional parameter name 'pageToken'}
@final string PAGE_TOKEN = "pageToken";
documentation {Holds the value for optional parameter name 'q'}
@final string QUERY = "q";
documentation {Holds the value for optional parameter name 'format'}
@final string FORMAT = "format";
documentation {Holds the value for optional parameter name 'metadataHeaders'}
@final string METADATA_HEADERS = "metadataHeaders";

documentation {Holds value for Content-Type}
@final string CONTENT_TYPE = "Content-Type";
documentation {Holds value for Content-Disposition}
@final string CONTENT_DISPOSITION = "Content-Disposition";
documentation {Holds value for Content-Transfer-Encoding}
@final string CONTENT_TRANSFER_ENCODING = "Content-Transfer-Encoding";
documentation {Holds value for Content-ID}
@final string CONTENT_ID = "Content-ID";
documentation {Holds value for boundary}
@final string BOUNDARY = "boundary";
documentation {Holds value for boundaryString}
@final string BOUNDARY_STRING = "boundaryString";
documentation {Holds value for boundaryString1}
@final string BOUNDARY_STRING_1 = "boundaryString1";
documentation {Holds value for boundaryString2}
@final string BOUNDARY_STRING_2 = "boundaryString2";

documentation {Holds value for multipart/*}
@final string MULTIPART_ANY = "multipart/*";
documentation {Holds value for text/*}
@final string TEXT_ANY = "text/*";
documentation {Holds value for image/*}
@final string IMAGE_ANY = "image/*";
documentation {Holds value for charset}
@final string CHARSET = "charset";
documentation {Holds value for base64}
@final string BASE_64 = "base64";
documentation {Holds value for inline}
@final string INLINE = "inline";
documentation {Holds value for attachment}
@final string ATTACHMENT = "attachment";
documentation {Holds value for filename}
@final string FILE_NAME = "filename";
documentation {Holds value for name}
@final string NAME = "name";
documentation {Holds value for inline image content id prefix}
@final string INLINE_IMAGE_CONTENT_ID_PREFIX = "image-";
documentation {Holds value for UTF-8}
@final string UTF_8 = "UTF-8";
documentation {Holds default value for bytes chunk to read from a byte channel}
@final int BYTES_CHUNK = 100000000;
documentation {Holds the value for trash}
@final string TRASH = "trash";
documentation {Holds the value for untrash}
@final string UNTRASH = "untrash";
documentation {Holds the value for error}
@final string ERROR = "error";
documentation {Holds the value for domain}
@final string DOMAIN = "domain";
documentation {Holds the value for reason}
@final string REASON = "reason";
documentation {Holds the value for message}
@final string MESSAGE = "message";
documentation {Holds the value for locationType}
@final string LOCATION_TYPE = "locationType";
documentation {Holds the value for location}
@final string LOCATION = "location";
documentation {Holds the value for status code}
@final string STATUS_CODE = "status code";

documentation {Holds name for header To}
@final string TO = "To";
documentation {Holds name for header From}
@final string FROM = "From";
documentation {Holds name for header Cc}
@final string CC = "Cc";
documentation {Holds name for header Bcc}
@final string BCC = "Bcc";
documentation {Holds name for header Subject}
@final string SUBJECT = "Subject";
documentation {Holds name for header Date}
@final string DATE = "Date";

documentation {Holds string for Gmail message/thread response format **full**}
@final public string FORMAT_FULL = "full";
documentation {Holds string for Gmail message/thread response format **metadata**}
@final public string FORMAT_METADATA = "metadata";
documentation {Holds string for Gmail message/thread response format **minimal**}
@final public string FORMAT_MINIMAL = "minimal";
documentation {Holds string for Gmail message/thread response format **raw**}
@final public string FORMAT_RAW = "raw";

documentation {Holds value for message type **text/plain**}
@final public string TEXT_PLAIN = "text/plain";
documentation {Holds value for message type **text/html**}
@final public string TEXT_HTML = "text/html";
