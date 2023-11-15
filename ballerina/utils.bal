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
import ballerina/lang.array;

isolated function base64UrlEncode(string contentToBeEncoded) returns string {
    string base64EncodedString = contentToBeEncoded.toBytes().toBase64();
    return re `/`.replaceAll(re `\+`.replaceAll(base64EncodedString, DASH), UNDERSCORE);
}

isolated function base64UrlDecode(string contentToBeDecoded) returns string|error {
    do {
        string base64Encoded = re `_`.replaceAll(re `-`.replaceAll(contentToBeDecoded, PLUS), FORWARD_SLASH);
        return check string:fromBytes(check array:fromBase64(base64Encoded));
    } on fail error e {
        return error InvalidEncodedValue(" is not a valid Base64 URL encoded value.", e);
    }
}
