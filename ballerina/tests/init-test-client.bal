// Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

// Connection Configurations
configurable string accountIdentifier = ?;
configurable string user = ?;
configurable string password = ?;
configurable string privateKeyPath = ?;
configurable string privateKeyPassphrase = ?;

Options options = {
    properties: {
        "JDBC_QUERY_RESULT_FORMAT": "JSON"
    }
};

// Initialize the Snowflake client
Client snowflakeClient = check new (accountIdentifier, user, password, options);
AuthConfig authConfig = {
    user,
    privateKeyPath,
    privateKeyPassphrase
};
AdvancedClient snowflakeKeyBasedClient = check new (accountIdentifier, authConfig, options);
