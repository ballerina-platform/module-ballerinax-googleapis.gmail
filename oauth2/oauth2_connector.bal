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

import ballerina/io;
import ballerina/net.http;
import ballerina/mime;

@Description {value:"Struct to initialize the connection."}
public struct OAuth2Connector {
    string accessToken;
    string baseUrl;
    string clientId;
    string clientSecret;
    string refreshToken;
    string refreshTokenEP;
    string refreshTokenPath;
    boolean useUriParams = false;
    http:HttpClient httpClient;
    http:ClientEndpointConfiguration clientConfig;
}

http:Response response = {};
http:HttpConnectorError httpConnectorError = {};

public function <OAuth2Connector oAuth2Connector> get (string path, http:Request originalRequest)
returns http:Response | http:HttpConnectorError {
    match oAuth2Connector.canProcess(originalRequest) {
        http:HttpConnectorError err => return err;
        boolean val => {
            var httpResponse = oAuth2Connector.httpClient.get(path, originalRequest);
            match  httpResponse {
                http:HttpConnectorError err => return err;
                http:Response res => {
                    response = res;
                    http:Request request = {};
                    match oAuth2Connector.checkAndRefreshToken(request) {
                        http:HttpConnectorError err => return err;
                        boolean isRefreshed => {
                            if (isRefreshed) {
                                match oAuth2Connector.httpClient.get(path, request) {
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

public function <OAuth2Connector oAuth2Connector> post (string path, http:Request originalRequest)
returns http:Response | http:HttpConnectorError {
    json originalPayload =? originalRequest.getJsonPayload();
    match oAuth2Connector.canProcess(originalRequest) {
        http:HttpConnectorError err => return err;
        boolean val => {
            var httpResponse = oAuth2Connector.httpClient.post(path, originalRequest);
            match  httpResponse {
                http:HttpConnectorError err => return err;
                http:Response res => {
                    response = res;
                    http:Request request = {};
                    request.setJsonPayload(originalPayload);
                    match oAuth2Connector.checkAndRefreshToken(request) {
                        http:HttpConnectorError err => return err;
                        boolean isRefreshed => {
                            if (isRefreshed) {
                                match oAuth2Connector.httpClient.post(path, request) {
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

public function <OAuth2Connector oAuth2Connector> put (string path, http:Request originalRequest)
returns http:Response | http:HttpConnectorError {
    json originalPayload =? originalRequest.getJsonPayload();
    match oAuth2Connector.canProcess(originalRequest) {
        http:HttpConnectorError err => return err;
        boolean val => {
            var httpResponse = oAuth2Connector.httpClient.put(path, originalRequest);
            match  httpResponse {
                http:HttpConnectorError err => return err;
                http:Response res => {
                    response = res;
                    http:Request request = {};
                    request.setJsonPayload(originalPayload);
                    match oAuth2Connector.checkAndRefreshToken(request) {
                        http:HttpConnectorError err => return err;
                        boolean isRefreshed => {
                            if (isRefreshed) {
                                match oAuth2Connector.httpClient.put(path, request) {
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

public function <OAuth2Connector oAuth2Connector> patch (string path, http:Request originalRequest)
returns http:Response | http:HttpConnectorError {
    json originalPayload =? originalRequest.getJsonPayload();
    match oAuth2Connector.canProcess(originalRequest) {
        http:HttpConnectorError err => return err;
        boolean val => {
            var httpResponse = oAuth2Connector.httpClient.patch(path, originalRequest);
            match  httpResponse {
                http:HttpConnectorError err => return err;
                http:Response res => {
                    response = res;
                    http:Request request = {};
                    request.setJsonPayload(originalPayload);
                    match oAuth2Connector.checkAndRefreshToken(request) {
                        http:HttpConnectorError err => return err;
                        boolean isRefreshed => {
                            if (isRefreshed) {
                                match oAuth2Connector.httpClient.patch(path, request) {
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


public function <OAuth2Connector oAuth2Connector> delete (string path, http:Request originalRequest)
returns http:Response | http:HttpConnectorError {
    match oAuth2Connector.canProcess(originalRequest) {
        http:HttpConnectorError err => return err;
        boolean val => {
            var httpResponse = oAuth2Connector.httpClient.delete(path, originalRequest);
            match  httpResponse {
                http:HttpConnectorError err => return err;
                http:Response res => {
                    response = res;
                    http:Request request = {};
                    match oAuth2Connector.checkAndRefreshToken(request) {
                        http:HttpConnectorError err => return err;
                        boolean isRefreshed => {
                            if (isRefreshed) {
                                match oAuth2Connector.httpClient.delete(path, request) {
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

function <OAuth2Connector oAuth2Connector> canProcess (http:Request request)
returns (boolean) | http:HttpConnectorError {
    if (oAuth2Connector.accessToken == "") {
        if (oAuth2Connector.refreshToken != "") {
            var  accessTokenValueResponse = oAuth2Connector.getAccessTokenFromRefreshToken(request);
            match accessTokenValueResponse {
                string accessTokenString => request.setHeader("Authorization", "Bearer " + accessTokenString);
                http:HttpConnectorError err =>  return err;
            }
        } else {
            httpConnectorError.message = "Valid access_token or refresh_token is not available to process the request";
            return httpConnectorError;
        }
    } else {
        request.setHeader("Authorization", "Bearer " + oAuth2Connector.accessToken);
    }
    return true;
}

function <OAuth2Connector oAuth2Connector> checkAndRefreshToken (http:Request request)
returns (boolean) | http:HttpConnectorError {
    if ((response.statusCode == 401) && oAuth2Connector.refreshToken != "") {
        var accessTokenValueResponse = oAuth2Connector.getAccessTokenFromRefreshToken(request);
        match accessTokenValueResponse {
            string accessTokenString => request.setHeader("Authorization", "Bearer " + accessTokenString);
            http:HttpConnectorError err => return err;
        }
        return true;
    }
    return false;
}

function <OAuth2Connector oAuth2Connector> getAccessTokenFromRefreshToken (http:Request request)
                                                        returns (string) | http:HttpConnectorError {
    http:HttpClient refreshTokenClient = http:createHttpClient(oAuth2Connector.refreshTokenEP,
                                                               oAuth2Connector.clientConfig);
    http:Request refreshTokenRequest = {};
    http:Response httpRefreshTokenResponse = {};
    http:HttpConnectorError connectorError = {};
    boolean useUriParams = oAuth2Connector.useUriParams;
    string accessTokenFromRefreshTokenReq = oAuth2Connector.refreshTokenPath;
    string requestParams = "refresh_token=" + oAuth2Connector.refreshToken
                                            + "&grant_type=refresh_token&client_secret=" + oAuth2Connector.clientSecret
                                            + "&client_id=" + oAuth2Connector.clientId;
    if(useUriParams) {
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
    json accessTokenFromRefreshTokenJSONResponse =? httpRefreshTokenResponse.getJsonPayload();

    if (httpRefreshTokenResponse.statusCode == 200) {
        string accessToken = accessTokenFromRefreshTokenJSONResponse.access_token.toString();
        oAuth2Connector.accessToken = accessToken;
        if (accessTokenFromRefreshTokenJSONResponse.refresh_token != null) {
            oAuth2Connector.refreshToken = accessTokenFromRefreshTokenJSONResponse.refresh_token.toString();
        }
    } else {
        connectorError.message = accessTokenFromRefreshTokenJSONResponse.toString();
        return connectorError;
    }
    return oAuth2Connector.accessToken;
}
