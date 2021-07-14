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

# Represents a watch response.
#
# + historyId - The ID of the mailbox's current history record.
# + expiration - When Gmail will stop sending notifications for mailbox updates (epoch millis) - (int64 format). 
@display {label: "Watch Response"}
public type WatchResponse record {
    @display {label: "History ID"}
    string historyId;
    @display {label: "Expiration"}
    string expiration;
};

# Represents a watch request body.
#
# + topicName - A fully qualified Google Cloud Pub/Sub API topic name to publish the events to. This topic name must
#               already exist in Cloud Pub/Sub and you must have already granted gmail "publish" permission on it. 
# + labelIds - Array of labelIds of gmail to restrict notifications about
# + labelFilterAction - Filtering behavior of labelIds list specified.
@display {label: "Watch Request Body"}
public type WatchRequestBody record {
    @display {label: "Topic Name"}
    string topicName;
    @display {label: "Label Ids"}
    string[] labelIds?;
    @display {label: "Label Filter Action"}
    LabelFilterAction labelFilterAction?;
};

# Represents label changed message.
#
# + messageDetail - The message which affected by label change  
# + changedLabelId - The changed label ID of the message
@display {label: "Changed Label"}
public type ChangedLabel record {
    @display {label: "Message"}
    gmail:Message messageDetail;
    @display {label: "Changed Label Ids"}
    string[] changedLabelId?;
};

# Represents the record of topic name and subscription name which was created.
#
# + topicResource - Topic resource name
# + subscriptionResource - Subscription resource name
@display {label: "Topic Subscription Detail"}
public type TopicSubscriptionDetail record {
    @display {label: "Topic Resource"}
    string topicResource;
    @display {label: "Subscription Resource"}
    string subscriptionResource;
};

# Represents a mail attachment
#
# + messageId - Message ID
# + msgAttachments - Message attachment  
@display {label: "Mail Attachment"}
public type MailAttachment record {
    @display {label: "Message ID"}
    string messageId;
    @display {label: "Message Attachments"}
    gmail:MessageBodyPart[] msgAttachments;
};
// Records for pubsub

# Represents a textual expression in the Common Expression Language (CEL) syntax.
#
# + expression - Textual representation of an expression in Common Expression Language syntax
# + title - Title for the expression
# + description - Description of the expression
# + location - String indicating the location of the expression for error reporting
@display {label: "Expression"}
public type Expression record {
    @display {label: "expression"}
    string expression;
    @display {label: "Title"}
    string title?;
    @display {label: "Description"}
    string description?;
    @display {label: "Location"}
    string location?;
};

# Associates members with a role.
#
# + role - Role that is assigned to members
# + members - Specifies the identities requesting access for a Cloud Platform resource
# + condition - The condition that is associated with this binding
@display {label: "Binding"}
public type Binding record {
    @display {label: "Role"}
    string role;
    @display {label: "Members"}
    string [] members;
    @display {label: "Condition"}
    Expression condition?;
};

# Represents an Identity and Access Management(IAM) policy, which specifies access controls for Google Cloud resources.
#
# + etag - Unique identity used for optimistic concurrency control  
# + version - Specifies the format of the policy
# + bindings - Associates a list of members to a role
@display {label: "Policy"}
public type Policy record {
    @display {label: "Etag"}
    string etag;
    @display {label: "Version"}
    int 'version?;
    @display {label: "Bindings"}
    Binding [] bindings?;
};

# Represents a policy constraining the storage of messages published to the topic.
#
# + allowedPersistenceRegions - A list of IDs of GCP regions where messages that are published to the topic may be 
#                               persisted in storage
@display {label: "Message Storage Policy"}
public type MessageStoragePolicy record {
    @display {label: "Allowed Persistence Regions"}
    string[] allowedPersistenceRegions;
};

# Represents Settings for validating messages published against a schema.
#
# + schema - The name of the schema that messages published should be validated against 
# + encoding - The encoding of messages validated against schema 
@display {label: "Schema Settings"}
public type SchemaSettings record {
    @display {label: "Schema"}
    string schema;
    @display {label: "Encoding"}
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
@display {label: "Topic Request Body"}
public type TopicRequestBody record {
    @display {label: "Labels"}
    map<string> labels?;
    @display {label: "Message Storage Policy"}
    MessageStoragePolicy messageStoragePolicy?;
    @display {label: "Kms Key Name"}
    string kmsKeyName?;
    @display {label: "Schema Settings"}
    SchemaSettings schemaSettings?;
    @display {label: "Satisfies Pzs"}
    boolean satisfiesPzs?;
};

# Represents a topic resource.
#
# + name - Name of the topic
@display {label: "Topic"}
public type Topic record {
    @display {label: "Topic Name"}
    string name;
    *TopicRequestBody;
};

# Contains information needed for generating an OpenID Connect token.
#
# + serviceAccountEmail - Service account email to be used for generating the OIDC token
# + audience - Audience to be used when generating OIDC token
@display {label: "Oidc Token"}
public type OidcToken record {
    @display {label: "Service Account Email"}
    string serviceAccountEmail;
    @display {label: "Audience"}
    string audience;
};

# Configuration for a push delivery endpoint.
#
# + pushEndpoint - A URL locating the endpoint to which messages should be pushed
# + attributes - Endpoint configuration attributes that can be used to control different aspects of message delivery
# + oidcToken - Contains information needed for generating an OpenID Connect token  
@display {label: "Push Config"}
public type PushConfig record {
    @display {label: "Push Endpoint"}
    string pushEndpoint;
    @display {label: "Attributes"}
    map<string> attributes?;
    @display {label: "Oidc Token"}
    OidcToken oidcToken?;
};

# Represents a policy that specifies the conditions for resource expiration.
#
# + ttl - Specifies the "time-to-live" duration for an associated resource
@display {label: "Expiration Policy"}
public type ExpirationPolicy record {
    @display {label: "TTL"}
    string ttl;
};

# Represents a policy for dead lettering.
#
# + deadLetterTopic - The name of the topic to which dead letter messages should be published
# + maxDeliveryAttempts - The maximum number of delivery attempts for any message
@display {label: "Dead Letter Policy"}
public type DeadLetterPolicy record {
    @display {label: "Dead Letter Topic"}
    string deadLetterTopic;
    @display {label: "Maximum Delivery Attempts"}
    string maxDeliveryAttempts;
};

# A policy that specifies how Cloud Pub/Sub retries message delivery.
#
# + minimumBackoff - The minimum delay between consecutive deliveries of a given message
# + maximumBackoff - The maximum delay between consecutive deliveries of a given message
@display {label: "Retry Policy"}
public type RetryPolicy record {
    @display {label: "Minimum Backoff"}
    string minimumBackoff;
    @display {label: "Maximum Backoff"}
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
@display {label: "Subscription Request"}
public type SubscriptionRequest record {
    @display {label: "Topic"}
    string topic;
    @display {label: "Push Config"}
    PushConfig pushConfig;
    @display {label: "Ack Deadline Seconds"}
    int ackDeadlineSeconds?;
    @display {label: "Retain Acked Messages"}
    boolean retainAckedMessages?;
    @display {label: "Message Retention Duration"}
    string messageRetentionDuration?;
    @display {label: "Labels"}
    map<string> labels?;
    @display {label: "Enable Message Ordering"}
    boolean enableMessageOrdering?;
    @display {label: "Expiration Policy"}
    ExpirationPolicy expirationPolicy?;
    @display {label: "Filter"}
    string filter?;
    @display {label: "Dead Letter Policy"}
    DeadLetterPolicy deadLetterPolicy?;
    @display {label: "Retry Policy"}
    RetryPolicy retryPolicy?;
    @display {label: "Detached"}
    boolean detached?;
};

# Represents a subscription resource.
#
# + name - Name of the subscription  
@display {label: "Subscription"}
public type Subscription record {
    @display {label: "Subscription Name"}
    string name;
    *SubscriptionRequest;
};

# Represents a setIamPolicy request body resource.
#
# + policy - Field Description  
@display {label: "Policy Request Body"}
public type PolicyRequestBody record {
    @display {label: "Policy"}
    Policy policy;
};

# Represents a pubsub error resource
#
# + code - Error code  
# + message - Error Message  
# + status - Error Status  
@display {label: "PubSub Error"}
public type PubSubError record {
    @display {label: "Error Code"}
    int code?;
    @display {label: "Error Message"}
    string message?;
    @display {label: "Status"}
    string status?;
};
