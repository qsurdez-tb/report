#import "../../macros.typ": note

= Python 3 migration : implementation details <appendix-python3-migration>

Supporting detail for the migration chapter (@python3-migration).

== The mechanical Python 2-isms

The syntactic changes Python 3 forces, counted from a real scan of the tree. These are the low-risk transforms done first to reach a clean compile. The application itself carried very few, the bulk lived in the libraries, and `NIST` in particular.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, center, center, center, center, center, center),
    table.header[Component][`print`][`iter*`][`has_key`][`xrange`][`basestring`][`StringIO`],
    [MDmisc], [1], [8],  [1], [9],  [4], [8],
    [NIST],   [3], [21], [5], [13], [0], [13],
    [PMlib],  [0], [0],  [0], [1],  [0], [0],
    [PiAnoS], [2], [5],  [0], [0],  [0], [1],
    [WSQ],    [0], [0],  [0], [0],  [0], [0],
    [web/app], [1], [3], [0], [2],  [1], [29],
  ),
  caption: [Occurrences of each Python 2-ism per component. `iter*` groups `iteritems`/`itervalues`/`iterkeys`.],
)

Each was translated by its standard Python 3 form: `print x` to `print(x)`, `d.iteritems()` to `d.items()`, `d.has_key(k)` to `k in d`, `xrange` to `range`, `basestring` to `str`, and `except E, e:` to `except E as e:`. The `StringIO` sites are not mechanical, they are decided per site in the bytes-versus-text pass below.

== The latin-1 rule for binary-but-text-shaped data

Python 2 made `str` and `bytes` the same type, so code that treated a binary blob as a string of one-byte characters worked for free. Python 3 separates them, and that separation breaks at every point where the `NIST` format or the `WSQ` buffers cross a file or library boundary. The rule adopted, and reused in the application, was:

#note[Binary-but-text-shaped formats (the NIST AN2 format, WSQ buffers) are round-tripped through `latin-1` at the I/O boundary, which maps bytes 0–255 to code points 0–255 losslessly. Genuine cryptography (`aes.py`, `hash.py`) is handled as real `bytes` end-to-end. The two strategies are never mixed.]

The `latin-1` choice localises the problem to the few lines where a file is read or written, instead of forcing a full-bytes rewrite of code that models a record as a string. Applying it took the `NIST` test suite from not running at all to 114 tests running and 113 passing.

== The residual NIST bugs

Running the `NIST` suite on `linux/amd64` (so the x86-64 WSQ binaries could execute) surfaced real migration bugs rather than environmental noise, taking the suite from 33 failures to 1.

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, left),
    table.header[Site][Cause],
    [`fingerprint/__init__.py`], [`from scipy.spatial.qhull import ConvexHull` was removed in scipy 1.8, repointed to `from scipy.spatial import ConvexHull`.],
    [`fingerprint/functions.py`], [`WSQ().decode()` now returns `bytes`, but the branch only handled `str`. Widened to accept both.],
    [`core/__init__.py`], [The decisive one. A coercion `if not isinstance(value, str): value = str(value)` turned `bytes` into their text repr `b'\xff…'`, quadrupling the size and corrupting the record. Fixed by decoding `bytes` through `latin-1` first.],
    [`fingerprint/functions.py`], [An `Annotation` deepcopy recursed infinitely because `__getattr__` read a not-yet-restored attribute. Made to fail fast on that attribute name.],
  ),
  caption: [The substantive bugs the amd64 test run exposed in `NIST`.],
)

The one deliberately-remaining failure is a tenprint-card test that asserts an exact-pixel `md5`. The structural assertions (image mode, size) pass, only the byte hash differs, because the card is composited by a newer Pillow than the baseline hash was recorded against. It is left failing rather than papered over.

== The WebAuthn API rewrite

The single largest item in the application was the passkey code. The installed library `webauthn==0.4.7` was abandoned, and its entire API was removed in the maintained successor `py_webauthn` (version 2.x) @py-webauthn-changelog. This was an application rewrite in two files, not a version bump.

This path cannot be exercised on `localhost` without an administrator's FIDO2 key, so it was validated on the dev server.

== The dependency bumps

Every pin in the application's `requirements.txt` was a last-Python-2 release. The migration lifted them together, the security-relevant and format-relevant moves being the following.

#figure(
  table(
    columns: (auto, auto, auto, 1fr),
    stroke: 0.5pt,
    fill: (col, row) => if row == 0 { luma(220) } else { white },
    align: (left, center, center, left),
    table.header[Package][Was][Now][Note],
    [`webauthn`], [0.4.7], [`py_webauthn` 2.x], [API rewrite above],
    [`flask`], [1.1.2], [3.x], [blueprint registration reviewed],
    [`pyBarcode`], [0.8b1], [`python-barcode`], [abandoned, renamed, call sites verified],
    [`pathlib`], [1.0.1], [removed], [now part of the standard library],
    [`scipy`], [1.2.3], [≥1.11], [lifted in lockstep with NIST and PMlib],
    [`numpy`], [1.16.6], [≥1.24], [removed aliases `np.int` / `np.float`],
    [`pillow`], [6.2.2], [≥10], [constant renames, e.g. `ANTIALIAS` to `LANCZOS`],
    [`cryptography`, `pycryptodome`, `gevent`], [Py2-era], [current], [re-tested against the crypto and server paths],
  ),
  caption: [The dependency moves the migration required. The base image moved from `python:2.7-slim-buster` to `python:3.11-slim-bookworm` in the same step.],
)
