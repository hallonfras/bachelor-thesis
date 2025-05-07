#import "/utils/todo.typ": TODO


State fuzzing is a method for constructing state-machine representations of protocol-behavior in a black-box manner. These state machines can then be used for things such as model-based conformance testing or fingerprinting.

Implementations of state fuzzing for TCP exist but are oftentimes outdated and difficult to run on modern machines, to this end I have developed TCP-Fuzzer a tool which implements state fuzzing for TCP using modern technologies in order to be simple to install and configure on modern machines.

This thesis details the implementation details of TCP-Fuzzer as well as possible future improvements to the tool. In addition I have used TCP-Fuzzer to learn the state machines of the windows, linux and macOS TCP stacks. The results of which will be presented in this thesis.
