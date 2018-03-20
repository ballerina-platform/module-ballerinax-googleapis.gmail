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
    gmail:Draft createDraftResponse = {};
    gmail:Draft updateResponse = {};
    boolean sendResponse = false;
    gmailConnector.init();


    gmail:Options options = {htmlBody:args[8]};
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
}

