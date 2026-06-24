#import "../macros.typ": note

= Sate of the Art <state-of-the-art>

The objective of this part of the thesis is source identification after a leak. Given a grayscale biometric image that leaked outside  ICNML, one can recover the recipient it was issued to, even after the file has been reencoded, resized, cropped or rotated and even if several recipients pooled their copies. Two layers must cooperate to achieve this. A collusion-resistant code decides what is embedded, it assigns each recipient a distinct codeword and accuses the guilty even under a collusion. A watermark decides how it is embedded, it carries the codeword bits inside the image so that they survive the manipulations an adversary applied before redistribution.

The two layers are studied by communities that rarely cite each other. 
Fingerprinting-code papers treat the channel that carries the bits abstractly, as a binary symmetric channel with adversarial noise. Watermarking papers treat the payload abstractly, as an opaque bit-string of fixed length. The contribution of this thesis lives in the seam between them, so this chapter surveys both layers surveys both layers and the interface they share. It first reviews the code layer, where the choice of construction fixes the bit budget every later decision must respect . It then reviews the embedding substrate, where the competing designs diverge most sharply, wheighing each candidate against the requirements ICNML actually imposes.



