#import "/utils/todo.typ": TODO

#pagebreak()

= Learned models
This section will give a brief discussion of the models generated for Windows (NT 10.0.26100), Linux (6.6.85) and MacOS (Darwin 24.4.0). They will mostly be compared to each other to see how the operating systems might differ in their implmentation.

As previously mentioned all models have been generated using only valid sequence and acknowledgement numbers. The input alphabet used is as follows

#pad(
  figure(

    table(
      columns: 2,
      [Symbol], [Flag],
      [S], [SYN],
      [A], [ACK],
      [SA], [SYN+ACK],
      [R], [RST],
      [RA], [RST+ACK],
      [F], [FIN],
      [FA], [FIN+ACK],
      [P], [PSH],
      [PA], [PSH+ACK],
    ),

    caption: [The input alphabet used for learning],
    gap: 2em,
  ),
  2em,
)


I have used this alphabet while learning all models except windows, where SA had to be removed because it caused nondeterminism. On windows sequences containing SA would cause following messages to either timeout or be responded to with R, seemingly randomly.

The models are displayed in figures 5,6 and 7. Transitions which can be made for many different input symbols have been merged with newlines separating input/output symbol pairs. In addition to the merging of transitions all transitions which loopback to the same state and have timeout as their output symbol have been hidden to enhance readability.

States which are used in normal operation for opening and closing connections have been colored green. States which aren't used in normal operation but appear in more than one model have been colored red.


#figure(
  image("../figures/darwin.svg"),
  caption: [A state machine describing the behavior of MacOS (Darwin 24.4.0)],
) <darwin>

#figure(
  image("../figures/linux.svg"),
  caption: [A state machine describing the behavior of Linux (6.6.85)],
) <linux>

#figure(
  image("../figures/windows.svg"),
  caption: [A state machine describing the behavior of Windows (NT 10.0.26100)],
) <windows>


== Discussion
In general it seems the Linux and MacOS state machines are most similar with Windows containing the most striking differences.


We can see that the Linux and MacOS state machines have three separate states for the three way handshake (labelled LISTEN, SYN_RECV, and ESTABLISHED for clarity). Interestingly however the Windows state machine doesn't distinguish between the SYN_RECV and ESTABLISHED states, looping back to SYN_RECV when sending an ACK.


This doesn't necessarily indicate non conformance to the specification since most behavior is the same just transitioning from the SYN_RECV state instead of the ESTABLISHED state.


A commonality between all the models is the existence of an UNRESPONSIVE state for which all transitions loop back and output either timeout or reset (remember that self loops with output symbol time out aren't shown for claritys sake).

This state is entered by sending a FIN+ACK while in SYN_RECV. In addition the macOS and Linux models have a state labeled CLOSE_WAIT2 which can transition to this UNRESPONSIVE state.

=== Non-standard states

The Windows and Linux models feature a state labelled LISTEN2 which behaves similarly to the regular LISTEN state but is reached through various kinds of nonstandard inputs. On Linux this likely occurs because of how the mapper handles sequence numbers. Since the sequence number is incremented by a large amount when receiving a reset. Since all of the transitions to LISTEN2 have reset as the output symbol they result in this change in sequence number which makes the next packet appear "fresh", which allows the normal connection flow to be completed from this state.

Similarly on Windows all transitions to LISTEN2 originate from listen and have timeout as the output symbol. Thus the following SYN packet sent is considered "fresh" by the SUT and a transition to SYN_RECV can be made.

The Linux and MacOS models feature a state labelled CLOSE_WAIT2 which is entered by sending a FIN packet from SYN_RECV. CLOSE_WAIT2 only has transitions to the UNRESPONSIVE state or back to a listening state and is thus a kind of stuck state either ending up in UNRESPONSIVE or starting a new connection.


The Linux model has a cluster of states labelled s5, s4 and s8. These i have categorised as miscellaneous states. Almost all of the transitions to and from these have timeout as the output symbol meaning they likely represent some kind of "stuck" state.








