= Application overview <application-overview>

This chapoter is an overview of the ICNML application from the point of view of different type of accounts. 

== Login

== Request an account

== Administrator 

First a focus on what an Administrator sees. The interface is organized around a persistent left-hand navigation menu with eight section: Submissions, Tables, Trainer folders, AFIS assign, CNM list, PiAnoS and New users. The header bar display the current username and has links to TOTP update, security keys and logout.


=== Submissions

The home page for an Administrator is the submissions list, displayed as a grid of donor cards (@fig-submissions-list). Each card is identified by a donor name and offers a _View_ button. Warning indicators flag donors that may have incomplete or pending data. // TODO check in code

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


Clicking on one of the target displays its detail page (@fig-target-detail). There are four groups of images linked to this target, Target annotations, Close Non-Match results, References, Marks. I'm not sure yet how it's orchestrated. // TODO check how it's all linked together

#figure(
  image(
    "../assets/screenshots/admin/08-donor-target-detail-admin.png",
    width: 100%
  ),
  caption: [Detail view of images linked to target]
) <fig-target-detail>