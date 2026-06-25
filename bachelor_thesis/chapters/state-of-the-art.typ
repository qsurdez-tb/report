#import "../macros.typ": note

= Sate of the Art <state-of-the-art>

The objective of this part of the thesis is source identification after a leak. Given a grayscale biometric image that leaked outside  ICNML, one can recover the recipient it was issued to, even after the file has been reencoded, resized, cropped or rotated and even if several recipients pooled their copies. Two layers must cooperate to achieve this. A collusion-resistant code decides what is embedded, it assigns each recipient a distinct codeword and accuses the guilty even under a collusion. A watermark decides how it is embedded, it carries the codeword bits inside the image so that they survive the manipulations an adversary applied before redistribution.

The two layers are studied by communities that rarely cite each other. 
Fingerprinting-code papers treat the channel that carries the bits abstractly, as a binary symmetric channel with adversarial noise. Watermarking papers treat the payload abstractly, as an opaque bit-string of fixed length. The contribution of this thesis lives in the seam between them, so this chapter surveys both layers surveys both layers and the interface they share. It first reviews the code layer, where the choice of construction fixes the bit budget every later decision must respect . It then reviews the embedding substrate, where the competing designs diverge most sharply, wheighing each candidate against the requirements ICNML actually imposes.


== The Collusion-Resistant Code Layer

What distinguishes this layer from ordinary per-recipient marking is the collusion. Several recipients, each holding a differently marked copy of the same image, compare their copies and assemble a new one that matches none of them exactly. Boneh and Shaw gave the first rigorous treatment of this attack and its defence under the marking assumption @bs98. A coalition can alter only the positions in which their copies already differ, and must leave untouched every position on which they agree, since those carry no information distinguishing one member from another. Within that model they constructed the first code that provably traces at least one colluder from a coalition of bounded size, and they proved a lower bound on the length any collusion-secure code must have. Their combinatorial construction attains the property but at a length far above that bound, which motivated the probabilistic codes that followed.

Tardos closed the gap @tardos08. Each code position $i$ is assigned a secret bias $p_i$ drawn from an arc-sine distribution and a recipient's codeword is minted by setting bit $i$ to $1$ independently with probability $p_i$. On recovery, an accusation score is accumulated per recipient by weighting each observed symbol against the secret bias of its position and any recipient whose score crosses a threshold is accused. 

The decisive property is the length: $ m = O(c^2 dot ln(n / epsilon))$ bits are enough to resist coalitions of up to $c$ colluders among $n$ recipients with false-accusation probability $epsilon$. 

== The Watermark layer

== The Embedding Substrate

== Candidate Embedding Families

=== Decomposition based hybrids (DWT-SVD)

=== Spread-spectrum watermarking

=== Informed embedding: QIM and spread-transform dither modulation

=== Learned embedders

== Positioning of This Work
