= Tools used <tools>

In writing this report, a generative artificial-intelligence tool was used as an aid to drafting and reformulation. All of the ideas, analyses and technical choices presented in this document are the work of the author. The generated content was systematically checked, adapted and validated by the author.

The tools used were the following.

- Claude Opus 4.8 (Anthropic) : help with reformulation, structuring the text, and producing the diagrams.
- Claude Fable 5 (Anthropic) : an AI coding assistant used as a pair-programming aid for the watermarking implementation, described below.

Beyond the writing, an AI coding assistant was also used for the most exploratory piece of engineering in this thesis, the Spread-Transform Dither Modulation (ST-DM) watermark. Working with Fable, the scheme was implemented (`stdm-global`) and then iterated into its three variants, the fixed-step baseline (`stdm-block`), the gain-invariant version that was ultimately retained (`stdm-gain`), and the `stdm-tiled` alternatives. The author set the design at each step, deciding what property each variant should target, such as gain invariance against brightness changes, while the assistant helped turn those choices into working code and shortened the loop between an idea and a testable implementation. Every variant was then measured by the author against the evaluation battery (@watermark-implementation), and only results that reproduced independently were kept, so the selection of `stdm-gain` rests on the measured evidence.
