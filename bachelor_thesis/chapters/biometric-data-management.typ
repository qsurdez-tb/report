#import "../macros.typ": note, concept

= Biometric Data Management <biometric-data>

#concept[
  Holding biometric images is ICNML's whole reason to exist, so their lifecycle is central. This chapter follows a biometric file through its life in the platform, from upload to deletion. Every image lives encrypted under its donor's key (the DEK, @per-donor-security), never on a plain filesystem. The code excerpts are in @appendix-biometric.
]

@biometric-flow-fig shows the path a biometric file takes. The sections below walk through where images are stored, how they are encrypted on the way in, decrypted on the way out, and removed.

#figure(
  image("../assets/biometric-management.drawio.png", width: 80%), // TODO simplify figures
  caption: [The life of a biometric file: upload and encryption, encrypted storage, decryption on serving, deletion.],
)<biometric-flow-fig>

== Where the images live

ICNML uses no filesystem. Every biometric image is stored as a base64-encoded string inside the database, encrypted beforehand with the donor's DEK. Several tables hold this content, each for a different kind of image:

- `files`, the main table for tenprint cards, mark images and NIST files.
- `thumbnails`, reduced-size previews generated on first access, also DEK-encrypted.
- `files_segments`, individual finger segments cropped from tenprint cards, DEK-encrypted.
- `cnm_annotation`, close-non-match annotation images, DEK-encrypted.
- `cnm_candidate`, candidate images, *not* DEK-encrypted.


== From upload to encrypted storage

Uploading goes through a single logged-in endpoint (`POST /upload`), and the handling forks by file type. NIST files (recognised by their extension) skip image processing entirely and their raw bytes are base64-encoded and DEK-encrypted straight into the `files` table.

Every other image goes through two preparation steps first. A resolution check rejects any image that carries no DPI metadata, since resolution is essential for forensic use (@appendix-biometric). Then an EXIF-based (Exchangeable image file format) rotation turns the image to its correct orientation and re-saves it. A useful side effect of that re-save is that the python image library used (`PIL`) drops the EXIF metadata, so incidental capture information does not travel with the stored image like the model of camera it was photographed with.

Only then is the file base64-encoded, DEK-encrypted, and inserted into `files`. The filename is encrypted with the submitter's session key (@crypto-utils), and for tenprint cards a thumbnail is generated and stored, itself DEK-encrypted.

== Serving: decryption on the fly

Images are never stored in the clear, so every time one is displayed it is decrypted on demand. A single function, `image_serve`, does this. It reads the encrypted `data`, fetches the DEK of the donor that owns the containing submission (a short SQL join from `donor_dek` through `users` to `submissions`), decrypts, and rebuilds a displayable image. If the DEK is unavailable, because the donor soft-deleted it, the content simply cannot be reconstructed, which is exactly the privacy-by-deletion behaviour described in the per-donor chapter.

== Deletion

Removing biometric data comes in two forms, and they are not equally clean.

1. Mark deletion is immediate and permanent, with no soft-delete or audit trail. A submitter may only delete their own marks (the ownership is enforced in the query), whereas the administrator path deletes by identifier alone, without that check.

2. Submission deletion is restricted. A submission folder can be deleted only while it has no consent form. Once a consent form is present, deletion is refused.


== Assessment

The storage design is sound in its core choice. No biometric image ever touches a filesystem or sits unencrypted, everything is DEK-encrypted in the database, thumbnails and segments included, and decryption happens only while serving. Enforcing a resolution and shedding EXIF metadata on upload are good, forensically-aware defaults.

Three gaps stand out for future work. The `cnm_candidate` images escape the per-donor encryption that protects everything else and should be brought back under it. Deletion is a hard `DELETE` with no soft-delete or audit trail, unlike the reversible DEK mechanism the platform relies on elsewhere. And the consent-form restriction on submission deletion contradicts the DEK-based right to erasure, so the two should be aligned. Storing images as base64 text in the database also inflates them by roughly a third, the same avoidable overhead noted for the consent form.
