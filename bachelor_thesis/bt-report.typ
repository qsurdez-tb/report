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

#import "macros.typ": *
#import "config.typ": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()

/*                        
                  ▄▄      
       ██         ██      
▄█▀▀▀ ▀██▀▀ ██ ██ ██ ▄█▀█▄
▀███▄  ██   ██▄██ ██ ██▄█▀
▄▄▄█▀  ██    ▀██▀ ██ ▀█▄▄▄
              ██          
            ▀▀▀           
*/

#set heading(numbering: none)

  // Format level 1 headings
#show heading.where(
  level: 1
): it => [
  #pagebreak(weak: true, to: none)
  #v(2.5em)
  #it
  \
]

#show outline.entry.where(
  level: 1
): it => {
  if it.element.func() != heading {
    // Keep default style if not a heading.
    return it
  }
  
  v(20pt, weak: true)
  strong(it)
}

#let confidential_text = [
  #if config.global.confidential{
    [Confidential]
  }
]

// Set global page layout
#set page(
  paper: "a4",
  numbering: "1",
  header: context{
    if (not is-first-page(page)) and (not is-title-page(page)) {
      columns(2, [
        #align(left)[#smallcaps([#currentH()])]
        #colbreak()
        #align(right)[#config.information.author.name]
      ])
      hr()
    }
  },
  footer: context{
    if not is-first-page(page){
      hr()
      columns(2, [
        #align(left)[#smallcaps(confidential_text)]
        #colbreak()
        #align(right)[#counter(page).display()]
      ])
    }
  },
  margin: (
    top: 150pt,
    bottom: 150pt,
    x: 1in
  )
)

// LaTeX look and feel :)
#set text(font: "New Computer Modern")
#show heading: set block(above: 1.4em, below: 1em)
#show heading.where(level:1): set text(size: 25pt)
#set table.cell(breakable: false)
#show figure: set block(breakable: true)
#show link: underline

#show raw.where(block: true): block.with(
  fill: luma(240),
  inset: 10pt,
  radius: 4pt,
)

#set text(lang: config.global.text_lang)


/*   
                             ▄▄                                    
                             ██          ██   ▀▀  ██               
████▄  ▀▀█▄ ▄████ ▄█▀█▄   ▄████ ▄█▀█▄   ▀██▀▀ ██ ▀██▀▀ ████▄ ▄█▀█▄ 
██ ██ ▄█▀██ ██ ██ ██▄█▀   ██ ██ ██▄█▀    ██   ██  ██   ██ ▀▀ ██▄█▀ 
████▀ ▀█▄██ ▀████ ▀█▄▄▄   ▀████ ▀█▄▄▄    ██   ██▄ ██   ██    ▀█▄▄▄ 
██             ██                                                  
▀▀           ▀▀▀                                                     
*/

#set par(leading: 0.55em, spacing: 0.55em, justify: true)
#image("images/HEIG-VD_logotype-baseline_rouge-cmjn.pdf", width: 6cm)
#v(10%)
#align(center, [#text(size: 14pt, [*Bachelor Thesis*])])
#v(4%)
#align(center, [#text(size: 24pt, [*#config.information.title*])])
#v(1%)
#align(center, [#text(size: 16pt, [#config.information.subtitle])])
#v(4%)
#if config.global.confidential{
  align(center, [#text(size: 14pt, [*Confidential*])])
}else{
  v(14pt)
}
#v(8%)

#align(left, [
  #block(
    width: 100%, [
    #table(
      stroke: none,
      columns: (35%, 65%),
      [*#if config.information.author.feminine_form { "Student" } else { "Student" }*], [*#config.information.author.name*],
      [],[],
      [*#if config.information.supervisor.feminine_form { "Supervisor" } else { "Supervisor" }*], [#config.information.supervisor.name],
      [],[],
      [*Department*], [#config.information.departement.long],
      [*Faculty*], [#config.information.filiere.long],
      [*Orientation*], [#config.information.orientation.long],
      [],[],
      [*Mandating Company*], [
        #config.information.industry_contact.name \
        #config.information.industry_contact.industry_name \
        #config.information.industry_contact.address
      ],
      [],[],
      [*Academic year*], [#config.information.academic_years]
    )
  ])
])
#align(bottom + right, [
  Yverdon-les-Bains, #datetime.today().display("[day].[month].[year]")
])
#pagebreak(weak: true)

/*
                  ▄▄                           ▄▄                                       
             ██   ██                 ██   ▀▀  ██  ▀▀               ██   ▀▀              
 ▀▀█▄ ██ ██ ▀██▀▀ ████▄ ▄█▀█▄ ████▄ ▀██▀▀ ██ ▀██▀ ██  ▄████  ▀▀█▄ ▀██▀▀ ██  ▄███▄ ████▄ 
▄█▀██ ██ ██  ██   ██ ██ ██▄█▀ ██ ██  ██   ██  ██  ██  ██    ▄█▀██  ██   ██  ██ ██ ██ ██ 
▀█▄██ ▀██▀█  ██   ██ ██ ▀█▄▄▄ ██ ██  ██   ██▄ ██  ██▄ ▀████ ▀█▄██  ██   ██▄ ▀███▀ ██ ██ 
*/

= Authentication

I hereby certify that I have completed this work myself and have used no other sources than those expressly mentioned.
#v(20%)

#table(
  stroke: none,
  columns: (60%, 40%),
  [], [#config.information.author.name]
)

#align(left + bottom, [
    Yverdon-les-Bains, #datetime.today().display("[day].[month].[year]")
  ])
#pagebreak(weak: true)

/*    
               ▄                 ▄▄          ▄▄       
              ▀                  ██          ██       
████▄ ████▄ ▄█▀█▄ ███▄███▄  ▀▀█▄ ████▄ ██ ██ ██ ▄█▀█▄ 
██ ██ ██ ▀▀ ██▄█▀ ██ ██ ██ ▄█▀██ ██ ██ ██ ██ ██ ██▄█▀ 
████▀ ██    ▀█▄▄▄ ██ ██ ██ ▀█▄██ ████▀ ▀██▀█ ██ ▀█▄▄▄ 
██                                                    
▀▀                                                    
*/

= Preamble

This Bachelor Thesis (hereinafter BT) is completed at the end of the study program, with a view to obtaining the title of Bachelor of Science HES-SO in Engineering.

#v(4%)

As an academic work, its content, without prejudging its value, does not engage the responsibility of the author, nor that of the Bachelor Thesis jury and the School.

#v(4%)

Any use, even partial, of this BT must be made in compliance with copyright law.

#v(10%)

#table(
  stroke: none,
  columns: (60%, 40%),
  [], [HEIG-VD],
  [], [The Head of Department #config.information.departement.court]
)

#align(bottom + left, [
  Yverdon-les-Bains, #datetime.today().display("[day].[month].[year]")
])
#pagebreak(weak: true)

/*
         ▄                          ▄  
        ▀                          ▀   
████▄ ▄█▀█▄ ▄█▀▀▀ ██ ██ ███▄███▄ ▄█▀█▄ 
██ ▀▀ ██▄█▀ ▀███▄ ██ ██ ██ ██ ██ ██▄█▀ 
██    ▀█▄▄▄ ▄▄▄█▀ ▀██▀█ ██ ██ ██ ▀█▄▄▄                             
*/

= Abstract

#align(left)[*Bachelor Thesis #config.information.academic_years*]
#align(left)[*Title:*  #config.information.title]
#align(left)[*Subtitle:*  #config.information.subtitle]

#v(5%)

#config.information.resume_publiable

#v(5%)

#align(bottom + left, [
  #block(
    width: 100%, [
      #table(
        stroke: none,
        columns: (35%, 65%),
        [*#if config.information.author.feminine_form { "Student" } else { "Student" }*], [*#config.information.author.name*],
        [],[],
        [*#if config.information.supervisor.feminine_form { "Supervisor" } else { "Supervisor" }*], [#config.information.supervisor.name],
        [],[],
        [*Mandating Company*], [#config.information.industry_contact.name],
      )
    ]
  )
])
#pagebreak(weak: true)

/*                                                                                
            ▄▄                         ▄▄                     ▄▄                                  
            ██    ▀▀                   ██                     ██                                  
▄████  ▀▀█▄ ████▄ ██  ▄█▀█▄ ████▄   ▄████ ▄█▀█▄ ▄█▀▀▀   ▄████ ████▄  ▀▀█▄ ████▄ ▄████ ▄█▀█▄ ▄█▀▀▀ 
██    ▄█▀██ ██ ██ ██  ██▄█▀ ██ ▀▀   ██ ██ ██▄█▀ ▀███▄   ██    ██ ██ ▄█▀██ ██ ▀▀ ██ ██ ██▄█▀ ▀███▄ 
▀████ ▀█▄██ ██ ██ ██▄ ▀█▄▄▄ ██      ▀████ ▀█▄▄▄ ▄▄▄█▀   ▀████ ██ ██ ▀█▄██ ██    ▀████ ▀█▄▄▄ ▄▄▄█▀ 
                                                                                   ██             
                                                                                 ▀▀▀              
*/

#include "chapters/specifications.typ"


#outline(title: "Table of contents", depth: 2, indent: 15pt)

/*                                                 
                                   ▄▄                                                   
                                   ██                                              ██   
▄████ ▄███▄ ████▄ ████▄ ▄█▀▀▀   ▄████ ██ ██   ████▄  ▀▀█▄ ████▄ ████▄ ▄███▄ ████▄ ▀██▀▀ 
██    ██ ██ ██ ▀▀ ██ ██ ▀███▄   ██ ██ ██ ██   ██ ▀▀ ▄█▀██ ██ ██ ██ ██ ██ ██ ██ ▀▀  ██   
▀████ ▀███▀ ██    ████▀ ▄▄▄█▀   ▀████ ▀██▀█   ██    ▀█▄██ ████▀ ████▀ ▀███▀ ██     ██   
                  ██                                      ██    ██                      
                  ▀▀                                      ▀▀    ▀▀                      
*/


// Set numbering for content
#set heading(numbering: "1.1")

/*
| ------------------------------------
| INSEREZ VOS CHAPITRES CI-DESSOUS
| ------------------------------------
*/

#include "chapters/introduction.typ"
#include "chapters/planification.typ"
#include "chapters/state-of-the-art.typ"
#include "chapters/repo-struct.typ"
#include "chapters/architecture.typ"
#include "chapters/implementation.typ"
#include "chapters/results.typ"
#include "chapters/conclusion.typ"

// ------------------------------------

// Remove numbering after content
#set heading(numbering: none)

/*   
▄▄        ▄▄    ▄▄                                   ▄▄              
██    ▀▀  ██    ██ ▀▀                                ██    ▀▀        
████▄ ██  ████▄ ██ ██  ▄███▄ ▄████ ████▄  ▀▀█▄ ████▄ ████▄ ██  ▄█▀█▄ 
██ ██ ██  ██ ██ ██ ██  ██ ██ ██ ██ ██ ▀▀ ▄█▀██ ██ ██ ██ ██ ██  ██▄█▀ 
████▀ ██▄ ████▀ ██ ██▄ ▀███▀ ▀████ ██    ▀█▄██ ████▀ ██ ██ ██▄ ▀█▄▄▄ 
                                ██             ██                    
                              ▀▀▀              ▀▀                    
*/

#if config.bibliography.content != none {
  bibliography(config.bibliography.content, style: config.bibliography.style)
}

/*           
           ▄▄    ▄▄            ▄▄                 ▄▄                                   
 ██        ██    ██            ██                ██  ▀▀                                
▀██▀▀ ▀▀█▄ ████▄ ██ ▄█▀█▄   ▄████ ▄█▀█▄ ▄█▀▀▀   ▀██▀ ██  ▄████ ██ ██ ████▄ ▄█▀█▄ ▄█▀▀▀ 
 ██  ▄█▀██ ██ ██ ██ ██▄█▀   ██ ██ ██▄█▀ ▀███▄    ██  ██  ██ ██ ██ ██ ██ ▀▀ ██▄█▀ ▀███▄ 
 ██  ▀█▄██ ████▀ ██ ▀█▄▄▄   ▀████ ▀█▄▄▄ ▄▄▄█▀    ██  ██▄ ▀████ ▀██▀█ ██    ▀█▄▄▄ ▄▄▄█▀ 
                                                            ██                         
                                                          ▀▀▀                          
*/

#context {
  let figures = query(figure.where(kind: image))
  if figures.len() != 0 {
    outline(title: "Figures table", target: figure.where(kind: image))
  }
}

/*
▄▄                            ▄▄                          ▄▄    ▄▄                         
██ ▀▀         ██              ██                ██        ██    ██                         
██ ██  ▄█▀▀▀ ▀██▀▀ ▄█▀█▄   ▄████ ▄█▀█▄ ▄█▀▀▀   ▀██▀▀ ▀▀█▄ ████▄ ██ ▄█▀█▄  ▀▀█▄ ██ ██ ██ ██ 
██ ██  ▀███▄  ██   ██▄█▀   ██ ██ ██▄█▀ ▀███▄    ██  ▄█▀██ ██ ██ ██ ██▄█▀ ▄█▀██ ██ ██  ███  
██ ██▄ ▄▄▄█▀  ██   ▀█▄▄▄   ▀████ ▀█▄▄▄ ▄▄▄█▀    ██  ▀█▄██ ████▀ ██ ▀█▄▄▄ ▀█▄██ ▀██▀█ ██ ██ 
*/

#context {
  let tables = query(figure.where(kind: table))
  if tables.len() != 0 {
    outline(title: "Tabs list", target: figure.where(kind: table))
  }
}

/*
 ▀▀█▄ ████▄ ████▄ ▄█▀█▄ ██ ██ ▄█▀█▄ ▄█▀▀▀ 
▄█▀██ ██ ██ ██ ██ ██▄█▀  ███  ██▄█▀ ▀███▄ 
▀█▄██ ██ ██ ██ ██ ▀█▄▄▄ ██ ██ ▀█▄▄▄ ▄▄▄█▀ 
*/

#fullpage([= Appendices])
#counter(heading).update(0)
#set heading(numbering: "I.i")

/*
| ------------------------------------
| INSEREZ VOS ANNEXES CI-DESSOUS
| ------------------------------------
*/

#include "chapters/tools-used.typ"
#set page(flipped: true)
#include "chapters/work-diary.typ"

// ------------------------------------