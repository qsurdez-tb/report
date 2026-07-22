= Documentation and Analysis <documentation>

Before ICNML could be modernised, it had to be understood. The platform had accumulated years of behaviour that no document described, so there was no map of what it did or of how it protected the data entrusted to it. This first stage of the thesis produced that map, documenting ICNML as it was found, the legacy Python 2.7 system, one part at a time.

The documentation was produced by reading the source code directly, since almost none existed beforehand, and it follows the same principles throughout. Each mechanism is explained in plain language a non-specialist can follow, its real parameters and configuration values are given rather than glossed over, and its weaknesses are named honestly rather than left implicit. Longer code listings and exhaustive tables are moved to the appendices so the discussion stays on the concepts, and every section closes with an assessment a future contributor can act on. These sections and their appendices are the technical-documentation deliverable of this thesis, and they are the reference the later chapters point back to whenever they build on the system.

Each section that follows takes one part of the platform, explains in plain terms what it does and how, and closes with an assessment of its strengths and its weaknesses. Between them they cover what a reader needs before the second stage changes anything, what ICNML is and how its codebase is built, how it authenticates users and controls access, how it encrypts and erases a donor's biometric data, the cryptographic tools that support it, how it marks and manages images, and how it is backed up and deployed.

// Demote the included former-chapters to sections of this chapter,
// and start each of them on a fresh page so the reader can tell them apart.
#[
  #set heading(offset: 1)
  #show heading.where(level: 2): it => [
    #pagebreak(weak: true, to: none)
    #v(2.5em)
    #it
    \
  ]
  #include "./context.typ"
  #include "./app-overview.typ"
  #include "./repo-struct.typ"
  #include "./authentication-roles-and-permissions.typ"
  #include "./per-donor-security-process.typ"
  #include "./crypto-utils.typ"
  #include "./tattooing.typ"
  #include "./biometric-data-management.typ"
  #include "./deployment.typ"
  #include "./backup-encryption.typ"
]
