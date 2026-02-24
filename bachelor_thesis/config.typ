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

#let config = (

    global: (
      confidential: false,
      text_lang: "en"
    ),

    information: (
      title: "Modernisation and reliability improvement of the ICNML biometric trace platform",
      subtitle: "",
      academic_years: "2025-26",
      departement: (
        court: "TIC",
        long: "Technologies de l'information et de la communication (TIC)",
      ),
      filiere: (
        court: "ISC",
        long: "Informatique et systèmes de communication (ISC)",
      ),
      orientation: (
        court: "ISC-L",
        long: "Logiciel (ISC-L)",
      ),
      author: (
        name: "Quentin Surdez",
        feminine_form: false,
      ),
      supervisor: (
        name: "Prof. Sylvain Pasini",
        feminine_form: false,
      ),
      industry_contact: (
        name: "UNIL - ESC",
        address: [
          Avenue François-Alphonse Forel\
          1015 Lausanne 
        ],
        industry_name: "Christophe Champod",
      ),
      resume_publiable: [
        #lorem(100)\
        \
        #lorem(50)
      ]
    ),
    bibliography: (
      content: read("bibliography.yaml", encoding: none),
      style: "ieee"
    ),
  )