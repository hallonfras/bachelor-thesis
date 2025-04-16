#import "/utils/todo.typ": TODO
#import "@preview/fletcher:0.5.7" as fletcher: diagram, node, edge

= Background

== The Internet protocol suite
The Internet protocol suite, also known as TCP/IP is a common way of describing internet communications. It is divided into 4 layers which are each responsible for different functions as displayed in Figure 1. #figure(
  image("../figures/ip_suite.svg", width: 80%),
  caption: [A diagram of the TCP/IP stack],
) <TCP_IP>

The _link_ layer is responsible for handling network interfaces, these could be physical network cards but also virtual ones as is common in VPN connections for example.
The _network_ layer is responsible for determining the source and destination of packets using IP addresses. It also provides rudimentary ways to send data in a connectionless, best-effort #footnote[Not guaranteeing the message is actually received] manner.
The _transport_ layer is responsible for managing communication between machines using internet sockets #footnote[A socket is simply an endpoint for a connection. Defined by transport protocol, IP-address and port number] allowing for multiple services to be run on the same machine. Protocols in the transport layer may also provide more reliable packet transfer than IP's best-effort model.
The _application_ layer is responsible for managing the data services transfer over the network established by the lower layers.

== TCP - Transmission Control Protocol
TCP is a transport layer protocol first proposed in 1974 @rfc675 and later standardized in 1980 @rfc761. It provides reliable, ordered and error checked communication on top of IP. This is accomplished by numbering all the bytes sent during communication. To keep track of this the TCP header has two numbers, a _sequence_ and _acknowledgement_ number, commonly shortened to _seq_ and _ack_ numbers. The seq number represents the byte number of the first byte sent and the ack number represents the byte number of the next byte the sender expects to receive. e.g if the client sends a packet with a seq number of 1 and a length of 20 the server would reply with an ack number of 21.

In addition to the sequence and acknowledgement numbers TCP headers also have a set of binary flags that manage various settings of the TCP protocol. The ones that will be of interest in this thesis are as follows.

#list(
  [*ACK*: signifies that the ack number of the packet is relevant. This is normally set for all packets except for the first.],
  [*SYN*: Signifies that the sender wants to synchronize sequence numbers. This is normally only set during the initial handshake process],
  [*RST*: Aborts the connection, immediately closing both sides.],
  [*FIN*: Signifies that the sender wants to close their side of the connection.],
  [*PSH*: Signifies that the receiver should deliver the data directly instead of buffering it.],
)

Note that multiple of these flags can be set at once. Combinations such as SYN+ACK or FIN+ACK are used in TCP communication.

*The Three-way handshake.*
Since TCP is a connection-oriented protocol it needs a way of establishing communication. This is done using the three way handshake. The client first sends a packet with seq number X and the SYN flag set. The server then responds with a packet of form (SYN+ACK,seq=Y,ack=X+1). The client responds with (ACK,seq=Y,ack=Y+1),establishing the connection.




== State Fuzzing and Model learning
A common method of conformance testing for software is called model-based testing. It involves constructing a model of how a given System Under Test (SUT) is supposed to behave according to the specification and then checking the observed behavior for conformance with this model. This has yielded good results for various kinds of software including previous work on TCP by Bishop et al @sewell. The model based approach is not without drawbacks however, chief among them being the time required to construct said model. This is especially troublesome if the software in question has many different optional extensions or happens to be updated often. State fuzzing aims to solve this by using model learning @vaandrager to automatically generate these models. This is done by sending input sequences chosen from an input alphabet and observing the outputs. Then a model is constructed based upon how the SUT has behaved and this model can be checked for adherence to the specification.

State fuzzing setups usually consist of three components as shown in Figure 2.

#pad(
  figure(
    diagram(
      node-stroke: .1em,
      node-shape: rect,
      spacing: 8em,
      node((0, 0), `Learner`, radius: 2.5em),
      edge(`Input symbol`, "->", shift: 13pt),
      node((1, 0), `Mapper`, radius: 2.5em),
      edge((0, 0), (1, 0), `Response symbol`, "<-", shift: -13pt),
      edge(`TCP-input`, "->", shift: 13pt),
      edge(`TCP-response`, "<-", shift: -13pt),
      node((2, 0), `SUT`, radius: 2.5em),
    ),
    caption: [A diagram of State-fuzzing architecture],
  ),
  1em,
)



The _learner_ selects symbols from a list of valid symbols, this is called the _alphabet_. It then sends these to the _mapper_ which converts them into concrete outputs. The mapper then recieves the response from the System Under Test (SUT) and converts them into alphabet symbols which it sends to the learner. An example for TCP could look like this.
#pad(
  figure(
    diagram(
      node-stroke: .1em,
      node-shape: rect,
      spacing: 8em,
      node((0, 0), `Learner`, radius: 2.5em),
      edge(`S`, "->", shift: 13pt),
      node((1, 0), `Mapper`, radius: 2.5em),
      edge((0, 0), (1, 0), `SA`, "<-", shift: -13pt),
      edge(`<SYN,0,0>`, "->", shift: 13pt),
      edge(`<SYN+ACK,132,1>`, "<-", shift: -13pt),
      node((2, 0), `SUT`, radius: 2.5em),
    ),
    caption: [An example exchange for TCP],
  ),
  1em,
)

The actual learning process involves the Learner component repeatedly picking sequences of input symbols from the alphabet and constructing a deterministic state machine consistent with the observed responses this is called the _hypothesis_. A component called the equivalence checker then attempts to come up with a counterexample for the hypothesis using model-based testing. A counterexample constitutes some sequence of inputs where the outputs don't match those predicted by the state machine. If a counterexample is found the learner continues refining the model. This cycle continues until no counterexample is found (within the alloted max amount of tests), at which point the last hypothesis is presented as the learned model.

Due to the black-box nature of the SUT this final model might be incorrect, but given a sufficient amount of tests it should provide an approximation accurate enough to analyze for possible conformance issues.
