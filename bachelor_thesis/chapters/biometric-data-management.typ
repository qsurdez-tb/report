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

The central decryption function is `image_serve` in `views/images/__init__.py`. It fetches the `data` column from the requested table, decrypts it with the submission's DEK, and transforms the result into a PIL image.

#figure(
  ```python
  if need_to_decrypt_with_donor_dek:
    img = utils.encryption.do_decrypt_dek( img, submission_id )

  if table == "files" and data[ "format" ].upper() == "NIST":
    img = str2nist2img( img )
  else:
    img = str2img( img )

  img = utils.images.patch_image_to_web_standard( img )
  ```,
  caption: [DEcryption and transformation of raw bytes into PIL image (`views/images/__init__.py`, ln 271-279)]
)

== File Deletion

=== Mark Deletion

Individual mark files are deleted with a direct `DELETE FROM files` SQL statement. The submitter route enforces ownership via `creator = session["user_id"]`. The admin route omits that constraint.

#figure(
  ```python
  if admin:
      sql = "DELETE FROM files WHERE uuid = %s"
      data = ( mark_id, )
  else:
      sql = "DELETE FROM files WHERE creator = %s AND uuid = %s"
      data = ( session[ "user_id" ], mark_id, )
  ```,
  caption: [Mark deletion with ownership check (`views/submission/__init__.py`, ln 1147-1153)]
)

Deletion is immediate and permanent. There is no mechanism of soft-delete.

=== Submission Deletion

A submission folder can only be deleted if the consent form is absent thus the submission folder is empty. Once `submission.consent_form` is `true`, the route returns an error and no deletion occurs.

#note[That's inconsistent with the right to deletion boasted about with the donor being able to delete their DEK at any given time.]

#figure(
  ```python
  cf = config.db.query_fetchone( sql, ( session[ "user_id" ], submission_id, ) )[ "consent_form" ]
  
  if not cf:
      sql = "DELETE FROM submissions WHERE submitter_id = %s AND uuid = %s"
      config.db.query( sql, ( session[ "user_id" ], submission_id, ) )
  else:
      current_app.logger.error( "Can  not delete a submission with consent form" )
  ```,
  caption: [Consent-form check on submission deletion (`views/submission/__init__.py`, ln 1177-1182)]
)

#figure(
  image("../assets/biometric-management.drawio.png"),
  caption: [Biometric files flow]
)