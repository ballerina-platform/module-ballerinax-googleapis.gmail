// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import googleapis.gmail.oas;

# The Gmail API lets you view and manage Gmail mailbox data like threads, messages, and labels.
public isolated client class Client {
    final oas:Client genClient;

    # Gets invoked to initialize the `connector`.
    #
    # + config - The configurations to be used when initializing the `connector` 
    # + serviceUrl - URL of the target service 
    # + return - An error if connector initialization failed 
    public isolated function init(ConnectionConfig config, string serviceUrl = "https://gmail.googleapis.com/gmail/v1")
    returns error? {
        oas:Client genClient = check new oas:Client(config, serviceUrl);
        self.genClient = genClient;
        return;
    }

    # Gets the current user's Gmail profile.
    #
    # + xgafv - V1 error format.
    # + access_token - OAuth access token.
    # + alt - Data format for response.
    # + callback - JSONP
    # + fields - Selector specifying which fields to include in a partial response.
    # + 'key - API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token.
    # + oauth_token - OAuth 2.0 token for the current user.
    # + prettyPrint - Returns response with indentations and line breaks.
    # + quotaUser - Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters.
    # + upload_protocol - Upload protocol for media (e.g. "raw", "multipart").
    # + uploadType - Legacy upload protocol for media (e.g. "media", "multipart").
    # + userId - The user's email address. The special value `me` can be used to indicate the authenticated user.
    # + return - Successful response 
    resource isolated function get users/[string userId]/profile(
            Xgafv? xgafv = (), string? access_token = (), Alt? alt = (), string? callback = (), string? fields = (),
            string? 'key = (), string? oauth_token = (), boolean? prettyPrint = (), string? quotaUser = (),
            string? upload_protocol = (), string? uploadType = ())
    returns Profile|error {
        return self.genClient->/users/[userId]/profile(xgafv, access_token, alt, callback, fields, 'key, oauth_token,
            prettyPrint, quotaUser, upload_protocol, uploadType
        );
    }

}
