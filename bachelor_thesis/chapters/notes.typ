= Notes <notes>

== 17.02

17.02 - After the meeting with my supervisor, things are clearer in my mind. Big themes of the thesis will be, security processes and how all the crypto is handled, how to make sure the deployment of a new instance is seamless, demistify the procedure to retrieve the data in the case of a backup (needs clarification), new features to add in the webapp.

17.02 - Explored the solutions for the template to use for the thesis. Chosen the official one.

17.02 - Tried to begin the planning on github as I suggested. I then saw the example yaml file provided in the typst template. I will first draft a simple table on paper or in md and then choose a display solution. 

17.02 - Everything in english or french ? !QUESTION

17.02 - Reading Gantty docs.

17.02 - Creating draft of planning on paper.

17.02 - Reporting planning to yaml for gantty.

17.02 - Thinking hard about wether or not I missed smth in the planning...

17.02 - Noticed some errors ^^' Forgot to consider the week of crunch as a week without work on the thesis... urrgh hate crunch

17.02 - Look around the specification of other's report to understand better what's expected

17.02 - Trying to write the summary of the problem, not an easy task !

17.02 - Used the description of the bachelor thesis as a base and translated it mostly

== 19.02

0822 - Thought quite a bit about the structure of the planning. Want to make it more detailed with mention of what, regarding to the report, is done.

0822 - Reflected on using branches for planning and spec. I think it's not overkill as it will help undersanding how I work and each brnach will be focused on a specific interest.

0958 - Realized that I wanna rewrite the spec I wrote on tuesday. Will divide it into summary and the problematic I think it will be better.

1023 - It's a bit hard to write the specifications. I'm faced with the tempation to use AI. I do wonder what I should prioritize. Speed but lesser quality or take my time to write these docs ? !QUESTION

1033 - I will start by writing some objectives based on the description we made with my supervisor.


== 24.02

0750 - Draft of the questions for the meeting

0825 - Work a bit on the spec + relearning some typst syntax. 

1030 - Working on the new iteration of the planning

1120 - Finding a way to have the hours for the tasks in planning

1300 - Finishing second iteration of the planning

1338 - Colleague asking for smth, getting back to finishing the plannin gwith a PR

1348 - Added a template for the PRs. 

1348 - Merged the second iteration of the planning into main

1355 - Merged main into docs/draft/spec and continue working on specifications

1356 - Have to rewrite the spec to adapt to the change in the planning ! Then write the deliverables part 

1415 - When writing the spec I can see that my planning had some mistakes and that I forgot about the watermark process
so I added this in place of the database as this was a bit redundant with the bcakup

1425 - Starting to write the deliverables

1510 - It took me a while and I feel like it's lacking somehow ... It will anyway evolve after the talk with the mandate

1516 - For a first draft I will say it's enough 

1520 - Starting to write the config so the report is generated correctly

1615 - Getting started for creating the repo where the code is stored. I will first clone all the repo from the gitlab, and put them raw in the icnml repository. Then I will skim through them to understand how to create my dev env with documentation !!!!

1622 - I can see that the doc/build/ is within the .gitignore as well as the tests folder. That smells bad.

1623 - cdn is a within .gitmodule so I will clone the repo both outside and within this so that we have all repo at one layout and where it's functionally expected

1633 - Tools repo are scripts and scripts repo are scripts too. This is gonna be fun to untangle

1635 - Fingerprintexperts repo seems to be smth for students or a test of sorts

1638 - The docker repo seems to be where I can start from to build my dev environment ! However, there seems to be libraries that are not part of the project ICNML on gitlab. I have to underline to Christophe that I need an access to the prod environment and copy the necessary libraries MDmisc, NIST, PiAnoS, PMlib and WSQ. This feels like quite the wall.

1650 - The afis_assigment repo seems to be unrelevant for the thesis

== 26.02

0740 - Getting ready for the meeting with the mandate about organisation and confirming the time allocated to work on icnml

0900 - the meeting was great, now I have to work on the code and I have to understand its different processes. Let's get started !

0905 - Writing the structure of the repositories with their first perceived responsabilities

1027 - First draft of repo structure is done, I'd like to make a schema to understand the relationships between the repo.

1052 - Finished schema on app.diagrams. I think I'll do my schema on this, it's easy and nice-looking.

1125 - 5 types of users: Donor, Submitter, Admin, AFIS and Trainer. The `config.py` file seems to have lots of things to understand how everything works.
I can't find the place where the image is decrypted. 1138 - It's in the `image_serve` function with `do_decrypt_dek` func 

1131 - Submission is where the image/file is encrypted

1136 - utils.encryption is where the encryption processes is.

1137 - Encrypt is documented as decrypt and vice-versa 

1140 - What is a dek ? -> Data Encryption Key https://security.stackexchange.com/questions/93886/dek-kek-and-master-key-simple-explanation

1143 - These are stored within the db as there is a table named donor-dek

1147 - when generating the dek, the code uses both aes and pbkdf2

== 03.03

0750 - Getting back into it

0803 - Made all the necessary requests for rights to access the application + the server. I should have them by this friday

0804 - I would like to focus on the process for the dek creation and create a document about it explaining the workflow

0827 - This seems to start at the submission. The donor will ask for an account and a submitter or admin will accept it via do_new

0840 - There's an iv created via Random. The encryptino uses the encryption utils and aes utils. The stores the salt and dek created in the db.

0848 - When creating the dek, it uses pbkdf2 but call it sha512. I don't think I understand wholly what's going on.

1055 - After meeting, switch everything to english !