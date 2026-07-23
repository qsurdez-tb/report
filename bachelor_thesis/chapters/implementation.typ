= Modernisation and Extension <implementation>

With the platform documented, the second stage changed it. Where the first stage asked what ICNML does, this one describes what was built during the thesis, and why each piece was needed. The focus points were chosen after a meeting with the client explaining the different findings of the first stage.

The work falls into three strands. The stack was modernised, with the whole codebase migrated off the end-of-life Python 2.7 that the analysis had identified as the root cause of most of the platform's fragility. A new feature was added, a robust traceable watermark that ties every downloaded biometric image to the person who obtained it, in place of the removable barcode documented earlier. And the platform's usability and operation were improved, through practical features for its forensic users and a reproducible way to run the modernised system in both development and production.

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
  #include "./python3-migration.typ"
  // #include "./dek-donor-generation.typ"
  #include "./state-of-the-art-watermarking.typ"
  #include "./watermark-implementation.typ"
  #include "./ux-improvements.typ"
  #include "./running-icnml.typ"
]