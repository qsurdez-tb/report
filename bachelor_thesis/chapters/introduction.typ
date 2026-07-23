= Introduction <introduction>

A fingerprint is not like a password. If a password leaks, it can be changed. A fingerprint cannot, it identifies a person for life, so a biometric record that leaks is compromised permanently. Any system that stores such data therefore carries an unusually heavy responsibility, and the way it protects that data deserves to be understood rather than merely trusted.

ICNML (International Close Non-Matches Library) is one such system. It is a web platform used by forensic-science institutions, notably the School of Forensic Science at the University of Lausanne, to collect and study the fingerprint cases that most often mislead examiners. It holds genuine biometric data, reference prints and latent marks from real donors, and it is the working environment in which that data is annotated and turned into training material for fingerprint examiners. What ICNML stores, and what it is used for, are set out in @icnml-context.

== A research platform grown critical

Over the years the platform became an important tool for several institutions, yet it remained at the academic prototype stage, with accumulated technical debt affecting its maintainability, its security, and the daily experience of the people who use it.

Three symptoms stood out at the start of this work. First, the system ran on Python 2.7, a version of the language that reached end of life in January 2020 and receives no security fix at all, so any flaw discovered in it stays open forever. Second, the environment could no longer be rebuilt from its own sources, which meant a new contributor could not realistically get the platform running. Third, and most importantly for a system holding biometric data, its security mechanisms were undocumented. The protections were real and, as this thesis shows, often quite sophisticated, but because nobody had written down how they worked, nobody could say with confidence what actually guarded the data or where its weak points lay. A sensitive system that cannot be explained is a system that cannot be trusted, maintained, or safely improved.

== What this thesis sets out to do

This thesis aims to modernise ICNML and to make it reliable and understandable. That aim was fixed at the outset as four concrete objectives, set out in the specifications, which in plain terms are the following.

+ *Make the platform maintainable.* Produce the documentation and the reproducible development environment that a future contributor needs in order to understand, install and work on ICNML, none of which existed before.
+ *Make its security transparent.* Audit each protection mechanism in turn, the user roles, the per-donor encryption, the shared cryptographic tools, the image marking, and the backups, and document how each works, naming its weaknesses honestly rather than glossing over them.
+ *Demystify the management operations.* Document, and where possible test, how the system is deployed and how its data is restored, so that these operations no longer depend on their original author.
+ *Improve the experience of its users.* Add the practical features the forensic teams actually asked for, in particular the ability to filter and manage data by donor and by image quality.

== Approach and structure of this document

The method throughout was as follows, read the existing code closely, explain what it does in terms anyone can follow, and only then improve it where the analysis showed it mattered most. The document is built in the same two movements, and each chapter opens with a short plain-language summary before going into detail, so that a reader can grasp the essentials without following every technical step.

The first part, Documentation and Analysis (@documentation), documents ICNML as it was found. It covers what the platform is and how it is built, its purpose (@icnml-context), the interface its users see (@application-overview) and the structure of its codebase (@repo-struct), then examines each protection mechanism in turn, the roles and the login process (@roles-and-permissions), the per-donor encryption that makes a donor's data erasable (@per-donor-security), the shared cryptographic utilities underneath it (@crypto-utils), the marking applied to downloaded images (@tattooing), the handling of the biometric data itself (@biometric-data), the original deployment pipeline (@deployment), and the encrypted backups (@backup-security).

The second part, Modernisation and Extension (@implementation), is the work this thesis added on top. It migrates the whole system from the end-of-life Python 2.7 to Python 3.11 (@python3-migration), then designs, implements and evaluates a traceable watermark that ties a leaked image back to the recipient it was issued to (@state-of-the-art, @watermark-implementation), improves the day-to-day experience of the platform's users (@ux-improvements), and shows how the modernised system is run, both locally and in a production-faithful setup (@running-icnml).
