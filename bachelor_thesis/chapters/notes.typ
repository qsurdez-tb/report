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

