import ballerina/jballerina.java;
import ballerinax/googleapis_gmail as gmail;

isolated function callOnMailboxChanges(SimpleHttpService httpService, gmail:MailboxHistoryPage mailboxHistoryPage) returns error?
    = @java:Method {
    'class: "org.ballerinalang.googleapis.gmail.HttpNativeOperationHandler"
} external;

isolated function callOnNewEmail(SimpleHttpService httpService, gmail:Message message) returns error?
    = @java:Method {
    'class: "org.ballerinalang.googleapis.gmail.HttpNativeOperationHandler"
} external;

isolated function callOnNewThread(SimpleHttpService httpService, gmail:MailThread thread) returns error?
    = @java:Method {
    'class: "org.ballerinalang.googleapis.gmail.HttpNativeOperationHandler"
} external;

isolated function callOnNewLabeledEmail(SimpleHttpService httpService, ChangedLabel changedLabeldMsg) returns error?
    = @java:Method {
    'class: "org.ballerinalang.googleapis.gmail.HttpNativeOperationHandler"
} external;

isolated function callOnNewStaredEmail(SimpleHttpService httpService, gmail:Message message) returns error?
    = @java:Method {
    'class: "org.ballerinalang.googleapis.gmail.HttpNativeOperationHandler"
} external;

isolated function callOnLabelRemovedEmail(SimpleHttpService httpService, ChangedLabel changedLabeldMsg) returns error?
    = @java:Method {
    'class: "org.ballerinalang.googleapis.gmail.HttpNativeOperationHandler"
} external;

isolated function callOnStarRemovedEmail(SimpleHttpService httpService, gmail:Message message) returns error?
    = @java:Method {
    'class: "org.ballerinalang.googleapis.gmail.HttpNativeOperationHandler"
} external;

isolated function callOnNewAttachment(SimpleHttpService httpService, gmail:MessageBodyPart attachment) returns error?
    = @java:Method {
    'class: "org.ballerinalang.googleapis.gmail.HttpNativeOperationHandler"
} external;

# Invoke native method to retrive implemented method names in the subscriber service
#
# + httpService - current http service
# + return - {@code string[]} containing the method-names in current implementation
isolated function getServiceMethodNames(SimpleHttpService httpService) returns string[] = @java:Method {
    'class: "org.ballerinalang.googleapis.gmail.HttpNativeOperationHandler"
} external;
