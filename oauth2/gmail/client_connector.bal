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

package oauth2.gmail;

import ballerina.net.http;

string accessTokenValue;
http:HttpConnectorError e;
http:InResponse response = {};

@Description {value:"OAuth2 client connector"}
@Param {value:"baseUrl: The endpoint base url"}
@Param {value:"accessToken: The access token of the account"}
@Param {value:"clientId: The client Id of the account"}
@Param {value:"clientSecret: The client secret of the account"}
@Param {value:"refreshToken: The refresh token of the account"}
@Param {value:"refreshTokenEP: The refresh token endpoint url"}
public connector ClientConnector (string baseUrl, string accessToken, string clientId, string clientSecret,
                                  string refreshToken, string refreshTokenEP, string refreshTokenPath) {

    endpoint<http:HttpClient> httpConnectorEP {
        create http:HttpClient(baseUrl, {});
    }

    @Description {value:"Get with OAuth2 authentication"}
    @Param {value:"path: The endpoint path"}
    @Param {value:"request: The request of the method"}
    @Return {value:"response object"}
    @Return {value:"Error occured during HTTP client invocation."}
    action get (string path, http:OutRequest request) (http:InResponse, http:HttpConnectorError) {
        populateAuthHeader(request, accessToken);
        response, e = httpConnectorEP.get(path, request);
        request = {};

        if (checkAndRefreshToken(request, accessToken, clientId, clientSecret, refreshToken, refreshTokenEP,
                                 refreshTokenPath)) {
            response, e = httpConnectorEP.get(path, request);
        }

        return response, e;
    }

    @Description {value:"Post with OAuth2 authentication"}
    @Param {value:"path: The endpoint path"}
    @Param {value:"request: The request of the method"}
    @Return {value:"response object"}
    @Return {value:"Error occured during HTTP client invocation."}
    action post (string path, http:OutRequest originalRequest) (http:InResponse, http:HttpConnectorError) {
        json originalPayload = originalRequest.getJsonPayload();

        populateAuthHeader(originalRequest, accessToken);
        response, e = httpConnectorEP.post(path, originalRequest);

        http:OutRequest request = {};
        request.setJsonPayload(originalPayload);

        if (checkAndRefreshToken(request, accessToken, clientId, clientSecret, refreshToken, refreshTokenEP,
                                 refreshTokenPath)) {
            response, e = httpConnectorEP.post(path, request);
        }

        return response, e;
    }

    @Description {value:"Put with OAuth2 authentication"}
    @Param {value:"path: The endpoint path"}
    @Param {value:"request: The request of the method"}
    @Return {value:"response object"}
    @Return {value:"Error occured during HTTP client invocation."}
    action put (string path, http:OutRequest originalRequest) (http:InResponse, http:HttpConnectorError) {
        json originalPayload = originalRequest.getJsonPayload();

        populateAuthHeader(originalRequest, accessToken);
        response, e = httpConnectorEP.put(path, originalRequest);

        http:OutRequest request = {};
        request.setJsonPayload(originalPayload);

        if (checkAndRefreshToken(request, accessToken, clientId, clientSecret, refreshToken, refreshTokenEP,
                                 refreshTokenPath)) {
            response, e = httpConnectorEP.put(path, request);
        }

        return response, e;
    }

    @Description {value:"Delete with OAuth2 authentication"}
    @Param {value:"path: The endpoint path"}
    @Param {value:"request: The request of the method"}
    @Return {value:"response object"}
    @Return {value:"Error occured during HTTP client invocation."}
    action delete (string path, http:OutRequest originalRequest) (http:InResponse, http:HttpConnectorError) {
        //json originalPayload = originalRequest.getJsonPayload();

        populateAuthHeader(originalRequest, accessToken);
        response, e = httpConnectorEP.delete(path, originalRequest);

        http:OutRequest request = {};
        //request.setJsonPayload(originalPayload);

        if (checkAndRefreshToken(request, accessToken, clientId, clientSecret, refreshToken, refreshTokenEP,
                                 refreshTokenPath)) {
            response, e = httpConnectorEP.delete(path, request);
        }

        return response, e;
    }

    @Description {value:"Patch with OAuth2 authentication"}
    @Param {value:"path: The endpoint path"}
    @Param {value:"request: The request of the method"}
    @Return {value:"response object"}
    @Return {value:"Error occured during HTTP client invocation."}
    action patch (string path, http:OutRequest originalRequest) (http:InResponse, http:HttpConnectorError) {
        json originalPayload = originalRequest.getJsonPayload();

        populateAuthHeader(originalRequest, accessToken);
        response, e = httpConnectorEP.patch(path, originalRequest);

        http:OutRequest request = {};
        request.setJsonPayload(originalPayload);

        if (checkAndRefreshToken(request, accessToken, clientId, clientSecret, refreshToken, refreshTokenEP,
                                 refreshTokenPath)) {
            response, e = httpConnectorEP.patch(path, request);
        }

        return response, e;
    }
}

function populateAuthHeader (http:OutRequest request, string accessToken) {
    if (accessTokenValue == null || accessTokenValue == "") {
        accessTokenValue = accessToken;
    }

    request.setHeader("Authorization", "Bearer " + accessTokenValue);
}

function checkAndRefreshToken (http:OutRequest request, string accessToken, string clientId,
                               string clientSecret, string refreshToken, string refreshTokenEP, string refreshTokenPath) (boolean) {
    boolean isRefreshed;
    if ((response.statusCode == 401) && refreshToken != null) {
        accessTokenValue = getAccessTokenFromRefreshToken(request, accessToken, clientId, clientSecret, refreshToken,
                                                          refreshTokenEP, refreshTokenPath);
        isRefreshed = true;
    }

    return isRefreshed;
}

function getAccessTokenFromRefreshToken (http:OutRequest request, string accessToken, string clientId, string clientSecret,
                                         string refreshToken, string refreshTokenEP, string refreshTokenPath) (string) {

    endpoint<http:HttpClient> refreshTokenHTTPEP {
        create http:HttpClient(refreshTokenEP, {});
    }

    http:OutRequest refreshTokenRequest = {};
    http:InResponse refreshTokenResponse = {};
    string accessTokenFromRefreshTokenReq;
    json accessTokenFromRefreshTokenJSONResponse;

    accessTokenFromRefreshTokenReq = refreshTokenPath + "?refresh_token=" + refreshToken
                                     + "&grant_type=refresh_token&client_secret="
                                     + clientSecret + "&client_id=" + clientId;
    refreshTokenResponse, e = refreshTokenHTTPEP.post(accessTokenFromRefreshTokenReq, refreshTokenRequest);
    accessTokenFromRefreshTokenJSONResponse = refreshTokenResponse.getJsonPayload();
    accessToken = accessTokenFromRefreshTokenJSONResponse.access_token.toString();
    request.setHeader("Authorization", "Bearer " + accessToken);

    return accessToken;
}
