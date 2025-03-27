#import "/utils/todo.typ": TODO

= Introduction
Uppsala University currently maintains protocol-state fuzzers for various network protocols, e.g DTLS@DTLS-fuzzer and EDHOC@EDHOC-fuzzer.

However the implementation for TCP@tcp-learner is rather old, being based on python2 which has since been deprecated, furthermore a generalized library for implementing state fuzzers has since been created @PSF.

Due to this an updated version of tcp-learner became necessary.


== Problem
#TODO[
  Describe the problem that you like to address in your thesis to show the importance of your work. Focus on the negative symptoms of the currently available solution.
]
As previously mentioned tcp-learner's mapper-component is based on python2 which is becoming increasingly unsupported on modern systems. The learner side doesn't fair much better, using an antiquated version of LearnLib.

== Objectives
#TODO[
  Describe the research goals and/or research questions and how you address them by summarizing what you want to achieve in your thesis, e.g. developing a system and then evaluating it.
]

== Outline
#TODO[
  Describe the outline of your thesis
]
