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

#Represents available triggers
public enum Trigger {
    ON_NEW_EMAIL,
    ON_NEW_THREAD,
    ON_NEW_LABELED,
    ON_NEW_STARED,
    ON_LABEL_REMOVED,
    ON_STAR_REMOVED,
    ON_NEW_ATTACHMENT
}

# Holds the value of label Id "STARRED".
const string STARRED = "STARRED";
#Holds the value of label Id "INBOX".
const string INBOX = "INBOX";

# Holds the value "me". Used as current authenticated userId.
const string ME = "me";

const string ROLE = "roles/pubsub.publisher";
const string IAM_POLICY_BINDING_MEMBER = "serviceAccount:gmail-api-push@system.gserviceaccount.com";
const string LISTENER_PATH = "/mailboxChanges";
const int ACK_DEADLINE_SECONDS = 10;
const boolean RETAIN_ACKED_MESSAGES = false;
const string MESSAGE_RETENTION_DURATION = "604800s";

