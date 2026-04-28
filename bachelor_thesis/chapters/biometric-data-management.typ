#import "../macros.typ": note

= Biometric Data Management

This chapter covers the complete lifecycle of biometric image files within ICNML: upload, storage, serving, segmentation, deletion and format handling. All biometric content is stored encrypted in the PostgreSQL database.

== Storage Model

ICNML does not use a file system. All biometric images are stored as base64 encoded string in the `data` column of the `files` table. Before storage, the content is encrypted with the donor's DEK, see @dek-donor-generation.

The database tables involved in biometric storage are:

- `files`: primary table for tenprint cards, mark images and NIST files
- `thumbnails`: reduced size previews, also DEK-encrypted, generated on first access.
- `files_segments`: individual finger segments cropped from tenprint cards, DEK-encrypted
- `cnm_annotation`: close non-match annotation images, DEK-encrypted
- `cnm_candidate`: candidate images, NOT DEK-encrypted

#note[The images in `cnm_candidate` are not DEK-encrypted. These images still contain biometric data. The absence of per-donor encryption is strange.]

== File Upload

The upload entrypoint is `POST /upload`, only logged-in users can access it. After a few checks as the presence of the `upload_type` parameter inn the request, the presence of the `file` in the request and a submission existing, each type of file is processed in a different way.

=== NIST Files

NIST files (check by their extensions, defined in `config.NIST_file_extensions`) bypass image processing entirely. The raw bytes are base64 encoded and DEK-encrypted before insertion into the `files` table with `format = NIST`.

=== Image Files

For all other file types, PIL opens the uploaded file and performs two preparation steps:

The first one is a resolution check. The image must carry DPI information in `img.info["dpi"]`. If the field is absent the upload is rejected. 

#figure(
  ```python
  try:
      res = int( img.info[ "dpi" ][ 0 ] )
      current_app.logger.debug( "Resolution: {}".format( res ) )
  except:
      return jsonify( {
          "error": True,
          "message": "No resolution found in the image. Upload not possible at the moment."
      } )
  ```,
  caption: [DPI check on upload (`views/submission/__init__.py`, ln 128-136)]
)

The second one is an EXIF-based rotation. If the imgae contains EXIF orientation metadata, it is rotated to the right orientation before storage with a call to a util function. 

After the rotation, the image is re-saved via PIL. PIL's save operation does not copy EXIF tags by default, so the stored image has its EXIF metadata removed.

=== Encryption and Persistence

After image preparation, the file bytes are base64 encoded, then DEK encrypted: 

#figure(
  ```python
  file_data = utils.encryption.do_encrypt_dek( file_data, submission_uuid )
                
  sql = utils.sql.sql_insert_generate( "files", [
      "folder", "creator",
      "filename", "type",
      "format", "size", "width", "height", "resolution",
      "uuid", "data"
  ] )
  ...
  config.db.query( sql, data )
  ```,
  caption: [DEK encryption and database insertion (`views/submission/__init__.py`, ln 276-290)]
)

The name of the file is also encrypted with the submitter's password before storage. 

For tenprint cards, a thumbnail is generated and stored immediately in the `thumbnails` table, also DEK-encrypted.

== Image Serving and Decryption



=== Thumbnail Fallback

=== NIST Tenprint Card Rendering

== Tenprint Segmentation

== File Deletion

=== Mark Deletion

=== Submission Deletion

== Caching