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

documentation{
    Represents Gmail endpoint.

    E{{}}
    F{{gmailConfig}} Gmail endpoint configuration
    F{{gmailConnector}} Gmail connector
}
public type Client object {
    public {
        GmailConfiguration gmailConfig;
        GmailConnector gmailConnector;
    }

    documentation{
        Gets called when the gmail endpoint is beign initialized.

        P{{config}} Gmail connector configuration
    }
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

    documentation{
        Returns the connector that client code uses.

        R{{}} Returns GmailConnector
    }
    public function getCallerActions() returns GmailConnector {
        return self.gmailConnector;
    }
};

documentation{
    Represents the Gmail client endpoint configuration.

    F{{clientConfig}} The HTTP Client endpoint configuration
}
public type GmailConfiguration {
    http:ClientEndpointConfig clientConfig;
};
