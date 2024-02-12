// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import ballerina/io;
import ballerina/os;
import ballerinax/googleapis.gmail;

configurable string refreshToken = os:getEnv("REFRESH_TOKEN");
configurable string clientId = os:getEnv("CLIENT_ID");
configurable string clientSecret = os:getEnv("CLIENT_SECRET");
configurable string recipient = os:getEnv("RECIPIENT");

public function main() returns error? {
    gmail:Client gmail = check new ({
        auth: {
            refreshToken,
            clientId,
            clientSecret
        }
    });

    // Compose the email message.
    string startTime = "10:00 AM";
    string endTime = "12:00 PM";
    string date = "2022-12-31";
    string companyName = "Choreo Team";

    string htmlContent = string `<html>
    <head>
        <title>Scheduled Maintenance</title>
    </head>
    <body>
        <img src="cid:choreoLogo" alt="Company Logo">
        <p>Dear user,</p>
        <p>We are writing to inform you that our services will be undergoing a scheduled maintenance break from ${startTime} to ${endTime} on ${date}. During this period, our services may not be available.</p>
        <p>We apologize for any inconvenience this may cause and appreciate your understanding as we work to improve our systems.</p>
        <p>Best Regards,</p>
        <p>${companyName}</p>
    </body>
    </html>`;

    gmail:MessageRequest message = {
        to: [recipient],
        subject: "Scheduled Maintenance Break Notification",
        bodyInHtml: htmlContent,
        inlineImages: [
            {
                contentId: "choreoLogo",
                mimeType: "image/png",
                name: "choreoLogo.png",
                path: "resources/choreo.png"
            }
        ]
    };

    // Send the email message.
    gmail:Message sendResult = check gmail->/users/me/messages/send.post(message);
    io:println("Email sent. Message ID: " + sendResult.id);
}

