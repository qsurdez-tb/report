= Specifications <specifications>

== Problem summary <problem-summary>

ICNML (International Close Non-Matches Library) is a web platform designed for handling
biometric data in scientific and experimentation contexts. It is deployed by several research institutions,
including the University of Lausanne, Ecole des Sciences Criminelles (UNIL-ESC). It is used by collaborators worldwide on projects focused
on image analysis and biometric recognition.

=== Problem statement <problem-statement>

The system was initially developed in a research environment that prioritized functionnality and flexibility over 
long-term maintenance and compliance with technical good practices . Today, the plateform remains a central component in many scientific
activities. However, its evolution and sustainability are limited by accumulated technical debt. These weaknesses affect
maintenability, security, and usability for developers, admins and end users alike.

== Specifications <specification-1>

=== Objectives <objectives>

This  aim of this bachelor thesis is to strenghten the security and maintenability of the ICNML platform. The work is 
built around the four following objectives. 

==== Reinforce technical maintainability

Produce documentation of the system architecture and
all critical processes so that future contributors can  understand, install, and develop the
platform easily compared to now. 

Current state: No installation guide, no architecture documentation, no documented development environment. Target state: A complete documentation set covering architecture, development setup, and all critical processes, validated by a successful fresh installation.

==== Improve security transparency

Bring transparency to internal security processes of the platform, with a focus on:
+ Per-donor data encryption in the database
+ Access control mechanisms
+ Watermark on the images downloaded

Current state: Encryption and access control mechanisms exist but are undocumented. Key storage practices are unknown prior to analysis. Target state: Each machanism is documented with its current implementation, known weakness identified if any, and refactoring applied if chosen for the development phase.

==== Demystify management operations

Document and, if chosen for the development phase, improve the procedures for installation, backup and restoration so that a new developer can perform these operations without assistance. 

Current state: No installation or backup procedure is documented. Restoration has never been formally tested. Target state: Step-by-step procedures for installation, backup and restoration, validated by executing each procedure in a development environment.

==== Optimize user experience

Improve filtering and management features for end users, in particular filtering by donor and image quality.

Current state: No filtering functionality exists for donor or image quality. Target state: At least one filtering feature implemented, tested and documented. The exact scope to be confirmed on 20.05 based on findings form the analysis phases.

=== Schedule <schedule>

This work begins the 16.02.2026 and ends the 23.07.2026. Over the 16 first weeks, from 16.02 to 08.06, the workload
is 12 hours per week. The 6 last weeks, from 08.06 to 27.07, the workload is the equivalent of a full-time.

An assessed intermediary submission is due on 20.05. The final report is due on the 27.07 at 12h00.

The defense will be organized between the 24.09 and the 11.10.

=== Tasks <taches>

The work is built into seven phases, each one building ontop of the previous one.

#figure(
   table(
      columns: (auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Phase*][*Dates*][*Deliverables*],
      [Starting],       [16-19.02],            [Initial planning document, this specification],
      [First steps in codebase],       [24.02-02.04],            [Doc: Architecture, dev environment],
      [User management],       [07-16.04],            [Doc: key generation, encryption, authentication],
      [Watermark management],       [23-30.04],            [Doc: watermarking process, steganography assessment],
      [Backup management],       [07-12.05],            [Doc: backup and restoration mechanism],
      [Deployment management],       [12-20.05],            [Deployment procedure, scope decision for development phase],
      [Development],       [20.05-10.07],            [Implemented and tested functional improvements],
      [End of project admin],       [13-23.07],            [Final report, publishable summary, poster],
      
    ),
    caption: [Phase breakdown]
)


=== Deliverables <deliverables>
Here are the expected deliverables :

+ Technical documentation on:
    - System architecture
    - Per-donor image encryption process with key generation and storage
    - Digital watermarking process applied to downloaded images
    - Backup mechanism 
    - Deployment procedure
    
 
+ Functional improvements:
  - Scope defined on 20.05. Candidates features include:
    - Sorting by donor
    - Sorting by image quality

+ Thesis deliverables:
    - An intermediary report due on 20.05
    - A final report due on 23.07
    - A publishable summary and a poster