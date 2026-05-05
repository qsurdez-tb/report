#import "../macros.typ": note

= Backup Encryption

This chapter documents the backup strategy implemented for the ICNML database. It covers how backup are created and encrypted and where the backup are stored. 

== Overview

The backup process is within a single shell script (`backup.sh`). This shell script resides in the `scripts` directory of the `icnml` repository. Each backup run creates seven files under a shared directory (`mnt/escnas/backup`):

- Three encrypted database dumps: `_data.backup`, `_dek.backup`, `_cf.backup`
- Five GPG-encrypted key share files: one per admin

The three dumps cover different subsets of the database and are all encrypted with the same symmetric passphrase using GPG AES-256. The passphrase itself is never stored, it is split across five people using Shamir's Secret Sharing GNU implementation @ssss-gnu. Each person's share is encrypted with their personal GPG public key that was previously imported on the machine. The means that to read the message, the person needs their own private key to decrypt it.


== Steps

=== Step 1, generating the passphrase

At the start of each backup, a 256-bit random passphrase is generated:

#figure(
  ```bash
  PASS=$(openssl rand -base64 32 | sha256sum | cut -d' ' -f1)
  ```,
  caption: [Passphrase generation (`scripts/backup.sh`, ln 18)]
)

`openssl rand -base64 32` produces 32 bytes (256 bits) of random data. Piping it trhough `sha256sum` creates a 256-bit digest. This value is used as the symmetric passphrase for all three database dumps produced in this run.

=== Step 2, distributing the passphrase via Shamir's Secret Sharing

The passphrase is split using Shamir's Secret Sharing (`ssss-split`) @ssss-gnu. This scheme splits a secret into $n$ shares such that any $t$ of them are sufficient to reconstruct the original. Fewer than $t$ reveal nothing.

The backup script uses a threshold of $t = 2$ and distributes $n = 5$ shares across the five shareholders.

#note[There's two email address that are owned by the old dev which means that he alone could decrypt it. I don't feel comfortable adding them in the report though. TODO discuss it with supervisor]

Each share is then wrapped in a message and GPG-encrypted for the corresponding recipient's public key:

#figure(
  ```bash
  SHARES=$(echo ${PASS} | ssss-split -t ${THRESHOLD} -n ${NBUSERS} -Q)
  i=0
  for s in ${SHARES}
  do
      cat <<EOF | gpg --encrypt --armor --recipient ${USERS[$i]} > ${DIRNAME}/${FILENAME_START}_ssss_${USERS[$i]}.asc
  This will allow the ICNML admin ...
      
  ssss_key: ${s}
      
  EOF
      i=$i+1
  done
  ```,
  caption: [Share generation and GPG encryption per recipient (`scripts/backup.sh`, ln 24-39)]
)

The result is five `.asc` file. Each file can only be decrypted by the holder of the corresponding GPG private key. Any two of the five stakeholders must coopereate to reconstruct the passphrase. A single shareholder cannot access the backup content alone.

=== Step 3, dumping and encrypting the database

The script then executes three separate `pg_dump` operations. They're all piped into `gpg --symmetric` with the same passphrase and AES-256 as the cipher:

#figure(
  ```bash
pg_dump -v -h ${HOST} -U ${DBUSER} -T ${DEKTABLE} -T ${CFTABLE} -Fc ${DBNAME} | gpg --armor --symmetric --cipher-algo AES256 --batch --yes --passphrase ${PASS} > ${DIRNAME}/${FILENAME_DATA}
pg_dump -v -h ${HOST} -U ${DBUSER} -t ${DEKTABLE}               -Fc ${DBNAME} | gpg --armor --symmetric --cipher-algo AES256 --batch --yes --passphrase ${PASS} > ${DIRNAME}/${FILENAME_DEK}
pg_dump -v -h ${HOST} -U ${DBUSER}                -t ${CFTABLE} -Fc ${DBNAME} | gpg --armor --symmetric --cipher-algo AES256 --batch --yes --passphrase ${PASS} > ${DIRNAME}/${FILENAME_CF}
  ```,
  caption: [Three database dump and encryption (`scripts/backup.sh`, ln 41-43)]
)

Here are the three dumps scopes:

#figure(
    table(
        columns: (auto, auto, 1fr),
        stroke: 0.5pt,
        fill: (col, row) => if row == 0 { luma(220) } else { white },
        align: (left, left, left),
        table.header[*File*][*Flag*][*Content*],
        [`_data.backup`], [`-T donor_dek -T cf`], [Full database *excluding* the DEK and consent form tables],
        [`_dek.backup`],  [`-t donor_dek`],        [Only the `donor_dek` table],
        [`_cf.backup`],   [`-t cf`],               [Only the `cf` (consent forms) table],
    ),
    caption: [Dumps scope]
)

The `-T` flag excludes a table. The `-t` flag selects only that table. The `-Fc` flag produces PostgreSQL's custom binary format, which is required by `pg_restore` @pg_dump-doc.

This allows three files with different responsabilities. One for the general application data, one for the encryption keys and one for the consent documents. However, the same passphrase is used for all three files. This means that any two shareholders can access to all three dumps.

=== Step 4, overwriting the passphrase

Once the dumps are written, the passphrase variable is overwritten:

#figure(
  ```bash
  PASS=$(openssl rand -base64 32)
  ```,
  caption: [Passphrase overwrites (`scripts/backup.sh`, ln 45)]
)

This replaces the in memory value of `PASS` with fresh random data. The passphrasae is never written to disk by the script itself. This makes sure that it can only be reconstructed by the shareholders.

#figure(
  image("../assets/backup-encryption.drawio.png"),
  caption: [Encryption steps]
)


== Backup Storage

#note[An analysis on the production database would be interesting as well as the production backup.]

The clean script reveals that backups are stored on a NAS mounted at `/mnt/escnas/backup/` and that files older than 30 days are automatically deleted:

#figure(
  ```bash
  DIRNAME=/mnt/escnas/backup/
  find ${DIRNAME} -type f -mtime +30 -exec rm -f {} \;
  ```,
  caption: [Rentention policy (`scripts/clean.sh`)]
)

Whether the three dump files and the five key share files are stored in the same directory or a different one is not specified by the scripts. 

#note[It may be a cronjob on the server. But there's absoluetly no clue in the different repos analysed.]

== Restore Process

The `combine.sh` script partially documents the decryption side. It finds all `.asc` files in the current directory, decrypts each with the shareholder's own GPG key, extracts the `ssss_key` lines, and reconstructs the passphrase:

#note[It feels like it's the command given to the shareholders to then send the result to the admin. Have to check whether the private GPG keys are on the prod server, cause we never know.]

#figure(
  ```bash
  VALUES=$(find . -name '*.asc' -exec gpg -d --yes {} 2>/dev/null \;)

  echo ${VALUES} | grep -o 'ssss_key: [0-9]\+-[a-f0-9]\+' | cut -d':' -f2 | ssss-combine -q -t 2 2>&1
  ```,
  caption: [Passphrase reconstruction (`scripts/combine.sh`)]
)

Once the passphrase is printed to stdout, the admin can decrypt each backup file manually. However, there's no script documenting the expected process. It would probably look like this:

#figure(
  ```bash
  gpg --decrypt --passphrase <PASS> --batch <file>.backup \
      | pg_restore -h <HOST> -U <USER> -d <DB>
  ```,
  caption: [Expected restore script]
)

#figure(
  image("../assets/backup-decryption.drawio.png"),
  caption: [Decryption steps]
)
