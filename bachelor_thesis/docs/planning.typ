#import "@local/heig-vd-report:1.1.0": *
#import "@preview/gantty:0.5.1": gantt
#show: conf.with(
  title: [Planning Focus points Development ICNML],
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

This document is a draft of the planning for the different development focus points for the bachelor thesis on ICNML. 

#v(5%)
#figure(
  gantt(yaml("planning-dev-gantt.yaml")),
  caption: [
    Inital planning for the project
  ])<gantt>
