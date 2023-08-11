# Examples

This directory contains a collection of sample code examples written in Ballerina. These examples demonstrate various
use cases of the module. You can follow the instructions below to build and run these examples.

## Running an Example

Execute the following commands to build an example from the source.

* To build an example

  `bal build <example-name>`


* To run an example

  `bal run <example-name>`

## Building the Examples with the Local Module

**Warning**: Because of the absence of support for reading local repositories for single Ballerina files, the bala of
the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your
local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally.

* To build all the examples

  `./build.sh build`


* To run all the examples

  `./build.sh run`