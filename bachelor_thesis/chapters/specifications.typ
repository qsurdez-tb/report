= Specifications <specifications>

== Problem summary <problem-summary>

ICNML (International Close Non-Matches Library) is a web platform designed for handling
biometric data in scientific and experimentation contexts. It is deployed by several research institutions,
including the University of Lausanne, Ecole des Sciences Criminelles (UNIL-ESC). It is used by collaborators worldwide on projects focused
on image analysis and biometric recognition.

=== Problem statement <problem-statement>

The system was initially developed in a research environment that prioritized functionality and flexibility over 
long-term maintenance and compliance with technical good practices . Today, the platform remains a central component in many scientific
activities. However, its evolution and sustainability are limited by accumulated technical debt. These weaknesses affect
maintainability, security, and usability for developers, admins and end users alike.

== Specifications <specification-1>

=== Objectives <objectives>

This bachelor thesis aims to strengthen the security and maintainability of the ICNML platform. The work is 
built around the four following objectives. 

==== Reinforce technical maintainability

Produce documentation of the system, the architecture and
setting up a development environment so that future contributors can  understand, install, and develop the
platform easily compared to now. 

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    align: (left, left),
    [Current State], [No installation guide, no architecture documentation, no documented development environment.],
    [Target State], [A complete documentation set covering system overview, architecture, development setup, validated by a successful fresh installation.]
  ),
  caption: [Current state and target state to reinforce techinal maintainability]
)

==== Improve security transparency

Bring transparency to internal security processes of the platform, with a focus on:
+ Per-donor security processes, including biometric data storage encryption and revocation
+ Access control mechanisms and roles
+ Watermark on the images downloaded
+ Backup encryption

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    align: (left, left),
    [Current State], [Encryption and access control mechanisms exist but are undocumented. Key storage practices are unknown prior to analysis. ],
    [Target State], [Each mechanism is documented with its current implementation, known weakness identified if any.]
  ),
  caption: [Current state and target state to improve security transparency]
)

==== Demystify management operations

Document and, if chosen for the development phase, improve the procedures for deployment and restoration so that a new developer can perform these operations without assistance. 

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    align: (left, left),
    [Current State], [No deployment or restoration procedure is documented. Restoration has never been formally tested.],
    [Target State], [Step-by-step procedures for deployment and restoration, validated by executing each procedure in a development environment.]
  ),
  caption: [Current state and target state to demystify management operations]
)

==== Optimize user experience

Improve filtering and management features for end users, in particular filtering by donor and image quality.

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    align: (left, left),
    [Current State], [No filtering functionality exists for donor or image quality.],
    [Target State], [The exact scope to be confirmed on 20.05 based on findings from the analysis phases.]
  ),
  caption: [Current state and target state to optimize user experience]
)

=== Schedule <schedule>

This work begins the 16.02.2026 and ends the 23.07.2026. Over the 16 first weeks, from 16.02 to 08.06, the workload
is 12 hours per week. The 6 last weeks, from 08.06 to 27.07, the workload is the equivalent of a full-time.

An assessed intermediary submission is due on 20.05. The final report is due on the 27.07 at 12h00.

The defense will be organized between the 24.09 and the 11.10.

=== Tasks <taches>

The work is built into seven phases, each one building ontop of the previous one.

#figure(
   table(
      columns: (30%, auto, auto),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left, center, left),
      table.header[*Phase*][*Dates*][*Deliverables*],
      [Starting],       [16-19.02],            [Initial planning document, this specification],
      [First steps in codebase],       [24.02-02.04],            [Doc: architecture, dev environment, system overview],
      [User management],       [07-16.04],            [Doc: per-donor security processes, access control mechanisms and roles],
      [Watermark management and biometric data],       [23-30.04],            [Doc: watermark process, steganography assessment, biometric data management],
      [Backup management],       [07-12.05],            [Doc: backup encryption],
      [Deployment management],       [12-20.05],            [Doc: deployment procedure, restoration procedure],
      [Development],       [20.05-10.07],            [Implemented and tested functional improvements],
      [End of project admin],       [13-23.07],            [Final report, publishable summary, poster],
      
    ),
    caption: [Phase breakdown]
)


=== Deliverables <deliverables>
Here are the expected deliverables :

+ Codebase with all new features

+ Technical documentation on:
    - System overview
    - System architecture
    - Development environment 
    - Per-donor security processes
    - Access control mechanisms and roles
    - Watermark process, steganography assesment
    - Biometric data management
    - Backup encryption
    - Deployment procedure
    - Restoration procedure
    
 
+ Functional improvements:
  - Scope defined on 20.05. Candidates features include:
    - Sorting by donor
    - Sorting by image quality

+ Thesis deliverables:
    - An intermediary report due on 20.05
    - A final report due on 23.07
    - A publishable summary and a poster on 23.07