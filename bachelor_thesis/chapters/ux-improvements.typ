#import "../macros.typ": note, concept

= Enhancing the User Experience <ux-improvements>

#concept[
  The fourth objective was to make ICNML easier to use without weakening its protections. This chapter presents four enhancements built for the platform's trainers, administrators and external recipients, a secure way to share a folder, automatic quality scoring of marks, a donor-aware search, and safe deletion with recovery, each fixing a concrete friction the analysis had surfaced. It also presents the administrator page that reads a watermark back from a suspected leak, the operator-facing side of the traceable-watermark work. One rule runs through all four, added convenience must never quietly remove a safeguard on the biometric data.
]

The fourth objective of this thesis was to enhance the day-to-day experience of the people who actually use ICNML. The trainers who build exercises from latent marks, the administrators who oversee the platform, and the external recipients who receive material from ICNML. Unlike the documentation and security work, whose scope was fixed at the outset, the exact features here were confirmed part-way through the project, on 20.05, once the analysis phases had revealed which frictions mattered most. This chapter presents the four enhancements that were built, each motivated by a concrete obstacle a user was hitting.

A guiding constraint runs through all four, ICNML holds sensitive biometric data, so a usability improvement must never quietly weaken a safeguard. Where a feature touches deletion, sharing, or the export of full-resolution images, the design keeps the cautious behaviour and adds the convenience around it.

== Sharing a folder without weakening security <ux-share>

Trainers regularly need to hand a whole folder of biometric images to an external collaborator, a colleague at another institution, a student cohort. The previous mechanism was blunt, and the natural workarounds (emailing files directly, sharing a login) are exactly the practices a biometric platform should discourage.

The enhancement replaces this with a secure folder-share flow. A trainer enters the recipients' email addresses. Each recipient receives a private, single-use link that expires after 72 hours. Opening the link is not enough to download anything, the recipient must then request a short numeric code, which arrives in a second email, and enter it correctly before the download begins. This is a deliberate two-channel check, the link and the code travel separately, so intercepting one does not grant access, the same principle as two-factor authentication applied to a file transfer.

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 10pt,
    align: horizon,
    image("../assets/screenshots/ux-improvements/03-share-folder.png", width: 100%),
    image("../assets/screenshots/ux-improvements/10-email-folder-share.png", width: 100%),
  ),
  caption: [The first channel. A trainer adds recipient addresses (left), and each recipient receives a private, single-use link that expires after 72 hours (right).]
)<fig-ux-share-link>

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 10pt,
    align: horizon,
    image("../assets/screenshots/ux-improvements/11-secure-download-card.png", width: 100%),
    image("../assets/screenshots/ux-improvements/12-code-input.png", width: 100%),
  ),
  caption: [The second channel. Opening the link is not enough, the recipient must request a short numeric code sent in a separate email (left) and enter it before the download begins (right).]
)<fig-ux-share-code>

Several precautions sit underneath the convenience:

- the link uses an unguessable random token, and the code is stored only in hashed form with a 15-minute lifetime.
- code entry is compared in constant time, is limited to five attempts, and each code works only once.
- every recipient who downloads is recorded, producing an audit list of exactly who received the material.

That audit list is where this feature meets the watermarking work of the previous chapters. Traceability only has interest when distinct copies reach distinct, identified recipients. If everyone shares one anonymous copy, a recovered payload points to no one in particular. The secure share flow is what makes per-recipient distribution real, so that the invisible payload carried by each downloaded image (@watermark-implementation) can later be tied back to a named person on the recipient list, through the verification page described in @ux-verify.

One caveat sits against these precautions. The recipient email addresses that form the audit list are stored in plain text in the database, unlike the donor emails elsewhere in ICNML, which are only ever kept encrypted or hashed. This is a known weakness. Because the audit trail must still be able to name a recipient for a watermark accusation, the fix is to encrypt these addresses at rest rather than hash them, so that a database dump no longer reveals who received what. It is a worthwhile item for future work.

== Judging image quality automatically <ux-quality>

A recurring, tedious task for a trainer is judging how usable or unusable (if a low quality mark is what interests the trainer) a latent mark is before building an exercise around it, a judgement previously made entirely by eye, one image at a time. ICNML has ~6000 marks so the task is daunting. The enhancement automates a first pass at this by integrating OpenLQM, the open-source local quality metric from NIST's fingerprint-quality lineage @nistlqm.

Every latent mark is scored automatically on upload, and a one-time backfill scored the marks already in the library. The trainer's search page gains a quality column and can sort marks by quality in ascending or descending order. This allow the most usable material to rise to the top of a large collection without any manual inspection. Two design points keep this honest for a forensic audience, the scoring is advisory (it orders and annotates, it never discards a mark), and marks that could not be scored are sorted last rather than being silently treated as low quality.

#figure(
  image("../assets/screenshots/ux-improvements/01-marks-search.png", width: 100%),
  caption: [The search page gains a quality column and a sort control, letting a trainer order thousands of marks by any quality metric, with the heatmap overlay toggled on here.]
)<fig-ux-quality-search>

Beyond a single number, a trainer often needs to know where on a print the clarity is good. The feature therefore offers a toggleable quality heatmap overlaid on the image, colouring local ridge clarity from poor to excellent. The palette was chosen to be colourblind-friendly, a deliberate accessibility choice so that the overlay is legible to the widest range of examiners. The integration was later extended from three metrics to the full set of thirteen OpenLQM metrics, giving trainers finer control over what "quality" means for their task.

#figure(
  grid(
    columns: (1.55fr, 1fr),
    column-gutter: 10pt,
    align: horizon,
    image("../assets/screenshots/ux-improvements/00-marks-detail.png", width: 100%),
    image("../assets/screenshots/ux-improvements/02-marks-search-detail.png", width: 100%),
  ),
  caption: [The toggleable, colourblind-friendly quality heatmap shows where ridge clarity is good on a single mark (left), and the full set of thirteen OpenLQM metrics is exposed as sort criteria (right).]
)<fig-ux-quality-detail>

Architecturally, the scoring runs in an isolated microservice container rather than inside the web application, because the underlying native quality tool could not share the web image's runtime. This isolation is also good practice. Indeed, the scoring service sits on an internal network only, never blocks an upload if it is slow or unavailable, and the whole feature can be turned off through a single configuration switch, after which ICNML behaves exactly as it did before.

== Finding a donor's marks quickly <ux-search>

Trainers needed to locate easily all marks belonging to a particular donor, and had no way to filter by donor at all. Rather than build a new filtering system, the enhancement extends the search page's existing free-text filter to also match the donor's username, so a trainer can type a donor name and see only that donor's marks. A small correctness fix accompanies it, usernames are now displayed and matched exactly as they are stored, instead of being cosmetically rewritten, so that what a trainer sees is what the search actually matches.


Reusing the filter the trainers already understood avoided adding a second, competing search widget to the interface.

#figure(
  image("../assets/screenshots/ux-improvements/05-marks-search-donor.png", width: 60%),
  caption: [Typing a donor name into the existing free-text filter now narrows the results to that donor's marks, with usernames matched exactly as stored.]
)<fig-ux-search-donor>

== Managing training folders safely <ux-delete>

Trainers could create exercise folders but not remove them, and removing a single image from a folder was hidden behind an undiscoverable right-click with no confirmation, an easy way to lose the wrong image. The enhancement makes both actions visible and, importantly, reversible where it matters.

Deleting a folder is a soft delete which means that the trainer marks their own folder inactive, and it disappears from their view, but nothing is destroyed. Administrators still see soft-deleted folders, greyed out with a status column, and can either restore them or, only then, permanently delete them. Permanent deletion is refused on any folder that is still active, so a folder can never be lost in a single click. This two-step design mirrors the caution ICNML already applies elsewhere to irreversible operations on sensitive data.

#figure(
  grid(
    columns: (1.35fr, 1fr),
    column-gutter: 10pt,
    align: horizon,
    image("../assets/screenshots/ux-improvements/07-delete-ui.png", width: 100%),
    image("../assets/screenshots/ux-improvements/08-restore-permanently.png", width: 100%),
  ),
  caption: [A soft-deleted folder is greyed out and stays visible to administrators (left), who alone can restore it or, only then, permanently delete it (right).]
)<fig-ux-delete-admin>

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 10pt,
    align: horizon,
    image("../assets/screenshots/ux-improvements/06-delete-confirmation.png", width: 100%),
    image("../assets/screenshots/ux-improvements/09-delete-permanently.png", width: 100%),
  ),
  caption: [Both steps are guarded by a confirmation. The reversible soft delete (left) and the irreversible permanent deletion, which spells out that it cannot be undone (right).]
)<fig-ux-delete-confirm>


Removing a single image from a folder is as well promoted to a visible remove button on each image, guarded by a confirmation dialog that shows a preview of the exact image about to be removed, so the trainer can see what they are deleting before they commit. One detail ties back to traceability again. When a folder is hard-deleted, the recipient records associated with it are kept, because they are the evidence a watermark accusation would rely on.

== Verifying a leaked image <ux-verify>

The four enhancements above were the scoped user-experience work. One more interface belongs in this chapter, because it is what makes the watermarking contribution usable in practice. A watermark is only as useful as an admin's ability to read it back, so the administrator side of ICNML gained a verification page.

An administrator uploads a suspected leaked image and, optionally, the UUID of the original stored file to help undo any rotation or rescaling. ICNML recovers the invisible payload and resolves it to a concrete provenance record (@fig-ux-verify), the account that downloaded the image with its e-mail and identifier, the file the copy is of, the moment the payload was embedded, the exact download event from the audit log, and whether the authentication seal, shown as the nonce binding, verified. That last line is what separates evidence from a guess, a verified seal means the recovered identity is one ICNML actually wrote rather than a coincidence or a forgery.

This closes the traceability loop the secure share flow opened. Distinct copies reach identified recipients, and a recovered payload names one of them.

#figure(
  image("../assets/screenshots/ux-improvements/04-watermark-verification.png", width: 80%),
  caption: [The administrator verification page. Uploading a suspected leaked image recovers the invisible payload and resolves it to the account, file, embedding time and download event that produced it, with the authentication seal shown as a verified nonce binding (`watermark_verify` blueprint).],
)<fig-ux-verify>

== Summary <ux-summary>

#figure(
  table(
    columns: (1fr, 1fr),
    stroke: 0.5pt,
    align: (left, left),
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    table.header[Enhancement][Obstacle it removes],
    [Secure folder share (link + emailed code, 72 h, audited)], [insecure ad-hoc sharing of biometric folders],
    [Automatic quality scoring, sorting and heatmap], [slow, manual, by-eye assessment of mark usability],
    [Donor-aware mark search], [no way to find all marks of one donor],
    [Safe folder and image deletion (soft delete, admin restore)], [no removal, or irreversible removal with no confirmation],
    [Watermark verification page (upload a suspect image, resolve to account and audit event)], [no operator-facing way to read a leaked image's mark back to its downloader],
  ),
  caption: [The user-experience work and the friction each item addresses, the four scoped enhancements and the administrator verification page.]
)

Taken together, the four enhancements share a common shape. They add convenience without removing a safeguard, they degrade gracefully or switch off cleanly, and two of them, the audited share flow and the retention of recipient records, are what give the watermarking contribution its real-world footing, put to use by the verification page of @ux-verify.
