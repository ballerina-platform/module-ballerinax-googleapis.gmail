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

package src.gmail;

import oauth2.gmail;
import ballerina.net.http;
import ballerina.util;
import ballerina.io;
import ballerina.log;
import ballerina.mime;

ClientConnector clientConnector;
boolean isConnectorInitialized = false;

@Description {value:"Gmail client connector"}
@Param {value:"userId: The userId of the Gmail account which means the email id"}
@Param {value:"accessToken: The accessToken of the Gmail account to access the gmail REST API"}
@Param {value:"refreshToken: The refreshToken of the Gmail App to access the gmail REST API"}
@Param {value:"clientId: The clientId of the App to access the gmail REST API"}
@Param {value:"clientSecret: The clientSecret of the App to access the gmail REST API"}
public connector ClientConnector (string userId, string accessToken, string refreshToken, string clientId,
                                  string clientSecret) {
    endpoint<gmail:ClientConnector> gmailEP {
        create gmail:ClientConnector("https://www.googleapis.com/gmail", accessToken, clientId, clientSecret, refreshToken,
                                      "https://www.googleapis.com", "/oauth2/v3/token");
    }

    http:HttpConnectorError e;
    GmailError gmailError = {};

    action init(){
        clientConnector = create ClientConnector(userId, accessToken, refreshToken, clientId, clientSecret);
        isConnectorInitialized = true;
    }

    @Description {value:"Retrieve the user profile information"}
    @Return {value:"response structs"}
    action getUserProfile () (UserProfile, GmailError) {
        http:OutRequest request = {};
        http:InResponse response = {};
        UserProfile getUserProfileResponse = {};
        string getUserProfilePath = "/v1/users/" + userId + "/profile";
        response, e = gmailEP.get(getUserProfilePath, request);

        if (e != null) {
            gmailError.statusCode = e.statusCode;
            gmailError.errorMessage = e.message;
            return null, gmailError;
        }
        int statusCode = response.statusCode;
        log:printInfo("\nStatus code: " + statusCode);
        json getUserProfileJSONResponse = response.getJsonPayload();

        if (statusCode == 200) {
            getUserProfileResponse = <UserProfile, userProfileTrans()>getUserProfileJSONResponse;
        } else {
            gmailError.statusCode = statusCode;
            gmailError.errorMessage = getUserProfileJSONResponse.error.message.toString();
        }
        return getUserProfileResponse, gmailError;
    }

    @Description {value:"Create a draft"}
    @Param {value:"createDraft: It is a struct. Which contains all optional parameters (to,subject,from,messageBody
    ,cc,bcc,id,threadId) to create draft message"}
    @Return {value:"response structs"}
    action createDraft (string recipient, string subject, string body, Options options) (Draft, GmailError) {
        http:OutRequest request = {};
        http:InResponse response = {};
        Draft createDraftResponse = {};
        string concatRequest = "";

        string to = recipient;
        string messageBody = body;
        string htmlBody = options.htmlBody;
        string from = options.from;
        string cc = options.cc;
        string bcc = options.bcc;
        string xmlFilePath = options.xmlFilePath;
        string xmlFileName = options.xmlFileName;
        string imageFilePath = options.imageFilePath;
        string imageFileName = options.imageFileName;
        string pdfFilePath = options.pdfFilePath;
        string pdfFileName = options.pdfFileName;

        if (to != "null" && to != "") {
            concatRequest = concatRequest + "to:" + to + "\n";
        }
        if (subject != "null" && subject != "") {
            concatRequest = concatRequest + "subject:" + subject + "\n";
        }
        if (from != "null" && from != "") {
            concatRequest = concatRequest + "from:" + from + "\n";
        }
        if (cc != "null" && cc != "") {
            concatRequest = concatRequest + "cc:" + cc + "\n";
        }
        if (bcc != "null" && bcc != "") {
            concatRequest = concatRequest + "bcc:" + bcc + "\n";
        }
        concatRequest = concatRequest + "content-type:multipart/mixed; boundary=boundaryString" + "\n";

        if (messageBody != "null" && messageBody != "") {
            concatRequest = concatRequest + "\n" + "--boundaryString" + "\n" + "content-type:text/plain" + "\n";
            concatRequest = concatRequest + "\n" + messageBody + "\n";
        }
        if (htmlBody != "null" && htmlBody != "") {
            concatRequest = concatRequest + "\n" + "--boundaryString" + "\n" + "content-type:text/html" + "\n";
            concatRequest = concatRequest + "\n" + htmlBody + "\n";
        }
        if (xmlFilePath != "null" && xmlFilePath != "") {
            concatRequest = concatRequest + "\n" + "--boundaryString" + "\n" + "content-type:text/xml";
            if (xmlFileName != "null" && xmlFileName != "") {
                concatRequest = concatRequest + ";name=" + xmlFileName + "\n";
            }
            concatRequest = concatRequest + "content-transfer-encoding:base64" + "\n";
            concatRequest = concatRequest + "\n" + encodeFile(xmlFilePath) + "\n";
        }
        if (imageFilePath != "null" && imageFilePath != "") {
            concatRequest = concatRequest + "\n" + "--boundaryString" + "\n" + "content-type:image/jpgeg";
            if (imageFileName != "null" && imageFileName != "") {
                concatRequest = concatRequest + ";name=" + imageFileName + "\n";
            }
            concatRequest = concatRequest + "content-transfer-encoding:base64" + "\n";
            concatRequest = concatRequest + "\n" + encodeFile(imageFilePath) + "\n";
        }
        if (pdfFilePath != "null" && pdfFilePath != "") {
            concatRequest = concatRequest + "\n" + "--boundaryString" + "\n" + "content-type:application/pdf";
            if (pdfFileName != "null" && pdfFileName != "") {
                concatRequest = concatRequest + ";name=" + pdfFileName + "\n";
            }
            concatRequest = concatRequest + "content-transfer-encoding:base64" + "\n";
            concatRequest = concatRequest + "\n" + encodeFile(pdfFilePath) + "\n";
        }

        concatRequest = concatRequest + "\n" + "--boundaryString--";
        string encodedRequest = util:base64Encode(concatRequest);
        encodedRequest = encodedRequest.replace("+", "-");
        encodedRequest = encodedRequest.replace("/", "_");
        json createDraftJSONRequest = {"message":{"raw":encodedRequest}};
        string createDraftPath = "/v1/users/" + userId + "/drafts";
        request.setHeader("Content-Type", "Application/json");
        request.setJsonPayload(createDraftJSONRequest);
        response, e = gmailEP.post(createDraftPath, request);

        if (e != null) {
            gmailError.statusCode = e.statusCode;
            gmailError.errorMessage = e.message;
            return null, gmailError;
        }
        int statusCode = response.statusCode;
        log:printInfo("\nStatus code: " + statusCode);
        json createDraftJSONResponse = response.getJsonPayload();

        if (statusCode == 200) {
            //io:println(createDraftJSONResponse);
            createDraftResponse = <Draft, draftTrans()>createDraftJSONResponse;
        } else {
            gmailError.statusCode = statusCode;
            gmailError.errorMessage = createDraftJSONResponse.error.message.toString();
        }
        return createDraftResponse, gmailError;
    }

    @Description {value:"Update a draft"}
    @Param {value:"draftId: Id of the draft to update"}
    @Param {value:"update: It is a struct. Which contains all optional parameters (to,subject,from,messageBody
    ,cc,bcc,id,threadId) to update draft"}
    @Return {value:"response structs"}
    action update (string draftId, string recipient, string subject, string body, Options options) (Draft, GmailError) {
        http:OutRequest request = {};
        http:InResponse response = {};
        Draft updateResponse = {};
        string concatRequest = "";

        string to = recipient;
        string messageBody = body;
        string htmlBody = options.htmlBody;
        string from = options.from;
        string cc = options.cc;
        string bcc = options.bcc;
        string xmlFilePath = options.xmlFilePath;
        string xmlFileName = options.xmlFileName;
        string imageFilePath = options.imageFilePath;
        string imageFileName = options.imageFileName;
        string pdfFilePath = options.pdfFilePath;
        string pdfFileName = options.pdfFileName;

        if (to != "null" && to != "") {
            concatRequest = concatRequest + "to:" + to + "\n";
        }
        if (subject != "null" && subject != "") {
            concatRequest = concatRequest + "subject:" + subject + "\n";
        }
        if (from != "null" && from != "") {
            concatRequest = concatRequest + "from:" + from + "\n";
        }
        if (cc != "null" && cc != "") {
            concatRequest = concatRequest + "cc:" + cc + "\n";
        }
        if (bcc != "null" && bcc != "") {
            concatRequest = concatRequest + "bcc:" + bcc + "\n";
        }
        concatRequest = concatRequest + "content-type:multipart/mixed; boundary=boundaryString" + "\n";

        if (messageBody != "null" && messageBody != "") {
            concatRequest = concatRequest + "\n" + "--boundaryString" + "\n" + "content-type:text/plain" + "\n";
            concatRequest = concatRequest + "\n" + messageBody + "\n";
        }
        if (htmlBody != "null" && htmlBody != "") {
            concatRequest = concatRequest + "\n" + "--boundaryString" + "\n" + "content-type:text/html" + "\n";
            concatRequest = concatRequest + "\n" + htmlBody + "\n";
        }
        if (xmlFilePath != "null" && xmlFilePath != "") {
            concatRequest = concatRequest + "\n" + "--boundaryString" + "\n" + "content-type:text/xml";
            if (xmlFileName != "null" && xmlFileName != "") {
                concatRequest = concatRequest + ";name=" + xmlFileName + "\n";
            }
            concatRequest = concatRequest + "content-transfer-encoding:base64" + "\n";
            concatRequest = concatRequest + "\n" + encodeFile(xmlFilePath) + "\n";
        }
        if (imageFilePath != "null" && imageFilePath != "") {
            concatRequest = concatRequest + "\n" + "--boundaryString" + "\n" + "content-type:image/jpgeg";
            if (imageFileName != "null" && imageFileName != "") {
                concatRequest = concatRequest + ";name=" + imageFileName + "\n";
            }
            concatRequest = concatRequest + "content-transfer-encoding:base64" + "\n";
            concatRequest = concatRequest + "\n" + encodeFile(imageFilePath) + "\n";
        }
        if (pdfFilePath != "null" && pdfFilePath != "") {
            concatRequest = concatRequest + "\n" + "--boundaryString" + "\n" + "content-type:application/pdf";
            if (pdfFileName != "null" && pdfFileName != "") {
                concatRequest = concatRequest + ";name=" + pdfFileName + "\n";
            }
            concatRequest = concatRequest + "content-transfer-encoding:base64" + "\n";
            concatRequest = concatRequest + "\n" + encodeFile(pdfFilePath) + "\n";
        }

        concatRequest = concatRequest + "\n" + "--boundaryString--";
        string encodedRequest = util:base64Encode(concatRequest);
        encodedRequest = encodedRequest.replace("+", "-");
        encodedRequest = encodedRequest.replace("/", "_");
        json updateJSONRequest = {"message":{"raw":encodedRequest}};
        string updatePath = "/v1/users/" + userId + "/drafts/" + draftId;
        request.setHeader("Content-Type", "Application/json");
        request.setJsonPayload(updateJSONRequest);
        response, e = gmailEP.put(updatePath, request);

        if (e != null) {
            gmailError.statusCode = e.statusCode;
            gmailError.errorMessage = e.message;
            return null, gmailError;
        }
        int statusCode = response.statusCode;
        log:printInfo("\nStatus code: " + statusCode);
        json updateJSONResponse = response.getJsonPayload();

        if (statusCode == 200) {
            //io:println(updateJSONResponse);
            updateResponse = <Draft, draftTrans()>updateJSONResponse;
        } else {
            gmailError.statusCode = statusCode;
            gmailError.errorMessage = updateJSONResponse.error.message.toString();
        }
        return updateResponse, gmailError;
    }

    @Description {value:"Send a particular draft"}
    @Param {value:"draftId: Id of the draft to send"}
    @Return {value:"response structs"}
    action send (string draftId) (boolean, GmailError) {
        http:OutRequest request = {};
        http:InResponse response = {};
        boolean sendResponse = false;
        json sendJSONRequest = {"id":draftId};
        string sendPath = "/v1/users/" + userId + "/drafts/send";
        request.setHeader("Content-Type", "Application/json");
        request.setJsonPayload(sendJSONRequest);
        response, e = gmailEP.post(sendPath, request);

        if (e != null) {
            gmailError.statusCode = e.statusCode;
            gmailError.errorMessage = e.message;
            return false, gmailError;
        }
        int statusCode = response.statusCode;
        log:printInfo("\nStatus code: " + statusCode);
        json sendJSONResponse = response.getJsonPayload();

        if (statusCode == 200) {
            sendResponse = true;
        } else {
            gmailError.statusCode = statusCode;
            gmailError.errorMessage = sendJSONResponse.error.message.toString();
        }
        return sendResponse, gmailError;
    }

    @Description {value:"Lists the drafts in the user's mailbox"}
    @Param {value:"getDrafts: It is a struct. Which contains all optional parameters (includeSpamTrash,maxResults,
    pageToken,q) to list drafts"}
    @Return {value:"response structs"}
    action getDrafts (DraftsListFilter getDrafts) (Drafts, GmailError) {
        http:OutRequest request = {};
        http:InResponse response = {};
        Drafts getDraftsResponse = {};
        string uriParams = "";
        string getDraftsPath = "/v1/users/" + userId + "/drafts";

        if (getDrafts != null) {
            string includeSpamTrash = getDrafts.includeSpamTrash;
            string maxResults = getDrafts.maxResults;
            string pageToken = getDrafts.pageToken;
            string q = getDrafts.q;

            if (maxResults != "") {
                uriParams = uriParams + "&maxResults=" + maxResults;
            }
            if (includeSpamTrash != "") {
                uriParams = uriParams + "&includeSpamTrash=" + includeSpamTrash;
            }
            if (pageToken != "") {
                uriParams = uriParams + "&pageToken=" + pageToken;
            }
            if (q != "") {
                uriParams = uriParams + "&q=" + q;
            }
        }
        if (uriParams != "") {
            getDraftsPath = getDraftsPath + "?" + uriParams.subString(1, uriParams.length());
        }

        response, e = gmailEP.get(getDraftsPath, request);
        if (e != null) {
            gmailError.statusCode = e.statusCode;
            gmailError.errorMessage = e.message;
            return null, gmailError;
        }
        int statusCode = response.statusCode;
        log:printInfo("\nStatus code: " + statusCode);
        json getDraftsJSONResponse = response.getJsonPayload();

        if (statusCode == 200) {
            getDraftsResponse = <Drafts, draftsTrans()>getDraftsJSONResponse;
        } else {
            gmailError.statusCode = statusCode;
            gmailError.errorMessage = getDraftsJSONResponse.error.message.toString();
        }
        return getDraftsResponse, gmailError;
    }

    @Description {value:"Delete a particular draft"}
    @Param {value:"draftId: Id of the draft to delete"}
    @Return {value:"response structs"}
    action deleteDraft (string draftId) (boolean, GmailError) {
        http:OutRequest request = {};
        http:InResponse response = {};
        boolean deleteDraftResponse = false;
        string deleteDraftPath = "/v1/users/" + userId + "/drafts/" + draftId;
        response, e = gmailEP.delete(deleteDraftPath, request);

        if (e != null) {
            gmailError.statusCode = e.statusCode;
            gmailError.errorMessage = e.message;
            return false, gmailError;
        }
        int statusCode = response.statusCode;
        log:printInfo("\nStatus code: " + statusCode);

        if (statusCode != 204) {
            gmailError.statusCode = statusCode;
            gmailError.errorMessage = response.reasonPhrase;
        } else {
            deleteDraftResponse = true;
        }
        return deleteDraftResponse, gmailError;
    }

    @Description {value:"Send a mail"}
    @Param {value:"sendEmail: It is a struct. Which contains all optional parameters (to,subject,from,messageBody,
    cc,bcc,id,threadId)"}
    @Return {value:"response struct"}
    action sendEmail (string recipient, string subject, string body, Options options) (Message, GmailError) {
        http:OutRequest request = {};
        http:InResponse response = {};
        Message sendEmailResponse = {};
        string concatRequest = "";

        string to = recipient;
        string messageBody = body;
        string htmlBody = options.htmlBody;
        string from = options.from;
        string cc = options.cc;
        string bcc = options.bcc;
        string xmlFilePath = options.xmlFilePath;
        string xmlFileName = options.xmlFileName;
        string imageFilePath = options.imageFilePath;
        string imageFileName = options.imageFileName;
        string pdfFilePath = options.pdfFilePath;
        string pdfFileName = options.pdfFileName;

        if (to != "null" && to != "") {
            concatRequest = concatRequest + "to:" + to + "\n";
        }
        if (subject != "null" && subject != "") {
            concatRequest = concatRequest + "subject:" + subject + "\n";
        }
        if (from != "null" && from != "") {
            concatRequest = concatRequest + "from:" + from + "\n";
        }
        if (cc != "null" && cc != "") {
            concatRequest = concatRequest + "cc:" + cc + "\n";
        }
        if (bcc != "null" && bcc != "") {
            concatRequest = concatRequest + "bcc:" + bcc + "\n";
        }
        concatRequest = concatRequest + "content-type:multipart/mixed; boundary=boundaryString" + "\n";

        if (messageBody != "null" && messageBody != "") {
            concatRequest = concatRequest + "\n" + "--boundaryString" + "\n" + "content-type:text/plain" + "\n";
            concatRequest = concatRequest + "\n" + messageBody + "\n";
        }
        if (htmlBody != "null" && htmlBody != "") {
            concatRequest = concatRequest + "\n" + "--boundaryString" + "\n" + "content-type:text/html" + "\n";
            concatRequest = concatRequest + "\n" + htmlBody + "\n";
        }
        if (xmlFilePath != "null" && xmlFilePath != "") {
            concatRequest = concatRequest + "\n" + "--boundaryString" + "\n" + "content-type:text/xml";
            if (xmlFileName != "null" && xmlFileName != "") {
                concatRequest = concatRequest + ";name=" + xmlFileName + "\n";
            }
            concatRequest = concatRequest + "content-transfer-encoding:base64" + "\n";
            concatRequest = concatRequest + "\n" + encodeFile(xmlFilePath) + "\n";
        }
        if (imageFilePath != "null" && imageFilePath != "") {
            concatRequest = concatRequest + "\n" + "--boundaryString" + "\n" + "content-type:image/jpgeg";
            if (imageFileName != "null" && imageFileName != "") {
                concatRequest = concatRequest + ";name=" + imageFileName + "\n";
            }
            concatRequest = concatRequest + "content-transfer-encoding:base64" + "\n";
            concatRequest = concatRequest + "\n" + encodeFile(imageFilePath) + "\n";
        }
        if (pdfFilePath != "null" && pdfFilePath != "") {
            concatRequest = concatRequest + "\n" + "--boundaryString" + "\n" + "content-type:application/pdf";
            if (pdfFileName != "null" && pdfFileName != "") {
                concatRequest = concatRequest + ";name=" + pdfFileName + "\n";
            }
            concatRequest = concatRequest + "content-transfer-encoding:base64" + "\n";
            concatRequest = concatRequest + "\n" + encodeFile(pdfFilePath) + "\n";
        }

        concatRequest = concatRequest + "\n" + "--boundaryString--";
        string encodedRequest = util:base64Encode(concatRequest);
        encodedRequest = encodedRequest.replace("+", "-");
        encodedRequest = encodedRequest.replace("/", "_");
        json sendEmailJSONRequest = {"raw":encodedRequest};
        string sendEmailPath = "/v1/users/" + userId + "/messages/send";
        request.setHeader("Content-Type", "Application/json");
        request.setJsonPayload(sendEmailJSONRequest);
        response, e = gmailEP.post(sendEmailPath, request);

        if (e != null) {
            gmailError.statusCode = e.statusCode;
            gmailError.errorMessage = e.message;
            return null, gmailError;
        }
        int statusCode = response.statusCode;
        log:printInfo("\nStatus code: " + statusCode);
        json sendEmailJSONResponse = response.getJsonPayload();

        if (statusCode == 200) {
            //io:println(sendEmailJSONResponse);
            sendEmailResponse = <Message, messageTrans()>sendEmailJSONResponse;
        } else {
            gmailError.statusCode = statusCode;
            gmailError.errorMessage = sendEmailJSONResponse.error.message.toString();
        }
        return sendEmailResponse, gmailError;
    }
}
