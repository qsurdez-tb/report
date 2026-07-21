= Conclusion <conclusion>

This thesis set out to modernise ICNML and to make it reliable and understandable, a platform that held genuine biometric data yet ran on an end-of-life language, could not be rebuilt from its own sources, and whose security no one had written down. Measured against the four objectives fixed at the start in the specifications, the work delivered on all of them, and on two it went beyond documentation into engineering.

== What was achieved

On maintainability, ICNML moved from having no documentation at all to a complete account of the system, its interface, its codebase, and a development environment a new contributor can actually bring up. The decisive step here was the migration of the entire codebase, four internal libraries and the Flask application, from Python 2.7 to Python 3.11 (@python3-migration). This removed the root cause behind most of the platform's fragility, and it was done without a data migration, because every stored format was preserved byte-for-byte so that existing accounts and encrypted images remain valid.

On security transparency, every core mechanism is now documented in plain terms with its weaknesses named rather than hidden. The audit produced concrete, actionable findings, among them the use of a predictable random source where a cryptographic one is required, timing-unsafe secret comparisons, a hand-rolled padding construction in place of authenticated encryption, image endpoints that serve unmarked copies and so leave no audit trail, and the fact that a donor's "erasure" is only eventual, because the per-donor keys are included in backups and so survive until the retention window passes (@per-donor-security, @crypto-utils, @backup-security). Naming these honestly is itself a result, since a weakness that is written down can be fixed, whereas one that is undocumented cannot.

On the management operations, the platform's original deployment pipeline is documented (@deployment), and the modernised system has been made runnable again end to end, both as a convenient local stack and as a production-faithful deployment with its full two-factor and passkey security genuinely working (@running-icnml).

On the user experience, a set of practical features was delivered, and, going well beyond the brief, the crude barcode stamp that the platform used to mark downloads, removable by a single crop, was replaced with a robust invisible watermark that spreads a cryptographic identifier across the whole image. That scheme was not merely described but designed, implemented, and measured against a battery of attacks, and the retained variant recovers the recipient from the great majority of attacked copies while remaining essentially invisible (@state-of-the-art, @watermark-implementation, @ux-improvements).

== Limitations

Several boundaries of this work should be stated plainly. The security weaknesses uncovered were deliberately documented rather than fixed during the migration, on the principle that a language port and a security change should not be tangled together in the same step, so they remain as prioritised follow-up work. The original automated deployment pipeline is still inert, and production has not yet been re-established on the new stack, the single-box deployment shown here demonstrates feasibility but is not a full replacement. Finally the traceable watermark is scoped to a single redistributing recipient, it does not defend against several recipients comparing their differently-marked copies to erase the trace.

== Future work

The natural continuation of this thesis follows directly from those limitations. The highest priorities are to re-establish a real production deployment on the Python 3.11 stack, built on maintained, submodule-free tooling, and to address the catalogued security weaknesses, replacing the predictable random source, adopting authenticated encryption. The watermarking work would be extended by marking every image-serving endpoint rather than only the download routes.

== Closing

ICNML is now a platform that can be explained, rebuilt, and safely worked on, which was not the case when this work began. It runs on a supported language, its security is documented rather than assumed, its downloads carry a mark that survives ordinary tampering, and the next contributor inherits both a working environment and a clear, honest map of what still needs strengthening. For a system entrusted with data that a person can never change, being understandable is not a luxury but a precondition for being trustworthy, and moving ICNML towards that standard is the contribution of this thesis.
