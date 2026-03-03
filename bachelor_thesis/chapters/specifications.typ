= Specifications <specifications>

== Problem summary <problem-summary>

*ICNML* (_International Close Non-Matches Library_) is an open-souce platform designed for handling
biometric traces in scientific and experimentation contexts. It is deployed by several research institutions,
including the University of Lausanne (_UNIL_). It is used by collaborators worldwide on projects focused
on image analysis and biometric recognition.

=== Problem statement <problem-statement>

The system was initially developed in a research environment that prioritized functionnality and flexibility over 
long-term maintenance and technical standardisation. Today, the plateform remains a central component in many scientific
activities. However, its evolution and sustainability are limited by accumulated technical debt. These weaknesses affect
maintenability, security, and usability for both admins and end users alike.

== Specifications <specification-1>

=== Objectives <objectives>

This  aim of this bachelor thesis is to strenghten the security and maintenability of the *ICNML* platform. The work is 
built around the 3 following objectives. 

The first objetive is to *reinforce technical maintainability* by producing documentation of the system architecture and
all critical processes. The underlying objective is to enable future contributors to understand, install, and develop the
platform easily compared to now. 

The second objective is to *improve security* by bringin transparency to internal processes:
- data encryption in the db
- access control mechanisms
- watermark on the images downloaded
- encryption mechanisms applied per donor

The third objective is to *demistify and reinforce management operations* such as installation and backup restoration.
This will improve maintanability and reusability by new developers. 

The third objective is to *optimise user experience* through filtering and management features. Especially filtering
by donor or image quality.

=== Schedule <schedule>

This work begins the 16.02.2026 and ends the 23.07.2026. Over the 16 first weeks, from 16.02 to 08.06, the workload
is 12 hours per week. The 6 last weeks, from 08.06 to 27.07, the workload is the equivalent of a full-time.

An assessed intermediary submission is due on 20.05. The final report is due on the 27.07 at 12h00.

The defense will be organized between the 24.09 and the 11.10.

=== Tasks <taches>

The work is built into seven phases, each one building ontop of the previous one.

The *Starting phase* (16-19.02) covers the creation of an initial planning document and the drafting of this specification.

The *First steps in the codebase phase* (24.02-02.04) involves an in-depth analysis of the current codebase, the production
of initial general technical documentation, and the setup of a *reproducible* local dev environment.

The *Watermark + backup management phase*  (07.04-23-04) is focus on the database encryption mechanisms as well as the process
behind the backup mechanism. It will also analyse the process of watermarking the images when they are downloaded from the webapp. 

The *User management phase* (23.04-07.05) analyses how the keys for the users are generated and stored, how their biometric data
 are encrypted and how the auth is managed within the application.

The *Deployment management phase* (07.05-20.05) analyses the current deployment solution and produces corresponding documentation.
By the end of this phase, the created documentation will give enough information to take a decision on which functional
improvements will be implemented during the development phase. 

The *Development phase* (20.05-10.07) covers the implementation of the improvements selected. The exact scope is to be determined
based on the findings of the precedent phases. 

The *Admin end of the project phase* (13.07-23.07) will focus on writing the final report and the different admin tasks 
that comes with the end of this bachelor thesis such as a publishable summary and a poster.


=== Deliverables <deliverables>
Here are the expected deliverables :

+ Technical documentation on:
    - System architecture
    - Per-donor image encryption process with key generation and storage
    - Digital watermarking process applied to downloaded images
    - Backup mechanism 
    - Deployment procedure
    
 
+ Functional improvements:
  - Scope defined on 20.05, once documentation is complete
  - Candidate features are as followed: 
    - Sorting by donor
    - Sorting by image quality

+ End of thesis deliverables:
    - An intermediary report due on 20.05
    - A final report due on 23.07
    - A publishable summary and a poster