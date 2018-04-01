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

package gmail;

import ballerina/net.http;
import oauth2;

@Description {value:"Struct to set the Gmail configuration."}
public struct GmailConfiguration {
    oauth2:OAuth2Configuration oauthClientConfig;
}

@Description {value:"Set the client configuration."}
public function <GmailConfiguration gmailConfig> GmailConfiguration () {
    gmailConfig.oauthClientConfig = {};
}

@Description {value:"Gmail Endpoint struct."}
public struct GmailEndpoint {
    oauth2:OAuth2Endpoint oauthEP;
    GmailConfiguration gmailConfig;
    GmailConnector gmailConnector;
}
@Description {value:"Initialize the gmail endpoint"}
public function <GmailEndpoint ep> init (GmailConfiguration gmailConfig) {
    ep.oauthEP.init(gmailConfig.oauthClientConfig);
    ep.gmailConnector.oauthEndpoint = ep.oauthEP;
    ep.gmailConnector.baseUrl = gmailConfig.oauthClientConfig.baseUrl;
}

public function <GmailEndpoint ep> register (typedesc serviceType) {

}

public function <GmailEndpoint ep> start () {

}

@Description {value:"Returns the connector that client code uses"}
@Return {value:"The connector that client code uses"}
public function <GmailEndpoint ep> getClient () returns GmailConnector {
    return ep.gmailConnector;
}

@Description {value:"Stops the registered service"}
@Return {value:"Error occured during registration"}
public function <GmailEndpoint ep> stop () {

}