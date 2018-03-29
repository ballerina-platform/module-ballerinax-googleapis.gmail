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

package oauth2;

import ballerina/net.http;

@Description {value:"Struct to define the OAuth2 configuration."}
public struct OAuth2Configuration {
    string accessToken;
    string baseUrl;
    string clientId;
    string clientSecret;
    string refreshToken;
    string refreshTokenEP;
    string refreshTokenPath;
    boolean useUriParams = false;
    http:ClientEndpointConfiguration clientConfig;
}

@Description {value:"OAuth2 Endpoint struct."}
public struct OAuth2Endpoint {
    OAuth2Configuration oAuth2Config;
    OAuth2Connector oAuth2Connector;
}

public function <OAuth2Endpoint oAuth2EP> init (OAuth2Configuration oAuth2Configuration) {
    oAuth2EP.oAuth2Connector = { accessToken:oAuth2Configuration.accessToken,
                       refreshToken:oAuth2Configuration.refreshToken,
                       clientId:oAuth2Configuration.clientId,
                       clientSecret:oAuth2Configuration.clientSecret,
                       refreshTokenEP:oAuth2Configuration.refreshTokenEP,
                       refreshTokenPath:oAuth2Configuration.refreshTokenPath,
                       useUriParams:oAuth2Configuration.useUriParams,
                       httpClient:http:createHttpClient(oAuth2Configuration.baseUrl, oAuth2Configuration.clientConfig)};
}

public function <OAuth2Endpoint oAuth2EP> register(typedesc serviceType) {

}

public function <OAuth2Endpoint oAuth2EP> start() {

}

@Description { value:"Returns the connector that client code uses"}
@Return { value:"The connector that client code uses" }
public function <OAuth2Endpoint oAuth2EP> getClient() returns OAuth2Connector {
    return oAuth2EP.oAuth2Connector;
}

@Description { value:"Stops the registered service"}
@Return { value:"Error occured during registration" }
public function <OAuth2Endpoint oAuth2EP> stop() {

}