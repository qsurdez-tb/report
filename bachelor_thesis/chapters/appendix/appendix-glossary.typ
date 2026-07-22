= Glossary <glossary>

This glossary collects the recurring technical terms of the thesis, from the biometric, security and signal-processing domains, in one place. Each term is defined in plain language on first use in the text as well. This is the single reference to return to. The watermarking-specific vocabulary is defined more fully in the terminology section of the state-of-the-art chapter (@state-of-the-art).

/ AES-GCM : Advanced Encryption Standard in Galois/Counter Mode. A way of encrypting data that also produces a short cryptographic "seal" (a tag). Anyone with the key can both read the data back and verify that it was not altered or forged.

/ AFIS : Automated Fingerprint Identification System. Software that searches a fingerprint or fingermark against a database of known prints and returns a shortlist of candidates for an examiner to compare.

/ BER : Bit Error Rate. The fraction of embedded bits that come back wrong after an image has been attacked. It measures how robust a watermark is (lower is better).

/ CSK : Client-Side Key. A key derived from the user's password inside the browser that never leaves the browser. ICNML uses it to encrypt items the user must be able to read back but the server should not, such as filenames and the donor email shown to the submitter.

/ DCT : Discrete Cosine Transform. A standard mathematical operation that re-describes a small image tile in terms of frequencies (broad shading versus fine detail) instead of raw pixel values. It is the same operation JPEG compression is built on.

/ DEK : Data Encryption Key. A per-donor key that encrypts all of that donor's biometric images.

/ FIDO2 / WebAuthn : an open standard for logging in with a physical security key (such as a USB device) instead of, or in addition to, a password. It is resistant to phishing because the key proves its identity to the exact physical device only. ICNML uses it as the strong second factor for administrators.

/ Latent mark : a fingermark left unintentionally on a surface, for example at a crime scene. Latent marks are usually partial, distorted and of variable quality, which is what makes their assessment and comparison difficult.

/ Minutiae : the small, individual features of a fingerprint's ridge pattern, for example ridge endings and bifurcations (points where a ridge splits). Fingerprint identification, whether by an examiner or by AFIS, rests on comparing minutiae.

/ OpenLQM : an open-source Local Quality Metric for fingerprint images, from the quality-metric lineage published by the United States National Institute of Standards and Technology (NIST). It scores how usable a print is with 13 different metrics.

/ Payload : the actual sequence of bits embedded into an image by a watermark. In this thesis the payload encodes an encrypted recipient identifier.

/ PBKDF2 : Password-Based Key Derivation Function 2. A deliberately slow method that turns a password into a key by hashing it many thousands of times together with a random salt.

/ PiAnoS : A web-based tool developed at the School of Criminal Justice of the University of Lausanne for viewing fingermarks and annotating their minutiae.

/ PSNR / SSIM : two measures of how much a watermark degrades an image. PSNR (Peak Signal-to-Noise Ratio, in decibels) compares raw pixel differences. SSIM (Structural Similarity, from 0 to 1) is closer to how a human perceives similarity. Higher is better for SSIM while for PSNR it can vary for each image which makes the metrics not very reliable.

/ QIM : Quantisation Index Modulation. A watermarking technique that writes a bit into an image by rounding a measurement of the image onto one of two interleaved grids, one grid meaning 0, the other meaning 1. Reading the bit back needs only the marked image, not the original.

/ Reed-Solomon code : an error-correcting code that adds redundancy to data so that a bounded number of corrupted symbols can be repaired exactly. It works on whole bytes, which suits localised damage such as a crop.

/ Regular expression (regex) : a compact text pattern used to search for or match strings that follow a given shape (for example, "a UUID" or "a date"). It is a standard tool for finding and extracting structured text.

/ Salt : a random value combined with a password before hashing, so that two identical passwords do not produce the same stored hash and precomputed guessing tables cannot be reused.

/ TOTP : Time-based One-Time Password. The six-digit codes, refreshed every thirty seconds, produced by an authenticator app. ICNML uses TOTP as a second authentication factor for non-administrator accounts.

/ Watermarking / Fingerprinting : embedding information directly into the content of an image so it travels with the picture. When each distributed copy carries a different mark identifying its recipient, so a recovered copy can be traced back to whom it was issued, the practice is called fingerprinting or traitor tracing.
