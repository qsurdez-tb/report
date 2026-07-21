#import "../macros.typ": note, concept

= Backup Mechanisms and Security <backup-security>

#concept[
  Backups face a hard problem. Keeping a full copy of a biometric database recoverable after a disaster, without letting any single person, or a stolen backup file, expose the data. ICNML solves it with a passphrase that no one holds, split across five people, and separate encrypted dumps. This chapter explains how that works and where it is strong or fragile. The shell scripts are in @appendix-backup.
]

== The security model

The core idea is that each backup run invents a fresh random passphrase, encrypts the database with it, then immediately destroys it, but not before splitting it into five pieces so that recovery is possible without any one person being able to open a backup alone.

The split uses Shamir's Secret Sharing @ssss-gnu, a scheme that breaks a secret into $n$ pieces such that any $t$ of them reconstruct it while fewer than $t$ reveal nothing at all. ICNML uses $t = 2$ of $n = 5$ which means that any two of the five shareholders can together rebuild the passphrase, no single one can. Each share is then locked to one specific person by encrypting it with their personal GPG public key. A stolen backup file is useless on its own, and so is any single shareholder. It takes two of five people cooperating to read a backup.

#figure(
  image("../assets/backup-encryption.drawio.png", width: 78%),
  caption: [A backup run: generate a passphrase, split and distribute it, encrypt the dumps, destroy the passphrase.],
)

== How a backup run works

A run proceeds in four steps (@appendix-backup):

1. Generate a passphrase. A fresh 256-bit random passphrase is produced for this run only.
2. Split and distribute it. The passphrase is split into five Shamir shares, and each share is GPG-encrypted for its shareholder, producing five `.asc` files only their owners can open.
3. Dump and encrypt. Three separate PostgreSQL dumps are taken and each is symmetrically encrypted with the passphrase using GPG AES-256.
4. Destroy the passphrase. The passphrase variable is overwritten with new random data, so it never reaches the disk and can only be recovered through the shares.

The three dumps deliberately separate the most sensitive tables from the rest:

#figure(
    table(
        columns: (auto, auto, 1fr),
        stroke: 0.5pt,
        fill: (col, row) => if row == 0 { luma(220) } else { white },
        align: (left, left, left),
        table.header[File][Scope flag][Content],
        [`_data.backup`], [`-T donor_dek -T cf`], [The whole database *except* the DEK and consent-form tables],
        [`_dek.backup`],  [`-t donor_dek`],       [Only the `donor_dek` table (the keys)],
        [`_cf.backup`],   [`-t cf`],              [Only the `cf` table (consent forms)],
    ),
    caption: [The three dump scopes. `-T` excludes a table, `-t` selects only it, `-Fc` is the format `pg_restore` needs @pg_dump-doc.]
)

Splitting the keys (`donor_dek`) and the consent forms into their own files is what keeps the regular data backup free of the material that would make a leak catastrophic, the same separation that lets a donor's DEK deletion stay irreversible. There is an important caveat, though: all three dumps are encrypted with the same passphrase, so the separation is organisational, not cryptographic. Any two shareholders who can open one file can open all three.

== Where backups live, and when they run

Backups are written to a NAS mounted at `/mnt/escnas/backup/`, and a companion cleanup script deletes anything older than 30 days (@appendix-backup). What the scripts do not reveal is when they run. No schedule, cron entry, or trigger is present in any repository analysed. In practice this is almost certainly a scheduled cron job on the server, but the fact that it cannot be confirmed from the code is itself a documentation gap worth closing. It is also left unspecified whether the five share files and the three dumps are stored together or apart, which matters, since co-locating them concentrates everything an attacker would need in one place.

== Restoring

Only the first half of recovery is scripted. A `combine.sh` helper gathers the shareholders' decrypted shares and reconstructs the passphrase (@appendix-backup), after which an administrator would decrypt each dump and run `pg_restore` by hand. No end-to-end restore script exists, and, by the client's own account, a restore has never been formally tested.

#figure(
  image("../assets/backup-decryption.drawio.png", width: 78%),
  caption: [Recovery: two shareholders reconstruct the passphrase, then each dump is decrypted and restored.],
)

== Assessment

The design is genuinely good where it counts. A fresh per-run passphrase that never touches disk, two-of-five secret sharing so no single person or stolen file suffices, per-recipient GPG encryption of the shares, isolation of the keys and consent forms into their own dumps, and a bounded retention window together make for a serious, well-thought-out scheme.

The weaknesses are worth acting on. First, the single shared passphrase means the three-way dump separation buys no cryptographic isolation, two shareholders unlock everything. Second, a threshold of two is low, and it only holds if no single person controls two shares, so share allocation needs to be audited to preserve the guarantee. Third, the trigger and schedule are undocumented, and, fourth, the restore path is only partially scripted and never formally exercised, which is the most dangerous gap of all, an untested backup is not yet a backup. Finally the dek is actually backuped, which means that DEK deletion by a donor will have effect only after the retention period of 30 days. Documenting the schedule and validating a full restore end-to-end should be a priority.
