#import "../macros.typ": note

= Upgrade Codebase to Python 3.x

ICNML runs on Python 2.7, which reached end-of-life in January 2020 and no longer receives security patches or bug fixes. This chapter describes the changes required to migrate the application and its dependent libraries to Python 3.9+. The scope covers the Flask application and the four internal libraries (`NIST`, `MDmisc`, `WSQ`, `PMlib`).
The changes fall in


== Runtime Breaking Changes

These changes prevent the interpreter from starting or cause an unhandled exception on the first call to the affected path. They represent the minimum required for the application to complete a single request under Python 3.

=== Removed Standard Library Modules

Python 3 reorganized and removed several modules that ICNML depends on directly:

#figure(
  table(
    columns: (auto, auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left, left),
    table.header[Python 2 import][Python 3 replacement][Affected file],
    [`import cPickle`],                    [`import pickle`],                        [`utils/redis.py`],
    [`from cStringIO import StringIO`],    [`from io import BytesIO`],               [`NIST/traditional/__init__.py`],
    [`import urlparse`],                   [`from urllib.parse import urlparse`],    [`MDmisc/database.py`],
  ),
  caption: [Removed modules and their Python 3 replacements @py3-whatsnew]
)

The Redis session backend deserializes every cache read with `cPickle.load()`. In addition to the Python 3 incompatibility, deserializing untrusted data with `pickle` is an important vector of attack if the Redis instance is every accessible to an attacker. The migration is quite the natural moment to replace pickle serialization with JSON, eliminating the vulnerability entirely rather than carrying it forward under a differnt module name. 

=== Built-in Functions and Syntax Removed

Python 3 removed `xrange`, `print` as a statement and direct list behavior on dictionary view methods. 

`print` as a statement is a parse-time error. Any file containing `print "..."` raises `SyntaxError` before the module is imported, meaning the entire application fails at startup rather than at the call site.

`xrange` was removed entirely. `range` is now lazy and is a direct replacement.

`dict.items()`, `dict.keys()`and `dict.values()` now return view objects instead of lists. Code that indexes into these directly raises `TypeError` @py3-whatsnew.

The NIST library additionally calls `.iteritems()` at seven sites in `NIST/traditional/__init__.py`. `.iteritems()` was removed entirely in PYthon 3. `.items()` has the same behaviour as `.iteritems()` from Python 2.

=== Redis `bytes` Return Type

`redis-py` 4.x changed the default return type of all `get()` calls from `str` to `bytes`. String comparisons against Redis values that were valid in Python 2 silently evaluates to `False` in Python 3 without raising an exception.

This particular comparison is in the TOTP validation path. A `False` result measn any valid TOTP code is treated as already used, silently blocking all TOTP based logins without an error message.

An easy fix would be to init all Redis clients with `decode_responses=True` in `config.py` @redis-doc. This tells `redis-py` to decode all responses to `str` and avoids requireing changes at every call site across the app.

== Semantic changes

These changes allow the application to start and handle requests but produce incorrect results without raising exceptions. They are harder to discover through static analysis alone because th ecode paths execute successfully.

=== Integer Division

In Python 2, the `/` operator between two integers performs floor division and returns an integer. In Python 3 it always returns a float. Expression used as array indices, byte offsets or loop bounds that depended on integer division will silently pass fractional values where integers are expected.

#figure(
  ```python
  # Python 2: n / 2 == 125 (int) when n == 250
  # Python 3: n / 2 == 125.0 (float) TypeError when used as list index
  for i in range( n / 2 ):
      high = ord( data[ 2*i ] )
  ```,
  caption: [Integer division in binary processing (`NIST/core/functions.py`)]
)

About 70 division expression exist across the NIST, PMlib and PiAnoS libraries. Of these, roughly 15 involve integer operands where an integer result is semantically required. These must be changed to `//`. The remaning expressions involve DPI-to-millimetre coordinate conversions where the float result produced by Python 3 is actually correct. 

=== `base64` returns `bytes`

In Python 3, `base64.b64encode()` returns a `bytes` object rather than a `str`. Code that stores the result in a text database column or concatenates it with a string raises `TypeError`.

The fix would be quite simple and would be `base64.b64encode( bytes ).decode("ascii")`. The same pattern applies wherever this function is called and stored as a text.

=== PBKDF2 Byte Encoding

In Python 2, `hashlib.pbkdf2_hmac` accepts `str` arguments for both the password and the salt, since `str` is a byte string. In Python 3, both arguments must be `bytes`, passing a `str` raises `TypeError`.

For ASCII-only inputs, which covers all salts generated by `random_data()` and all password restricted to the ASCII character set, UTF-8 and Latin-1 encodings are identical, so the PBKDF2 output is the same between Python 2 and Python 3. Non-ASCII passwords creates a different hash under UTF-8 than the Latin-1 byte representation Python 2 used. This means exisiting stored hashes for those passwords will no longer verify.

=== `map` and `filter` Return Iterators

In Python 3, `map()` and `filter()` return lazy iterators rather than lists. Code that indexes into the return value raises `TypeError` and code that iterates the result twice silently produces an empty sequence on the second pass. 

== NIST library

The NIST fingerprint library (`NIST/`) poses the highest migration risk of the codebase. The library treats Python 2's `str` type as a raw byte buffer throughout its parsing logic. This is not a set of isolated call sites but an architectural assumption that runs through every layer of the library.

=== The `str` as bytes Problem

NIST binary files is a mix of ASCII text fields with binary fingerprint image data. The library reads the entire file as a single `str`, splits it on byte value separator constants, and processes individual character with `ord()`:

#figure(
  ```python
  # NIST/core/config.py
  FS = chr( 0x1c )   # Field Separator
  GS = chr( 0x1d )   # Group Separator
  RS = chr( 0x1e )   # Record Separator
  US = chr( 0x1f )   # Unit Separator

  # NIST/traditional/__init__.py, splits entire binary buffer on a str separator
  records = data.split( FS )
  ```,
  caption: [Separator constants and binary buffer splitting (`NIST/core/config.py`, `NIST/traditional/__init__.py`)]
)

In Python 3, reading a file in binary mode returns `bytes`. A `bytes` buffer cannot be split using a `str` separator, the `split()` call raises `TypeError`. Reading in text mode instead fails immediately on the binary fingerprint image data. 

=== Internal Representation Options

Three strategies exist for how the library represents NIST data internally after migration:

#figure(
  table(
    columns: (auto, 1fr, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left, left),
    table.header[Option][Approach][Trade-off],
    [A : Full `bytes`],           [Separator constants become `b'\x1c'` etc..., all field operations use byte methods],       [Correct model but requires changes to every text-field parsing function in the library],
    [B : Full `str` (Unicode)],   [Binary fields base64-encoded, text fields stay `str`],                                   [The `load()` entry point still receives a binary file and cannot split `bytes` with a `str` separator without an explicit decode step],
    [C : Hybrid],   [Decode the raw file buffer with Latin-1 at `load()`, binary blobs stored explicitly as `bytes`], [Minimum changes, all downstream text-field parsing works without changes, Latin-1 round-trips byte values without loss],
  ),
  caption: [Internal representation options for the NIST library]
)

Option C would require a single change at the `load()` entry point: 

#figure(
  ```python
  # Python 2 : raw binary file read as str (byte string)
  with open( path, "rb" ) as fp:
      data = fp.read()

  # Python 3 : decode once at the I/O boundary with Latin-1
  with open( path, "rb" ) as fp:
      data = fp.read().decode( "latin-1" )
  ```,
  caption: [Latin-1 decode at the `load()` I/O boundary]
)

Binary blobs fields must still be re-encoded back to `bytes` when passed to external consumers, but this is marginal and isolated to one field rather than changing the whole library.

== Dependency Upgrades

Every dependency is pinned to a Python 2 version. All packages require upgrading. Several require API changes beyond a version bump !

#figure(
  table(
    columns: (auto, auto, auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left, left, left),
    table.header[Package][Current][Target][Notes],
    [`flask`],           [`1.1.2`],   [`3.x`],     [Python 3 support added in 2.0, application factory pattern and blueprint registration unchanged],
    [`flask_session`],   [`0.3.1`],   [`0.8+`],    [API compatible, Redis session backend unchanged],
    [`pycryptodome`],    [`3.9.9`],   [`3.20+`],   [`icnml_copy` already uses pycryptodome, `icnml_webapp` uses `pycrypto==2.6.1` which has known CVEs and no Python 3 release , must be replaced],
    [`webauthn`],        [`0.4.7`],   [`2.x`],     [Complete API replacement, see @webauthn-upgrade],
    [`redis`],           [`3.5.3`],   [`5.x`],     [Initialize all clients with `decode_responses=True` to restore `str` return type],
    [`pillow`],          [`6.2.2`],   [`10.x`],    [Several deprecated constants removed in 10.0 (e.g., `Image.ANTIALIAS` -> `Image.LANCZOS`), run with `-W error::DeprecationWarning` to surface all affected call sites],
    [`scipy`],           [`1.2.3`],   [`1.13+`],   [Python 3 support added in 1.3, API stable for the array operations in use],
    [`numpy`],           [`1.16.6`],  [`1.26+`],   [Drop-in for the numerical operations in PMlib and PiAnoS],
    [`gevent`],          [`21.1.2`],  [`24.x`],    [Python 3.10+ requires gevent 22.10.2+, greenlet ABI changed between versions],
    [`gnupg`],           [`2.3.1`],   [`2.3.1`],   [Python 3 compatible, verify the `_parsers.Verify.TRUST_LEVELS` patch in `config.py` still applies after upgrade],
    [`pyotp`],           [`2.x`],     [`2.9+`],    [Python 3 compatible, no API changes required],
    [`psycopg2`],        [`2.x`],     [`2.9+`],    [Python 3 compatible, no changes required],
  ),
  caption: [Dependency versions , current vs. Python 3 target]
)

=== WebAuthn Library Replacement <webauthn-upgrade>

`webauthn==0.4.7` is unmaintained and has no Python 3 release. The replacement is `py_webauthn 2.x` which is a complete API rewrite with no backwards compatibility.

The application uses four classes from the old library across `views/login/__init__.py` and `views/newuser/__init__.py`:

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left),
    table.header[Class][Purpose],
    [`WebAuthnMakeCredentialOptions`], [Generate registration challenge],
    [`WebAuthnRegistrationResponse`],  [Verify registration attestation response],
    [`WebAuthnUser`],                  [User model for credential binding],
    [`WebAuthnAssertionResponse`],     [Verify authentication assertion response],
  ),
  caption: [WebAuthn classes used in the application]
)

The database stores `credential_id` and `pub_key` as text columns. `py_webauthn 2.x` uses `bytes` for `credential_id` and a different public key serialization format @py-webauthn-changelog. Existing hardware keys may require re-enrollement after migration.


== Suggested Migration Roadmap

The following roadmap was thought our so that each step is verifiable before the next is taken care of. Dependencies between steps are what suggest the order. The interpreter must pass before semantic issues can be tested, and the NIST library must be stable before any fingerprint upload can be validated. 


#figure(
  table(
    columns: (auto, auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (center, left, left),
    table.header[Step][Target][Rationale],
    [1], [Fix syntax (`print`, `xrange`, `.iteritems()`)],               [`2to3` handles these automatically. No logic changes. Required before the interpreter can import any module.],
    [2], [Replace removed modules (`cPickle` → JSON, `cStringIO`, `urlparse`)], [Import errors, fixes are isolated. Switching `cPickle` to JSON at this step also eliminates the RCE vector.],
    [3], [Upgrade `redis-py`, add `decode_responses=True` to all clients], [Prevents the silent TOTP bypass and all other `bytes`/`str` comparison failures across the auth flow.],
    [4], [Fix `base64` and PBKDF2 `bytes` encoding in the application],  [Affects login, consent form, and DEK flows. Validate against the existing database with a test account before proceeding.],
    [5], [Fix integer division in PMlib (`//` where integer intent)],    [Isolated to one library. Can be tested independently without the full application stack.],
    [6], [Migrate NIST library (Option C Latin-1 decode, `bytes` for data fields)], [Highest-risk change. All fingerprint upload and retrieval flows depend on it. Run the NIST doctester (`python3 doctester.py` in `library/NIST/`) as the primary check.],
    [7], [Upgrade all dependencies, audit Pillow API],                   [Run `python -W error::DeprecationWarning` to surface deprecations before they become runtime removals.],
    [8], [Rewrite WebAuthn integration],                                 [Requires a FIDO2 hardware key for end-to-end testing. We can keep the old implementation on a branch until the new one is validated for both the login and the new-user validation flows.],
  ),
  caption: [Recommended migration order]
)

