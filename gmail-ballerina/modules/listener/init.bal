import ballerina/jballerina.java;

isolated function init() {
    setModule();
}

isolated function setModule() = @java:Method {
    'class: "org.ballerinalang.googleapis.gmail.ModuleUtils"
} external;
