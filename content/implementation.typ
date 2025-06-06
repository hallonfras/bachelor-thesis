#import "/utils/todo.typ": TODO
#import "@preview/fletcher:0.5.7" as fletcher: diagram, node, edge

#show raw: set text(font: "Iosevka")

= Implementation

== Overview
The work I have done in this thesis largely consists of implementing the tool TCP-Fuzzer, a modern state fuzzer for TCP.

TCP-Fuzzer builds upon the earlier tool tcp-learner @tcp-learner developed by Fiterau-Brostean et al. and used in much of their research on TCP. @tcp-fuzzing1 @tcp-fuzzing2 @tcp-fuzzing3

With the deprecation of Python 2.x tcp-learner has become increasingly difficult to run on modern machines. Because of this i have ported the mapper component to python3 making significant changes because of differences between the python2 and python3 versions of the libraries used. In addition I have chosen to rewrite the learner using ProtocolState-Fuzzer @PSF in order to bring TCP-Fuzzer more in line with modern projects such as EDHOC-Fuzzer @EDHOC-fuzzer.


== The mapper
I have implemented the mapper in python3 using the libraries _Scapy_,_Impacket_ and _Pcapy_ @scapy @impacket @pcapyng to access networking functionality. The general structure of the mapper is summarized in this diagram.

#pad(
  figure(
    diagram(
      node-stroke: .1em,
      node-shape: rect,
      spacing: 4em,
      edge((-1, 1), "r", "-|>", `Main.py`, label-pos: 0, label-side: center),
      node((0, 1), `Builder.py`, radius: 3.5em),
      node((1, 0), `Sender.py`, radius: 3.5em),
      node((1, 1), `LearnerSocket.py`, radius: 3.5em),
      node(
        (1, 2),
        `SUTSocket.py`,
        radius: 3.5em,
        fill: rgb(236, 236, 236, 50%),
        stroke: rgb(236, 236, 236, 50%),
      ),
      edge((0, 1), (1, 0), "-|>"),
      edge((0, 1), (1, 1), "-|>"),
      edge((0, 1), (1, 2), "-|>"),
      edge((1, 0), (1, 1), "-|>"),
      edge((1, 1), (1, 0), "-|>"),
    ),
    caption: [The layout of the mapper],
    gap: 2em,
  ),
  1em,
)

=== Builder

The Builder is responsible for parsing the configuration file and instantiating the other components with proper values e.g the IP address and port of the SUT. The most interesting functionality here is the parsing of the config file. The python3 standard library has various utilities for parsing markup languages, I chose to use TOML @TOML due to familiarity with it. In addition to this I used JSON-schema @JSON-schema for validating the configuration file. This allows for specifying required and optional fields in the configuration file as well as data types for the fields, providing useful error-messages for invalid configurations.

=== Sender

The Sender is responsible for constructing TCP packets and sending them to the SUT. I have implemented this using _Scapy_ @scapy, a packet manipulation library capable of crafting, sending and recieving various kinds of packets.
Scapy provides the function `sr1` which allows sending any number of packets #footnote("in this case always  one") and receiving the first response, with configurable timeout. This is useful since we never expect to receive more than one packet in response from the SUT. In addition the ability to configure the timeout is needed since we need to set the timeout such that we can be sure we have received the response from the SUT, otherwise this will cause non-determinism. The sender also provides the ability to reset the SUT between input sequences sent by the learner. This is done by simply switching the port number to a different random port number.

=== LearnerSocket

The LearnerSocket is responsible for handling communication with the learner. It establishes a TCP socket over which the learner and mapper communicate. In addition to maintaining this socket the LearnerSocket component parses inputs from the learner and calls the appropriate functions within the sender, e.g calling reset for a reset input or sending a packet when receiving flags,seq and ack numbers.

=== SUTSocket
The SUTSocket is responsible for communicating with the SUT via TCP socket. This enables fuzzing of the TCP-socket API by adding socket commands such as _listen_ and _accept_ to the input alphabet.

Due to time constraints the SUTSocket component is not fully implemented.

== The Learner

I have implemented the Learner in java using the library ProtocolState-Fuzzer @PSF,henceforth referred to as PSF. PSF is a general purpose library for constructing state-fuzzers. It provides a learner and equivalence checker based on LearnLib @LearnLib, as well as various interfaces for the inputs and outputs sent and received from the mapper.

In addition I have chosen to manage seq and ack numbers in the learner, sending them to the mapper along with the flags when constructing packets. This is to facilitate future work on TCP-Fuzzer that might consider learning with seq and ack numbers as parameters. The seq and ack numbers which the learner outputs are always valid, accurately handling invalid numbers requires distinguishing between different categories of invalid numbers (e.g reusing previous sequence numbers vs skipping forward to future ones). This would vastly expand the complexity of the learner and I have therefore not implemented support for invalid sequence and acknowledgement numbers.

In order to make each sequence sent independent the seq number is incremented by a large number (> 1000000) each time the SUT is reset. This is to make sure future seq numbers are outside the window of any previous communication. For the same reason the seq number is also incremented when receiving a packet with RST flag set.


== Experimental Setup

In order to simplify running on different operating systems i have chosen to run the experiments using docker and docker-compose @docker. This means the installation process is largely the same regardless of host operating system. In order to provide a SUT docker images running QEMU @docker-macos @docker-windows have been used for non Linux SUTs. For Linux SUTs the host kernel is used. In order to listen to incoming TCP connections i have used a simple TCP echo-server @tcp-echo running on the SUT.

Some settings had to be tweaked on the SUTs to facilitate proper behavior for testing. Modern TCP-Implementations implement Nagle's algorithm for combining multiple small packets into one larger packet as well as an algorithm that delays ACKs in order to acknowledge multiple packets at once. Both of these had to be disabled in order to remove non determinism.

