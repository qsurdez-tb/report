= Cryptographic utilities — implementation details <appendix-crypto>

Code excerpts and the full call-site inventory for the cryptographic-utilities chapter (@crypto-utils).

== Where randomness is used <apx-rand-sites>

Every random value in ICNML comes from the single `random_data` function. The call sites below all inherit its weaknesses (the non-cryptographic generator and the reduced 36-character alphabet).

#figure(
    table(
        columns: (auto, auto, 1fr),
        stroke: 0.5pt,
        fill: (col, row) => if row == 0 { luma(220) } else { white },
        align: (left, center, left),
        table.header[Call site][Length][What the random value becomes],
        [`config.py:23`],            [20],  [Flask `SECRET_KEY` fallback (signs the session cookie)],
        [`utils/hash.py:43`],        [100], [Default PBKDF2 salt when none is supplied],
        [`utils/encryption.py:183`], [20],  [DEK salt (`DEK_SALT_LENGTH`)],
        [`utils/encryption.py:194`], [20],  [Random field inside the DEK check object],
        [`views/newuser/__init__.py`], [20], [Per-user password salt (`PASSWORD_SALT_LENGTH`)],
    ),
    caption: [Every place `random_data` feeds a security-sensitive value.]
)

== Hashing (`utils/hash.py`)

#figure(
  ```python
  def __init__( self, word, salt = None, iterations = 20000, hash_name = "sha512" ):
      if salt != None and salt.startswith( "pbkdf2$" ):          # parse a stored hash
          self.word = word
          self.stored_hash = salt
          _, self.hash_name, self.salt, self.iterations, self.h = salt.split( "$" )
          self.iterations = int( self.iterations )
      else:                                                       # fresh hash
          self.word = word
          self.salt = salt or rand.random_data( 100 )
          self.iterations = int( iterations )
          self.hash_name = hash_name
  ```,
  caption: [Constructor doubling as a parser for stored hashes (`utils/hash.py`, ln 34-47).]
)

#figure(
    ```python
    def hash( self, hash_only = False ):
        h = binascii.hexlify( hashlib.pbkdf2_hmac( self.hash_name, self.word, self.salt, self.iterations ) )
        if hash_only:
            return h
        return "$".join( map( str, [ "pbkdf2", self.hash_name, self.salt, self.iterations, h ] ) )
    ```,
    caption: [Producing a raw digest or the self-describing stored string (`utils/hash.py`, ln 49-62).]
)

== Encryption (`utils/aes.py`)

#figure(
    ```python
    class AESCipher( object ):
        def __init__( self, key ):
            self.key = hashlib.sha256( key.encode() ).digest()   # 32-byte AES-256 key

    def encrypt( self, data ):
        data = self._pad( data )
        iv = Random.new().read( AES.block_size )                 # fresh IV per call
        cipher = AES.new( self.key, AES.MODE_CBC, iv )
        return "$".join( map( str, [ "AES256", base64.b64encode( iv ),
                                     base64.b64encode( cipher.encrypt( data ) ) ] ) )

    def decrypt( self, data ):
        _, iv, data = data.split( "$" )
        cipher = AES.new( self.key, AES.MODE_CBC, base64.b64decode( iv ) )
        return self._unpad( cipher.decrypt( base64.b64decode( data ) ) ).decode( "utf-8" )
    ```,
    caption: [Key derivation, encryption and decryption. Format `AES256$<iv>$<ciphertext>` (`utils/aes.py`, ln 67-104).]
)

#figure(
    ```python
    encryption_prefix = "icnml$"

    def do_encrypt( data, password ):
        return AESCipher( password ).encrypt( encryption_prefix + data )

    def do_decrypt( data, password ):
        try:
            data = AESCipher( password ).decrypt( data )
            return data[ len( encryption_prefix ): ] if data.startswith( encryption_prefix ) else "-"
        except:
            return "-"
    ```,
    caption: [The `"icnml$"` prefix as an integrity marker; any failure returns `"-"` (`utils/aes.py`, ln 10-36).]
)

== High-level contexts (`utils/encryption.py`)

#figure(
    ```python
    session[ "password" ] = utils.hash.pbkdf2(
        form_password, "AES256", config.PASSWORD_NB_ITERATIONS ).hash()

    def do_encrypt_user_session( data ):
        return aes.do_encrypt( data, session[ "password" ] )

    def do_decrypt_user_session( data ):
        return aes.do_decrypt( data, session[ "password" ] )
    ```,
    caption: [The session key (a PBKDF2 hash salted with the fixed `"AES256"`) and the session-scoped wrappers built on it (`views/login/__init__.py`, ln 221; `utils/encryption.py`, ln 218-230).]
)
