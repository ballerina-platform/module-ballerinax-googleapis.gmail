// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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


# Holds the value for URL of pubsub.
const string PUBSUB_BASE_URL = "https://pubsub.googleapis.com/v1";
# Holds the value for "/" string.
const string FORWARD_SLASH_SYMBOL = "/";
# Holds the value of label Id "STARRED".
const string STARRED = "STARRED";
#Holds the value of label Id "INBOX".
const string INBOX = "INBOX";

# Holds the value "me". Used as current authenticated userId.
const string ME = "me";
# Holds the value for empty string.
const string EMPTY_STRING = "";
# Holds the value for new line string.
const string NEW_LINE = "\n";
# Holds the value for ";" string.
const string WHITE_SPACE = " ";
# Holds the value for ":" string.
const string COLON_SYMBOL = ":";
# Holds the value for ";" string.
const string SEMICOLON_SYMBOL = ";";
# Holds the value for error.
const string ERROR = "error";
# Holds the value for domain.
const string DOMAIN = "domain";
# Holds the value for reason.
const string REASON = "reason";
# Holds the value for message.
const string MESSAGE = "message";
# Holds the value for locationType.
const string LOCATION_TYPE = "locationType";
# Holds the value for location.
const string LOCATION = "location";
# Holds the value for status code.
const string STATUS_CODE = "status code";

# Holds the value for IAM role for topic IAM policy.
const string ROLE = "roles/pubsub.publisher";
# Holds the value for service account for push notification setup.
const string IAM_POLICY_BINDING_MEMBER = "serviceAccount:gmail-api-push@system.gserviceaccount.com";
# Holds the value for push notification listener path in http service.
const string LISTENER_PATH = "/mailboxChanges";
# Holds the value for topic prefix.
const string TOPIC_NAME_PREFIX = "topic-";
# Holds the value for subscription prefix.
const string SUBSCRIPTION_NAME_PREFIX = "subscription-";
# Holds the value for one day interval in seconds for watch scheduler.
const decimal INTERVAL_TO_WATCH = 86400;
# Holds the value for Google project resource path.
const string PROJECTS = "/projects/";
# Holds the value for subscriptions resource path.
const string SUBSCRIPTIONS = "/subscriptions/";
# Holds the value for topics resource path.
const string TOPICS = "/topics/";
# Holds the value for :getIamPolicy resource path.
const string GETIAMPOLICY = ":getIamPolicy";
# Holds the value for :setIamPolicy resource path.
const string SETIAMPOLICY = ":setIamPolicy";
# Holds the value Error code in listener.
const string GMAIL_LISTENER_ERROR_CODE = "(ballerinax/googleapis.gmail) GmailListenerError";

public enum Encoding {
    ENCODING_UNSPECIFIED,
    JSON,
    BINARY
}
