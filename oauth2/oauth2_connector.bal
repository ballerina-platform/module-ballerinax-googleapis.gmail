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

import ballerina/http;
import ballerina/mime;
import ballerina/util;

public type OAuth2Connector object {
    public {
        string accessToken;
        string baseUrl;
        string clientId;
        string clientSecret;
        string refreshToken;
        string refreshTokenEP;
        string refreshTokenPath;
        boolean useUriParams = false;
        boolean setCredentialsInHeader = false;
        http:HttpClient httpClient;
        http:ClientEndpointConfiguration clientConfig;
    }
    private {
        http:Response response;
        http:HttpConnectorError httpConnectorError;
    }

    new (accessToken, baseUrl, clientId, clientSecret, refreshToken, refreshTokenEP, refreshTokenPath, useUriParams,
    setCredentialsInHeader, httpClient, clientConfig) {
    }

    public function get (string path, http:Request originalRequest) returns http:Response|http:HttpConnectorError {
        match self.canProcess(originalRequest) {
            http:HttpConnectorError err => return err;
            boolean val => {
                var httpResponse = self.httpClient.get(path, originalRequest);
                match httpResponse {
                    http:HttpConnectorError err => return err;
                    http:Response res => {
                        response = res;
                        http:Request request = new ();
                        match self.checkAndRefreshToken(request) {
                            http:HttpConnectorError err => return err;
                            boolean isRefreshed => {
                                if (isRefreshed) {
                                    match self.httpClient.get(path, request) {
                                        http:HttpConnectorError err => return err;
                                        http:Response newResponse => response = newResponse;
                                    }
                                }
                            }

                        }
                    }
                }
            }
        }
        return response;
    }

    public function post (string path, http:Request originalRequest) returns http:Response|http:HttpConnectorError {
        var requestJson = originalRequest.getJsonPayload();
        json originalPayload = check requestJson;
        match self.canProcess(originalRequest) {
            http:HttpConnectorError err => return err;
            boolean val => {
                var httpResponse = self.httpClient.post(path, originalRequest);
                match httpResponse {
                    http:HttpConnectorError err => return err;
                    http:Response res => {
                        response = res;
                        http:Request request = new ();
                        request.setJsonPayload(originalPayload);
                        match self.checkAndRefreshToken(request) {
                            http:HttpConnectorError err => return err;
                            boolean isRefreshed => {
                                if (isRefreshed) {
                                    match self.httpClient.post(path, request) {
                                        http:HttpConnectorError err => return err;
                                        http:Response newResponse => response = newResponse;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return response;
    }

    public function put(string path, http:Request originalRequest) returns http:Response|http:HttpConnectorError {
        var responseJson = originalRequest.getJsonPayload();
        json originalPayload = check responseJson;
        match self.canProcess(originalRequest) {
            http:HttpConnectorError err => return err;
            boolean val => {
                var httpResponse = self.httpClient.put(path, originalRequest);
                match httpResponse {
                    http:HttpConnectorError err => return err;
                    http:Response res => {
                        response = res;
                        http:Request request = new ();
                        request.setJsonPayload(originalPayload);
                        match self.checkAndRefreshToken(request) {
                            http:HttpConnectorError err => return err;
                            boolean isRefreshed => {
                                if (isRefreshed) {
                                    match self.httpClient.put(path, request) {
                                        http:HttpConnectorError err => return err;
                                        http:Response newResponse => response = newResponse;
                                    }
                                }
                            }

                        }
                    }
                }
            }
        }
        return response;
    }

    public function patch(string path, http:Request originalRequest) returns http:Response|http:HttpConnectorError {
        var requestJson = originalRequest.getJsonPayload();
        json originalPayload = check requestJson;
        match self.canProcess(originalRequest) {
            http:HttpConnectorError err => return err;
            boolean val => {
                var httpResponse = self.httpClient.patch(path, originalRequest);
                match httpResponse {
                    http:HttpConnectorError err => return err;
                    http:Response res => {
                        response = res;
                        http:Request request = new ();
                        request.setJsonPayload(originalPayload);
                        match self.checkAndRefreshToken(request) {
                            http:HttpConnectorError err => return err;
                            boolean isRefreshed => {
                                if (isRefreshed) {
                                    match self.httpClient.patch(path, request) {
                                        http:HttpConnectorError err => return err;
                                        http:Response newResponse => response = newResponse;
                                    }
                                }
                            }

                        }
                    }
                }
            }
        }
        return response;
    }

    public function delete(string path, http:Request originalRequest) returns http:Response|http:HttpConnectorError {
        match self.canProcess(originalRequest) {
            http:HttpConnectorError err => return err;
            boolean val => {
                var httpResponse = self.httpClient.delete(path, originalRequest);
                match httpResponse {
                    http:HttpConnectorError err => return err;
                    http:Response res => {
                        response = res;
                        http:Request request = new ();
                        match self.checkAndRefreshToken(request) {
                            http:HttpConnectorError err => return err;
                            boolean isRefreshed => {
                                if (isRefreshed) {
                                    match self.httpClient.delete(path, request) {
                                        http:HttpConnectorError err => return err;
                                        http:Response newResponse => response = newResponse;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return response;
    }

    function canProcess(http:Request request) returns (boolean)|http:HttpConnectorError {
        if (self.accessToken == "") {
            if (self.refreshToken != "" && self.clientId != ""
            && self.clientSecret != "") {
                var accessTokenValueResponse = self.getAccessTokenFromRefreshToken(request);
                match accessTokenValueResponse {
                    string accessTokenString => request.setHeader("Authorization", "Bearer " + accessTokenString);
                    http:HttpConnectorError err => return err;
                }
            } else {
                httpConnectorError.message = "Valid access_token or refresh_token is not available to process the request";
                return httpConnectorError;
            }
        } else {
            request.setHeader("Authorization", "Bearer " + self.accessToken);
        }
        return true;
    }

    function checkAndRefreshToken(http:Request request) returns (boolean)|http:HttpConnectorError {
        if ((response.statusCode == 401) && self.refreshToken != "" && self.clientId != ""
        && self.clientSecret != "") {
            var accessTokenValueResponse = self.getAccessTokenFromRefreshToken(request);
            match accessTokenValueResponse {
                string accessTokenString => request.setHeader("Authorization", "Bearer " + accessTokenString);
                http:HttpConnectorError err => return err;
            }
            return true;
        }
        return false;
    }

    function getAccessTokenFromRefreshToken(http:Request request) returns (string)|http:HttpConnectorError {
        http:HttpClient refreshTokenClient = http:createHttpClient(self.refreshTokenEP,
            self.clientConfig);
        http:Request refreshTokenRequest = new ();
        http:Response httpRefreshTokenResponse = new ();
        http:HttpConnectorError connectorError = {};
        boolean useUriParams = self.useUriParams;
        boolean setCredentialsInHeader = self.setCredentialsInHeader;
        string accessTokenFromRefreshTokenReq = self.refreshTokenPath;
        string requestParams = "refresh_token=" + self.refreshToken
        + "&grant_type=refresh_token&client_secret=" + self.clientSecret
        + "&client_id=" + self.clientId;
        string base64ClientIdSecret;
        if (setCredentialsInHeader) {
            string clientIdSecret = self.clientId + ":" + self.clientSecret;
            match (util:base64EncodeString(clientIdSecret)){
                string encodeString => base64ClientIdSecret = encodeString;
                util:Base64EncodeError err => {
                    httpConnectorError.message = err.message;
                    return httpConnectorError;
                }
            }
            refreshTokenRequest.addHeader("Content-Type", "application/x-www-form-urlencoded");
            refreshTokenRequest.addHeader("Authorization", "Basic " + base64ClientIdSecret);
            refreshTokenRequest.setStringPayload("grant_type=refresh_token&refresh_token=" + self.refreshToken);
        } else if (useUriParams) {
            refreshTokenRequest.addHeader("Content-Type", "application/x-www-form-urlencoded");
            refreshTokenRequest.setStringPayload(requestParams);
        } else {
            accessTokenFromRefreshTokenReq = accessTokenFromRefreshTokenReq + "?" + requestParams;
        }
        var refreshTokenResponse = refreshTokenClient.post(accessTokenFromRefreshTokenReq, refreshTokenRequest);
        match refreshTokenResponse {
            http:Response httpResponse => httpRefreshTokenResponse = httpResponse;
            http:HttpConnectorError err => return err;
        }
        var requestAccessTokenJson = httpRefreshTokenResponse.getJsonPayload();
        json accessTokenFromRefreshTokenJSONResponse = check requestAccessTokenJson;

        if (httpRefreshTokenResponse.statusCode == 200) {
            string accessToken = accessTokenFromRefreshTokenJSONResponse.access_token.toString() but { () => "" };
            self.accessToken = accessToken;
            if (accessTokenFromRefreshTokenJSONResponse.refresh_token != ()) {
                self.refreshToken = accessTokenFromRefreshTokenJSONResponse.refresh_token.toString() but { () => "" };
            }
        } else {
            connectorError.message = accessTokenFromRefreshTokenJSONResponse.toString() but { () => "" };
            return connectorError;
        }
        return self.accessToken;
    }
};
