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
The donor's uuid and the submitter username are displayed below.

#figure(
  image(
    "../assets/screenshots/admin/02-donor-page-admin.png",
    width: 80%
  ),
  caption: [Donor detail page]
) <fig-donor-detail>