= Application overview <application-overview>

This chapoter is an overview of the ICNML application from the point of view of different type of accounts. 

== Login

The Login page (@fig-login) is minimal with a username and password field. It contains the link to request a password reset as well as the link tho request an account. It displays the version with the git commit hash as well as the timestamp of the commit.

#figure(
  image(
    "../assets/screenshots/00-login.png"
  ),
  caption: [Login page]
) <fig-login>

== Request an account

The request an account page (@fig-request-account) is where a user without an account can request to the Administrator an account for the ICNML application. The form needs the first name, last name, email and what kind of account the user would like to be given. The selection is a subset of all the accounts of the application, see @roles-and-permissions.

#figure(
  image(
    "../assets/screenshots/01-request-account.png"
  ),
  caption: [Request an account page]
) <fig-request-account>

== Administrator 

First a focus on what an Administrator sees. The interface is organized around a persistent left-hand navigation menu with eight section: Submissions, Tables, Trainer folders, AFIS assign, CNM list, PiAnoS and New users. The header bar display the current username and has links to TOTP update, security keys and logout.


=== Submissions

The home page for an Administrator is the submissions list. It's displayed as a grid of donor cards (@fig-submissions-list). Each card has the donor username as title and a _View_ button. Warning indicators flag donors that may have incomplete or pending data. // TODO check in code

#figure(
  image(
    "../assets/screenshots/admin/01-home-page-admin.png", 
    width: 80%
    ),
    caption: [Administrator home page, submissions grid]
) <fig-submissions-list>

Selecting a donor opens its detail page (@fig-donor-detail), which presents the five data categories associated with that donor: General Pattern, Tenprint(s), Target(s), Mark(s) target and Mark(s) incidental. Green checkmarks indicate something I'm not sure of yet. // TODO check in code 
The donor's username is displayed above. The donor's uuid and the submitter username are displayed below.

#figure(
  image(
    "../assets/screenshots/admin/02-donor-page-admin.png",
    width: 80%
  ),
  caption: [Donor detail page]
) <fig-donor-detail>

==== General Pattern

The general pattern view (@fig-donor-gp) shows the ten fingerprint classificatios, one per finger, each labelled with its dedicated pattern type. The Administrator can edit any classification via a modal (@fig-donor-gp-update) that presents all possible pattern types as selectable icons.

#figure(
  image(
    "../assets/screenshots/admin/03-donor-gp-admin.png",
    width: 80%
  ),
  caption: [General pattern view]
) <fig-donor-gp>

#figure(
  image(
    "../assets/screenshots/admin/04-donor-gp-update-admin.png",
    width: 100%
  ),
  caption: [Modal to update the general pattern of a finger]
) <fig-donor-gp-update>

==== Tenprints

The tenprint list view (@fig-tenprint-list) displays all the tenprints uploaded for this specific donor.

#figure(
  image(
    "../assets/screenshots/admin/05-donor-tenprints-admin.png",
    width: 80%
  ),
  caption: [Tenprint list view]
) <fig-tenprint-list>

Selecting a tenprint displays the tenprint itself with all the segments (e.g. where the right thumb is, left ring, etc...) annotated on it (@fig-donor-tenprint-detail). On the right, a list of metadata for the image and different buttons to manage both the segments and the image. 

The admin can delete segments informations, update the segment informations, go to the segements list (@fig-donor-tenprint-segment), download the image or delete the tenprint card.

#figure(
  image(
    "../assets/screenshots/admin/06-donor-tenprint-detail-admin.png",
    width: 80%
  ),
  caption: [Tenprint detail view with segments and metadata]
) <fig-donor-tenprint-detail>

Clicking on the Go to segments list, displays the image within each segment with the name of the specfic segment.

#figure(
  image(
    "../assets/screenshots/admin/06.05-donor-tenprint-segment-list-admin.png",
    width: 100%
  ),
  caption: [Segment list from tenprint]
) <fig-donor-tenprint-segment>

==== Targets

The targets view (@fig-target) displays the ten rolled reference prints associated with the donor, one per finger, each labelled with the finger position. A badge is present to give info // TODO check what info specifically 

#figure(
  image(
    "../assets/screenshots/admin/07-donor-target-admin.png",
    width: 100%
  ),
  caption: [Targets view list]
) <fig-target>


Clicking on one of the target displays its detail page (@fig-target-detail). There are four groups of images linked to this target: Target annotations, Close Non-Match results, References, Marks. I'm not sure yet how it's orchestrated. // TODO check how it's all linked together

#figure(
  image(
    "../assets/screenshots/admin/08-donor-target-detail-admin.png",
    width: 100%
  ),
  caption: [Detail view of images linked to target]
) <fig-target-detail>

==== Marks

Marks are divided into two subcategories: Mark target and Mark incidental. The two pages share the functionalities. 
A grid to display all the images in one category with a search bar. Info badge are here to indicate something again // TODO check what in code
(@fig-marks-target, @fig-marks-incidental)

#figure(
  image(
    "../assets/screenshots/admin/09-donor-mark-targets-admin.png",
    width: 100%
  ),
  caption: [Target marks grid]
) <fig-marks-target>

#figure(
  image(
    "../assets/screenshots/admin/11-donor-mark-incidental-admin.png",
    width: 80%
  ),
  caption: [Incidental marks grid]
) <fig-marks-incidental>

Clicking on a mark, whether incidental or target, displays the detail view for this specific mark (@fig-marks-detail). The metadata of this image are displayed as well as six editable fields that are: Detection, Surface, Activity, Distortion, Location and Notes. Then we have two action buttons: Download image and Delete mark.

#figure(
  image(
    "../assets/screenshots/admin/12-donor-mark-incidental-detail-admin.png",
    width: 80%
  ),
  caption: [Detail view for marks]
) <fig-marks-detail>

=== Tables

The tables page is a view of the relevant information for each created donor. Each row
corresponds to a donor and displays its UUID with numerical counters: number of latent targets, number of latent incidental targets, number of tenprints for fingers and palms, number of segments and number of targets.
This view can be useful to have a quick overview of the donor's states.

#figure(
  image(
    "../assets/screenshots/admin/13-tables-admin.png",
    width: 80%
  ),
  caption: [Tables view]
) <fig-tables>

=== Trainer Folders

The trainer folders page displays a table of the created folder exercises created by trainers (@fig-trainer-folders). Each entry shows the name of the folder, the creation time, its UUID, the number of marks it contains and the which trainer created it. There is a list of action buttons: Rename, Show, Users, Dowload. The Users action button does not work in the current version of the application. There's no way to delete a previously created folder.

#figure(
  image(
    "../assets/screenshots/admin/14-trainer-folders-admin.png",
    width: 80%
  ),
  caption: [Trainer folders]
) <fig-trainer-folders>

==== Show

The Show action button displays the images that are within the exercise folder of interest
(@fig-trainer-folders-show). The images are not clickable. 

#figure(
  image(
    "../assets/screenshots/admin/15-trainer-folder-show-admin.png",
    width: 80%
  ),
  caption: [Show view of a trainer folder]
) <fig-trainer-folders-show>

=== AFIS assignment

The AFIS assignment page (@fig-afis-assign) supports assignment of targets to AFIS users. 
The workflow is still a mystery to me. // TODO ask Christophe about the workflow
There are three steps: select AFIS users, select targets, and generate assignments. // Maybe needs confirmation of the code !
Each stpe opens a modal pre-populated with structured data: the user list provides `id;username;email` records, the target list provides `uuid:donor_username;fpx;submitter_username` records and the resulting assignment format maps to `folder_uuid;type;username` which can be updated (@fig-afis-assign-assignments).

#figure(
  image(
    "../assets/screenshots/admin/16-afis-assign-admin.png",
    width: 80%
  ),
  caption: [AFIS assignment]
) <fig-afis-assign>

#figure(
  image(
    "../assets/screenshots/admin/19-afis-assign-assignment.png",
    width: 80%
  ),
  caption: [Resulting AFIS assignment update modal]
) <fig-afis-assign-assignments>

=== CNM list

The CNM list (@fig-cnm-list) displays all close non-match images in the library. Each image is labelled with its UUID and status: blue indicates an Incidental Mark, red indicates a Target mark and grey indicates No Mark Value. 
I have to discuss with the client for the meaning of these indicators !

#figure(
  image(
    "../assets/screenshots/admin/20-cnm-list-admin.png"
  ),
  caption: [CNM list view]
) <fig-cnm-list>

Clicking on an image displasy the detail view for this object (@fig-cnm-detail). First there is the Close Non-Match upload form where the AFIS user can document the CNM. 

Below, we have the tenprint cards uploaded linked to this target as well as a screenshot from the AFIS system with the minutiae on the CNM and the uploaded finger from the tenprint.

#figure(
  image(
    "../assets/screenshots/admin/21-cnm-detail-admin.png"
  ),
  caption: [Detail view of CNM image]
) <fig-cnm-detail>

=== PiAnoS admin

This section of the application is to bridge the PiAnoS application and the ICNML application. 
This page offers two buttons: Copy all accounts to PiAnoS and Open PiAnoS. When the buttons are clicked on the production web applicaiton, a 502 Gateway error is displayed.

#figure(
  image(
    "../assets/screenshots/admin/22-pianos-admin.png"
  ),
  caption: [PiAnoS page]
) <fig-pianos>

=== New users

The new users page displays the account requests from users (@fig-new-users). This is where the Administrator will validate or reject the account request for a selected subset of the different roles in ICNML, see @roles-and-permissions.

The Administrator can validate via the Validate button and reject via the Reject button. The fields are editable, but when edited on the prod version, it was not propagated to the database.

#figure(
  image(
    "../assets/screenshots/admin/23-new-users-admin.png"
  ),
  caption: [New users page management]
) <fig-new-users>

=== Security keys

The security keys page (@fig-security-keys) is where the user can manage its passkeys. They can either add new ones or delete previoulsy existing ones.

#figure(
  image(
    "../assets/screenshots/admin/24-security-keys-admin.png"
  ),
  caption: [Security keys page management]
) <fig-security-keys>
