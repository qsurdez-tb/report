= Biometric Data Management : implementation details <appendix-biometric>

Code excerpts for the biometric data management chapter (@biometric-data).

== Upload

#figure(
  ```python
  try:
      res = int( img.info[ "dpi" ][ 0 ] )
  except:
      return jsonify( { "error": True,
          "message": "No resolution found in the image. Upload not possible at the moment." } )
  ```,
  caption: [Resolution check. An image with no DPI metadata is rejected (`views/submission/__init__.py`, ln 128-136).]
)

#figure(
  ```python
  file_data = utils.encryption.do_encrypt_dek( file_data, submission_uuid )
  sql = utils.sql.sql_insert_generate( "files", [
      "folder", "creator", "filename", "type",
      "format", "size", "width", "height", "resolution", "uuid", "data" ] )
  config.db.query( sql, data )
  ```,
  caption: [The prepared bytes are base64-encoded, DEK-encrypted, then inserted into `files` (`views/submission/__init__.py`, ln 276-290).]
)

== Serving and decryption

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
  caption: [`image_serve` decrypts with the donor DEK and rebuilds a PIL image (`views/images/__init__.py`, ln 271-279).]
)

#figure(
  ```sql
  SELECT donor_dek.dek
  FROM donor_dek
  LEFT JOIN users ON users.username = donor_dek.donor_name
  LEFT JOIN submissions ON submissions.donor_id = users.id
  WHERE submissions.uuid = %s
  LIMIT 1
  ```,
  caption: [Fetching the donor DEK for a submission (`utils/encryption.py`, ln 41-48).]
)

== Deletion

#figure(
  ```python
  if admin:
      sql = "DELETE FROM files WHERE uuid = %s"
      data = ( mark_id, )
  else:
      sql = "DELETE FROM files WHERE creator = %s AND uuid = %s"
      data = ( session[ "user_id" ], mark_id, )
  ```,
  caption: [Mark deletion. The submitter path is ownership-checked, the admin path is not (`views/submission/__init__.py`, ln 1147-1153).]
)

#figure(
  ```python
  cf = config.db.query_fetchone( sql, ( session[ "user_id" ], submission_id, ) )[ "consent_form" ]
  if not cf:
      sql = "DELETE FROM submissions WHERE submitter_id = %s AND uuid = %s"
      config.db.query( sql, ( session[ "user_id" ], submission_id, ) )
  else:
      current_app.logger.error( "Can not delete a submission with consent form" )
  ```,
  caption: [A submission can only be deleted while it has no consent form (`views/submission/__init__.py`, ln 1177-1182).]
)
