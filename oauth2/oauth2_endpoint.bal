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

public type OAuth2Client object {
    public {
        OAuth2Connector conn;
        OAuth2ClientEndpointConfig config;
    }

    new () {

    }

    public function init(OAuth2ClientEndpointConfig config) {
        self.config = config;
        self.conn = new (config.accessToken, config.baseUrl, config.clientId, config.clientSecret, config.refreshToken,
            config.refreshTokenEP, config.refreshTokenPath, config.useUriParams, config.setCredentialsInHeader,
            http:createHttpClient(config.baseUrl, config.clientConfig), config.clientConfig);
    }

    public function register(typedesc serviceType) {

    }

    public function start() {

    }

    @Description {value:"Returns the connector that client code uses"}
    @Return {value:"The connector that client code uses"}
    public function getClient() returns OAuth2Connector {
        return self.conn;
    }

    @Description {value:"Stops the registered service"}
    @Return {value:"Error occured during registration"}
    public function stop() {

    }
};

public type OAuth2ClientEndpointConfig {
    string accessToken;
    string baseUrl;
    string clientId;
    string clientSecret;
    string refreshToken;
    string refreshTokenEP;
    string refreshTokenPath;
    boolean useUriParams = false;
    boolean setCredentialsInHeader = false;
    http:ClientEndpointConfiguration clientConfig;
};
