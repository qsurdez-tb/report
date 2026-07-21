#import "../macros.typ": note, concept

= Repository Structure <repo-struct>

#concept[
  ICNML is not one repository but a scattering of them, tied together by a build pipeline. Mapping that scattering was the first task of this thesis, because nothing else, starting up an environment, reading the code, planning changes, was possible without knowing which repository held what and how they depended on one another. This chapter is that map. The repositories, what each is for, and the dependency structure that links them.
]

@repo-schema-fig shows how the repositories depend on one another. The `web` repository holds the application itself, and `docker` and `base` wrap it for building and deployment.

#figure(
  image("../assets/repo_dependencies.png", width: 78%),
  caption: [Dependencies between the ICNML repositories.],
)<repo-schema-fig>

== The repositories

@repo-table lists every repository, its purpose, and the state it was found in. Several are peripheral to this thesis and could be retired, the bulk of the work concerns `web`.

#figure(
  table(
    columns: (1.5fr, 3fr, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left, left),
    table.header[Repository][Purpose][State],
    [`web`], [The web application: Flask code, SQL schema, and the encryption utilities. The core of the platform.], [Active],
    [`docker`], [The application build and CI pipeline. Has `web` as a submodule.], [Submodules unreachable],
    [`base`], [A minimal Debian Docker base image plus its CI (Kaniko build).], [Last commit 2022],
    [`cdn`], [The JavaScript and CSS libraries used by the web app (jQuery, AES, PBKDF2, Dropzone, and others). A submodule of `web`.], [Active],
    [`scripts`], [Database-management scripts: backup, cleanup, duplication, and GPG-share combining.], [Active],
    [`config/production`], [Part of an automated process, its commits track the `web` repository.], [Active],
    [`tools`], [Python data-migration and conversion scripts.], [Depends on missing submodules],
    [`documents`], [A single donor consent-form PDF.], [Static],
    [`afis_assignments`], [One R script for filtering lab data, its input CSV is absent.], [Out of scope],
    [`fingerprintexperts` `assessment`], [Results of fingerprint-expert tests on ICNML images.], [Out of scope],
  ),
  caption: [The ICNML repositories.],
)<repo-table>

Two structural facts stand out. The `web` repository is where almost all the application logic and the security-sensitive code lives, so it is where this thesis spends most of its effort. And several repositories (`docker`, `tools`) depend on git submodules whose remotes are no longer reachable, which is the first obstacle a new developer hits and a recurring theme of the environment obstacles catalogued in @appendix-dev-env.

== Outdated dependencies

Analysing the `web` repository's `requirements.txt` surfaced several critically outdated libraries, each carrying known vulnerabilities.

#figure(
  table(
      columns: (auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, left),
      table.header[Library][Risk],
      [`pycrypto==2.6.1`], [Last updated 11 years ago. Known CVEs CVE-2018-6594 (High) and CVE-2013-7459 (Critical). Abandoned, and should be removed, as it is not used by the app.],
      [`cryptography==3.3.2`], [Old version with multiple known CVEs (CVE-2026-26007, CVE-2023-50782, both High). The current version has none known.],
      [`pillow==6.2.2`], [Old version with known CVEs (CVE-2021-28675, CVE-2021-25289, both High). The current version has none known.],
      [`python2.7`], [End-of-life since January 2020, no longer patched. Pending CVEs include CVE-2023-24329 and CVE-2022-48560 (Medium).],
    ),
    caption: [The most critical outdated dependencies, CVE severities from @cve_site.],
)

The root cause is that the codebase runs on Python 2.7. That pins every dependency to an old version, since newer releases have dropped Python 2 support, so libraries cannot simply be bumped one at a time. The only durable fix is to migrate the codebase to Python 3.9 or later, which would unlock current, patched versions of every affected library.

== Conclusion

The repository layout tells the story of a research project that grew organically into a constellation of loosely coupled repositories, several now unused or unreachable, held together by an automated pipeline that assumes submodules and a container registry that are no longer reachable. Three things would most improve it. Consolidating or retiring the out-of-scope repositories would reduce the surface a newcomer must understand. Restoring, or vendoring, the missing submodule dependencies would make the build reproducible. And migrating off Python 2.7 would resolve the dependency vulnerabilities at their root rather than one CVE at a time. The environment obstacles catalogued in @appendix-dev-env show what these gaps cost in practice.
