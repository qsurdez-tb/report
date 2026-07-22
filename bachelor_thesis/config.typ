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
        court: "ICT",
        long: "Information and Communication Technologies",
      ),
      filiere: (
        court: "CS",
        long: "Computer Science and Communication Systems",
      ),
      orientation: (
        court: "SD",
        long: "Software development",
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
        name: "UNIL - School of Forensic Science",
        address: [
          Avenue François-Alphonse Forel\
          1015 Lausanne 
        ],
        industry_name: "Christophe Champod",
      ),
      resume_publiable: [
        ICNML (International Close Non-Matches Library) is a web platform used by forensic-science institutions to store fingerprint data and build training exercises for examiners. Because a fingerprint identifies a person for life, the data it holds demands strong protection. Yet the platform had grown out of a research prototype and carried heavy technical debt. It ran on Python 2.7, unsupported since 2020, its environment could no longer be rebuilt, and its security mechanisms had never been documented, so no one could say what actually protected the data.

        This thesis audited the platform by reading its code and documented each of its security mechanisms in plain terms, naming their weaknesses honestly rather than hiding them. It then went beyond description on two fronts. The entire codebase was migrated from the obsolete Python 2.7 to a supported Python 3.11 without any loss of existing data, and the crude barcode that marked downloaded images, removable by a single crop, was replaced by a robust invisible watermark tying each image to whoever obtained it.

        ICNML now runs again on supported foundations, its protections are documented rather than assumed, and its downloads carry a mark that survives ordinary tampering. The weaknesses uncovered were deliberately documented rather than altered during the migration, and together with rebuilding a full production deployment they form a clear, prioritised roadmap for the work that follows.
      ]
    ),
    bibliography: (
      content: read("bibliography.yaml", encoding: none),
      style: "ieee"
    ),
  )