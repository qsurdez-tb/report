/*
|              ██         
| ████▄ ▄███▄ ▀██▀▀ ▄█▀█▄ 
| ██ ██ ██ ██  ██   ██▄█▀ 
| ██ ██ ▀███▀  ██   ▀█▄▄▄ 
| 
| Ce fichier est basé sur du code précédemment écrit par @DACC4 et @samuelroland.
| Dépot original: https://github.com/DACC4/HEIG-VD-typst-template-for-TB
| 
*/

#let alignedpage() = [
  #pagebreak(weak: true, to: "odd")
]

#let blankpage() = [
  #pagebreak()
  #pagebreak()
]

#let fullpage(body) = [
  #alignedpage()
  #body
  #pagebreak(weak: true)
]

#let is-first-page(page) = {
  let pageNumber = counter(page).get().first()
  pageNumber == 1
}

#let is-title-page(page) = {
  query(heading.where(level: 1)).any(it => it.location().page() == here().page())
}

#let hr(width: 100%) = {
  line(length: width, stroke: (thickness: 0.5pt))
}
#let hr_dotted(width: 100%) = {
  line(length: width, stroke: (thickness: 0.5pt, dash: ("dotted")))
}

#let currentH(level: 1)={
  let elems = query(selector(heading.where(level: level)).after(here()))

  if elems.len() != 0 and elems.first().location().page() == here().page() {
    return [#elems.first().body] 
  } else {
    elems = query(selector(heading.where(level: level)).before(here()))
    if elems.len() != 0 {
      return [#elems.last().body] 
    }
  }
  return ""
}

#let annex(body) = {
  set heading(numbering: "A", supplement: [Annexe])
  body
}

#let note(body) = block(
  fill: blue.lighten(70%),
  stroke: (left: 3pt + blue),
  inset: (x: 12pt, y: 8pt),
  radius: 3pt,
  width: 100%,
)[*Note:* #body]