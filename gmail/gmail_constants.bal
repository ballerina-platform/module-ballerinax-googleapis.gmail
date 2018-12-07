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

//API urls
final string BASE_URL = "https://www.googleapis.com/gmail";
# Holds the value for URL of refresh token end point.
final string REFRESH_TOKEN_EP = "https://www.googleapis.com/oauth2/v3/token";
# Holds the value for oauth scheme.
final string OAUTH = "oauth";

# Holds the value for user resource path.
final string USER_RESOURCE = "/v1/users/";
# Holds the value for messages resource path.
final string MESSAGE_RESOURCE = "/messages";
# Holds the value for send messages resource.
final string MESSAGE_SEND_RESOURCE = "/messages/send";
# Holds the value for attachments resource path.
final string ATTACHMENT_RESOURCE = "/attachments/";
# Holds the value for threads resoure path.
final string THREAD_RESOURCE = "/threads";
# Holds the value for profile resource path.
final string PROFILE_RESOURCE = "/profile";
# Holds the value for label resource path.
final string LABEL_RESOURCE = "/labels";
# Holds the value for modify resource action.
final string MODIFY_RESOURCE = "/modify";
# Holds the value for history resource path.
final string HISTORY_RESOURCE = "/history";
# Holds the value for drafts resource path.
final string DRAFT_RESOURCE = "/drafts";
# Holds the value for send draft resource.
final string DRAFT_SEND_RESOURCE = "/drafts/send";

# Holds the value for empty string.
final string EMPTY_STRING = "";
# Holds the value for new line string.
final string NEW_LINE = "\n";
# Holds the value for ";" string.
final string WHITE_SPACE = " ";
# Holds the value for ":" string.
final string COLON_SYMBOL = ":";
# Holds the value for "-" string.
final string DASH_SYMBOL = "-";
# Holds the value for "/" string.
final string FORWARD_SLASH_SYMBOL = "/";
# Holds the value for "+" string.
final string PLUS_SYMBOL = "+";
# Holds the value for "_" string.
final string UNDERSCORE_SYMBOL = "_";
# Holds the value for ";" string.
final string SEMICOLON_SYMBOL = ";";
# Holds the value for "=" string.
final string EQUAL_SYMBOL = "=";
# Holds the value for "\"" string.
final string APOSTROPHE_SYMBOL = "\"";
# Holds the value for "?" string.
final string QUESTION_MARK_SYMBOL = "?";
# Holds the value for "&" string.
final string AMPERSAND_SYMBOL = "&";
# Holds the value for ">" string.
final string GREATER_THAN_SYMBOL = ">";
# Holds the value for "<" string.
final string LESS_THAN_SYMBOL = "<";
# Holds the value for "*" string.
final string STAR_SYMBOL = "*";

# Holds the value for optional parameter name 'includeSpamTrash'.
final string INCLUDE_SPAMTRASH = "includeSpamTrash";
# Holds the value for optional parameter name 'labelIds'.
final string LABEL_IDS = "labelIds";
# Holds the value for optional parameter name 'maxResults'.
final string MAX_RESULTS = "maxResults";
# Holds the value fo optional parameter name 'pageToken'.
final string PAGE_TOKEN = "pageToken";
# Holds the value for optional parameter name 'q'.
final string QUERY = "q";
# Holds the value for optional parameter name 'format'.
final string FORMAT = "format";
# Holds the value for optional parameter name 'metadataHeaders'.
final string METADATA_HEADERS = "metadataHeaders";
# Holds the value for 'historyTypes'.
final string HISTORY_TYPES = "historyTypes";
# Holds the value for 'labelId'.
final string LABEL_ID = "labelId";
# Holds the value for 'startHistoryId'.
final string START_HISTORY_ID = "startHistoryId";

# Holds value for Content-Type.
final string CONTENT_TYPE = "Content-Type";
# Holds value for Content-Disposition.
final string CONTENT_DISPOSITION = "Content-Disposition";
# Holds value for Content-Transfer-Encoding.
final string CONTENT_TRANSFER_ENCODING = "Content-Transfer-Encoding";
# Holds value for Content-ID.
final string CONTENT_ID = "Content-ID";
# Holds value for boundary.
final string BOUNDARY = "boundary";
# Holds value for boundaryString.
final string BOUNDARY_STRING = "boundaryString";
# Holds value for boundaryString1.
final string BOUNDARY_STRING_1 = "boundaryString1";
# Holds value for boundaryString2.
final string BOUNDARY_STRING_2 = "boundaryString2";

# Holds value for multipart/*.
final string MULTIPART_ANY = "multipart/*";
# Holds value for text/*.
final string TEXT_ANY = "text/*";
# Holds value for image/*.
final string IMAGE_ANY = "image/*";
# Holds value for charset.
final string CHARSET = "charset";
# Holds value for base64.
final string BASE_64 = "base64";
# Holds value for inline.
final string INLINE = "inline";
# Holds value for attachment.
final string ATTACHMENT = "attachment";
# Holds value for filename.
final string FILE_NAME = "filename";
# Holds value for name.
final string NAME = "name";
# Holds value for inline image content id prefix.
final string INLINE_IMAGE_CONTENT_ID_PREFIX = "image-";
# Holds value for UTF-8.
final string UTF_8 = "UTF-8";
# Holds default value for bytes chunk to read from a byte channel.
final int BYTES_CHUNK = 100000000;
# Holds the value for trash.
final string TRASH = "trash";
# Holds the value for untrash.
final string UNTRASH = "untrash";
# Holds the value for error.
final string ERROR = "error";
# Holds the value for domain.
final string DOMAIN = "domain";
# Holds the value for reason.
final string REASON = "reason";
# Holds the value for message.
final string MESSAGE = "message";
# Holds the value for locationType.
final string LOCATION_TYPE = "locationType";
# Holds the value for location.
final string LOCATION = "location";
# Holds the value for status code.
final string STATUS_CODE = "status code";

# Holds name for header To.
final string TO = "To";
# Holds name for header From.
final string FROM = "From";
# Holds name for header Cc.
final string CC = "Cc";
# Holds name for header Bcc.
final string BCC = "Bcc";
# Holds name for header Subject.
final string SUBJECT = "Subject";
# Holds name for header Date.
final string DATE = "Date";
# Holds name for id.
final string ID = "id";
# Holds name for threadId.
final string THREAD_ID = "threadId";

# Holds string for Gmail message/thread response format **full**.
public final string FORMAT_FULL = "full";
# Holds string for Gmail message/thread response format **metadata**.
public final string FORMAT_METADATA = "metadata";
# Holds string for Gmail message/thread response format **minimal**.
public final string FORMAT_MINIMAL = "minimal";
# Holds string for Gmail message/thread response format **raw**.
public final string FORMAT_RAW = "raw";

# Holds value for message type **text/plain**.
public final string TEXT_PLAIN = "text/plain";
# Holds value for message type **text/html**.
public final string TEXT_HTML = "text/html";

// Error Codes
final string GMAIL_ERROR_CODE = "(wso2/gmail)GmailError";
