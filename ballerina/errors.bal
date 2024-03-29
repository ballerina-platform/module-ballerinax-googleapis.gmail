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

# Defines the generic error type for the `gmail` module.
public type Error distinct error;

# Error that occurs when there is an issue with inline images or attachments. This could be due to issues like file not found, unsupported file type, etc.
public type FileGenericError distinct Error;

# Error that occurs when an invalid encoded value is provided for the `data` fields.
public type ValueEncodeError distinct Error;
