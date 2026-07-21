#import "../macros.typ": note, concept

= Tattooing <tattooing>

#concept[
  Every image ICNML serves for download is stamped with a pair of barcodes, one identifying the file and one recording who downloaded it and when. The source code calls this tattooing (`image_tattoo` in `views/images/__init__.py`). Its intent is forensic. If a downloaded biometric image later resurfaces where it should not, the stamp is meant to tie that copy back to the account that pulled it. This chapter documents the tattooing as found in the codebase, what each mark records, and where it falls short, the shortcomings that motivate the invisible traceable watermark developed later (@watermark-implementation). The Python listings are in @appendix-tattooing.
]

Tattooing is applied to an image at the moment it is downloaded, as one step of the download endpoints. @tattoo-flow-fig shows where it sits in that path. It leaves the pixels of the image itself untouched and instead grows the canvas, adding one strip above the image and one below it, so the two marks live in the added margins rather than over the biometric content. The original DPI metadata is read before the operation and written back afterwards, so the marked copy still reports the resolution of the source.

#figure(
  image("../assets/watermark-flow.drawio.png", width: 70%),
  caption: [Where tattooing sits in the flow from a download endpoint.],
)<tattoo-flow-fig>

== The two marks

Tattooing writes two CODE128 barcodes with deliberately different roles. CODE128 is an ordinary one-dimensional barcode, the kind a warehouse scanner reads, so both marks are machine-readable with any standard reader.

#figure(
  table(
    columns: (1fr, 3fr, 2fr, 2fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left, left, left),
    table.header[Mark][Encodes][Placement][Visibility],
    [Visible identifier ], [the first 18 characters of the file UUID], [a full-width strip pasted at the top, pushing the image down], [plainly visible, with the value printed as text under the bars],
    [Tracking strip], [the downloader's `user_id` and the Unix timestamp of the download], [a roughly 10-pixel strip at the bottom-right], [less-perceptible, no readable text],
  ),
  caption: [The two barcodes tattooing adds to every downloaded image.],
)

#figure(
  image("../assets/1f89d1cd_tatooed.png", width: 40%),
  caption: [Example of the result of tattoing an image from ICNML.]
)

The split matters, and it is easy to misread. The mark a viewer first notices, the visible barcode at the top, carries only part of the file identifier. It says nothing about who downloaded the copy or when. The real audit trail, the recipient's account and the moment of download, lives entirely in the second mark, the less-perceptible strip at the bottom. That is the one an examiner would have to recover to attribute a leaked copy to a person.

== Where it is applied, and where it is not

Tattooing is invoked on the endpoints that hand a user a full image to keep, the submission target download, the AFIS downloads, the training exercise download, and similar routes. On those paths every served copy is stamped.

Not every path that serves an image is one of them. Two routes serve full images to any logged-in user with no tattooing at all.

- `GET /image/file/<file_id>/preview`, the JPEG preview.
- `GET /image/file/<file_id>/tiff`, the full-resolution TIFF.

An authenticated user who fetches an image through these routes receives it unmarked, so that access leaves no audit trail. The tattoo can therefore be avoided entirely by choosing the endpoint, without defeating any mark, simply by never asking for a marked copy in the first place.

== Assessment

Tattooing is best understood as a lightweight audit stamp rather than a robust watermark, and the source is honest about this. It is cheap, it needs no keys, and on the download endpoints it does record a real who-and-when for each served copy. As a deterrent and a first-line audit record it has value.

Its weaknesses, in order of severity, all follow from the same root, that the marks are added to the margins of the image rather than woven into it.

+ It survives almost no handling. The visible barcode is removed by a single crop of the top strip, and the tracking strip by a crop of the bottom one. Any recompression, rescale or rotation that a redistributed image ordinarily undergoes degrades the bars until they no longer scan. The mechanism resists nothing an evasive redistributor would do, and the code itself notes it does not withstand cropping or transformation.
+ The audit trail can be bypassed without any attack on the mark. Because the preview and TIFF endpoints serve unmarked full images, a user who wants an untraceable copy need only request one through those routes.
+ The human-visible mark cannot attribute a leak on its own. It encodes only the file identifier, so recovering it tells an examiner which image leaked but not to whom it was issued. Attribution depends entirely on the near-invisible bottom strip, which is also the easiest part to crop away.

These limitations are precisely what the traceable watermark in @watermark-implementation is built to overcome. Instead of stamping removable barcodes into the margins, it spreads a cryptographic recipient identity invisibly across the whole image, so that a crop, a recompression or a rescale can no longer strip the copy of its origin.
