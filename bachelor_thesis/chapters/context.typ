

= ICNML: context <icnml-context>

== What is ICNML ?

ICNML (International Close Non-Matches Library) is a web platform designed for managing biometric data in scientific and forensic research contexts.  It is used by several reasearch institutions, for example at the University of Lausanne, Ecole des Sciences Criminelles (UNIL-ESC). It supports research in fingerprint identification.

The platform is both a library and a work environment for fingerprint traces (marks) and reference prints (tenprints), supporting all the steps from data acquisition to creating exercises for examiner training.

== Scientific context and motivation

Fingerprint examination in forensic science relies on comparing a latent mark found at a crime scene with a reference database. The Automated Fingerprint Identification Systems (AFIS) return a ranked list of candidate matches. The candidates that rank highly but do not actually correspond to the source trace are called Close Non-Matches (CNM). These are particularly valuable in research as they represent challenges for identification.

ICNML was built to collect, organise, and exploit these challenges for identification. It has two missions: 

+ Acts as a recipient for donors' biometric data (traces and reference tenprints) and for close non-matches results returned by AFIS searches.
+ Provide trainers with the annotated data they need to build exercises that test fingerprint examiners against difficult, realistic scenarios.

== Data acquisition to exercises creation

There are three different steps to understand the ICNML workflow from data creation to exercises creation.

=== Stage 1: data acquisition

A Submitter registers a new Donor in the system, for more info on the roles see @roles-and-permissions. The donor provides fingerprint reference cards (tenprints) and latent traces (marks). 
Consent forms are acquired at this stage for new donors. Upon registration, a per-donor cryptographic key (DEK, see @dek-donor-generation) is generated and all biometric data for that donor is stored encrypted.

=== Stage 2: AFIS search

An Administrator creates an AFIS target by submitting a trace to the AFIS users. The AFIS users will submit the target created by the Administrator to an Automated Fingerprint Identification System. 
The AFIS returns a ranked list of candidate matches. The AFIS user will annotate those candidates, records a PFSP decision for each, a quality score that characterises the quality of the close non-match.

This will grow the library of close non-matches on ICNML.

=== Stage 3: Trainer exercise creation

A Trainer uses the mark data, together with the known true correspondence and the AFIS close non-matches to build training exercises. For each exercise the trainer can choose to include either correct matches or misleading close non-matches.

This allows the trainer to create realistic examination scenarios. Then the trainer can download the exercises they created and give them to their team.
