#import "../macros.typ": note

= State of the Art for Tracing the Source of a Leaked Image <state-of-the-art>

This part of the thesis concerns source identification after a leak. When a grayscale biometric image issued by ICNML reappears outside the system, the goal is to recover which recipient it was given to. Even after the file has been reencoded, rescaled, cropped or rotated.

At a high level, the process is a loop. A recipient identifier is embedded into the image, the marked copy is handed to that recipient, the copy is later shared or leaked and possibly distorted and the identifier is finally recovered from the suspect copy to designate the recipient it was issued to.

#figure(
  image("../assets/watermark-sota-generic.drawio.png", width: 80%),
  caption: [Generic source identification after a leak.]
)

A solution to this problem is built from two largely independent layers. A code layer turns a recipient identifier into a redundant sequence of symbols that can be recovered even if distorted, and a watermark scheme embeds those symbols into the image with as little noise as possible and in a robust way so that compression, rescaling, etc... doesn't corrupt the symbols.

== Terminology

The two communities this work draws on, signal processing on one side and coding theory on the other, use a dense and overlapping vocabulary. The terms below are used throughout this chapter with the following meaning.

/ Watermarking : the act of embedding information (the payload) directly into the content of an image so that it is carried by the image itself rather than by a separate file or header. Robust watermarking specifically aims for the payload to survive distortion of the image.

/ Payload : the sequence of bits or symbols actually embedded into the image. Here the payload encodes a recipient identifier.

/ Fingerprinting : watermarking where each distributed copy carries a different payload, one per recipient, so that a recovered copy can be tied back to the specific recipient it was issued to. Also called traitor tracing.

/ Recipient : the entity a marked copy is issued to and that a recovered payload designates. In ICNML this is the party who downloads an image.

/ Collusion : an attack where several recipients, each holding a differently marked copy of the same image, compare their copies to forge a new copy whose payload traces back to none of them. A group of such recipients is a coalition.

/ Marking assumption : the rule that defines what a coalition can do. Where all colluders' copies agree on a symbol, that symbol cannot be altered undetected. Where the copies differ, the coalition may set the symbol freely.

/ Imperceptibility : how little the embedding degrades the visible image. 

/ Robustness : how well the payload survives distortions of the image.

/ Capacity : how many payload bits the image can carry.

/ Transform domain : a representation of the image in terms of frequeny-like coefficients (for example wavelet or cosine coefficients) rather than raw pixels. Embedding in this domain is more robust than embedding in the pixels directly.

/ Code layer : the error-correcting step that turns a short identifier into a longer, redundant sequence of symbols and reconstructs the identifier from a distorted reading.

/ Synchronisation : recovering the alignment of the embedding grid before reading the payload. Geometric distortions desynchronise this grid, which is a distinct problem from ordinary symbol errors.


== Evaluation criteria

Every watermarking scheme is governed by a three-way trade-off between imperceptibility, robustness and capacity. Improving one of these properties degrades at least one of the others @cox07. In the present context, two further criteria refine the picture. The first is traceability. The payload must reliably carry enough information to designate one recipient among all of them. The second is the attack model the scheme is expected to survive. Distinguishing a single redistributor from a coalition is what separates the two code families discussed below @cox02.

== The code layer

=== Collusion-resistant fingerprinting

Fingerprinting codes assign a distinct codeword to each recipient and are designed to remain traceable even under collision. Their definition constraint is the marking assumption where all colluders' copies agree on a symbol, that symbol cannot be altered without detection, but where the copies differ the coalition may set the symbol freely. The first codes provably secure under this assumption were proposed by Boneh and Shaw @bs98, at the cost of long codewords.

Tardos @tardos08 reduced this length with a probabilistic construction whose length is optimal. Each recipient's codeword is created symbol by symbol from a distribution parameterised by a per-position bias and tracing is performed with an accusation score. A code of length 

$ m = O(c^2 ln(n / epsilon)) $

is sufficient to accuse, with false-positive probability $epsilon$, at least one member of any coalition of up to $c$ recipients among $n$. Following work reduced the length like the method proposed by Skoric et al. @skoric08 that uses symmetric two-sided scoring which improved the accusation power. Then even tighter analyses shortened the codewords further @laarhoven14 and asymmetric variants addressed the buyer-seller trust problem @charpentier11, how a buyer can actually trust the seller in the case of many different sellers and buyers. This family of codes has been paired with transform-domain watermarking for video @rehman22 mostly in literature. Tardos codes are the state of the art for collusion-resistant fingerprinting.

=== Why Tardos is set aside

Despite their optimality, Tardos codes were investigated and not retained for ICNML for several reasons: 

1. Threat model
Tardos codes defend against a coalition exploiting the marking assumption. The scenario considered here is a single recipient redistributing one copy. 

2. Capacity cost
The quadratic dependence on the coalition size $c$ makes the codeword length grow to thousands of symbols even for modest parameters. This can be an actual problem for the watermarking scheme on images as the space available for redundancy is very limited.

=== Error-correcting codes

Once collusion is out of scope, the code layer becomes a classical error-correction problem. Indeed, the problem is to send to a recipient an identifier through a noisy channel and recover it intact despite potential distortions.

Reed-Solomon (RS) codes fit this well. They work on symbols, small groups of bits, rather than single bits. An $"RS"(n, k)$ code adds $n - k$ redundant symbols to $k$ data symbols and can repair up to 

$ t = floor((n - k) / 2)$

corrupted ones. Working on symbols is the key advantage here, because a localised attack such as cropping damages a contiguous region of the image, which maps to a few whole symbols rather than many scattered bits, exactly what RS corrects the most efficiently and what is probably one of the most likely attack for ICNML biometric images. RS has been used as the coding layer of wavelet-domain schemes @abdul13 and of a scheme designed specifically to resist JPEG compression and cropping @liu25. It recovers the payload in a determinist way and costs only $n - k$ extra symbols. This is very interesting if the embedded bits are an encrypted token as this ensures all the bits will be extracted and then the token can be decrypted by the server to accuse the leaker with precision.

== The watermarking scheme

=== Spread-spectrum watermarking

The foundational principle for robust embedding is spread spectrum. The payload is treated as a low-power signal spread across many perceptually significant components of the image, so that no single component reveals or carries the whole mark and an attacker cannot remove it without degrading the image @cox97. This principle is introduced for multimedia by Cox et al. and consolidated in the reference text on the subject @cox07. 

It underlies the transform-domain schemes in use today and frames how a recipient identifier can be hidden robustly enough to be recovered after a leak.

=== Decomposition-based hybrids

The robustness of the embedding itself comes largely from the domain in which symbols are inserted. Rather than the spatial domain, modern robust schemes work in a transform domain, where the payload is spread across coefficients that survive compression and geometric edits. Hybrid constructions that combine several decompositions, for example a wavelet transform (DWT) with a singular value decomposition (SVD), concentrate robustness while preserving imperceptibility @abdul13 @liu25.

=== Quantisation-based embedding

Where spread-spectrum adds the payload to the image, Quantisation Index Modulation (QIM) encodes each symbol by quantising a host feature with one of several quantisers @chen01. Detection reads the symbol back from whichever quantiser the feature is closest to, without the original image. Dither Modulation is its practical form, using dithered uniform quantisers.

Spread-Transform Dither Modulation (ST-DM) combines the two @chen01. The image is projected onto a pseudo-random direction and dither modulation is applied to that projection. It keeps QIM's blind detection while gaining robustness from spreading the mark over many coefficients. Applied per block on the mid-band of a block DCT, it stays on the JPEG grid. Embedding each symbol redundantly across scattered blocks then manges the payload survive cropping, as the surviving blocks still carry every symbol.

== Synchronisation against geometric attacks

Geometric distortions, rotation, scaling, translation and cropping, are the hardest class for a block-transform scheme. Indeed, the distortions do not merely flip a few bits, they desynchronise the embedding grid, misaligning every block at once and producing an error rate far beyond what the code layer can correct. A handful symbol errors is what an error-correcting code is designed for. However, a loss of synchronisation is not. The recent literature addresses this through two distinct strategies.

The first approach avoids the problem instead of correcting it. The payload is hidden using image features that barely change when the image is rotated, scaled or shifted. This allows the watermark to be read back without ever undoing the distortion. Recent works use image moments which are compact mathematical descriptors of the image whose values stay almost the same under these geometric changes @ma20. The trade-off is that it leaves room for only a small payload.

The second strategy corrects the problem directly. It works out how the image was rotated, scaled or shifted and reverses that transformation before reading the watermark. To find the transformation, some methods finds points in the image that move with it, then realign the image using those points as anchors. A recent algorithm combines this with a DWT-SVD scheme @xi24. Other recent work instead trains a neural network to recognise how the image was distorted and undo it before decoding @li23.

Once the image is realigned, only small scattered errors remain, the kind the code layer with RS already corrects. This approach work hand in hand with error correction.

#figure(
  image("../assets/example-sync.png"),
  caption: [Original, Augmented, Resynchronized. Geometric desynchronisation and the result of resynchronisation @syncseal25]
)

== Retained approach

This thesis combines a transform-domain watermark with a Reed-Solomon code layer, rather than a collusion-resistant fingerprinting code. Because only a single recipient is in scope, Reed-Solomon is enough. 
Implementation are found in python package `blind_watermark` @blind-watermark for the transform-domain watermark and `reedsolo` @reedsolo for the Reed-Solomon encoding and decoding.

#figure(
  image("../assets/watermark-pipeline.drawio.png", width: 80%),
  caption: [End-to-end source identification after a potential leak.]
)

Everyday distortions such as compression, mild cropping are handled by the code's built-in error correction. Rotation and rescaling, which throw the whole image out of alignment, are dealt with only if needed by a synchronisation approach. 

