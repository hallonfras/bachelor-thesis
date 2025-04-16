#import "/utils/todo.typ": TODO

= Introduction
The amount of connected devices is expected to reach 40 billion by 2030 @iot, TCP accounting for roughly half of this traffic. This puts increasing pressure on the security and reliability of protocol implementations.


Much effort has been put in to studying model-based conformance testing for TCP. Early efforts often used handcrafted models based upon the protocol specification @5727598, This however is not guaranteed to be consistent with how actual implementations behave in practice.

In 2006 Bishop et al @sewell developed a post hoc model of how the TCP protocol behaves in practice, they then implemented a model checker in order in order to verify their specification against traces gathered from various implementations of the TCP protocol.

#TODO("I need some sourcing on state fuzzing methodology")

More recently efforts have been made in trying to infer a model based upon a running protocol implementation. This is done through a process called state fuzzing. State fuzzing involves sending input sequences to a protocol implementation and constructing a model based on the responses.

This technique has been succesfully applied to protocols such as TLS @somorovsky,SSH @pverleg and TCP. @ramonjansen

There exist up to date implementations for fuzzing TLS and SSH in TLS-attacker @TLS-attacker and ssh-fuzzer @ssh-fuzzer, however implementations for TCP are rather outdated. Work by Ramon Jansen @ramonjansen and Fiterau-Brostean et al. @tcp-fuzzing1 is almost ten years old at this point.

In this work i seek to remedy this by developing TCP-Fuzzer, a modern implementation of state fuzzing for TCP. I then apply it to some common operating system TCP implementations.

The outline of this thesis is as follows. Sections 2.1 and 2.2 explain the basics of the internet protocol stack and TCP. Section 2.3 provides information on the state fuzzing process.

Section 3 details how TCP-Fuzzer is implemented with section 3.2 focusing on the mapper component and section 3.3 on the learner component. Section 3.4 describes the experimental setup and how the SUTs are configured.

In section 4 the resulting models are discussed and compared. Finally section 5 contains conclusions and future work.

