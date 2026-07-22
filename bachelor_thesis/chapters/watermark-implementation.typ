#import "../macros.typ": note, concept

= Implementing a Traceable Watermark <watermark-implementation>

#concept[
  This chapter builds the traceable watermark that the previous chapter designed, and measures how well it works. Each time an authorised user downloads a biometric image, ICNML spreads an invisible, encrypted payload identifying that download across the whole picture, so a leaked copy can later be tied back to the account it came from, even after recompression, resizing or cropping. The chapter follows the payload from what it encodes, through how it is hidden and recovered, to how it is wired into ICNML, and closes with an evaluation against a battery of image attacks.
]

The previous chapter surveyed how a leaked image can be traced back to the recipient it was issued to, and settled on a design: an error-correcting code layer (Reed-Solomon) carrying an encrypted recipient identifier, embedded by a transform-domain watermark. This chapter describes the working implementation of that design that was added to ICNML, explains each choice, and reports how well it performs when the marked image is attacked.

The goal is worth restating in forensic terms. A biometric image leaves ICNML when an authorised user downloads it. If that image later resurfaces somewhere it should not, the institution needs to answer one question: which download did this copy come from? A watermark answers it by writing an invisible payload into the image itself, so the payload travels with the picture even after it has been recompressed, resized or cropped. Unlike the existing barcode tattoo (@tattooing) which is a visible strip that a simple crop removes, the payload described here is spread invisibly across the whole image.

== Composition of the payload <wm-payload>

Before hiding anything, the system decides what to hide. Each marked copy carries a small identity record, the payload, built from three facts already known at download time:

#figure(
  table(
    columns: (auto, auto, 1fr),
    stroke: 0.5pt,
    align: (left, left, left),
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    table.header[Field][Size][Meaning],
    [`user_id`], [4 bytes], [the authenticated account that requested the download],
    [`file_uuid`], [16 bytes], [which stored image this copy is of],
    [`timestamp`], [4 bytes], [when the download happened (Unix time)],
  ),
  caption: [The 24-byte identity record embedded in every downloaded copy (`watermark/__init__.py`).]
)

This record is not embedded as-is. It passes through two protective layers first, in the order shown in @watermark-pipeline.

The first layer is encryption with authentication. The record is encrypted with AES-256 in Galois/Counter Mode (AES-GCM) @nist80038d. Encryption matters because the payload should not itself leak who downloaded a file to anyone who learns the embedding recipe. Only ICNML, holding the secret key, can read it back. The "authentication" part adds a short cryptographic seal (a 16-byte tag): when the payload is later recovered, ICNML can verify the seal and be certain the identity it reads is one it actually wrote, not a coincidence or a forgery. This is what lets a recovered payload support an accusation rather than a guess.

The second layer is error correction. The encrypted record is wrapped in a Reed-Solomon code @reed60, which appends 32 bytes of redundancy. Reed-Solomon works on whole bytes (symbols) rather than single bits, and can repair any 16 corrupted bytes out of the codeword. The encryption and Reed-Solomon pairing is important as encryption is brittle by design. If even one bit of the encrypted record is wrong, decryption fails completely, there is no "almost right" ciphertext. The lossy channel of a watermarked image will flip bits. Error correction absorbs those flips so that the encryption layer always receives an exact, unmodified record to decrypt. The two layers protect against different things and neither replaces the other.


The result of these two layers is a fixed-length string of bits, 672 bits in the current configuration (84 bytes: 12 for the encryption nonce, 24 for the record, 16 for the authentication seal, 32 for the Reed-Solomon redundancy), that is now is ready to be hidden in the picture.

== Where the payload lives: hiding bits in an image <wm-carrier>

Writing bits into an image so that they survive editing is a signal-processing problem. The core idea, established in the state-of-the-art chapter, is to embed in a transform domain rather than in the raw pixels. Instead of nudging individual pixel brightnesses (which the smallest edit disturbs), the image is described in terms of frequency-like coefficients, and the payload is written into the coefficients that survive ordinary handling.

The implementation follows four principles, each answering a specific way an image gets damaged.

/ Work on 8x8 blocks, in the mid frequencies : The image is cut into small 8x8 tiles, and each tile is transformed with the Discrete Cosine Transform, the same tiling that JPEG itself uses. Within each tile, the payload is written only into the middle frequency band. Low frequencies carry the broad shading a viewer notices immediately, and high frequencies are exactly what JPEG throws away when it compresses. The middle band is the compromise, robust to compression, yet not visually obvious. This is what buys JPEG robustness

/ Scatter every bit across the whole image : No bit is written in a single place. Each bit of the payload is embedded redundantly into many tiles scattered pseudo-randomly across the picture, and recovery pools the evidence from all of them by majority. A crop deletes some copies of each bit, but as long as enough scattered copies survive somewhere in the remaining region, every bit is still recoverable.

/ Encode each bit by quantisation, not by adding a pattern : ICNML's images are mostly grayscale, so the payload has nowhere to hide except in the very luminance the fingerprint ridges are made of. The scheme uses Quantisation Index Modulation @chen01: to write a bit into a tile, a keyed measurement of that tile is nudged onto one of two interleaved "grids", one grid meaning 0, the other meaning 1. Recovery simply checks which grid the measurement is closest to.

/ Make the strength follow the local texture : How hard the payload is pushed into each tile is scaled by how textured that tile already is. Strong payloads hide inside strong ridges where the eye cannot see them. Near-blank background tiles receive almost nothing. This is perceptual masking, and it is why the marked images score so well on perceived-similarity measures even where the raw pixel difference is not tiny (@fig-masking).

#figure(
  image("../assets/plots/region_masking.png", width: 92%),
  caption: [The retained gain-invariant scheme on one print, zoomed into a high-information region of dense ridges and a low-information background region. The embedded crops are indistinguishable from the cover, while the amplified difference (×10) shows the mark filling the textured ridges and barely touching the flat background. This is the perceptual masking that keeps the mark invisible.],
)<fig-masking>

The one refinement worth explaining is gain invariance, because it is the distinguishing feature of the scheme that was retained. A common, innocent transformation is a change of brightness or contrast, or a gamma correction applied by a viewer. Under plain quantisation, multiplying every pixel by, say, 1.1 shifts every measurement off its grid and the payload becomes unreadable, even though the image looks unchanged. The implemented scheme sidesteps this by measuring each tile relative to itself. It divides the quantised measurement by a reference computed from a low-frequency coefficient of the same tile, a coefficient the embedding never touches. When brightness scales up, both the measurement and its reference scale by the same factor, and their ratio, the thing that actually decides the bit, does not move. This is Rational Dither Modulation @perezgonzalez05, adapted here to use a per-tile reference so that it also survives cropping (a global reference would shift whenever a crop changes which part of the image remains).

#note[Two named variants exist in the code (`watermark/scheme.py`): `stdm-block`, the fixed-step baseline, and `stdm-gain`, the gain-invariant variant that is the default. They share all the block machinery and differ only in how the quantiser step is set.]

== Undoing geometry: resynchronisation <wm-resync>

Rotation and rescaling are a harder class of attack than compression or cropping. They do not merely corrupt a few bits, they slide the entire 8x8 grid out of alignment, so the recovery step reads every tile from the wrong place and recovers nothing. The code layer cannot help here. Indeed, error correction fixes scattered errors, not a loss of alignment.

The implementation handles this with an optional resynchronisation step used only during verification, when ICNML still holds the original stored image to compare against (`watermark/resync.py`). It finds distinctive keypoints in both the suspect copy and the original, matches them, and computes the rotation-plus-scale transform that best maps one onto the other (ORB features with a RANSAC fit, discarding mismatches. See glossary.). Applying the inverse transform snaps the suspect copy back onto the original's grid, after which ordinary recovery proceeds. The same step also tries a few forensic-specific normalisations, inverting the grayscale or mirroring the image, since those are edits a fingerprint copy plausibly undergoes.

#figure(
  image("../assets/plots/output-orb.webp", width: 75%),
  caption: [Example of matching feature for an image using OpenCV's ORB detector. @gfgorb]
)

Verification therefore proceeds in the two following attempts. First read the payload directly, and only if that fails, then resynchronise against the original and read again (`watermark_verify/verify.py`). The direct path covers the common cases (compression, brightness, mild cropping), the resync path is the fallback for geometric distortion.

== How it is wired into ICNML <wm-integration>

The watermark is applied at the moment of download. When an authenticated user downloads a full-resolution image, the serving code embeds a freshly built payload for that user before the bytes leave the server (`watermark/service.py`). At the same time, ICNML writes one row to a `watermark_event` audit table recording the file, the user, the encryption nonce (Number only used once), and a digest of the payload. This row is the server-side ledger. On recovery, the identity read out of a suspect image is cross-checked against it, confirming that the payload corresponds to a real, logged download.

The feature fails safe and fails open. If the watermark keys are not configured, or if embedding raises an error, the download is still served (with the existing visible tags), and the event is logged. A biometric image being available to its authorised user is treated as more important than guaranteeing the invisible payload, an explicit operational choice recorded in the code.

Recovery is exposed to administrators through a dedicated verification page (`watermark_verify` blueprint). An administrator uploads a suspect image, optionally alongside the original, and the page reports the recovered `user_id`, the matching user record, the originating download event, and whether resynchronisation was needed.

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    align: (left, left),
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    table.header[Component][Role],
    [`watermark/base.py`], [image -> luminance conversion, the watermarker interface],
    [`watermark/codec.py`], [AES-GCM encryption and Reed-Solomon coding of the payload],
    [`watermark/scheme.py`], [the two embedding schemes and their keyed layout],
    [`watermark/resync.py`], [geometric resynchronisation for the verification path],
    [`watermark/service.py`], [download-time embedding and audit logging],
    [`watermark_verify/`], [the administrator recovery interface],
  ),
  caption: [The watermarking module added to ICNML.]
)

== Two independent secrets <wm-security>

The security of the scheme rests on two keys that do different jobs, and it is worth separating them because they fail differently.

The embedding key seeds the scattering of bits across tiles, the secret directions the measurements are taken along, and the placement of the two quantiser grids. Without it, an attacker who knows the entire published algorithm still cannot read the payload. They do not know where each bit is, nor along which axis it was written. This follows Kerckhoffs's principle @kerckhoff, the algorithm is public, only the key is secret.

The encryption key protects the identity itself. Even a complete break of the embedding key yields only ciphertext. Without the encryption key it cannot be turned into a name, and it cannot be forged into an accusation against someone else, because the authentication seal would not verify.

Two limitations are stated honestly, as they bound what the current implementation should claim:

- Reusing one key across many images leaks it slowly. The watermarking-security literature @cayre05 shows that an adversary holding many images marked with the same key can gradually estimate the secret. In ICNML's threat model the adversary is a leak recipient holding one or a few copies and no originals, the weak end of that spectrum, but per-donor or per-submission keys are the mitigation if this becomes a concern.
- Keys prevent reading and forging, not erasing. An attacker who only wants to destroy the payload can still try heavy compression or noise. Whether they succeed is a robustness question, answered by the evaluation below, not a security one.

== Does it work? Evaluation <wm-evaluation>

The scheme was measured, not merely discussed. An evaluation script (the `test-scripts` repository) embeds an encrypted identifier with each candidate scheme, subjects every marked copy to a battery of 32 attacks, and reports three things:

+ One how many bits were flipped (bit error rate). 
+ Two whether the full identifier was recovered exactly end-to-end. 
+ Three how much the image was visibly degraded. 

The attack battery covers the ordinary signal-processing distortions (JPEG at several qualities, cropping, rotation, rescaling, brightness and gamma changes, noise, blur) and a forensic-workflow family specific to fingerprints: grayscale inversion, mirroring, contrast equalisation, sharpening, and round-trips through WSQ, the FBI's fingerprint compression format. The carriers are thirty fingerprint, palm-print and tenprint images from ICNML.

A fourth criterion is biometric utility. Using the open-source FingerJetFX minutiae extractor @fjfx, the script measures what fraction of a print's identifying minutiae still survive after the payload is embedded, an indication of how much the embedding disturbs the automatic minutiae detection a forensic examiner relies on.

Six schemes were put through the identical carriers and attacks: the four STDM variants developed for this thesis (`stdm-block`, `stdm-gain`, `stdm-tiled` and `stdm-global`) and two off-the-shelf library watermarkers kept as baselines (`bw-svd`, the `blind_watermark` DWT-DCT-SVD scheme, and `imw-dwtdct`, the `invisible-watermark` DWT-DCT scheme).

#figure(
  image("../assets/plots/overall_recovery.png", width: 88%),
  caption: [Identifier recovery pooled over the whole 32-attack battery, one dot per carrier image. The tight ST-DM clusters separate cleanly from the widely-scattered library baselines.]
)<fig-overall-recovery>

Pooled over the whole battery (@fig-overall-recovery), the schemes separate cleanly. `stdm-block` recovers the identifier from 89% of attacked copies and `stdm-gain` from 84%, ahead of `stdm-tiled` (74%), the `bw-svd` baseline (70%), `stdm-global` (68%) and, far below, `imw-dwtdct` (22%). The per-image dots show this is not the work of a few lucky carriers as the ST-DM variants stay tight while the baselines scatter.

#figure(
    image("../assets/plots/recovery_heatmap.png"),
    caption: [Exact identifier recovery for every scheme and attack, grouped by attack family. Warm cells are failures, cool cells successes. The blank forensic block for the two library baselines marks attacks they were never run against.]
  )<fig-recovery-heatmap>

Which attacks actually break each scheme is laid out in the per-attack recovery matrix (@fig-recovery-heatmap). Strong JPEG (quality 10) and heavy crops are the universal stress points (@fig-jpeg-robustness, appendix, traces the JPEG case quality by quality), `stdm-global` collapses under cropping (8% recovered), and `stdm-gain`'s one soft spot is the combined attacks (40-47%) that stack a geometric distortion on top of compression. The error-correcting layer is what keeps the rest of the matrix green, @fig-rs-margin (appendix) shows how much of the 16-byte Reed-Solomon budget each attack family consumes, and for every family bar the hardest combined cases the median stays comfortably below the correctable limit, this proves that the correction layer is important and interesting in our usecase.

Before pooling fidelity across the library, it helps to see the effect on a single print. @fig-contact-sheet embeds one palm print with all six schemes and amplifies the resulting payload ten-fold. The embedded prints (upper row) are indistinguishable from the cover to the eye, exactly the point of an invisible payload. The amplified difference (lower row) is where the schemes part ways, the ST-DM variants leave only a faint trace, `stdm-gain` the faintest. `stdm-global` sprays a uniform speckle across even the flat background it need not touch, and the `bw-svd` baseline lays heavy, structured noise over the whole print, the visible damage its lower fidelity score reflects.

#figure(
  image("../assets/plots/embed_contact_sheet.png", width: 100%),
  caption: [One palm print embedded by each of the six schemes (upper row, with per-image PSNR and SSIM), and the same watermark amplified ten-fold (lower row). The embedded prints are perceptually identical to the cover, while the amplified difference reveals how much each scheme disturbs the image and where.]
)<fig-contact-sheet>

Raw robustness is only half the decision. @fig-fidelity generalises that single example across all thirty carriers: `stdm-gain` embeds at a mean SSIM of 0.98, essentially indistinguishable from the stored original, whereas the equally-robust `stdm-block` sits at 0.93 and the `bw-svd` baseline falls to a visibly degraded 31 dB PSNR.

#figure(
  image("../assets/plots/fidelity.png", width: 100%),
  caption: [Imperceptibility of the embedded payload, one point per image. `stdm-gain` reaches a near-original SSIM of 0.98.]
)<fig-fidelity>

#figure(
  image("../assets/plots/tradeoff.png", width: 80%),
  caption: [The decision plot. Robustness against imperceptibility, with payload size encoding minutiae retention. `stdm-gain` is the only scheme in the top-right corner, robust and near-invisible at once.]
)<fig-tradeoff>

This is the heart of the choice, drawn together in @fig-tradeoff, which plots robustness against imperceptibility with payload size encoding biometric utility. The retained scheme, `stdm-gain`, is not the highest scorer on raw recovery, and it is chosen on a threat-model argument rather than a leaderboard one. It is the only scheme that sits in the top-right corner, high robustness and high fidelity together, and it is the most robust of all to the innocent photometric edits (brightness, contrast, gamma) a forensic image is most likely to undergo in ordinary use, which is exactly what its gain-invariant design was built to buy.

The two library baselines were evaluated and set aside for two independent reasons. They are weak, `imw-dwtdct` recovers only 22% of copies and fails outright on JPEG and on every combined attack, while `bw-svd`, though more robust, degrades the print too far to be usable. They are also terribly slow on ICNML's imagery (3-5min per images). The library implementations are written for small consumer photographs, whereas ICNML's prints routinely run to tens or hundreds of megapixels, so a single embed-and-attack pass was slow enough that the baselines could only be run over a reduced subset (286 trials each, against 1020 for every ST-DM variant) and were never subjected to the forensic family at all. Writing a transform-domain scheme was therefore not a matter of preference but rather of necessity.

== Limitations and future work <wm-limits>

The implementation deliberately scopes the adversary to a single redistributing recipient, so it uses an error-correcting code rather than a collusion-resistant fingerprinting code (Tardos). If future ICNML workflows distribute distinctly-marked copies to many students at once, several of whom might compare their copies to erase the trace, the code layer would need to be revisited.

