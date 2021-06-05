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

import ballerinax/googleapis.gmail as gmail;

# Represents label changed message.
#
# + message - The message which affected by label change  
# + changedLabelId - The changed label id of the message
public type ChangedLabel record {
    gmail:Message message;
    string[] changedLabelId?;
};

# Represents the record of topic name and subscription name which was created.
#
# + topicResource - Topic resource name
# + subscriptionResource - Subscription resource name
public type TopicSubscriptionDetail record {
    string topicResource;
    string subscriptionResource;
};

# Represents a mail attachment
#
# + messageId - Message Id
# + msgAttachments - Message attachment  
public type MailAttachment record {
    string messageId;
    gmail:MessageBodyPart[] msgAttachments;
};
// Records for pubsub

# Represents a textual expression in the Common Expression Language (CEL) syntax.
#
# + expression - Textual representation of an expression in Common Expression Language syntax
# + title - Title for the expression
# + description - Description of the expression
# + location - String indicating the location of the expression for error reporting
public type Expression record {
    string expression;
    string title?;
    string description?;
    string location?;
};

# Associates members with a role.
#
# + role - Role that is assigned to members
# + members - Specifies the identities requesting access for a Cloud Platform resource
# + condition - The condition that is associated with this binding
public type Binding record {
    string role;
    string [] members;
    Expression condition?;
};

# Represents an Identity and Access Management(IAM) policy, which specifies access controls for Google Cloud resources.
#
# + etag - Unique identity used for optimistic concurrency control  
# + version - Specifies the format of the policy
# + bindings - Associates a list of members to a role
public type Policy record {
    string etag;
    int 'version?;
    Binding [] bindings?;
};

# Represents a policy constraining the storage of messages published to the topic.
#
# + allowedPersistenceRegions - A list of IDs of GCP regions where messages that are published to the topic may be 
#                               persisted in storage
public type MessageStoragePolicy record {
    string[] allowedPersistenceRegions;
};

# Represents Settings for validating messages published against a schema.
#
# + schema - The name of the schema that messages published should be validated against 
# + encoding - The encoding of messages validated against schema 
public type SchemaSettings record {
    string schema;
    Encoding encoding;
};

# Represents a topic request body resource.
#
# + labels - An object containing a list of "key": value pairs
# + messageStoragePolicy - Policy constraining the set of Google Cloud Platform regions where messages published to 
#                          the topic may be stored
# + kmsKeyName - The resource name of the Cloud KMS CryptoKey to be used to protect access to messages published on 
#                this topic
# + schemaSettings - Settings for validating messages published against a schema
# + satisfiesPzs - Reserved for future use. This field is set only in responses from the server
public type TopicRequestBody record {
    map<string> labels?;
    MessageStoragePolicy messageStoragePolicy?;
    string kmsKeyName?;
    SchemaSettings schemaSettings?;
    boolean satisfiesPzs?;
};

# Represents a topic resource.
#
# + name - Name of the topic
public type Topic record {
    string name;
    *TopicRequestBody;
};

# Contains information needed for generating an OpenID Connect token.
#
# + serviceAccountEmail - Service account email to be used for generating the OIDC token
# + audience - Audience to be used when generating OIDC token
public type OidcToken record {
    string serviceAccountEmail;
    string audience;
};

# Configuration for a push delivery endpoint.
#
# + pushEndpoint - A URL locating the endpoint to which messages should be pushed
# + attributes - Endpoint configuration attributes that can be used to control different aspects of message delivery
# + oidcToken - Contains information needed for generating an OpenID Connect token  
public type PushConfig record {
    string pushEndpoint;
    map<string> attributes?;
    OidcToken oidcToken?;
};

# Represents a policy that specifies the conditions for resource expiration.
#
# + ttl - Specifies the "time-to-live" duration for an associated resource
public type ExpirationPolicy record {
    string ttl;
};

# Represents a policy for dead lettering.
#
# + deadLetterTopic - The name of the topic to which dead letter messages should be published
# + maxDeliveryAttempts - The maximum number of delivery attempts for any message
public type DeadLetterPolicy record {
    string deadLetterTopic;
    string maxDeliveryAttempts;
};

# A policy that specifies how Cloud Pub/Sub retries message delivery.
#
# + minimumBackoff - The minimum delay between consecutive deliveries of a given message
# + maximumBackoff - The maximum delay between consecutive deliveries of a given message
public type RetryPolicy record {
    string minimumBackoff;
    string maximumBackoff;
};

# Represents a subscription request resource.
#
# + topic - The name of the topic from which this subscription is receiving messages
# + pushConfig - Configuration for a push delivery endpoint
# + ackDeadlineSeconds - The approximate amount of time (on a best-effort basis) Pub/Sub waits for the subscriber to 
#                        acknowledge receipt before resending the message
# + retainAckedMessages - Indicates whether to retain acknowledged messages
# + messageRetentionDuration - How long to retain unacknowledged messages in the subscription's backlog, from the 
#                              moment a message is published
# + labels - An object containing a list of "key": value pairs
# + enableMessageOrdering -  Indicates whether messages published will be delivered with the same orderingKey in 
#                            PubsubMessage
# + expirationPolicy - A policy that specifies the conditions for this subscription's expiration
# + filter - An expression written in the Pub/Sub filter language
# + deadLetterPolicy - A policy that specifies the conditions for dead lettering messages in this subscription
# + retryPolicy - A policy that specifies how Pub/Sub retries message delivery for this subscription
# + detached - Indicates whether the subscription is detached from its topic
public type SubscriptionRequest record {
    string topic;
    PushConfig pushConfig;
    int ackDeadlineSeconds?;
    boolean retainAckedMessages?;
    string messageRetentionDuration?;
    map<string> labels?;
    boolean enableMessageOrdering?;
    ExpirationPolicy expirationPolicy?;
    string filter?;
    DeadLetterPolicy deadLetterPolicy?;
    RetryPolicy retryPolicy?;
    boolean detached?;
};

# Represents a subscription resource.
#
# + name - Name of the subscription  
public type Subscription record {
    string name;
    *SubscriptionRequest;
};

# Represents a setIamPolicy request body resource.
#
# + policy - Field Description  
public type PolicyRequestBody record {
    Policy policy;
};

# Represents a pubsub error resource
#
# + code - Error code  
# + message - Error Message  
# + status - Error Status  
public type PubSubError record {
    int code?;
    string message?;
    string status?;
};
