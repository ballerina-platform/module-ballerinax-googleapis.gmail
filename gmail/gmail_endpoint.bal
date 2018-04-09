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
import wso2/oauth2;

@Description {value:"GMail Endpoint type."}
public type Client object {
    public {
        oauth2:Client oauthEP;
        GMailConfiguration gMailConfig;
        GMailConnector gMailConnector;
    }

    new () {}

    @Description {value:"Initialize the gMail endpoint"}
    public function init(GMailConfiguration gMailConfig) {
        gMailConfig.oAuth2ClientConfig.useUriParams = true;
        self.oauthEP.init(gMailConfig.oAuth2ClientConfig);
        self.gMailConnector.oauthEndpoint = self.oauthEP;
    }


    public function register(typedesc serviceType) {

    }

    public function start() {

    }

    @Description {value:"Returns the connector that client code uses"}
    @Return {value:"The connector that client code uses"}
    public function getClient() returns GMailConnector {
        return self.gMailConnector;
    }

    @Description {value:"Stops the registered service"}
    @Return {value:"Error occured during registration"}
    public function stop() {

    }
};

@Description {value:"Type to set the GMail configuration."}
public type GMailConfiguration {
    oauth2:OAuth2ClientEndpointConfiguration oAuth2ClientConfig;
};
