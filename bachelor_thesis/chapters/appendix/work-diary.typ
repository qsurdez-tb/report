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

    // 05.05,Tuesday,8h
    [05.05.2026], [Backup encryption chapter writing and schemas], [0], [0], [3], [0],
    [05.05.2026], [Update meeting with supervisor], [0], [0], [0], [0.5],
    [05.05.2026], [Cryptographic utilities chapter, code study and documentation], [1.5], [0], [3], [0],

    // 07.05,Thursday,4h
    [07.05.2026], [Report proof-reading and login-flow reflection], [0], [0], [4], [0],

    // 12.05,Tuesday,8h
    [12.05.2026], [Deployment documentation and pipeline investigation (submodule 404, registry TLS)], [1], [0], [3], [0],
    [12.05.2026], [Production database dump for a development dataset], [0], [1.5], [0], [0.5],
    [12.05.2026], [Deployment sequence diagram and broken-pipeline section], [0], [0], [2], [0],

    // 19.05,Tuesday,8h
    [19.05.2026], [Development-focus document and missing-feature screenshots], [0], [0], [3], [0],
    [19.05.2026], [Meeting with supervisor], [0], [0], [0], [1],
    [19.05.2026], [Presentation exploration (reveal.js) and first draft], [0], [0], [0], [4],

    // 26.05,Tuesday,8h
    [26.05.2026], [Python 2.7 to 3 upgrade feasibility analysis and write-up], [2], [0], [2], [0],
    [26.05.2026], [GPG private key investigation for deployment and consent forms], [1], [0], [0], [0],
    [26.05.2026], [Presentation refinement and practice], [0], [0], [0], [3],

    // 28.05,Thursday,4h
    [28.05.2026], [Attack-surface document supporting the Python 3 upgrade argument], [2], [0], [2], [0],

    // 02.06,Tuesday,8h
    [02.06.2026], [Presentation translation and delivery], [0], [0], [0], [2],
    [02.06.2026], [Supervisor feedback review and feedback-tracking file], [0], [0], [1], [0.5],
    [02.06.2026], [Development-priority document and planning update], [0], [0], [2.5], [2],

    // 04.06,Thursday,4h
    [04.06.2026], [Planning update and coordination email], [0], [0], [0], [1.5],
    [04.06.2026], [Dev-server setup (Docker, repository access, database upload)], [0], [2.5], [0], [0],

    // 09.06,Tuesday,0h
    [09.06.2026], [Sick day], [0], [0], [0], [0],

    // --- full-time phase from 08.06 ---
    // 12.06,Friday,6h
    [12.06.2026], [Production-faithful deployment, database restore streaming to the dev server], [0], [5], [0], [0],
    [12.06.2026], [HTTPS setup and first Python 3 migration guide draft], [0], [1], [0], [0],

    // 16.06,Tuesday,8h
    [16.06.2026], [Dev-server DNS and Caddy setup, production data restore], [0], [3], [0], [0],
    [16.06.2026], [Python 3 migration of the internal libraries (MDmisc, start of NIST)], [0], [5], [0], [0],

    // 17.06,Wednesday,8h
    [17.06.2026], [Python 3 migration of NIST (bytes/str, latin-1 boundary, amd64 WSQ tests)], [0], [6], [0], [0],
    [17.06.2026], [Library-migration pull requests and start of the web application port], [0], [2], [0], [0],

    // 18.06,Thursday,8h
    [18.06.2026], [Web application Python 3 migration (WebAuthn, Jinja templates, encoding)], [0], [6], [0], [0],
    [18.06.2026], [Migration notes and end-to-end validation on the dev server], [0], [1], [1], [0],

    // 19.06,Friday,8h
    [19.06.2026], [Trainer-search pagination fix and download-button debugging], [0], [2], [0], [0],
    [19.06.2026], [Meeting with the client, scope questions (AFIS visibility, sharing)], [0], [0], [0], [1],
    [19.06.2026], [Watermarking state-of-the-art reading and bibliography (Tardos)], [5], [0], [0], [0],

    // 22.06,Monday,8h
    [22.06.2026], [Watermarking state-of-the-art reading (spread-spectrum, collusion, Tardos)], [8], [0], [0], [0],

    // 23.06,Tuesday,8h
    [23.06.2026], [Watermarking papers (DWT-SVD, Tardos-based video, robust schemes)], [5], [0], [0], [0],
    [23.06.2026], [Tardos simulation script and JPEG-compression attack measurement], [0], [3], [0], [0],

    // 24.06,Wednesday,8h
    [24.06.2026], [Watermarking-scheme experiments (DWT-DCT-SVD, ST-DM/QIM, grayscale)], [1], [4], [0], [0],
    [24.06.2026], [Resynchronisation against rotation attacks], [0], [2], [0], [0],
    [24.06.2026], [State-of-the-art writing], [0], [0], [1], [0],

    // 25.06,Thursday,8h
    [25.06.2026], [State-of-the-art first draft and code-layer reflection (Reed-Solomon)], [1], [0], [6], [0],
    [25.06.2026], [Watermarking pipeline and synchronisation figures], [0], [0], [1], [0],

    // 26.06,Friday,5h
    [26.06.2026], [State-of-the-art proof-reading, bibliography and clarifications], [1], [0], [4], [0],

    // 29.06,Monday,8h
    [29.06.2026], [Secure folder-share feature, architecture and workflow design], [1], [2], [0], [0],
    [29.06.2026], [Secure folder-share implementation (tokens, Redis, email sender)], [0], [5], [0], [0],

    // 30.06,Tuesday,8h
    [30.06.2026], [Secure folder-share implementation (landing page, download path)], [0], [7], [0], [0],
    [30.06.2026], [Pull-request drafting and bug fixes], [0], [1], [0], [0],

    // 01.07,Wednesday,8h
    [01.07.2026], [Secure folder-share pull request and AES-GCM + Reed-Solomon test script], [0], [4], [0], [0],
    [01.07.2026], [State-of-the-art terminology, QIM section and attack model], [0], [0], [3], [0],
    [01.07.2026], [Other-project duties and workplace incident], [0], [0], [0], [1],

    // 02.07,Thursday,7h
    [02.07.2026], [Watermarking test scripts, scheme and attack improvements (with Fable)], [0], [4], [0], [0],
    [02.07.2026], [State-of-the-art finalisation and proof-reading], [0], [0], [3], [0],

    // 03.07,Friday,7h
    [03.07.2026], [Test-scripts refactor, all-scheme comparison harness and minutiae retention], [0], [7], [0], [0],

    // 06.07,Monday,8h
    [06.07.2026], [OpenLQM quality feature, microservice design and integration], [1], [7], [0], [0],

    // 07.07,Tuesday,8h
    [07.07.2026], [OpenLQM heatmap endpoint, colourblind palette, sorting and backfill], [0], [6], [0], [0],
    [07.07.2026], [Username-search feature and pull requests], [0], [1.5], [0], [0],
    [07.07.2026], [Other-project duties], [0], [0], [0], [0.5],

    // 08.07,Wednesday,8h
    [08.07.2026], [Safe folder and image deletion feature (soft delete, admin restore)], [0], [3], [0], [0],
    [08.07.2026], [Quality feature extended to all 13 OpenLQM metrics and granular sort], [0], [4.5], [0], [0],
    [08.07.2026], [Client request handling and coordination], [0], [0], [0], [0.5],

    // 10.07,Friday,8h
    [10.07.2026], [Dockerfile maintainability and image-ordering bug fix], [0], [2], [0], [0],
    [10.07.2026], [Merging feature pull requests and porting lost commits from the production version], [0], [6], [0], [0],

    // 13.07,Monday,8h
    [13.07.2026], [Dev-server access debugging (firewall, Caddy, passkeys) and coordination], [0], [1], [0], [1.5],
    [13.07.2026], [Full-resolution watermarking comparison data and scheme-choice preparation], [0.5], [2], [0], [0],
    [13.07.2026], [Watermark integration planning, branch merges and UX pull request], [0], [3], [0], [0],

    // 14.07,Tuesday,8h
    [14.07.2026], [Watermarking evaluation plots and image corpus (PSNR, SSIM, minutiae) with Fable], [0], [5], [0], [0],
    [14.07.2026], [Forensic attack battery and visual embedding comparison], [0], [2], [0], [0],
    [14.07.2026], [Scheme selection analysis (stdm-gain versus stdm-block)], [1], [0], [0], [0],

    // 15.07,Wednesday,10h
    [15.07.2026], [Watermark feature implementation (payload codec, keyed embedding, nonce table)], [0], [6], [0], [0],
    [15.07.2026], [Watermark service layer, event logging and resynchronisation], [0], [2], [0], [0],
    [15.07.2026], [Production incident handling and client script (tenprint cards)], [0], [1.5], [0], [0.5],

    // 16.07,Thursday,8h
    [16.07.2026], [Watermark integration into the download pipeline with fail-open fallback], [0], [5], [0], [0],
    [16.07.2026], [Watermark verification implementation and admin resync helper], [0.5], [2.5], [0], [0],

    // 17.07,Friday,5h
    [17.07.2026], [Watermark verification and writing the watermark and UX chapters], [0], [2], [3], [0],

    // 20.07,Monday,8h
    [20.07.2026], [Report figures and screenshots (watermarking and UX)], [0], [0], [2], [0],
    [20.07.2026], [Thesis-wide rewrite for a pedagogic tone, starting with authentication], [0], [0], [6], [0],

    // 21.07,Tuesday,8h
    [21.07.2026], [Chapter rewrites, Python 3 migration chapter, introduction and conclusion], [0], [0], [7], [0],
    [21.07.2026], [Meeting with supervisor], [0], [0], [0], [1],

    // 22.07,Wednesday,8h
    [22.07.2026], [Feedback review and implementation across the report], [0], [0], [6], [0],
    [22.07.2026], [Poster preparation], [0], [0], [1], [1],

    // 23.07,Thursday,4h
    [23.07.2026], [Last changes before sending the thesis], [0], [0], [5], [0],

  )],
  caption: [Work diary],
  kind: table
  )
]
}