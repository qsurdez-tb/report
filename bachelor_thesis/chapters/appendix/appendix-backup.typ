= Backup Mechanisms : implementation details <appendix-backup>

Shell excerpts for the backup chapter (@backup-security).

== Encryption (`scripts/backup.sh`)

#figure(
  ```bash
  PASS=$(openssl rand -base64 32 | sha256sum | cut -d' ' -f1)   # 256-bit passphrase
  ```,
  caption: [Fresh per-run passphrase (`scripts/backup.sh`, ln 18).]
)

#figure(
  ```bash
  SHARES=$(echo ${PASS} | ssss-split -t ${THRESHOLD} -n ${NBUSERS} -Q)
  i=0
  for s in ${SHARES}; do
      cat <<EOF | gpg --encrypt --armor --recipient ${USERS[$i]} > ${DIRNAME}/..._ssss_${USERS[$i]}.asc
  ssss_key: ${s}
  EOF
      i=$i+1
  done
  ```,
  caption: [Splitting the passphrase into shares and GPG-encrypting one per shareholder (`scripts/backup.sh`, ln 24-39).]
)

#figure(
  ```bash
  pg_dump -h ${HOST} -U ${DBUSER} -T ${DEKTABLE} -T ${CFTABLE} -Fc ${DBNAME} | gpg --symmetric --cipher-algo AES256 --passphrase ${PASS} > ${FILENAME_DATA}
  pg_dump -h ${HOST} -U ${DBUSER} -t ${DEKTABLE}               -Fc ${DBNAME} | gpg --symmetric --cipher-algo AES256 --passphrase ${PASS} > ${FILENAME_DEK}
  pg_dump -h ${HOST} -U ${DBUSER}                -t ${CFTABLE} -Fc ${DBNAME} | gpg --symmetric --cipher-algo AES256 --passphrase ${PASS} > ${FILENAME_CF}
  ```,
  caption: [Three scoped dumps, each encrypted with the same passphrase (`scripts/backup.sh`, ln 41-43).]
)

#figure(
  ```bash
  PASS=$(openssl rand -base64 32)   # overwrite the in-memory passphrase
  ```,
  caption: [The passphrase is overwritten and never written to disk (`scripts/backup.sh`, ln 45).]
)

== Retention (`scripts/clean.sh`)

#figure(
  ```bash
  DIRNAME=/mnt/escnas/backup/
  find ${DIRNAME} -type f -mtime +30 -exec rm -f {} \;
  ```,
  caption: [Backups on the NAS older than 30 days are deleted (`scripts/clean.sh`).]
)

== Restore (`scripts/combine.sh` and the manual step)

#figure(
  ```bash
  VALUES=$(find . -name '*.asc' -exec gpg -d --yes {} 2>/dev/null \;)
  echo ${VALUES} | grep -o 'ssss_key: [0-9]\+-[a-f0-9]\+' | cut -d':' -f2 | ssss-combine -q -t 2 2>&1
  ```,
  caption: [Reconstructing the passphrase from the shareholders' decrypted shares (`scripts/combine.sh`).]
)

#figure(
  ```bash
  gpg --decrypt --passphrase <PASS> --batch <file>.backup | pg_restore -h <HOST> -U <USER> -d <DB>
  ```,
  caption: [The (undocumented) manual restore step, reconstructed from the encryption side.]
)
