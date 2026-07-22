#import "../macros.typ": note, concept

= State of the Art for Tracing the Source of a Leaked Image <state-of-the-art>

#concept[
  When a biometric image issued by ICNML leaks, the question is which recipient it came from. This chapter surveys how the literature answers that question, by hiding a recipient identifier inside the image so it can be recovered even after the copy has been recompressed, cropped or rotated. It separates the two independent pieces every such scheme needs, a code layer that keeps the identifier readable through damage and a watermark that hides it robustly, and narrows the many published options down to the design this thesis implements.
]

This part of the thesis concerns source identification after a leak. When a grayscale biometric image issued by ICNML reappears outside the system, the goal is to recover which recipient it was given to. Even after the file has been reencoded, rescaled, cropped or rotated.

At a high level, the process is a loop. A recipient identifier is embedded into the image, the marked copy is handed to that recipient, the copy is later shared or leaked and possibly distorted and the identifier is finally recovered from the suspect copy to designate the recipient it was issued to.

#figure(
  image("../assets/watermark-sota-generic.drawio.png", width: 80%),
  caption: [Generic source identification after a leak.]
)

A solution to this problem is built from two largely independent layers. A code layer turns a recipient identifier into a redundant sequence of symbols that can be recovered even if distorted, and a watermark scheme embeds those symbols into the image with as little noise as possible and in a robust way so that compression, rescaling, etc... doesn't corrupt the symbols.

== Terminology

The two communities this work draws on, signal processing on one side and coding theory on the other, use a dense and overlapping vocabulary.

/ Watermarking : the act of embedding information (the payload) directly into the content of an image so that it is carried by the image itself rather than by a separate file or header. Robust watermarking specifically aims for the payload to survive distortion of the image.

/ Recipient identifier : A recipient identifier is any information allowing to identify a recipient amongst others. In the case of this work, it would a user id from the database and a timestamp.

/ Payload : the sequence of bits or symbols actually embedded into the image. Here the payload encodes a recipient identifier.

/ Fingerprinting : watermarking where each distributed copy carries a different payload, one per recipient, so that a recovered copy can be tied back to the specific recipient it was issued to. Also called traitor tracing.

/ Recipient : the entity a marked copy is issued to and that a recovered payload designates. In ICNML this is the party who downloads an image.

/ Collusion : an attack where several recipients, each holding a differently marked copy of the same image, compare their copies to forge a new copy whose payload traces back to none of them. A group of such recipients is a coalition.

/ Marking assumption : the rule that defines what a coalition can do. Where all colluders' copies agree on a symbol, that symbol cannot be altered undetected. Where the copies differ, the coalition may set the symbol freely.

/ Imperceptibility : how little the embedding degrades the visible image. Measurements in the litterature are peak signal-to-noise ratio (PSNR) or structural similarity (SSIM).

/ Robustness : how well the payload survives distortions of the image. Measurement in the litterature is bit error rate (BER).

/ Capacity : how many payload bits the image can carry.

/ Transform domain : a representation of the image in terms of frequency-like coefficients (for example wavelet or cosine coefficients) rather than raw pixels. Embedding in this domain is more robust than embedding in the pixels directly.

/ Code layer : the step that turns a short identifier into a longer, redundant sequence of symbols and reconstructs the identifier from a distorted reading.

/ Synchronisation : recovering the alignment of the embedding grid before reading the payload. Geometric distortions desynchronise this grid, which is a distinct problem from ordinary symbol errors.

== Attack model

The scheme is defined by what it is expected to survive, so the adversary and the distortions in scope are stated explicitly.

The adversary is a single recipient who redistributes the one copy they received. Their goal is to reuse or share the image while stripping the traceability, either deliberately or as a side effect of ordinary handling. The attacks in scope are the signal-processing and geometric distortions a redistributed image typically undergoes:

- lossy recompression (for example JPEG)
- rescaling (down- or up-sampling)
- cropping of a region of the image
- rotation and small translations

A threat out of scope is downsampling so aggressive that the biometric content itself is destroyed. Such an attack defeats any watermark, but it also defeats the attacker's purpose, since the image is no longer usable as a biometric.

The defender's goal is to recover the recipient identifier from a leaked copy that has undergone any combination of the in-scope attacks.

== Evaluation criteria

Every watermarking scheme is governed by a three-way trade-off between imperceptibility, robustness and capacity. Improving one of these properties degrades at least one of the others @cox07. In the present context, three further criteria refine the picture. 

The first is traceability. The payload must reliably carry enough information to designate one recipient among all of them. In ICNML the identifier is an encrypted recipient token of a few hundred bits.

The second is the attack model the scheme is expected to survive. Distinguishing a single redistributor from a coalition is what separates the two code families discussed below @cox02.

The third is specific to ICNML and it is the reference observer. Imperceptibility is judged against a forensic examiner, since that is to whose an image is intended. Preserving automated (AFIS) matching performance on marked copies is not a requirement of this work. Actually a watermark that perturbs automated matching of a leaked copy is beneficial, as it reduces exploitability of a leaked biometric image. 

== The code layer

=== Collusion-resistant fingerprinting

Fingerprinting codes assign a distinct codeword to each recipient and are designed to remain traceable even under collusion. Their definition constraint is the marking assumption where all colluders' copies agree on a symbol, that symbol cannot be altered without detection, but where the copies differ the coalition may set the symbol freely. The first codes provably secure under this assumption were proposed by Boneh and Shaw @bs98, at the cost of long codewords.

Tardos @tardos08 reduced this length with a probabilistic construction whose length is optimal. Each recipient's codeword is created symbol by symbol from a distribution parameterised by a per-position bias and tracing is performed with an accusation score. A code of length 

$ m = O(c^2 ln(n / epsilon)) $

is sufficient to accuse, with false-positive probability $epsilon$, at least one member of any coalition of up to $c$ recipients among $n$. Following work reduced the length like the method proposed by Skoric et al. @skoric08 that uses symmetric two-sided scoring which improved the accusation power. Then even tighter analyses shortened the codewords further @laarhoven14. This family of codes has been paired with transform-domain watermarking for video @rehman22 in literature. Tardos codes are the state of the art for collusion-resistant fingerprinting.

=== Why Tardos is set aside

Despite their optimality, Tardos codes were investigated and not retained for ICNML for several reasons: 

1. Threat model (decisive)
Tardos codes defend against a coalition exploiting the marking assumption. The threat model for this work, agreed with the supervisor, scopes the adversary to a single recipient redisitrbuting the one copy they received. 

2. Capacity cost (secondary)
The quadratic dependence on the coalition size $c$ makes the codeword length grow to thousands of symbols even for modest parameters. For the full resolution images of ICNML this is not a hard blocker on its own but it reinforces the first reason as there is nothing to offset the cost.

=== Error-correcting codes

Once collusion is out of scope, the code layer becomes a classical error-correction problem. Indeed, the problem is to send to a recipient an identifier through a noisy channel and recover it intact despite potential distortions.

Reed-Solomon (RS) codes fit this well. They work on symbols, small groups of bits, rather than single bits. An $"RS"(n, k)$ code adds $n - k$ redundant symbols to $k$ data symbols and can repair up to 

$ t = floor((n - k) / 2)$

corrupted ones. Working on symbols is the key advantage here, because a localised attack such as cropping damages a contiguous region of the image, which maps to a few whole symbols rather than many scattered bits, which is what RS corrects the most efficiently and what is probably one of the most likely attack for ICNML biometric images. RS has been used as the coding layer of wavelet-domain schemes @abdul13 and of a scheme designed specifically to resist JPEG compression and cropping @liu25. 

It recovers the payload in a deterministic way and costs only $n - k$ extra symbols. This is very interesting if the embedded bits are an encrypted token as this ensures all the bits will be extracted, if the corrupted symbols stay within the correction budget $t$, and then the token can be decrypted by the server to accuse the recipient that realeased the image with precision.

== Studied watermarking schemes

=== Spread-spectrum watermarking

The foundational principle for robust embedding is spread spectrum. The payload is treated as a low-power signal spread across many perceptually significant components of the image, so that no single component reveals or carries the whole mark and an attacker cannot remove it without degrading the image @cox97. This principle is introduced for multimedia by Cox et al. and consolidated in the reference text on the subject @cox07. 

It underlies the transform-domain schemes in use today and frames how a recipient identifier can be hidden robustly enough to be recovered after a leak.

=== Decomposition-based hybrids

The robustness of the embedding itself comes largely from the domain in which symbols are inserted. Rather than the spatial domain, modern robust schemes work in a transform domain, where the payload is spread across coefficients that survive compression and geometric edits. Hybrid constructions that combine several decompositions, for example a wavelet transform (DWT) with a singular value decomposition (SVD), concentrate robustness while preserving imperceptibility @abdul13 @liu25.

Most of these schemes were designed for colour images, where the payload can be hidden in a colour channel. On the grayscale images ICNML handles, the payload competes directly with the luminance the biometric content lives in, which tightens the imperceptibility budget.

=== Quantisation-based embedding

Where spread-spectrum adds the payload to the image, Quantisation Index Modulation (QIM) encodes each symbol by quantising a host feature with one of several quantisers @chen01. Detection reads the symbol back from whichever quantiser the feature is closest to, without the original image. Dither Modulation is its practical form, using dithered uniform quantisers.

Spread-Transform Dither Modulation (ST-DM) combines the two @chen01. The image is projected onto a pseudo-random direction and dither modulation is applied to that projection. It keeps QIM's blind detection while gaining robustness from spreading the mark over many coefficients. Applied per block on the mid-band of a block DCT, it stays on the JPEG grid. Embedding each symbol redundantly across scattered blocks then manages the payload survive cropping, as the surviving blocks still carry every symbol.

=== Learned watermarking

A more recent family trains end-to-end neural encoder-decoder pairs to embed and extract the payload, starting with HiDDeN @zhu18 and its successors. These schemes are set aside here as the substrate they've been trained on is mainly composed of small colour images which is not the kind of image ICNML works on. They also require GPU inference at embedding time and their learned behaviour is harder to audit than a deterministic scheme. This is a relevant concern when the extracted payload is meant to support an accusation.

== Synchronisation against geometric attacks

Geometric distortions, rotation, scaling, translation and cropping, are the hardest class for a block-transform scheme. Indeed, the distortions do not merely flip a few bits, they desynchronise the embedding grid, misaligning every block at once and producing an error rate far beyond what the code layer can correct. A handful symbol errors is what an error-correcting code is designed for. However, a loss of synchronisation is not. The recent literature addresses this through two distinct strategies.

The first approach avoids the problem instead of correcting it. The payload is hidden using image features that barely change when the image is rotated, scaled or shifted. This allows the watermark to be read back without ever undoing the distortion. Recent works use image moments which are compact mathematical descriptors of the image whose values stay almost the same under these geometric changes @ma20. The trade-off is that it leaves room for only a small payload.

The second strategy corrects the problem directly. It works out how the image was rotated, scaled or shifted and reverses that transformation before reading the watermark. To find the transformation, some methods find points in the image that move with it, then realign the image using those points as anchors. A recent algorithm combines this with a DWT-SVD scheme @xi24. Other recent work instead trains a neural network to recognise how the image was distorted and undo it before decoding @li23.

Once the image is realigned, only small scattered errors remain, the kind the code layer with RS already corrects. This approach work hand in hand with error correction.

#figure(
  image("../assets/example-sync.png", width: 80%),
  caption: [Original, Augmented, Resynchronized. Geometric desynchronisation and the result of resynchronisation @syncseal25]
)

== Retained approach

This thesis combines a transform-domain watermark with a Reed-Solomon code layer, rather than a collusion-resistant fingerprinting code. Because only a single recipient is in scope, Reed-Solomon is enough. 

#figure(
  image("../assets/watermark-pipeline.drawio.png", width: 70%),
  caption: [End-to-end source identification after a potential leak.]
)<watermark-pipeline>

The watermarking scheme is not yet fixed. Two candidates from the previous sections are explored. One is a decomposition-based hybrid in the DWT-DCT-SVD domain, the other is a Spread-Transform Dither Modulation. They are compared along the criteria established above such as robustness under the in-scope attacks and the capacity each leaves for the code layer. Selecting the scheme is part of the implementation work. Candidate implementations under evaluation include the `blind_watermark` @blind-watermark package for the DWT-DCT-SVD hybrid and `reedsolo` @reedsolo for the Reed-Solomon layer.

Everyday distortions such as compression, mild cropping are handled by the code layer's built-in error correction. Rotation and rescaling, which throw the whole image out of alignment, are handled, only if needed, by a synchronisation approach. 

