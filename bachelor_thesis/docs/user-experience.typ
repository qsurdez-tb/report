#import "@local/heig-vd-report:1.1.0": *
#show: conf.with(
  title: [User Experience Features ICNML],
  authors: (
    (
      name: "Quentin Surdez",
      affiliation: "ISCL, HEIG-VD",
      email: "quentin.surdez@heig-vd.ch",
    )
  ),
  date: "2026-06-02",
)

= Introduction

This document presents the different user experiences that need to be added to ICNML with their order of priority. 1 being the highest priority, 7 being the lowest. It will be used as a guideline to implement features and create the planning.

== Features and Priorities

#figure(
  table(
      columns: (auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left),
      table.header[Priority][Feature],
      [1], [Add a delete action button on the `Trainer` folder],
      [2], [Add a delete action button on the images in a `Trainer` folder],
      [3], [When searching as a `Trainer`, allow filtering by donor (username)],
      [4], [Add the `openLQM` quality detection algorithm on traces and sort by quality the traces],
      [5], [Add a toggable superposition of the quality heatmap produced by the algo on the traces],
      [6], [Add the capacity for a `Trainer` to choose amongst existing exemplars for a single trace],
      [7], [Add for the `Admin` a table with all users + capacity for an admin to remove a user],
    ),
    caption: [Features with their associated priority]
)

== Exemples

Here's a few mockups for how the feature will be implemented. Style is not the focus but functionality.

#figure(
  image("assets/delete-button-trainer-folder.drawio.png"),
  caption: [Add a button to delete a folder]
)

#figure(
  image("assets/delete-button-trainer-traces.drawio.png"),
  caption: [Add a button to delete an image from a folder]
)

#figure(
  image("assets/search-filter-donor.drawio.png"),
  caption: [Search traces by donor]
)

#figure(
  image("assets/mark-change-exemplar.drawio.png"),
  caption: [Add button to change examplar for a mark]
)
