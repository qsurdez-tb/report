= Work diary <work-diary>

#{
  show figure: set block(breakable: true)

block[
#figure(
  align(center)[#table(
    columns: 6,
    align: (left,left,right,right,right,right,),
    table.header([Date], [Description], [Rech. \[h\]], [Dev. \[h\]], [Rapport \[h\]], [Admin \[h\]],),
    table.cell(align: right, colspan: 6)[#emph[The work diary continues on the next page.];],

    // 17.02,Tuesday,8h
    [17.02.2026], [Kick-off meeting with supervisor and thesis scoping], [0], [0], [0], [2],
    [17.02.2026], [Planning setup,Gantty, paper draft and template selection], [0], [0], [0], [2],
    [17.02.2026], [Research on other theses’ specifications and problem summary writing], [1], [0], [3], [0],

    // 19.02,Thursday,4h
    [19.02.2026], [Planning structure and branching strategy reflection], [0], [0], [0], [1],
    [19.02.2026], [Specifications writing,objectives and structure], [0], [0], [3], [0],

    // 24.02,Tuesday,8h
    [24.02.2026], [Meeting preparation and second iteration of planning], [0], [0], [0], [3],
    [24.02.2026], [Specifications, deliverables and report configuration], [0], [0], [4], [0],
    [24.02.2026], [Initial ICNML repositories exploration], [1], [0], [0], [0],

    // 26.02,Thursday,4h
    [26.02.2026], [Meeting with mandate on organisation and project scope], [0], [0], [0], [1.5],
    [26.02.2026], [Repository structure documentation and schema], [0], [0], [1.5], [0],
    [26.02.2026], [Code exploration,users, DEK generation and encryption], [1], [0], [0], [0],

    // 03.03,Tuesday,8h
    [03.03.2026], [Access rights requests and meeting with supervisor], [0], [0], [0], [0.5],
    [03.03.2026], [DEK creation and encryption code exploration], [1.5], [0], [0], [0],
    [03.03.2026], [DEK generation process documentation and schema], [0], [0], [2.5], [0],
    [03.03.2026], [Roles and permissions,code exploration and documentation], [1], [0], [2.5], [0],

    // 16.03,Monday,8h
    [16.03.2026], [Rereading and updating previous documents], [0], [0], [1], [0],
    [16.03.2026], [Database exploration,local PostgreSQL setup and schema analysis], [0.5], [0.5], [0], [0],
    [16.03.2026], [Database architecture documentation and specification update], [0], [0], [6], [0],

    // 19.03,Thursday,4h
    [19.03.2026], [Admin account setup and missing libraries retrieval with Christophe], [0], [0], [0], [2.5],
    [19.03.2026], [Application walkthrough meeting with Christophe], [0], [0], [0], [1.5],

    // 24.03,Tuesday,8h
    [24.03.2026], [Application context document writing], [0], [0], [1.5], [0],
    [24.03.2026], [Specification revision and restructuring], [0], [0], [2], [0],
    [24.03.2026], [Production admin account setup meeting], [0], [0], [0], [0.5],
    [24.03.2026], [Development environment setup], [0], [4], [0], [0],

    // 26.03,Thursday,4h
    [26.03.2026], [Development environment debugging and documentation], [0], [1], [0.5], [0],
    [26.03.2026], [Application overview documentation with screenshots], [0], [0], [2.5], [0],

    // 31.03,Tuesday,8h
    [31.03.2026], [Production database access investigation], [0.5], [0], [0], [0],
    [31.03.2026], [Supervisor feedback review and report adjustments], [0], [0], [1], [0.5],
    [31.03.2026], [Application overview documentation], [0], [0], [6], [0],

    // 02.04,Thursday,4h
    [02.04.2026], [Specification final review and quality check], [0], [0], [0.5], [0],
    [02.04.2026], [Development environment repository and README creation], [0], [1], [0.5], [0],
    [02.04.2026], [Specification export to text formats and submission to supervisor], [0], [0], [0], [0.5],
    [02.04.2026], [Development environment setup documentation], [0], [0], [1.5], [0],

    // 14.04,Tuesday,8h
    [14.04.2026], [Per-donor security processes planning and code exploration], [2], [0], [0], [0],
    [14.04.2026], [Per-donor security processes documentation (DEK and email encryption)], [0], [0], [1.5], [0],
    [14.04.2026], [Meeting with supervisor], [0], [0], [0], [0.5],
    [14.04.2026], [Consent form pipeline documentation], [0], [0], [2], [0],
    [14.04.2026], [Per-donor security processes diagrams creation and integration], [0], [0], [2], [0],

    // 16.04,Thursday,4h
    [16.04.2026], [Consent form flow diagram redesign (submitter and donor views)], [0], [0], [1], [0],
    [16.04.2026], [Authentication process documentation and code research], [1], [0], [1], [0],
    [16.04.2026], [Cryptographic concepts deep dive (AES CBC, PBKDF2, GPG)], [1], [0], [0], [0],

    // 21.04,Tuesday,8h
    [21.04.2026], [Cryptographic course study (supervisor materials and CAA course)], [2], [0], [0], [0],
    [21.04.2026], [AES CBC mode and PBKDF2 iterations analysis in codebase], [2], [0], [0], [0],
    [21.04.2026], [Authentication Login Flow documentation], [0], [0], [2], [0],
    [21.04.2026], [Password Reset Flow documentation], [0], [0], [2], [0],

    // 28.04,Tuesday,8h
    [28.04.2026], [Authentication documentation completion and code research], [1], [0], [1], [0],
    [28.04.2026], [Authentication diagrams creation and integration], [0], [0], [1], [0],
    [28.04.2026], [Watermark process documentation], [0.5], [0], [1], [0],
    [28.04.2026], [Biometric data management documentation and flow diagram], [0.5], [0], [1.5], [0],
    [28.04.2026], [PiAnoS international coordination meeting], [0], [0], [0], [1.5],

    // 30.04,Thursday,4h
    [30.04.2026], [Documentation cleanup and deliverable planning], [0], [0], [1], [0],
    [30.04.2026], [Deprecated libraries analysis and documentation], [1], [0], [1], [0],
    [30.04.2026], [Production deployment investigation (python2, docker swarm, code access)], [1], [0], [0], [0],

  )],
  caption: [Work diary],
  kind: table
  )
]
}