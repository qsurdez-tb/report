= Cahier des charges <cahier-des-charges>

== Résumé du problème <résumé-du-problème>

// TODO ask wether we use english or french cause frenglish is a big no-no

*ICNML* (_International Close Non-Matches Library_) is an open-souce platform designed for handling
biometric traces in scientific and experimentation contexts. It is deployed by several research institutions,
including the University of Lausanne (_UNIL_). It is used by collaborators worldwide on projects focused
on image analysis and biometric recognition.

=== Problématique <problématique>

The system was initially developed in a research environment that prioritized functionnality and flexibility over 
long-term maintenance and technical standardisation. Today, the plateform remains a central component in many scientific
activities. However, its evolution and sustainability are limited by accumulated technical debt. These weaknesses affect
maintenability, security, and usability for both admins and end users alike.

== Cahier des charges <cahier-des-charges-1>
#lorem(100)

=== Objectifs <objectifs>

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

=== Déroulement <déroulement>

This work begins the 16.02.2026 and ends the 23.07.2026. Over the 16 first weeks, from 16.02 to 08.06, the workload
is 12 hours per week. The 6 last weeks, from 08.06 to 27.07, the workload is the equivalent of a full-time.

An assessed intermediary submission is due on 20.05. The final report is due on the 27.07 at 12h00.

The defense will be organized between the 24.09 and the 11.10.

=== Tâches <taches>

The work is built into five phases, each one building ontop of the previous one.

The *Starting phase* (16-19.02) covers the creation of an initial planning document and the drafting of this specification.

The *First steps in the codebase phase* (24.02-31.03) involves an in-depth analysis of the current codebase, the production
of initial technical documentation, and the setup of a *reproducible* local dev environment. This is the foundation of 
the following phases. This phase will produce general documentation.

The *Cryptography focus phase*  (31.03-09.04) involves a targeted of the image encryption mechanisms, including key generation
and management per donor. This is followed by the production of dedicated documentation covering these processes.

The *Backup focus phase* (14.04-23.04) analyses the actual dual-key backup system, identifies its tradeoffs, and document the 
current process as well as possible improvements.

The *Deployment focus phase* (23.04-30.04) analyses the current deployment solution and produces corresponding documentation.
By the end of this phase, the created documenation will give enough information to take a decision on which functional
improvements will be implemented during the development phase.

The *Development phase* (05.05-23.07) covers the implementation of the improvements selected. The exact scope is to be determined
based on the findings of the precedent phases. Some features already asked by the mandate are found in the deliverables section. 

=== Livrables <livrables>
Les délivrables seront les suivants :
+ Une documentation contenant :
  - Une analyse de marché
  - La décision qui découle de l’analyse
  - Spécifications
  - Les informations du module tel que le fonctionnement et les limitations
  - Une planification initiale et finale
  - Un mode d’emploi
+ Un module remplissant les objectifs défini au point 2.1.
+ Un software implémentant les améliorations s’il a été possible de les effectuer.