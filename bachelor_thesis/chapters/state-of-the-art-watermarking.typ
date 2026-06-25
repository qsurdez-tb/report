#import "../macros.typ": note

= State of the Art <state-of-the-art>

This part of the thesis concerns source identification after a leak. When a grayscale biometric image issued by ICNML reappears outside the system, the goal is to recover which recipient it was given to. Recover it even after the file has been reencoded, rescaled, cropped or rotated.

The threat considered is a single recipient redistributing the copy they received, rather than a coalition of recipients. This framing matters. Indeed, it determines which family of codes is appropriate, and it is the reason a theoretically optimal but collusion-resistant construction is set aside in favour of a simpler error-correcting one. 

A solution to this problem is built from two largely independent layers. A code layer turns a recipient identifier into a redundant sequence of symbols that can be recovered even if distorted, and a watermark substrate embeds those symbols into the image imperceptibly and robustly.

== Evaluation criteria

Every watermarking scheme is governed by a three-way trade-off between imperceptibility, robustness and capacity. Improving one of these properties degrades at least one of the others @cox07. In the present context, two further criteria refine the picture. The first is traceability. The payload must reliably carry enough information to designate one recipient among all of them. The second is the attack model the scheme is expected to survive. For a single redistributor the relevant attacks are signal-processing distortions (compression, scaling, cropping, rotatino), whereas for a coalition the dominant threat is collusion, where several recipients compare their differently marked copies to forge an untraceable one @cox02. Distinguishing these two attack models is what separates the two code families discussed below.

== The code layer

=== Collusion-resistant fingerprinting

Fingerprinting codes assign a distinct codeword to each recipient and are designed to remain traceable even under collision. Their definition constraint is the *marking assumption* where all colluders' copies agree on a symbol, that symbol cannot be altered without detection, but where the copies differ the coalition may set the symbol freely. The first codes provably secure under this assumption were proposed by Boneh and Shaw @bs98, at the cost of long codewords.

Tardos @tardos08 reduced this length with a probabilistic construction whose length is optimal. Each recipient's codeword is created symbol by symbol from a distribution parametereised by a per-position bias and tracing is performed with an accusation score. A code of length 

$ m = O(c^2 ln(n / epsilon)) $

is sufficient to accuse, with false-positive probability at mose $epsilon$, at least one member of any coalition of up to $c$ recipients amon $n$. Following word refined the scheme without changing its nature like the method proposed by Skoric et al. @skoric08 that uses symmetric two-sided scoring which improved the accusation power. Then even tighter analyses shortened the codewords further @laarhoven14 and asymmetric variants addressed the buyer-seller trust problem @charpentier11. This family of codes has been paired with transform-domain watermarking for video @rehman22. Tardos codes are therefore the state of the art for collusion-resistant fingerprinting.

=== Why Tardos is set aside

Despite their optimality, Tardos codes were investigated and not retained for ICNML for several reasons: 

1. Threat model
Tardos codes defend against a coalition exploiting the marking assumption. The scenario considered here is a single recipient redistributing one copy. 

2. Capacity cost
The quadratic dependence on the coalition size $c$ makes the codeword length grow to thousands of symbols even for modest parameters.

=== Erorr-correcting codes

Once colusion it out of scope, the code layer becomes a classical error-correction problem. Indeed, the problem is to send to a recipied an identifier through a noisy channel and recover it intact despite potential distortions.

Reed-Solomon (RS) codes fit this well. They work on symbols, small groups of bits, rather than single bits. An $"RS"(n, k)$ code adds $n - k$ redundant symbols to $k$ data symbols and can repair up to 

$ t = floor((n - k) / 2)$

corrupted ones. Working on symbols is the key advantage here, because a localised attack such as cropping damages a contiguous region of the image, which maps to a few whole symbols rather than many scattered bits, exactly what RS corrects the most efficiently and what is probably one of the most likely attack for ICNML biometric images. RS has been used as the codeing layer of wavelet-domain schemes @abdul13 and of a schemed designed specifically to resist JPEG compression and cropping @liu25. It recovers the payload in a determinist way and costs only $n - k$ extra symbols. This is very interesting if the embedded bits are an encrypted token as this ensures all the bits will be extracted and then the token can be decrypted by the server to accuse the leaker with precision.

== The watermark substrate

=== Decomposition-based hybrids

The robustness of the embedding itself

=== Spread-spectrum watermarking

== Synchronisation against geometric attacks

== Retained approach

