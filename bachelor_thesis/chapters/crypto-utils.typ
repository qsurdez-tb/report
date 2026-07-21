#import "../macros.typ": note, concept

= Cryptographic Utilities <crypto-utils>

#concept[
  ICNML's security rests on a small toolbox of cryptographic building blocks that are producing unpredictable random values, hashing passwords, and encrypting data. They live in four utility files, and because every security process in the platform reuses the same tools, their strengths and, more importantly, their weaknesses propagate everywhere. This chapter examines what each file provides and where each falls short. The code excerpts and the full call-site inventory are in @appendix-crypto.
]

The four files stack into layers, shown in @crypto-stack-fig. At the bottom, `rand.py` produces raw randomness. On top of it, `hash.py` and `aes.py` provide the two core operations, password hashing and data encryption. Above them, `encryption.py` bundles these into the ready-made contexts the rest of the application calls. Thus a weakness in the bottom layer undermines everything built on it.

#figure(
  image("../assets/crypto-stack.drawio.png", width: 60%),
  caption: [The cryptographic-utility layers. Everything ultimately depends on `rand.py`.],
)<crypto-stack-fig>

== Randomness (`utils/rand.py`)

Unpredictable random values are the foundation of every key, salt, and one-time token in ICNML. They all come from one function:

#figure(
  ```python
  def random_data( N ):
      return "".join( random.choice( string.ascii_uppercase + string.digits ) for _ in range( N ) )
  ```,
  caption: [The single source of randomness in ICNML (`utils/rand.py`, ln 7-12).]
)

Two weaknesses sit in these two lines, and both matter because this function feeds every salt, the `SECRET_KEY` that signs the session cookie when none are provided, the DEK salt, and the password-reset tokens (the full list is in @apx-rand-sites).

The first is the generator. Python's `random` module is a Mersenne Twister, built for statistical simulation, not security. An observer who collects enough of its output can reconstruct its internal state and predict all future values. The correct tool is the `secrets` module, which draws from the operating system's entropy source. It resurfaces in the authentication and per-donor chapters, and it is a small, well-defined change.

The second is the alphabet. Restricting output to 26 uppercase letters plus 10 digits means each character carries only $log_2(36) approx 5.2$ bits instead of the 8 bits of a full byte. A 20-character value therefore holds about 103 bits of randomness rather than 160 @entropy-wiki, weaker than its length suggests.

== Password hashing (`utils/hash.py`)

All hashing goes through a small wrapper around PBKDF2, a standard function that turns a password into a fixed fingerprint by hashing it many thousands of times with a random salt. It makes each guess expensive in compute time.

The wrapper stores its result in a self-describing format, `pbkdf2$sha512$<salt>$<iterations>$<digest>`, that records the parameters used. This is what lets the login flow notice a hash made with outdated settings and quietly upgrade it (@roles-and-permissions). The security-critical iteration counts are set well above the wrapper's modest default of 20 000, and @iteration-counts lists them by what each one protects.

#figure(
    table(
      columns: (auto, auto, 1fr),
      stroke: 0.5pt,
      fill: (col, row) => if row == 0 { luma(220) } else { white },
      align: (left, center, left),
      table.header[Protects][Iterations][Where it is used],
      [Donor e-mail hash], [50 000],  [The donor's identifier in the `submissions` and `users` tables],
      [Account password],  [50 000],  [The server-side password hash checked at login],
      [Data Encryption Key], [500 000], [Deriving a donor's DEK (highest cost, the main secret)],
      [Consent-form e-mail], [100 000], [The e-mail hash stored with the consent form (`cf` table)],
  ),
  caption: [PBKDF2 iteration counts, grouped by what each hash protects (`config.py`).]
)<iteration-counts>

== Data encryption (`utils/aes.py`)

Symmetric encryption, using one secret key both to encrypt and decrypt, is handled by an AES-256 wrapper. It takes whatever key it is given (a password, a PBKDF2 hash, or the DEK), reduces it to the required 32 bytes with a single SHA-256 hash, and encrypts in CBC (Cipher Block Chaining) mode with a fresh random initialisation vector (IV) on every call, so encrypting the same text twice never yields the same ciphertext. The stored form is `AES256$<iv>$<ciphertext>`.

Two design choices deserve a critical eye. First, integrity is checked by prepending a fixed marker, `"icnml$"`, to every plaintext and confirming it reappears after decryption, discarding the result otherwise. This is a substitute for real authenticated encryption. It detects gross corruption but does not cryptographically prove the ciphertext was produced by ICNML, unlike the AES-GCM used in the watermarking work (@watermark-implementation). Second, decryption wraps everything in a bare `except` that returns a plain `"-"` on any failure.

== High-level contexts (`utils/encryption.py`)

The top layer packages the primitives into the contexts the application actually calls. The main one is session-scoped encryption. At login, a PBKDF2 hash of the user's password (salted with the fixed string `"AES256"`) is placed in the session, and two wrappers, `do_encrypt_user_session` and `do_decrypt_user_session`, use it as the key. This is what binds a submitter's reversible data, the donor e-mail and nickname, to their live session (@per-donor-security). Without that session key, the ciphertext cannot be opened. The other context, per-donor DEK encryption, is covered in the per-donor security chapter.

== Assessment

The toolbox gets the fundamentals right. PBKDF2 with high iteration counts, a fresh IV per encryption, self-describing hashes that enable transparent upgrades, and a clean separation between the primitive and high-level layers are all sound.

The weaknesses cluster at two levels. At the base, `rand.py` uses a predictable generator over a reduced alphabet, and because everything depends on it (@crypto-stack-fig), this is the highest-value fix, moving to the `secrets` module over a full-byte alphabet. In the encryption layer, the `"icnml$"`-prefix integrity check and the error-swallowing CBC decryption should give way to authenticated encryption (AES-GCM), which provides confidentiality and integrity together. Neither change is architectural. Both replace a DIY mechanism with the standard one.
