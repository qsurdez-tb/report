#import "../macros.typ": note, concept

= ICNML: Context <icnml-context>

#concept[
  ICNML is a web platform for storing and working with fingerprint data in forensic research. This chapter explains what it is for, the forensic problem it addresses, the two roles it plays, and the three-stage workflow, from collecting a donor's prints to handing a trainer a finished exercise, that the rest of the thesis documents in detail.
]

== What is ICNML?

ICNML (International Close Non-Matches Library) is used by several research institutions, notably the School of Criminal Justice at the University of Lausanne (UNIL-ESC), to support research in fingerprint identification.

It plays two roles at once. It is a library, a secure repository of fingerprint marks (traces) and reference prints (tenprints). It is also a workspace, the place where the forensic research workflow is actually carried out, from collecting a donor's data to preparing training exercises for fingerprint examiners. Keeping both under one roof, and doing so securely, is what makes the platform useful and what makes its security processes worth documenting.

== The forensic problem it addresses

Fingerprint examination compares a latent mark, a partial, often poor-quality print left at a scene, against a reference database. To narrow the field, examiners use an Automated Fingerprint Identification System (AFIS), a separate system, external to ICNML, that returns a ranked list of candidate prints. The candidates that rank highly but are not the true source are called Close Non-Matches (CNM).

These close non-matches are the heart of the matter. They are the cases most likely to mislead an examiner, and so they are exactly the material needed to study identification errors and to train examiners against realistic, difficult scenarios. ICNML exists to collect and exploit them, which gives it two research-driven missions:

+ Collect and protect donors' biometric data (marks and reference tenprints) together with the close non-matches returned by AFIS searches, building an organised research corpus.
+ Serve trainers with the annotated data they need to build exercises that test fingerprint examiners against genuinely hard, realistic cases.

== From a donor's prints to a finished exercise

The platform's work follows three stages, each carried out by a different role. Understanding this flow is the quickest way to see how the roles, the platform, and its database relate. The roles themselves are detailed in @roles-and-permissions.

=== Stage 1: data acquisition

A Submitter registers a new Donor, who provides reference tenprints and latent marks. Consent is recorded at this point. On registration, a per-donor cryptographic key (the DEK, @per-donor-security) is generated and every piece of that donor's biometric data is stored encrypted under it.

=== Stage 2: AFIS search

An Administrator turns a mark into an AFIS target and assigns it to AFIS users, who run it through the external identification system. The returned candidates are annotated, each with a decision and a quality score characterising the close non-match. This is what steadily grows ICNML's library of hard cases.

=== Stage 3: exercise creation

A Trainer draws on the marks, the known true correspondences, and the AFIS close non-matches to build training exercises, choosing for each whether to include a correct match or a misleading close non-match. The result is a set of realistic examination scenarios the trainer can download and give to their team.
