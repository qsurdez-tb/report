#import "../macros.typ": note, concept

= Application Overview <application-overview>

#concept[
  ICNML is used through a web interface, and the quickest way to grasp what the platform does is to see what its users see. This chapter is a guided tour, mostly from the Administrator's viewpoint since that role reaches every screen, of the main pages: how one logs in, how a donor's biometric data is organised, and where the interface still shows rough edges. It closes with an honest read of the interface's strengths and weaknesses.
]

== The first view: logging in

Access to ICNML is not open. The platform is reachable on the web, but every account must be approved by an administrator before it can be used, and in production a second authentication factor is mandatory (@roles-and-permissions). The login page (@fig-login) is deliberately minimal: a username and password, links to reset a password or request an account, and the running version shown as a git commit hash and timestamp. A visitor without an account uses the request form (@fig-request-account), giving their name, e-mail, and the role they want, chosen from the subset of roles open to public request. An administrator then approves or rejects the request.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 10pt,
  [#figure(image("../assets/screenshots/00-login.png", width: 100%), caption: [Login page.]) <fig-login>],
  [#figure(image("../assets/screenshots/01-request-account.png", width: 100%), caption: [Request-an-account form.]) <fig-request-account>],
)

== The Administrator's interface

The Administrator reaches every screen, so their view is the most complete. It is organised around a persistent left-hand navigation menu, Submissions, Tables, Trainer folders, AFIS assign, CNM list, PiAnoS, and New users, with a header bar carrying the current username and links to TOTP setup, security keys, and logout.

=== Submissions: a donor's data

The home page is the submissions list, a grid of donor cards each carrying the donor's username and a _View_ button, with warning indicators on donors that may have incomplete data (@fig-submissions-list). Selecting a donor opens its detail page (@fig-donor-detail), which gathers the five data categories held for that donor, General Pattern, Tenprints, Targets, Mark targets, and Mark incidentals, above the donor's UUID and submitter.

#figure(image("../assets/screenshots/admin/01-home-page-admin.png", width: 100%), caption: [Submissions grid (Administrator home).]) <fig-submissions-list>

#figure(image("../assets/screenshots/admin/02-donor-page-admin.png", width: 100%), caption: [Donor detail, the five data categories.]) <fig-donor-detail>

/ General pattern : The general-pattern view shows the ten fingerprint classifications, one per finger, each labelled with its pattern type. Any classification can be edited through a modal that presents every pattern type as a selectable icon (@fig-donor-gp, @fig-donor-gp-update).

#figure(image("../assets/screenshots/admin/03-donor-gp-admin.png", width: 100%), caption: [General-pattern view.]) <fig-donor-gp>

#figure(image("../assets/screenshots/admin/04-donor-gp-update-admin.png", width: 66%), caption: [Pattern-type edit modal.]) <fig-donor-gp-update>

/ Tenprints : The tenprint list shows every reference card uploaded for the donor. Selecting one displays the card with its segments annotated (which finger sits where) alongside metadata and controls to update or delete segments, download, or remove the card (@fig-tenprint-list, @fig-donor-tenprint-detail). A separate segments list shows each segment cropped and labelled (@fig-donor-tenprint-segment).

#figure(image("../assets/screenshots/admin/05-donor-tenprints-admin.png", width: 100%), caption: [Tenprint list.]) <fig-tenprint-list>

#figure(image("../assets/screenshots/admin/06-donor-tenprint-detail-admin.png", width: 100%), caption: [Tenprint detail with segments and metadata.]) <fig-donor-tenprint-detail>

#figure(image("../assets/screenshots/admin/06.05-donor-tenprint-segment-list-admin.png", width: 70%), caption: [Segment list from a tenprint.]) <fig-donor-tenprint-segment>

/ Targets : The targets view shows the ten rolled reference prints, one per finger. Opening one reveals four groups of linked images: target annotations, Close Non-Match results, references, and marks (@fig-target, @fig-target-detail).

#figure(image("../assets/screenshots/admin/07-donor-target-admin.png", width: 100%), caption: [Targets view.]) <fig-target>

#figure(image("../assets/screenshots/admin/08-donor-target-detail-admin.png", width: 80%), caption: [Images linked to a target.]) <fig-target-detail>

/ Marks : Marks come in two subcategories, target and incidental, sharing the same layout: a searchable grid of images (@fig-marks-target, @fig-marks-incidental). Opening a mark shows its metadata with six editable fields (Detection, Surface, Activity, Distortion, Location, Notes) and buttons to download or delete it (@fig-marks-detail).

#grid(
  columns: (1fr, 1fr),
  column-gutter: 10pt,
  [#figure(image("../assets/screenshots/admin/09-donor-mark-targets-admin.png", width: 100%), caption: [Target marks grid.]) <fig-marks-target>],
  [#figure(image("../assets/screenshots/admin/11-donor-mark-incidental-admin.png", width: 100%), caption: [Incidental marks grid.]) <fig-marks-incidental>],
)

#figure(image("../assets/screenshots/admin/12-donor-mark-incidental-detail-admin.png", width: 62%), caption: [Mark detail with editable fields.]) <fig-marks-detail>

=== Tables

The tables page is a per-donor summary: one row per donor showing its UUID and numeric counters (latent targets, latent incidentals, finger and palm tenprints, segments, targets), a quick way to gauge each donor's state (@fig-tables).

#figure(image("../assets/screenshots/admin/13-tables-admin.png", width: 100%), caption: [Per-donor summary table.]) <fig-tables>

=== Trainer folders

This page lists the exercise folders created by trainers, each with its name, creation time, UUID, mark count, and author, plus Rename, Show, Users, and Download actions (@fig-trainer-folders). The Show action displays the folder's images, which are not clickable (@fig-trainer-folders-show).

#figure(image("../assets/screenshots/admin/14-trainer-folders-admin.png", width: 100%), caption: [Trainer folders list.]) <fig-trainer-folders>

#figure(image("../assets/screenshots/admin/15-trainer-folder-show-admin.png", width: 70%), caption: [Contents of a trainer folder.]) <fig-trainer-folders-show>

#note[In the version analysed, the Users button did nothing and there was no way to delete a folder. Both gaps were addressed by the user-experience work of this thesis (@ux-improvements).]

=== AFIS assignment

The AFIS assignment page assigns targets to AFIS users in three steps: select users, select targets, generate assignments (@fig-afis-assign). Each step opens a modal pre-populated with structured records, and the resulting assignment can be edited (@fig-afis-assign-assignments).

#figure(image("../assets/screenshots/admin/16-afis-assign-admin.png", width: 100%), caption: [AFIS assignment steps.]) <fig-afis-assign>

#figure(image("../assets/screenshots/admin/19-afis-assign-assignment.png", width: 66%), caption: [Assignment edit modal.]) <fig-afis-assign-assignments>

=== CNM list

The Close Non-Match list gathers every CNM image in the library, each labelled with its UUID and a status colour: blue for an incidental mark, red for a target mark, grey for no mark value (@fig-cnm-list). Opening one shows the CNM documentation form above, the linked tenprint cards and the AFIS screenshot with minutiae (@fig-cnm-detail).

#figure(image("../assets/screenshots/admin/20-cnm-list-admin.png", width: 100%), caption: [Close Non-Match list.]) <fig-cnm-list>

#figure(image("../assets/screenshots/admin/21-cnm-detail-admin.png", width: 100%), caption: [Close Non-Match detail.]) <fig-cnm-detail>

=== PiAnoS

*PiAnoS* (Picture Annotation System) is a separate web tool, developed at the School of Forensic Science of the University of Lausanne, for viewing fingermarks and annotating their minutiae. This page is meant to bridge ICNML and a PiAnoS instance, offering two buttons, _Copy all accounts to PiAnoS_ and _Open PiAnoS_ (@fig-pianos). Both return a 502 Gateway error on the production deployment, so the integration is effectively inactive.

#figure(image("../assets/screenshots/admin/22-pianos-admin.png", width: 62%), caption: [The (inactive) PiAnoS bridge page.]) <fig-pianos>

=== New users and security keys

The new-users page is where an administrator validates or rejects account requests for the publicly requestable roles (@fig-new-users). The security-keys page lets a user register or remove WebAuthn hardware keys (@fig-security-keys).

#figure(image("../assets/screenshots/admin/23-new-users-admin.png", width: 100%), caption: [Account-request management.]) <fig-new-users>

#figure(image("../assets/screenshots/admin/24-security-keys-admin.png", width: 66%), caption: [Security-key management.]) <fig-security-keys>

=== Marks search to add to trainer folder

The marks search page is where a trainer or an administrator can browse the mark library and choose which ones to add to its exercise folder. There's currently no way to sort the images by any metrics which is resolved by the user-experience work of this thesis (@ux-improvements).

#figure(image("../assets/screenshots/admin/25-marks-search.png", width: 100%), caption: [Marks searching page.]) <fig-marks-search>

== User interface: strengths and weaknesses

The interface has real strengths. A single persistent navigation menu keeps the whole platform reachable, the card-and-grid layouts make a donor's many data categories easy to scan, search bars are provided where collections grow large, and the running version is shown openly, which helps support and debugging.

The weaknesses are mostly unfinished edges rather than design faults. Several controls are inert or do not persist: the Users button on trainer folders did nothing, and edits made to the new-users and AFIS records were not saved back to the database. The PiAnoS bridge returns a gateway error in production. Folder deletion was missing entirely, images in a folder are not clickable, and several status indicators (card warnings, the coloured CNM badges) are shown without an in-interface explanation of what they mean. A number of these gaps, folder deletion, safe removal, quality-aware search and secure sharing, were closed by the functional-improvement work of this thesis (@ux-improvements). The remainder are concrete, well-defined items for future work.
