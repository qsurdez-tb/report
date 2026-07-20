#import "../macros.typ": note

= Watermarking evaluation, supplementary figures <appendix-wm-eval>

This annex collects the detailed evaluation figures referenced from the watermarking chapter (@wm-evaluation). They break the pooled results down attack by attack and expose the error-correction margin behind the recovery rates.

#figure(
  image("../assets/plots/jpeg_robustness.png", width: 62%),
  caption: [Robustness of the four ST-DM variants to JPEG compression, as quality drops from 95 to 10. Above, the bit error rate (median and inter-quartile band across images); below, the resulting identifier-recovery rate. All four variants decode reliably down to quality 30 and diverge only under the heaviest compression.]
)<fig-jpeg-robustness>

#page(flipped: true)[
  #figure(
    image("../assets/plots/recovery_heatmap.png", width: 100%),
    caption: [Exact identifier recovery for every scheme and attack, grouped by attack family. Warm cells are failures, cool cells successes. The blank forensic block for the two library baselines marks attacks they were never run against.]
  )<fig-recovery-heatmap>

  #figure(
    image("../assets/plots/rs_margin.png", width: 100%),
    caption: [Reed-Solomon correction budget consumed per attack family, expressed as byte errors over the 16 correctable. The dashed line is the correction limit: as long as a scheme stays below it the identifier decodes exactly. The margin is comfortable everywhere except the hardest combined attacks.]
  )<fig-rs-margin>
]
