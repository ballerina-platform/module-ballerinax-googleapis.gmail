// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/task;
import ballerina/time;

class Job {
    *task:Job;
    private Listener 'listener;

    isolated function init(Listener 'listener) {
        self.'listener = 'listener;
    }

    public isolated function execute() {
        checkpanic self.'listener.watchMailbox();
        checkpanic self.scheduleNextWatchRenewal();
    }

    isolated function scheduleNextWatchRenewal() returns error? {
        time:Utc currentUtc = time:utcNow();
        decimal timeDifference = (self.'listener.getExpirationTime()/1000) - (<decimal>currentUtc[0]) - 60;
        time:Utc scheduledUtcTime = time:utcAddSeconds(currentUtc, timeDifference);
        time:Civil scheduledTime = time:utcToCivil(scheduledUtcTime);
        task:JobId result = check task:scheduleOneTimeJob(self, scheduledTime);
    }
}
