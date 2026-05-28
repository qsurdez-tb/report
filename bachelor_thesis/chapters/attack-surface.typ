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


== High Findings

== Medium Findings

== Attack scenarios for Critical Findings