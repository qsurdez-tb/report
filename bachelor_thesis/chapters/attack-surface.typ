= Attack Surface

== Critical Findings

=== Remote Code Execution via cPickle Deserialization from Redis <finding-cpickle>

The Redis cache layer stores serialized Python objects and deserializes them on retrieval using `cPickle.load`:

#figure(
  ```python
  def cache_get( key ):
      buff = config.redis_dbs[ "cache" ].get( key )
      if buff == None:
          return None
      return cPickle.load( buff )
  ```,
  caption: [cPickle deserialization from the Redis cache (`utils/redis.py`, ln 34-37)]
)

`cPickle.load` executes arbitrary Python code embedded in the pickled byte stream during deserialization @python-pickle-docs. Any value written to the `cache` Redis database is deserialized the next time the corresponding cached function is called. An attacker who can write an arbitrary value to Redis can thus achieve remote code execution with the privileges of the Flask process @payloads-pickle.

Redis is bound to `127.0.0.1` in the Docker Compose configuration and is not directly reachable from the internet under normal conditions. However, a Docker network misconfiguration, a server-side request forgery vulnerability, or lateral movement from another compromised container in the same stack would all provide the required write access.

The cache key format is `SHA-256(<commit-short> + "_" + <func_name> + "_" + <args>)`. An attacker who knows the deployed commit hash, which is available from the unauthenticated `/version` endpoint, can pre-compute the key for any cached function and inject a malicious payload.

=== Second-Order SQL Injection via `account_type.name`

During user registration, the account type name is fetched from the database and then embedded directly into a SQL string 
using string interpolation:

#figure(
  ```python
  account_type_name = config.db.query_fetchone( sql, ( account_type, ) )[ "name" ]
  account_type_name = account_type_name.lower()
  sql = "SELECT nextval( 'username_{}_seq' ) as id".format( account_type_name )
  config.db.query_fetchone( sql )
  ```,
  caption: [Second-order SQL injection in new user creation (`views/newuser/__init__.py`, ln 59-62)]
)

This is a second-order injection because the malicious value does not come from user input directly but from the database. Exploiting it requires write access to the `account_type` table, which constrains the attack. If a name as `a') = '1' OR '1` is inserted, the constructed query becomes:

#figure(
  ```sql
  SELECT nextval( 'username_a') = '1' OR '1_seq' ) as id
  ```,
  caption: [Injected SQL query after name interpolation]
)

This would provide a boolean oracle. The query either succeeds or raises a PostgresQL exception. This binary outcome is sufficient to extract any column from any table in the database using a standard boolean technique @owasp-sqli.

Applying a whitelist check after retrieving the account type name would be an easy fix.

== High Findings

=== Insecure PRNG for Security-Critical Random Values

Python's built-in `random` module uses Mersenne Twister, which is designed for statistical simulations and is not cryptographically secure @random-doc. Its internal state can be reconstructed from a sufficiently large set of observed outputs. The `random_data` function in `utils/rand.py`, which uses this module, is the unique source of randomness for all security-critical values in the application. This is documented in the cryptographic utilities chapter @crypto-utils.

The fix is to change the `random_data` to use `os.urandom` or `secrets`, which reads from the operating system entropy source.

== Medium Findings

== Attack scenarios for Critical Findings