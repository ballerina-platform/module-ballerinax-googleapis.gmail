# Specification: Ballerina Gmail Library

_Owners_: @niveathika \
_Reviewers_: @daneshk \
_Created_: 2022/10/31 \
_Updated_: 2023/10/31 \
_Edition_: Swan Lake 

## Introduction

This is the specification for the Gmail package of the [Ballerina language](https://ballerina.io), which provides client functionalities
to communicate with [Google Gmail API v1](https://developers.google.com/gmail/api/guides).

The Gmail library specification has evolved and may continue to evolve in the future. The released versions of the specification can be found under the relevant GitHub tag.

If you have any feedback or suggestions about the library, start a discussion via a [GitHub issue](https://github.com/ballerina-platform/ballerina-standard-library/issues) or in the [Discord server](https://discord.gg/ballerinalang). Based on the outcome of the discussion, the specification and implementation can be updated. Community feedback is always welcome. Any accepted proposal, which affects the specification is stored under `/docs/proposals`. Proposals under discussion can be found with the label `type/proposal` on GitHub.

The conforming implementation of the specification is released and included in the distribution. Any deviation from the specification is considered a bug.

## Contents

1. [Overview](#1-overview)
2. [Client](#2-client)
    * 2.1 [Initializing the Client](#21-initializing-the-client)
 
## 1. Overview

The Ballerina language provides first-class support for writing network-oriented programs. The Gmal package uses these language constructs and creates the programming model to consume Gmail REST API.

The Gmail package provides user friendly resource methods to invoke [Gmail API v1](https://gmail.googleapis.com/$discovery/rest?version=v1).

## 2. Client

This section describes the client of the Ballerina Gmail package. To use the Ballerina Gmail package, a user must import the Ballerina Gmail package first.

###### Example: Importing the Gmail Package

```ballerina
import ballerinax/googleapis.gmail;
```

The `gmail:Client` can be used to connect to the Gmail RESTful API. The client currently supports processing of `Profile`, `Message`, `Draft`, `Thread` and `Label` resources. The client uses HTTP as the underlying protocol to communicate with the API.

#### 2.1 Initializing the Client

The `gmail:Client` init method requires a valid authentication credential to initialize the client. 

```ballerina
gmail:Client gmailClient = check new gmail:Client (
        config = {
            auth: {
                refreshToken: refreshToken,
                clientId: clientId,
                clientSecret: clientSecret
            }
        }
    );
```

The `gmail:Client` uses `http:Client` as its underlying implementation; this `http:Client` can be configured by providing the `gmail:ConnectionConfig` as a parameter via the `gmail:Client` init method.
