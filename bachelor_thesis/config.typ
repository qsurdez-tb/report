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
        ICNML (International Close Non-Matches Library) is a web platform used by forensic-science institutions to store fingerprint data and to build training exercises for examiners. Because a fingerprint identifies a person for life, protecting that data matters. Grown from a research prototype, the platform carried heavy technical debt. Indeed, it ran on Python 2.7, which reached end of life in 2020 and receives no security fix, its environment could no longer be rebuilt, and its security mechanisms had never been documented.

        This thesis modernised ICNML and made it understandable. The system was audited by reading its code, and each protection mechanism was documented in plain terms as follows: the user roles, the per-donor encryption that lets a donor's data be erased, the cryptographic utilities, the marking of downloaded images, and the encrypted backups. The concrete weaknesses were named honestly, among them a predictable random source, a too-simple padding scheme, and the fact that a donor's data was only eventually erasable because the keys that decrypt it were kept in the backups. A full documentation set and a reproducible development environment were produced where none had existed.

        The work also went further. The entire codebase was migrated from the obsolete Python 2.7 to a supported Python 3.11, so existing data stayed valid, removing the root cause of most of its fragility. The crude, easily-cropped barcode on downloaded images was replaced by a robust invisible watermark that ties each image to whoever obtained it. Measured against many manipulations, it recovered the downloader from the large majority of attacked copies while staying essentially invisible. ICNML now ran again end to end, and the documented weaknesses, with re-establishing production on the new stack, formed a prioritised map for future work.
      ]
    ),
    bibliography: (
      content: read("bibliography.yaml", encoding: none),
      style: "ieee"
    ),
  )