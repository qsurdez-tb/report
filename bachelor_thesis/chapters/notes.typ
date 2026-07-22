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

0858 - I see that username and email are use to create the dek as the user did not yet create a password. Let's keep an eye on this.

0902 - Well I'm focusing a bit on the encryption today but I feel like it's such an important part that I should tackle it as soon as I can to understand the components early on

0905 - Then we move to donor onboarding which uses the hash of the email in the path of the url.

0926 - Beginning the writing of the document after the look through the code !

0927 - After doing this document, I should focus on a more generic one like what are the roles and what are their purposes. This makes more sense at the beginning ^^

0940 - Maybe also the session object, talking a bit more on that would be helpful for the next documents


1055 - After meeting, switch everything to english !

1123 - Finished translating everything to english and incorporating the repo struct chapter !

1302 - Finished the last step for the DEK generation. Now I want to create a schema to make it more visually impactful

1315 - Finished the schema

1326 - Now let's create the doc explaining every role 

1406 - This is harder than thought as I have to skim through all the code and check which is allowed what. A bit tiring.

1425 - I'm slow and that's okay 

1516 - The decorator section took a long time

1617 - almost finished the role descriptions. then the roles-and-permissions doc will be finished I think. A nice schema can be made on thursday

1632 - Fnished the role and permissions doc ! Yay

== 16.03

0720 - Rereading work done on the 03.03

0750 - Just thought about the sql schema that I could input in DataGrip to get a nice schema out of it !

0804 - Finished rereading and updating previous work

0819 - Created a lil postgres Docker, mounted the sql tables + scripts. Had to tinker with the scripts a bit but the scripts ran and now I can access the data as it should be in the prod icnml database

0822 - Quite interesting, as there are looots of sequences in it created by the sql files. And 2 views !

0824 - It's quite strange cause, there's barely any foreign keys ... Like the files table has a creator column that is only an integer and common sense would expect a foreign key to the user table ? What's the reason for not having foreign keys ? Security perhaps ? Feels like shadowing and not real security mechanism

0830 - The views seem to get the different files table without the data column. Data column which is a varchar, not a blob. That's a strange choice. Is it because the data is a text and not bytes ? Is there some base64 encoding involved. Transforming binary data into ASCII text ? The upload of files is an interesting process that should have a dedicated document !

0853 - Let's get started on writing the doc for the db architecture. I'll see how detailed I wanna be for it

0928 - I don't know if we prefer bulletpoints or prose for explaining the constraints and the indexes ? !QUESTION - I prefer in bullet points so that the structure is always the same !

1009 - Finished the first 5 tables.

1045 - Talked with a colleague about ICNML and how strange it was that the DEK is plainly stored in the db and the use of the dek_check as it seemed redundant after the discussion. This can be interesting to talk about with my supervisor.

1123 - I would like to check wether or not the docker image of ICNML contains the library that is not accessible anymore MDmisc and NIST etc...

1259 - I'd like to finish the db arch by the end of today. I think it's an important work and quite a big one too. This will give me a better overview of what is the architecture of the webapp ! (Spoiler, it already does)

1317 - I really do wonder how the dump was generated, I mean it's so strange that some primary key are explicit primary keys but most aren't ...

1416 - Almost finished !

1434 - Finished, let's update the specifications again with the new planning

1443 - Finished updating the new spec

1458 - Thought about making a new diagram with the guessed FK relationships so we have a better view. It seems like a nice-to-have but not necessary ?

1502 - Did it quickly with AI, will study this later

1518 - Tried to pull the docker image from the gitlab repository and impossible, error 404 with unexpected end of input JSON: 
>docker pull esc-md-git.unil.ch/icnml/docker/web
>Using default tag: latest
>Error response from daemon: error parsing HTTP 404 response body: unexpected end of JSON input: ""

1525 - Using the production repo with the docker compose template, I don't have any idea what the .env should look like for the configuration variable. I just hope I'll have the access to the ICNML machine.

== 19.03

0845 - Had a meeting with Christophe to setup the admin account on the icnml machine. That's done. I also managed to find the missing libraries on the machine which I copied into the icnml repo. There's also some env and docker-compose that do not look like the ones in the repo so I will have to copy them AND find a way to exclude all the keys and info that are sensitive ! (a simple .gitignore rule will do the trick)

1113 - Finished the meeting to explain the App ICNML. 

== 24.03

0800 - Getting back into the project 

0816 - After the different meetings I had with Christophe, I'd like to make a file that would actually explain what the project is about. Some kind of contextualisation or introduction to the bachelor's thesis. 

0819 - The plan for today is creating the contextualisation, making the last adjustments on the spcifications, creating a *reproducible* dev env (that's going to be tough).

0841 - Is doing a state of the art interesting in my bachelor thesis context ? !QUESTION

0847 - First step of context is done and seems quite ok to me

0848 - I feel like explaining the whole pipeline/workflow would help understanding the scope of the webapp? Data acquisition -> AFIS search -> Trainer exercise creation

0924 - Finished the doc, it was easy with all the talks I had with the mandate. Now let's have a little break before rereading the specifications and making it better !

0943 - Let's get back to it.

1013 - Going back and forth with read-proofing my document and seeing the feedback of Claude Sonnet 4.6

1038 - Restructure the objectives section so that it's more easily readable.

1041 - I'm thinking about removing the tasks prose and replacing it with a tab. Maybe more readable ? Cause who actually cares about what I'll be doing in some ways ... Hmmmm I wonder, I wonder.

1110 - Seeing the result on paper I feel like a table is way clearer and easier to read through than the prose and it's more structured which I like.

1112 - Changing target state, current state with bullet points, that is more readable than just in plain text

1131 - Last rereading to spot typo

1138 - Now meeting to have an Admin account on the prod webapp

1300 - Coming back and getting started with the dev environment

1400 - This is harder than expected

1500 - Really harder than expected with the image that is not compatible with version 1 of Docker and not compatible with containerd, this is terrible

1550 - So I asked Claude to help me debugging and I finally managed to get to the end of it. The WSQ code is not compatible with my architecture, so I had to run it with linux/amd64 --platform docker flag

1617 - It's not per se reproducible as the library I had to download from the server are inexistent currently. So I'm a bit perplexe on how to treat it from now on ... I'll write the docs on how to reproduce this on Thursday.

1634 - I managed to make it work with redis and the db, well with the docker-compose file ! That's a super amazing feat, now we'll see if it's broken or not on Thrusday

0735 - Getting back into it

0736 - Trying once again to build from the dev env snatched from the server. With the changes made on Tuesday !

0750 - good news, it works and the admin account is setup. However, the functionalities are not fully working as the migration script is not applied. But, to apply it seems the script expects the table to already exists with the `_old` suffix. Stranger by the hour.

0754 - Trying to run the sql tables script within the migration folder straight on the database.

0754 - Again some errors, I think there's something missing. A file with the creation of the old tables or something else entirley. 
`docker compose exec -T db psql -U icnml -d icnml -f /dev/stdin < web/app/migration/311cac7b746c1852c012fa6fdfbe84eaceb27236/tables.sql`

0759 - There's still one table that's missing and that's the cnm_annotation one ... I can't find it in the different folders 

0804 - Not just one unfortunately, there's the cnm_annotation table, the cnm_result table.

0808 - I'm actually blocked, cause I can't seem to connect to the database on the prod server ... So I will have to see with Christophe once again and download the DDL from the actual prod DB ... Urrrgh that's so annoying. 

0814 - I'm gonna make a quick doc on the different steps I made to have the app half-working in a dev environment.

0850 - Began by explaining everything that went wrong, but that's not what's interesting.

0913 - Done with the first draft of the document. Have to check whether or not I can push on a new repo that would be made for dev env on the organisation.

0918 - I'm gonna focus on making an overview of the app with screenshots so that the current functionalities are documented. 

0931 - Taking screenshots to cover all the admin pages at first !

1006 - I'm a bit lost, I don't know what to do :(

1014 - Let's try writing a doc for an overview of the web app !

1054 - It's going quite wel, have to pu t areminder on watching all the TODOs in the documents so that I can be sure of what I write ! 
(like what are the little exclamation signs or marked signs and what do they say about the data ?)

1149 - Reached the marks gonna stop now.

== 31.03

0815 - Getting back into it

0823 - Trying to find the credentials to conntect to the prod db so I can see all the tables used

0834 - Managed to find the credentials but I have an error when I want to see the tables. I will go check with Christophe if he has the same behavior as me 

0839 - Let's read the feedback from the supervisor

0845 - Feedback is good generally, I'm just not sure to understand what he means by being coherent between the different parts of my specification and my report ? Not sure I understand, I'll ask him later during our meeting

0848 - Upon more careful reading I think that the access control is the main culprit as I already have it in my report I didn't thought of including it in the list of deliverables ^^'. But let's ask anyway !

0909 - Changes made based on feedback for title page

0912 - Let's get back into the app overview document

0938 - After some writing, I think I would up my game in documentation writing by giving
each chapter one of the four Diataxis axiom ... I may want to read more on that later on. Could be a nice source as well !

1015 - Meeting with client and with supervisor

- Nommer une fois bien les déliverables, et les redire 
- Distinguer les différents processus
- On se perd un peu parce que les choses sont assez différentes 
- Se retrouver dans les noms du chapitre, Biometric data management
- Revocation aussi qui est important ! 
- Structurer mieux mieux mieux !!!!
- User management, biometric data (revocation), backup, déploiement
- Current state and target state pas assez graphiquement clair psk on dirait uniquement pour le dernier point. 
- Intro qui explique comment accéder à la solution
- Diataxis qui est pas mal
- Retour pour qqn d'externe puisse suivre facilement 

1119 - Working on making a better structure for specifications

1130 - Eating break

1243 - Getting back to specifications

1349 - I think the specifications are approaching their final state

1353 - Switching to app overview doc

1429 - The app overview from the admin point of view is finished !

1433 - Going back into the dev environment setup

1531 - Quite difficult to find the prod config so I can connect to the server. I cannot have the default values of some tabels :((

1532 - I will continue the dev environment without them and that's okay. I'll add them later on.

1539 - onto setting up the db as the prod env automatically in the dev environment

1609 - Ok now other stuff is not working like the web container not running by default ? 

1625 - It works again, will check if it truly works on Thursday

== 02.04

0800 - Rereading the specifications

0834 - Finished the specifications, I'm a bit stressed but it's a good work I think !

0837 - Let's get back into the development environment setup !

0904 - Finished creating a repo for the dev environment + README.md with ~clear explanation on what are the changes and why they were needed. Some are not present, have to go through it again later on

1010 - Exporting typst spec to txt and md

1028 - Sending txt and md version to supervisor

1029 - Getting back into the dev setup document

1053 - Finished dev env now writing the struggles associated with it

1200 - Finsished

== 14.04

0744 - Getting back into it, taking some time to see where I'm at and what are the next steps

0752 - Purpose of today is renaming and adding to roles and permissions as well as dek donor generation to have all per-donor security processes and the access control mechanisms and roles ! (authentication)

0757 - Add authentication to roles-and-permissions and rename the doc (carful about renaming the anchor as it's the reference in other files), Add other security processes in dek-donor-generation (could be mixed with the biometric data management).

0819 - Trying to list all the different per-donor security processes: biometric data encryption in submission, two email encryption format, session-based encryption, filename encryption, consent form pipeline, donor account activation pipeline (mostly the difference with other accounts as the others will be discussed someplace else), dek softdelete mechanism + reconstruction. Almost all of them lie in views/submission | donor/__init__.py 

0830 - Listing take some time as I hace to go through the codebase searching for it.

0851 - I'm thinking about creating a file for explaining how the dev has created wrapper around common encryption libraries and submit that to check if it's ok or not ? 

0913 - Okay, let's get started writing the doc per-donor-security-processes

1016 - Integrated the dek generation doc in per donor sec proc + add the mechanisms to never store plaintext emails when form is submitted.

1017 - I don't know if I want to address the biometric files encryption now or later on ? I feel like the consent form does fit this doc better as its mechanism is different from the biometric files... 

1030 - Metting with the boss and then eating break

1230 - Getting back to it.

1327 - Finished consent form section

1420 - Continuing the document

1436 - I think it's finished ?

1528 - Finished creating the diagrams

1536 - Diagrams well inserted in the report

1536 - Exploring authentication 

== 16.04

0753 - Getting back into it

0800 - Thinking about dividing the consent form flow with what the submitter does and what the donor does, cause currently it's a bit complex and not easy to understand when you come upon the diagram. 

0815 - Created both diagrams to insert them at the right place in the report

0830 - Added both of the diagrams in the report getting into the authentication doc !

0930 - Struggling with the session part reading the docs and I don't see where the .execute_command comes from 

1003 - This is difficult understanding how all these cryptographic functions are used in ways that I don't expect in the code to write the auth doc

1050 - Stopping writing and doing some more reasearch on the difference between AES, PBKDF2 and GPG.

== 21.04

0750 - Getting back into it

0811 - Looking at the crypto course given by my supervisor. This seems promising and I will give it the time it needs. 

1020 - Is the check_dek something akin to the authenticated encryption ? It's not really in the context of encryption more of creating the key though 

1023 - The AES mode chosen is CBC !

1049 - Beginning to read the CAA course which is more practical than the first one.

1115 - With the knowledge acquired I feel more and more perplex about the use of random and the reduced output  which translates to a loss of entropy per bit ! And everything is a string not bytes which seems even weirder to me.

1128 - I-m reading a lot but I think it's important and it gives me clarity on what I've been reading in the code for the past few months.

1145 - The more I read and the more I feel like doing a deep dive into the utils module to unravel what is used for the hash and AES file and understand where the limitations are linked to the libraries not updated etc etc 

1155 - The iterations on the server side need to be pumped up. The course recommends 310'000 for server-side hashing and 10'000'000 for critical keys. Currently 50'000... Weak to GPU attacks.

1203 - Break time

1305 - Getting back into writing about the auth 

1337 - There's some weird operator precedence stuff happening in the verification of the password. It's a or not verify ??? I don't understand. It's just bad written code, that's all...

1455 - Finished the Login Flow section 

1524 - Finished the Password Reset Section 

1528 - I think it's the end of the day as I am a bit sick 


== 23.04 

Sick day

== 28.04

0727 - Getting back into it

0729 - A bit late on the auth process document, I have to work a bit schnelly schnelly today and on Thursday to be able to give a complete analyse of the processes within the codebase. 

0730 - Getting back into the auth writing 

0753 - Finally the figures are not too tight with the text with a little change that is very welcome to the eyes

0838 - Finished the doc on authentication, getting started on the watermark doc after a break

0903 - Finished the schemas for the auth part which I forgot about ^^

0908 - Added the schemas in the auth file

1025 - Came back from a coffee break with the colleagues

1119 - Finished the watermark document, will start the biometric data management doc

1230 - Stopped break

1313 - Came back continue writing the biometric data doc

1354 - Finished writing the biometric data management doc for now.

1416 - Finished the nice schema and included it in the report for the flow of the biometric data files

1443 - Break for the meeting with the US people on Pianos

1539 - End of the meeting, which will be the end of the day on ICNML

== 30.04

0745 - Cleanup the docs 

0821 - The next deliverable is the steganogaphy assesment. There's no steganography in the app so should I do maybe the different techniques used currently and how we could implement them ? Seems like a second part of the TB kind of thing ... 

0823 - Could write the different stuff seen on the use of deprecated libraries !

0936 - Had to check whether the prod deployment was launching the flask app with a python2 or python3 command and it's indeed python2 !

0945 - Discovered that the prod server is using docker swarm for some reason...

0954 - I cannot find the code that I copied on my machine previously... That seems very very strange... It seems the previous dev, whose access are still valid on the machine, removed it for some reason

1150 - End of the day

== 05.05

0757 - Getting back into it 

0814 - Getting started on the backup encryption chapter 

1000 - Finished the backup encryption chapter 

1005 - Creating the different schemas for the chapter

1030 - Update with supervisor (talk about the assistant post?, talk about the presentation to the mandate at the enf of May, talk about how confident I feel, talk about the focus I wanna give to the encryption and hash utils files to document them as they're the backbone of the encryption, talk about the images that have no steganogaphy and can be downloaded easily without any watermark) -> Aussi présentation de ce qui sera la suite. Faire une proposition de cve que je souhaite pour la suite.

1050 - End of update + break

1142 - end of the schemas

1147 - Add the schemas to the report, not the most aesthetic but for now it's okkay

1152 - Food time !

1300 - begin the crypto utils document to add some documentation of the basic 

1447 - It's a bit hard as I still don't have all the knowledge to properly understand all of it

1600 - Finish the crypto utils chapter

== 07.05

0850 - Rereading the whole document to proofread it

1016 - Should make smth of a flow for the first login also for the account that can request the account

== 12.05

0750 - Getting back into it

0800 - Starting the deployment document

0852 - All the pipeline cannot work because of the 404 on the submodules url AND the tls error with the cr.unil.ch !!! I'll keep writing the doc but the one thing I understand now is that no one can actually develop on the applicaiton...

0925 - Finally managed to get to the prod db. I was thinking of dumping the prod db to use as an dev environment to have some data to use as tests. 

1000 - With the ok of the mandate, dumping the db so that I will be able to use it during the development phase !

1104 - End of the deployment documentation

1116 - Creating a schema for the deployment steps. I still don't understand why it's in different repositories and not just one ?

1400 - Finished the sequence diagram + embedded in the report 

1445 - Add section to tell about the broken pipeline !

1509 - Thinking about what the dev timeline should be about

== 19.05

0800 - Getting back into it 

0810 - Relauching the export of the prod database as it's stopped midway last time

0811 - Writing docs on the development interest 

0920 - First draft of the dev-focus document according to my interests

1001 - Screenshots for explaining what's missing

1003 - Exploring reveal.js for the presentation

1030 - Start meeting

1115 - End meeting

1120 - Starting work on the presentation

1230 - Finished first draft of presentation
                                        
== 26.05

0730 - Getting back into it

0806 - Seeing if a surface attack document could be interesting ? Mentioning cPickle, SQL injection possible in certain context, etc...

0827 - I regained access to my desk at Unil Yay

0828 - Trying to find how difficult it's gonna be to upgrade from Python 2.7 to Python 3.9+

0924 - Refine the presentation

0926 - Talking with colleague how possible it is to have a new VM for ICNML ? He's not here too bad

0934 - Checking where the GPG private key could be held as it will be needed for the deployment on a new server ...

1015 - The key is not found on the container or the server. It will be asked at next meeting. I must amend what I said, it's not necessary for deployment but only for decrypting the encrypted PDF forms

1020 - I think having a doc on the upgrade from python 2.7 to python 3.9 can be interesting. Like smth of an analysis where I can highlight the points where it's necessary to spend efforts and what tools exist, what the litterature says about it etc etc...

1232 - Still writing it. Good to know that all the code from the libraries are under GNU licence so I can post them anywhere and make any change that I want !

1330 - Finished analysis

1336 - Practising the presentation 

1343 - Quite satisfied 

== 28.05

0800 - Getting back into it

0850 - Read an article https://www.geeksforgeeks.org/python/latest-update-on-python-4/ That further aliments my point on upgrading to Python 3 !!!

0900 - I'm a bit lost on what I could do ? 

0910 - Doing a surface attack document ??? It would be interesting as it would further aliments the arguments on upgrading to Python 3 ?

1102 - It's taking quite long as it's not smth I'm used to 

== 02.06

0730 - Getting back into it + translating the presentation to french

0745 - Transalted the presentation !

0745 - Reading the feedback from the supervisor

0750 - Creating a typst file or md file so that I can reference the feedback would be interesting I think ?

0832 - Not sure what the underline sentences or words are supposed to mean ? Otherwise it's often the obscurity of the codebase that makes what I say not that clear. Or more likely I didn't clarify it enough ! I like the suggeested structure with explanation first and the how it's implemented. I will lose less people ^^

1008 - A bit stressed about the presentation ...

1124 - It went well !


1244 - Getting back to it

1305 - Simple doc for priority done, i feel like having images with exemples would be interesting even if with Gimp or another simple software to draw the features 

1600 - Finished writing the planning

== 04.06

0800 - Changed the planning a bit but it took a long time and I hate doing gantt chart Urrrgh

0900 - Sent the email

0922 - Created a repo in the ICNML copy project on ESC gitlab with all the homemade deps 

0943 - Successfully installed docker on the dev server

1011 - Setup a github token to access to the icnml-dev repo and the icnml repo and copied them on the 

1018 - Downloading rsync so that I can upload the db dump on the remote server and even if connection is lost it can retake from where it left. It will take ~9h 

== 09.06

Sick day

== 12.06

1138 - Task for today is to deploy the application as if it were in prod. The db needs to be copied into the /data disk

1139 - First I wanna check that the db is what it's supposed to be by mounting it on a docker on my machine ... 

1207 - The pgrestore command takes a very long time which is kinda expected...

1247 - It's not working as expected as the restore needs another 471Go of storage and I can't really afford that on my machine. I'll have to stream the restore to the /data on the dev server so we can test it on there !

1251 - Pushed the changes made on the dev machine where I changed the env variable to its own url 

1308 - Made it so that we can connect via HTTPS and realized that the WebAuthn will need to be reregister as the domain has changed

1337 - Launched the script to stream the restore so that there's only one file on my machine and the usable data in the dev machine

1356 - Tried to create a Python3 migration guide with Opus 4.8 and the result is quite astounding...

== 16.06

0730 - Getting back into it

0740 - Change need to be made in the dev machine as we now have a DNS record for the machine. Will install Caddy so that we can connect from the UNIL network and act as if this was prod

0806 - Working, connecting to the login page on my browser at the address https://esc-icnml-qs.unil.ch

0807 - Now streaming the dump into the live db on the ethernet cable 

0825 - Drop the db as it created the base table, and now streaming. The 500Go should be transferred in about 1h. Discovering caffeinate to make sure the Mac doesn't sleep ^^

0852 - I shouldn't have trusted the sysadmin and should have done it over the nigt :(( as it's taking quite a long time 

0907 - Might as well start upgrading from python2 to 3 MDmisc and other libraries if time allows 

0916 - Setup an environment so that I can call python3 and python2 (binaries are only available for Rosetta ... so had to do some magic tricks)

0918 - Need to pip freeze those requirements that are so empty ... 

1026 - The migration is smooth sailing

Qui attaquerait le système et pourquoi ? A la fin analyser ce qu'on a fait et qu'est-ce que ça a résolu!

1338 - Finished MDmisc, all tests pass but there are still stuff that has idiomatic Python2

1350 - Realised that it's not finished ... as the doctester is a bit of a smoke test and I need to check the other files as well

1520 - Finished first file of NIST. Will stop here for today

== 17.06

0733 - Getting back into it. Had to remove some stuff on the computer as the storage was filling up

0909 - When trying to run the NIST tests, the other modules are not on the path. The thing is that I keep encountering small problems that get added up and it's getting frustrating. How can someone code so badly ?

1003 - Ran the tests and encountering bytes/str issues 

1008 - Chose to transform at the IO/bytes boundary bytes into string so I don't have to change everythign. 114 tests passing, 46 failing

1029 - Ran into platfoirm problem as WSQ can only work on x_86 arch not arm

1036 - Will create a Dockerfile with platform amd so I can actually test with WSQ ?

1050 - That added some complexity but now the tests are FAIL and no more ERROR which means that the outptu mismatches

1105 - The except: pass swallow all the exceptions so it's hard to debug 

1117 - 1 last test with md5 drift because of 
Pillow transfo and I guess it's because of the version so will ignore it

1323 - Okayyy, I think the migration of the libraries is done !

1346 - Made all the PRs so that it's clean in the project

1419 - Starting the work on the webapp

1509 - Crypto has the same behavior in Py2 to Py3 and all the import problems

1602 - Logging page running with Py3, let's gooooo

== 18.06

0855 - Getting back into it 

0913 - Wrote docs on the changes for Python3 Migration. Have to focus on webauthn upgrade now... But that's big big and I don't have a fidokey :(( so we'll see how we can handle that ? 

0957 - the webauthn migration is not an easy task

1003 - Templates are using Jinja which exposes the methods of dict and thus iteritems so had to recheck all templates 

1102 - Testing all the changes on the dev server with old data 

1324 - Debugged some encoding problems at the NIST load function anbde basically turned everything into latin-1 to have a 1:1 byte char ratio and it works yaaaaay
So I'm pretty sure the dev server is working well on prod data and there's just the connection to a smtp server to have a parity in terms of features.

1335 - The smtpauth is not smth I can really work with, or maybe I will check in prod the value of the password and paste it here ? It's worth a try atleast

1446 - Confirmed that the new user path is working correctly with the right email sent with the correct link so I think the miration is over ! Yay

== 19.06

0742 - Getting back into it

0802 - Getting new info on the message sent by Sylvain

0807 - 1 real question is should the operation be AFIS-invisible

0826 - Doing a quick fix to paginate the trainre search page cause it was overloading the gevent thread with the added str to PIL object conversion in Py3


Réu Christophe: DEMANDE si la stégano doit être invisible aux AFIS et à combien de personnes les images sont généralement partagées.

0921 - Debug the absence of the download button

1109 - Went into a sidetrack for a colleague, it's haaard to do the state of the art I don't want to :((

1310 - Skimming through articles, updating the bibliography, finding some interesting stuff about Tardos

1530 - Finsished establishing a bib that I will read next week

== 22.06

0830 - Getting back into it

0919 - Reading the history of electronic watermarking to start with context

0942 - Very cool and interesting to have a context for watermarking and defining what I want for ICNML -> transaction tracking (or fingerprinting). Interesting with spread-spectrum and gonna read the chapter about it from the book of the author !

1010 - The Approches for Robust Watermarking chapter is very very interesting so that I can see all strategies that were implemented. I'd like to find and read more up-to-date papers though. I saw 

1110 - Introduction of Collusion-secure Fingerprinting for Digital Data was quite intense but it's referenced by lots of paper and it explains more clearly the problem of collision and the MArking Assumption.

1111 - What about knowing when the file has been tampered with ? It's out of scope but Rabin algo on Wikipedia could be interesting. Nope Rabin is integrity of data while Tardos is traitor tracing and that's what I want

1120 - Getting to read the Optimal Probabilistic Fingerprint Codes. It says optimal, it sounds pretty good to my ears

1224 - Coming back from the break and continuing reading the 

1309 - I'm a bit lost with this paper. It's very tough and mathematical. It's interesting for me, but good lord it's hard to read !

1418 - Going through other articles to understand better the embedding layer of the bits. 

1444 - Read intro of Optimal symmetric Tardos traitor tracing schemes. IT's basically an optimized version of Tardos and I feel like I begin to understand better and better.

1503 - Reading short paper on biometric data

1514 - Not very very interesting except for the fact that's it's biometric data 

1523 - Reading another article about asymmetric fingerprinting scheme based on Tardos

1525 - Reading the abstract Tardos Codes are a state-of-the-art for collusion-resistant fingerprinting codes but the problem of an untrustworthy provider is not ours as there is only one, the server.

1534 - Looking at the Tardos implementation. We need a vector when we apply the fingerprinting and we need to know how many users are gonna access it... We don't really have that in ICNML. Is that a requirement that would make things far worse if I don't, or I initialize a vector for N=100 users and then reference it when I have to ? 

== 23.06

0745 - Reading An Optimized Hybrid Algorithm for Blind Watermarking Scheme Using Singular Value Decomposition in RDWT-DCT Domain 

0800 - They are a lot of grammatical errors which make me unconfident about the paper and I discard it

0805 - Reading DWT Collusion Resitant Video Watermarking Using Tardos Family Codes which seems to be quite in the scope of what I want to do 

0828 - This seems like the Graal. Woaaw I begin to understand aékjfhgasjdhf happy

0853 - Found a follow-up article which goes in more detail for a robust watermarking scheme using Tardos-Skoric codes from the same authors ! yaaaaay

1001 - Big thinking about actually whether or not we want collusion-resistant fingerprinting codes ? Have to make a message to my supervisor to understand better !

1024 - Well after the message is sent I'm a bit lost on what I could do now ? 

1134 - Read an interesting paper on Robust and Secure Watermarking if we move away from Tardos codes 

1211 - I tried to make sense of the different techniques and their implications but the field is so vast and I'm not sure I understand every parameters that will allow me to make a smart decision...

1336 - Reading more papers on on watermarking schemes that would be robust so I can advance without the feedback from my supervisor

1400 - Gonna write scripts to understand better and check with real values and data for a better argument 

1600 - Finished writing the tardos-simulation with an attack of JPEG compression quality and below 30% the bit error ratio is above 50% so it's not usable as the image is still very exploitable !

== 24.06 

0730 - Getting back into it

0740 - Confirming the results from yesterday. 

0813 - I want to have more hands-on experience and create more simulations to see and understand this Tardos Codes and the watermarking schemes. It's a bit hard but it's better than staying in the abstract without clear material feedbacks.

0929 - I'm realizing that the TIFF images are in GrayScale and we want to embed the fingerprint via watermarking and keep the image as a TIFF in GrayScale. Will that change smth ? Cause currently the only lib I found made me convert the TIFF to PNG to embed it...

1013 - With DWT-DCT-SVD pipeline it works quite okay except for the 20 quality which may come from SVD. I wanna test out the DWT-DCT pipeline without SVD and see the results on JPEG compression.

1106 - Comparing DWT-DCT and the previous one I see that SVD is quite important. I feel like I'm going into places and I want to refocus on reading papers and writing the state of the art cause it's necessary by now !

1118 - Can't find access to https://link.springer.com/chapter/10.1007/978-981-95-3616-0_22 which seemed quite interesting for me. Maybe I should focus on grayscale image watermarking

1133 - Found A sophisticated and provably grayscale image watermarking system
using DWT-SVD domain this article where they claim to be able to embed 8 bits per pixel with watermaring which seems quite huge. I will double-check when coming back from eating

1243 - Reading more about DWT based blind watermarking. The thing is that all these methods are quite well-known and could be inferred by an attacker ? Hmmm this is a side of the problem I didn't consider

1259 - Searching for comparison of watermarking scheme so I can choose one cause it's difficult being so lost

1312 - Trying out stuff in the test scripting. Not sure where this is leading but at least it's a bit more concrete than reading articles upon articles.

1322 - Reading paper on st-dm qim which looks promising as there wouldn't be any svd applied.

1337 - Well refactored the code to create new attacks and the results are terrible ... for rotation of 5deg everything is a miss nothing can be accused ... This feels like a bottleneck and the length of the codeword is definitely a part of this bottlneck

1343 - Back at being lost ...

1413 - Created a sync to conteract the rotation attack and the results are very good !

1507 - Results are good and now writing the state of the art.

1610 - Finsished the day

== 25.06

0745 - Getting back into it

0800 - Thinking and exchanging with friends on the message sent by my supervisor

0900 - Thinking about going back to Error Correcting Code like Reed-Solomon 

0905 - Need to reframe the SOTA 

1000 - I'm super lost, everything I do seems bad, I'm gonna go check the SOTA of friends 

1211 - Stopping writing the SOTA and taking a well-deserved break.

1315 - Getting back to SOTA

1406 - Finished the first draft ! Yaaay

1435 - Created and added a schema to demonstrate a pipeline with watermarking

1535 - Skimmed through litterature to find a good illustration for the synchronisation and foiund one

1610 - I think the state of the art is finished. Gonna put it aside and reread it tomorrow before sending it to my supervisor

== 26.06

0800 - Rereading the SOTA and thinking about the next steps

1000 - Searching for implementations to add to the SOTA in the bib

1040 - Proof-reading the SOTA 

1110 - Finished proof-reading the SOTA

1140 - Rewriting some part to be more explicit as the supervisor is not certain ECC are interesting in our setting

1320 - Taking the afternoon off cause the situation is a bit too stressful for me


== 29.06

0755 - Getting back into it 

0805 - As I wait for the feedback on the SOTA, I want to already work on the email workflow for downloading an image with a code sent to confirm the email inputed by the trainer and then each user can download the exercise folder by themselves. This will be linked to the Users button in the trainer list view and in the admin view as well.

0830 - Drafting the plan for the coding session of today 

0852 - It's a tad complicated as the architecture is really not great and I want the workflow to be clean and understabndable 

0857 - Getting more familiar with the good practice in Flask dev

0912 - It's quite minimal compared to Django for example. I will do a folder for this workflow and have all the relative files within it. Maybe views_internal/public would be a good idea too. I'd like to have a repository that talk with the DB, a service layer that handles the passing of data from the views to the repositoryx and then a HTML layer with only the view and rendering logic 

0935 - Starting coding with first a focus on the rand util functions and the redis config adding a share db to not bleed in the other workflows

0954 - Layed out the architecture for the work. I choose to do everything on one branch as I don't have any colleagues working with me.

1114 - Still coding

1154 - Wanna add a new user type trainee so we can track who has access to what

1336 - Little sender class done

1443 - Setting up the dev mail backend 

1511 - So everything works until the url for the landing which I haven't done yet. We're getting there slowly

1606 - I stop here and will continue tomorrow morning 

== 30.06

0755 - Getting back into it

0807 - Writing the landing page for the share folder feature

0850 - I feel like the code in the same ShareToken is not a very good idea in the end. It should be its own 

0924 - Confirmed it works until the download path ! Cool !

Intitulé à changer et donner les définitions. Avoir un processus plus générique dans l'image. Donner les définitions. Vraiment y'a bcp de définition. Définir le modèle d'attaque. Figure dans le SOTA plus générique. Identifiant -> Dans l'image -> partage -> retrouvé le fingerprinting. Le plus compliqué et le plus encourageant. Remettre le schéma pour faire en sorte d'avoir la retained approach. 

1322 - Finishing the download path so that the feature is ready and work 

1439 - Okay it works and it seems quite sound I'm happy happy ^^

1545 - Drafting the PR after some bugs 

== 01.07

0733 - Getting back into it

0740 - Finishing the PR 

0832 - Had to work on answering RTI questions + working a bit on the SEAL project 

0938 - Have to work on some test scripts to explore the different possibilities for the pipeline. And rewrite/work on the SOTA, which is a bit annoying right now ^^'

1035 - Created a test script to see if the idea of AESGCM + RS is interesting or not ?

1125 - Had to handle an emergency at work where the thunderstorm rained a bit too much and someone left the windows opened in another desk ^^'

1225 - Added the output of each attacks and embedding to see whether or not it's okay to add more noise into the image. And honestly you can see the noise but it doesn't feel very annoying compared to the original, it would be acceptable in my view. Have to check with Christophe whether or not it's acceptable.

1333 - Continuing the tests 

1352 - I feel like it's time to get back to the SOTA and be done with it...

1424 - Finished the terminology part 

1517 - I added a section on QIM as this seems quite important to me if we use it in the implementation.

1529 - Need to defined the attack model 

1640 - Finished defining the attack model 

== 02.07

0830 - Getting back into it

0912 - Tried some stuff on the test scripts but getting back into the SOTA so that it's finished and behind me.

0943 - Adding the watermarking with 

1009 - I will let the SOTA marinate for a bit and then keep on testing watermarking schemes 

1039 - Testing out Fable on the test scripts repository

1200 - It was very interesting and we made the schemes better with compression and added new attacks aswell

1310 - Getting back into it and rereading one last time the SOTA

1340 - Finished proof-reading the SOTA 

1409 - Thinking about the structure for the design and architecture document ? 

== 03.07

0800 - Getting back into it

0846 - Refactorign the test scripts files so I can understand better what I did. Everything lives a bit everywhere so it needs order.

1148 - Refactored the code so that I can run a compare with all the watermarking schemes created and have a csv to analyse the data later on.

1149 - Checking the automatic minutiae detector and the difference between the OG image and the watermarked one.

1515 - Made it work and now I have a nice CSV file for comparisons

== 06.07

0730 - Getting back into it

0736 - Wanna change and start working on the quality feature so that I can check and estimate how much time I have left for this thesis. I estimated it would be the longest task in the UX part so wanna work on it quite a bit.

0754 - Exploring the existing shiny app Christophe made with OpenLQM and ILFQM

0839 - So OpenLQM is a free software given by NIST. It has realeases on Github and one for debian distro. I'm thinking of going for a microservice where we can send images to on the Docker Network. I feel like it's not vulnerable to do it that way. Otherwise I would have to change my base image. Generation of heatmap could act like thumbnails probably or in the db ? That's a bit unclear for now. The sorting could be on the metrics which will be in the db for sure that makes sense.

0928 - I'm not too sure it's a good idea the microservice ? It feels a bit too complicated as I realized OpenLQM CLI does not expose a command to get the heatmap which we'll need after getting the metrics ... 0

0948 - Okay so no building the thingie from source is not a possibility according to the dev as it takes about 30min for all the dependencies to download... And I can't change my bookworm image as it requires Python3.12 and I m igrated to 3.11 ... Soooo back to the first solution 

1011 - Okay the service is running and the endpoints are working as expected ! This looks like a good victory ^^ I'm happy 

1040 - Working on the integration with icnml !

1233 - Keep working on the integration with schema def done and now lqm utils

1303 - The lqm utils file is done and I now have to test it out and see whether or not it works !

1449 - Had some problems but now I get all the info I need except the heatmap that's all black ?

1458 - Found out the reason as all pixels have a value from 0-4 

1558 - Okay it's quite difficult cause I never tested the submission workflow and it's difficult as there are some bugs left over from the migration to Python3 ... 

1621 - Okay confirmed that the mark has a quality score and that it works ! Pfiouuuu I'm commiting the changes for the submission and stuff in another branch 

1640 - Gonna work on the Watermarking tomorrow so that I can advance on this part. I need to be very knowledgeable about the algorithm used !

== 07.07

0750 - Getting back into it

0841 - Had to work on the SEAL project a bit to be sure everything runs smoothly before the 

0843 - I will try to finish the OpenLQM feature today so that I can go back to the 

0943 - Confirmed the creation of the colorised heatmap with a dedicated endpoint. Added a TIFF mark target and the heatmap created well. I did follow the same pattern of storing within the db the heatmap directly in b64. I wonder if I should go back on that ? As the db is already verrrrry big and that would only make it bigger especially if we create the files for every stored mark ?

0955 - I'm changing everything to bytes so that it's not too much overhead and we're following good practices when storing images in a db

1004 - It's done and now I feel a bit better ^^

1047 - Okay, I chose veridis colour palette so I can check if the colors are good or not (colorblind friendly). It looks okay and the sorting works. Now I have to check if it works on the dev server

1109 - Just launched the migration script ! Let's hope I don't overbloat the db with these heatmaps as they're 6074 marks ^^'

1123 - According to my estimations, there's about 4.5 hours left until all images have a heatmap ! Then the feature will be finished and over, yay!

1259 - Working a bit for the project SEAL

1423 - Finished creating the PR. I'm taking a small break waiting for the end of the backfill !

1458 - I'm waiting for the backfill script to run so I can check how well it ran on the dev server.

1542 - Well just implemented the search by username so it's going better than expected ^^ And I just won 3 days of work 

1556 - Finished the PR. That was quite easy ^^

1616 - Still waiting for the backfill to finish


1700 - Going back home

== 08.07

0735 - Fixing \_load_encrypted so that it returns None when resolution is outside so that the migration script is faster 

0745 - Relaunching the script so that we can see it end ! And put that behind us ^^

0817 - Just merged the searcheable by username in the marks 

0819 - I hesistate on doing a new UX feature or advancing on the watermarking 

0849 - Coding the feature for soft-deletion by trainer of their folder and hard/restore action by admin with distinctive 

0933 - Okay, the logic for soft deletion from trainer side is working and hard delete as well from admin side ! Now onto the delete image within a folder via a button !

1012 - Created the PR for the deletion buttons

1015 - Had a mail from Christophe for the quality feature where he wants more metrics and a better granular search ... That's gonna be a bit harder and maybe I will have to add some columns to the table ^^

1407 - Been trying to do the update but the backfill script keep failing because of some docker cache build image or other.

1414 - Found a bug in the UPSERT query ... aie aie aie, Claude found it and corrected it

1424 - Lauchned the script from the container so even if my SSH session is out it keeps continuing.

1451 - Adding the sorting buttons as requested by Christophe to see how it is with both asc and desc order with all lqm metrics 

1502 - Chose a dropdown menu and it feels pretty neat as the metric of interest is what is showing on the card 

1536 - Okay it works quite well on the remote dev server with the prod data so I'm happy happy.

== 10.07

0830 - Getting back into it 

0835 - Checking the state on the dev server with prod data... It's great !

0841 - Wanna make the Dockerfile more maintainable and not too download dependent.

0900 - Finished by pinning the vendor stb_image_write and better linkage of cpp 

0906 - Realized that the images are sorted by page but not inside the page, wanna fix that

0924 - Pinpointed the bug and fixed it !

0930 - Merged the PR with the delete actions buttons

0932 - Creating the PR for the new feature of adding all LQM metrics within the db and the search per metric and asc/desc

0945 - Finished writing the PR for the feature of all 13 OpenLQM metrics

0943 - Fuck, the version of ICNML is not the last one... I need to check what were the changes just like the Add selected exemplar or Add tenprints when clicking on a mark... Urrrgh so annoying...

1028 - Just analysing takes quite a lot of time ...

1056 - There's unfortunately quite a lot of changes that I will need to port to my version .... urrrrgh that's soooo annoying and so unlogical. I really never wanna work with this guy in my entire life ... I'll take a break, I need it...

1257 - Okay I ran away enough and now I have to get back to it and fix that

1319 - Merged the OpenLQM extension and created a branch where I will do all the edits, all the commits were lost

1333 - I don't want to do this .................

1356 - Finished the first on 6 commits to port ...

1604 - Let's check on the dev server if everything works well 

== 13.07

0800 - Getting back into it

0801 - Thinking about a UI to upload leaked image and choose the corresponding image so that resync can work ? + Extraction of the thingie. Maybe this should come after I created the watermarking pipeline ? Don't know I'm a bit lost ^^'

0807 - First problem there's nothing logging and the website is not accessible ... 

0817 - It's strange and I think the error might come from the firewall or the Caddyfile ? 

0829 - I can reach it from safari but not from firefox since the last update ? What the hell 

0906 - Abandonning the firefox fix and continuing with Safari but now I have to tell the browser to accept passkeys from my password manager 

1042 - Had a super long talk with my collleague about the maintainability of the icnml app for the future especially using my version for the prod. Now have to send an email to Christophe and explains everything that's going on ...  So many admins Urrrgh

1052 - Email sent, now back to the work ^^'

1123 - Relaunching some tests on images with full resolution from the prod server without the tattooing to see the exact behaviour we will have and then check whether I go on the UI or the implementation of the watermarking. I want a bit more data for choosing the watermarking scheme !

1216 - Very long scripts I feel like the morning was harder than expected :((

1222 - Saw that the step parameter needed some tweaking and made a quick script to launch the compare on each image in the assets folder on 12 images and now going to eat hoping it will be over when I come back 

1305 - The script is still ongoing so I will think about the architecture for integrating the watermark scheme we choose in the end.

1329 - Created the plan for integrating the Watermarking scheme to the app ! But then I need to merge the secure folder download first !

1339 - And it has lots of conflicts urrrrgh. That's normal but urrrrgh hate resolving git conflicts 

1355 - The exercises.html is annoying to merge ... 

1403 - Finished merging ! It was a bit complicated ^^

1406 - Okay, so now I have everything in place to add the watermarking package to the app as smth 

1412 - Well no, cause I haven't applied the migration for this new feature ... urrrgh this is a lot in fact should have done the merge earlier 

1414 - Gonna work on making it more maintainable 

1441 - Done, now check that it works. It does but it writes Network error even though it downloaded correctly and the name is generic not the name of the folder in ICNML so I have to fix that and then end the day

1556 - Created the PR for the UX improvements and now the data for comparing the 

1605 - Committing the changes in test-scripts

1611 - Made commits clean for test scripts !

1619 - Thinking about how I could use the data the most effectivly possible with some images next to it ? 

1630 - I think I'm gonna leave it here... and start back tomorrow

1638 - Okay, I'm stopping now cause I'm a bit tired 

== 14.07

0700 - Getting back into it

0715 - Reflecting on the script made yesterday and wanting to create smth better. With refactoring the existing one and making PSNR, SSIM and minutiae retention plots. Having the RS-margin apparent would be interesting to further justify its use. Maybe I could also create a 

0749 - Created with Fable nice plots with explicit data. Now I can see that the suggested implementation in libraries are a bit meeh. I want to remove the two and have 11 images for them. I will download more and more images to build a nice corpus of images (marks, but also tenprints) so I can argue to use the watermark at every point in the application ? 

0756 - Still have to go on the branch where the download is possible. The thing is that the download button is here in the UI so yeah. I have to think about it a bit more whether I allow the admin to download or not ? 

0810 - Created a corpus a bit randomly and discovered color images, PNG images and very very large images as well. Relaunched the script that skips the already created CSV and removing the two libraries watermarking schemes as they were taking forever and their output is not so good. Let's see what the plots look like afterwards !

0827 - It's taking its time but still less time than before ! 

0853 - Thinking about the fact that having a timestamp would be interesting for who accesses the folders ? As I reused the previously created exercise_trainee_list table it didn't have a created_at timestamp field. And I'm thinking about encrypting the email sent to ? So that the db doesn't have plain email ? Is it really interesting maybe not to be fair ?

0901 - I now have all the data I can work with and graphs that are quite informative. I now need visual comparison of the embedded images and the original data, so I can also compare through that ! 

0908 - Okay Fable is really amazing and the output is exactly what I wanted... It's scary 

0932 - I think the gain variant of stdm is quite interesting even though it's not the most robust one as the SSIM is the highest ! I'm a bit torn that Christophe is in the US on holidays when I'm faced with the choice of the algorithm and all the data to support the choice as well ^^'

0936 - I have to remember to rewrite the README of the icnml-dev as it's not up to date anymore

0951 - I have lost all motivations I wanna be on holidays ... Urrrrgh 

1002 - Okay, the comparison of the images is very good. I'm quite happy with it.

1009 - Checking everything is working nice in the dev remote server

1029 - FIXME need to fix the bug when clicking on Asc/Desc button for upload order and the app freezes ... That's not the behavior expected ! Needs to be corrected pronto ! maybe right after the meeting with the supervisor. If he shows up ^^' 

1114 - Okay pfiouu not easy all that, not easy ...

1229 - I'm a bit lost on what to do as I'm waiting for scripts to run 

1329 - working on forensic usual transform attacks so that I can measure the schemes against those as well

1445 - Finished rerunning the script and then working on the data and plots

1640 - Choosing the gain or block variant after the careful analysis of the plots and images 

== 15.07

0700 - Getting back into it 

0716 - Looking at the diagrams I'm still a bit unsure about the scheme to choose. The forensic attack battery is the one I created and I don't know if it makes sense in the work ? Grrrr I wish I could contact someone easily about that ? 

0717 -  Anyway, it's gonna be one of the stdm scheme and to be more precise either the block or gain variant... 

0734 - Merging the lost commit branch into main... It's taking some time as there are conflicts ^^'

0742 - Conflicts are resolved

0750 - Coding the watermark feature.

0828 - Who in the world names one of his internal package uuid ? urrrrgh cvan't import it easily it's just friction upon friction the dev on this codebase

0840 - Hmm it seems to be working and it was my IDE being mislead. I hate this old dev who doesn't even know smth that obvious ...

0854 - Have to create a new table in the DB for the nonce. 

0925 - It's a bit difficult as I have to make sure that the key generated randomly and in a non-deterministic way have to be used inside a deterministic algo as seed to spread the bits in a random way... Urrrgh complicated.

1011 - Put it aside and worked on the codec to encode decode with RS and AESGCM 

1121 - Working on the service layer (orchestration) with the record of the watermarking event even when the watermarking failed

1203 - Implementing the resync. Well after the break

1302 - Had a 1 hour nap, that felt very very good 

1357 - Handling the problem with pianos and icnml prod down ... 

1427 - Cookie_path was mindtct and the binary is gone ... I have some very big feelings of hate for that person...

1545 - well finally finished and it took quite a while on my TB :(( A bit annoying

1627 - Now working on what Christophe asked me to do. Script for downloading the tenprint back cards 

1731 - Finished for the day

== 16.07

0830 - Getting back into it and preparing the file transfer of the palm images

0842 - Well good news a friend invited me to Paléo ! yay

0847 - Just realized that I haven't tested the attack by zipping ? Is it lossless ? I'm not so sure

0918 - Wanna try out a new rsync scheme that looks promising SIFT with MAGSAC. 

0920 - Rerunning the compare_all script and we shall see what's the output after finishing working on the watermarking ^^'

0928 - Integrating the watermark into the secure_download pipeline.

0939 - I'm thinking of a fallback to the old method if there's an exception when watermarking the image like it's too small. I feel like that's smart rather than aborting completly the downloading. 

1142 - Been implementing the verification for the watermark and it's going okay. A bit long but okay.

1413 - Having trouble with opencv :(( Always complicated with that package

1437 - Pushed all the commits and everything works ! Yay ! Wanna sleep now...

1447 - Adding UUID on top of the card in folder for admins so they can easily see the uuid of the original for resync

1530 - Finished ! Urrrgh so so soooo tiring though

== 17.07 

Feeling queasy 

Implemented the WAtermark verify when I could during the day + writing the watermark-implementation chapter + ux-improvements chapters

== 20.07

0800 - Getting back into it

0916 - Reread the watermark-implemenation chapter and have to redo some stuff and add a discussion on the graphs generated as they are quite awesome and telling.

0931 - Both chapters are honestly quite good. I need to add the images and screenshots so that readers can easily see what I'm talking about. Perhaps quite small and in column so that it's quite interesting but doesn't take too musch space. Like dialog confirmation ^^ But the service is down so have to go to IT service.

1010 - Okay it's resolved

1016 - Discovered a new bug with toggle view. Honestly let's just remove the button...

1020 - There's also a bug with the delete button ? WTF ? 

1142 - Added the plots in the watermark-implementaion + screenshots for ux-improvements. Now rewording the whole thesis and let's see if we can finish this today. That would be sooooo cool...

1220 - Rewriting the auth document as it's the most symptomatic of the last version

1354 - I think I have a very interesting version and I found the tone I wanna give to the thesis.

1600 - Rewrote a lot of chapters

== 21.07 

0820 - Getting back into it

0940 - Rewrote two chapters and they read so well and look so good I'm happy happy

Write the résumé publiable au passé et en français et en anglais pour être tranquille

1115 - Finished meeting and it went quite well hehe. Happy happy

1405 - Wrote a loooot and also finished the python3 migration doc

1608 - Just finished conclusion + intro ... I have some tears in my eyes. It's the wind ! It's the wiiiind ! 

== 22.07

0800 - Stressed and reviewing the feedback all day and then the poster adfkajhflkhasldkfhsldkfhlaksdjhf

1440 - I think I've finished implementing feedback urrjkhaflkgjhakdlfhgdg
