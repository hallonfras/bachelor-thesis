#import "/utils/todo.typ": TODO

= Future Work
As it currently stands TCP-Fuzzer is missing some of the intended functionality. As described in section 3.2.4 the part of the mapper that handles TCP-socket calls isn't fully implemented and is thus an obvious candidate for future work. This would also enable fuzzing of clients. As it currently stands only servers can be fuzzed since they are already listening at the start of the exchange removing the need for socket commands such as LISTEN or ACCEPT in the input alphabet.

Another option for future work would be handling non-valid sequence numbers. This introduces a fair amount of complexity because sequence numbers can be invalid in more than one way e.g old/reused sequence numbers versus large out of window new sequence numbers. This might result in very large state machines.

The third option I see for future work would be introducing parameters with RA learning. This has already been done for tcp-learner @tcp-fuzzing3 however it would have to be entirely reimplemented for TCP-Fuzzer because of the switch to PSF @PSF for the learner. Interestingly there is current work on including support for RA learning in PSF, so this is a rather promising candidate for future work.


= Conclusions
This thesis has detailed the implementation of TCP-Fuzzer, a modern implementation of state-fuzzing for TCP. In general the code base is a fair bit simpler as compared to @tcp-learner, this is due to various advancements in the libraries used which meant that workarounds present in tcp-learner were no longer necessary. It is also simpler to setup and configure due to TCP-Fuzzer leveraging docker and docker-compose for managing the SUT simplifying the process of virtualization and networking.

A rudimentary analysis has shown that the models generated are fairly similar to previous work by Fiterau-Brostean et al @tcp-fuzzing1 although this requires further testing which is deemed outside the scope of this thesis.


