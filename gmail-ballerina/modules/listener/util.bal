import ballerina/log;
import ballerinax/googleapis_gmail as gmail;

isolated function createTopic(gmail:Client gmailClient, string topicName, string subscriptionName, 
                                  string project, string pushEndpoint) returns @tainted [string,string] | error {
    gmail:Topic topic = check  gmailClient->createPubsubTopic(project,topicName);
    string topicResource = topic.name;
    log:printInfo(topicResource + " is created");
    if (topicResource !== "") {
        gmail:Policy existingPolicy = check gmailClient->getPubsubTopicIamPolicy(<@untainted>topicResource);
        string etag = existingPolicy.etag;
        if (etag !== "") {
            gmail:Policy newPolicy = {
                                        "version": 1,
                                        etag: etag,
                                        bindings: [
                                            {
                                                role: ROLE,
                                                members: [
                                                         IAM_POLICY_BINDING_MEMBER
                                                        ]
                                            }
                                        ]
                                    };
            json newPolicyRequestbody = {
                                            "policy": newPolicy.toJson()
                                        };
            gmail:Policy createdPolicy = check gmailClient->setPubsubTopicIamPolicy(<@untainted>topicResource,
                                                                                    newPolicyRequestbody);               
            string subscriptionResource = check createSubscription(gmailClient, subscriptionName, project, pushEndpoint,
                                                                   topicResource);
            return [topicResource, subscriptionResource];                                                                  
        }
    }

    return error("Can't subscribe");
    
}

isolated function createSubscription(gmail:Client gmailClient, string subscriptionName, string project, 
                                     string pushEndpoint, string topicResource) returns @tainted string | error {
    gmail:SubscriptionRequest subscriptionRequestbody  = {
                                    topic: topicResource,
                                    pushConfig: {
                                                    pushEndpoint: pushEndpoint+LISTENER_PATH
                                                },
                                    ackDeadlineSeconds: ACK_DEADLINE_SECONDS,
                                    retainAckedMessages: RETAIN_ACKED_MESSAGES,
                                    messageRetentionDuration: MESSAGE_RETENTION_DURATION
                                };
    gmail:Subscription subscription = check gmailClient-> subscribePubsubTopic(project, subscriptionName, 
                                                                                    subscriptionRequestbody);
    log:printInfo(subscription.name + " is created");                                                                                         
    return  subscription.name;                                                                               
}
