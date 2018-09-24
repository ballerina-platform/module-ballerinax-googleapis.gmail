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

import ballerina/http;

# Represents Gmail endpoint.
# + gmailConfig - Gmail endpoint configuration
# + gmailConnector - Gmail connector
public type Client object {
    public GmailConfiguration gmailConfig;
    public GmailConnector gmailConnector;

    # Gets called when the gmail endpoint is beign initialized.
    # + config - Gmail connector configuration
    public function init(GmailConfiguration config) {
        config.clientConfig.url = BASE_URL;
        match config.clientConfig.auth {
            () => {}
            http:AuthConfig authConfig => {
                authConfig.refreshUrl = REFRESH_TOKEN_EP;
                authConfig.scheme = http:OAUTH2;
            }
        }
        self.gmailConnector = new;
        self.gmailConnector.client.init(config.clientConfig);
    }

    # Returns the connector that client code uses.
    # + return - Returns GmailConnector
    public function getCallerActions() returns GmailConnector {
        return self.gmailConnector;
    }
};

# Represents the Gmail client endpoint configuration.
# + clientConfig - The HTTP Client endpoint configuration
public type GmailConfiguration record {
    http:ClientEndpointConfig clientConfig;
};
