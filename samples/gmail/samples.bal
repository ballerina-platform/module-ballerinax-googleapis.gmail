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

package samples.gmail;

import src.gmail;
import ballerina.io;

function main (string[] args) {
    endpoint<gmail:ClientConnector> gmailConnector {
        create gmail:ClientConnector(args[0], args[1], args[2], args[3], args[4]);
    }

    gmail:GmailError e = {};
    gmail:UserProfile userProfileResponse = {};
    gmail:Draft createDraftResponse = {};
    gmail:Draft updateResponse = {};
    gmail:Drafts getDraftsResponse = {};
    gmail:Message sendEmailResponse = {};
    boolean sendResponse = false;
    boolean deleteDraftResponse = false;
    gmailConnector.init();

    io:println("-----Calling getUserProfile action-----");
    userProfileResponse, e = gmailConnector.getUserProfile();
    if (e.errorMessage == "") {
        io:println(userProfileResponse);
    } else {
        io:println(e);
    }

    gmail:Options options = {htmlBody:args[8], xmlFilePath:args[9], xmlFileName:args[10], imageFilePath:args[11],
                                imageFileName:args[12], pdfFilePath:args[13], pdfFileName:args[14]};
    createDraftResponse, e = gmailConnector.createDraft(args[5], args[6], args[7], options);
    if (e.errorMessage == "") {
        io:println("-----Calling createDraft action-----");
        io:println(createDraftResponse);
        updateResponse, e = createDraftResponse.update(args[5], "UpdatedMail", args[7], options);
        if (e.errorMessage == "") {
            io:println("-----Calling update action-----");
            io:println(updateResponse);
            sendResponse, e = updateResponse.send();
            if (e.errorMessage == "") {
                io:println("-----Calling send action-----");
                io:println(sendResponse);
            } else {
                io:println(e);
            }
        } else {
            io:println(e);
        }
    } else {
        io:println(e);
    }
    getDraftsResponse, e = gmailConnector.getDrafts({maxResults:"1"});
    if (e.errorMessage == "") {
        io:println("-----Calling getDrafts action-----");
        io:println(getDraftsResponse);
    } else {
        io:println(e);
    }
    deleteDraftResponse, e = gmailConnector.deleteDraft(getDraftsResponse.drafts[0].id);
    if (e.errorMessage == "") {
        io:println("-----Calling deleteDraft action-----");
        io:println(deleteDraftResponse);
    } else {
        io:println(e);
    }
    sendEmailResponse, e = gmailConnector.sendEmail(args[5], args[6], args[7], options);
    if (e.errorMessage == "") {
        io:println("-----Calling sendEmail action-----");
        io:println(sendEmailResponse);
    } else {
        io:println(e);
    }
}

