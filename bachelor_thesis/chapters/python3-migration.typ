#import "../macros.typ": note, concept

= Migrating to Python 3 <python3-migration>

#concept[
  ICNML was written for Python 2.7, a language version that reached end of life in January 2020 and has received no security fix since. That single fact is the root cause behind much of the fragility described in the earlier chapters, from the unbuildable environment (@appendix-dev-env) to the stalled deployment pipeline (@deployment). This chapter documents migrating the whole codebase, four internal libraries and the Flask application, to Python 3.11. The work was done as a clean break, with one hard constraint. Every stored format, password hashes and encrypted image blobs alike, had to stay byte-for-byte identical so that existing data would still decrypt after the move. The detailed tables and code-level fixes are in @appendix-python3-migration.
]

== Why it had to be done

Running on an end-of-life interpreter is not a stylistic complaint, it has concrete consequences. No security patch will ever be issued for Python 2.7 again, so any vulnerability found in the interpreter or its standard library stays open permanently. The wider ecosystem has moved on too, the libraries ICNML depends on stopped shipping Python 2 releases years ago, which is why the environment could no longer be rebuilt from current package sources and why the deployment pipeline, pinned to abandoned versions, could not be revived in place. Migrating to a supported interpreter is the prerequisite that makes every other piece of maintenance possible again.

The target chosen was Python 3.11. It is recent enough to be fully supported, yet conservative enough that the numerical and image libraries ICNML leans on (`numpy`, `scipy`, `pillow`, `cryptography`) all have mature, well-tested releases for it.

== The strategy: a clean break, from the bottom up

Two decisions shaped the whole effort.

The first was to make a clean break rather than a gradual bridge. A common way to migrate is to make the code run under both interpreters at once, using a compatibility layer, and switch over later. That path was rejected. It doubles the surface to reason about and leaves compatibility shims to remove afterwards. Since ICNML controls its own deployment and did not need to serve both interpreters simultaneously, the code was moved straight to Python 3 and Python 2 support was dropped outright.

The second decision was the order of work. ICNML is not one program but a Flask application sitting on top of four internal libraries, and those libraries depend on one another. Migrating them in dependency order, from the most foundational upward, guarantees that a freshly-migrated Python 3 module is only ever tested against dependencies that are themselves already on Python 3, never against a Python 2 one. @py3-order-fig shows that order.

#figure(
  image("../assets/py3-migration-order.drawio.png", width: 100%),
  caption: [The migration proceeded bottom-up by dependency: the libraries first (Phase 1), then the Flask application on top of them (Phase 2).],
)<py3-order-fig>

This split the work into two phases, the libraries first and the application second, and each phase was gated by tests before the next began.

== The safety net: proving nothing changed

The danger in a migration like this is not the code that crashes, a crash is loud and easy to find. It is the code that keeps running but now produces a subtly different result. Two guards were put in place against exactly that.

For the libraries, the guard was their existing doctest suites, which encode the expected output of hundreds of small operations. A migrated module was only accepted once its suite ran green again, so any silent change in behaviour showed up as a failing test.

For the application, the guard was stricter, because the application does cryptography. ICNML's password hashes and its per-donor encryption (@crypto-utils, @per-donor-security) derive keys from strings, and if the migrated code encoded those strings even slightly differently, every hash and every key would come out different. Existing accounts would fail to log in and existing images would fail to decrypt, silently. To prevent this, a baseline was captured on the old Python 2 stack, a real encrypted blob together with the key needed to open it, and the migrated Python 3 build was required to decrypt that exact blob byte-for-byte before the migration could proceed. This was treated as a blocking gate. Until it passed, the port was not a port but a data-loss risk.

== Phase 1: the libraries

The libraries carried the bulk of the mechanical changes, the syntax Python 3 no longer accepts, counted in full in @appendix-python3-migration. Those were quick. The real work was a single deeper problem which is the difference between text and bytes.

Python 2 blurred that line, treating a string and a sequence of raw bytes as the same thing. Python 3 separates them cleanly, and that separation breaks any code that had been quietly relying on the blur. ICNML's libraries were full of such code, because the biometric file formats they parse (the NIST fingerprint format, the WSQ compressed images) are binary data that the old code modelled as ordinary text.

The approach was to draw a firm line, stated in full in @appendix-python3-migration. Binary data that merely looks text-shaped is converted at the edges through a lossless one-byte-per-character encoding @latin-encoding, so the bulk of the parsing code can keep treating it as text. Genuine cryptography, by contrast, is handled as true bytes from end to end. The two strategies are kept strictly apart, because mixing them is precisely what silently corrupts data.

`NIST`, the fingerprint-format library, was the hardest case by a wide margin and the one where this discipline paid off. Once its test suite could run at all, it exposed a series of genuine migration bugs, the most dangerous of which turned encrypted binary content into a garbled text representation four times its size. Fixing them took the suite from thirty-three failures down to one, and that last failure is a deliberate, documented exception rather than an unsolved problem which is not a problem for the application.

== Phase 2: the application

With the libraries on Python 3, the Flask application was ported on top of them. Its risk was concentrated in three places, in decreasing order of effort.

The largest was the passkey (WebAuthn) code. The library ICNML used for hardware-key authentication had been abandoned, and its replacement shares none of the old programming interface, so the registration and login routes had to be rewritten against the new one rather than merely re-pinned. Because this path cannot be exercised without an administrator's physical security key, it was validated against the dev environment with actual DNS record.

The second was the same text-versus-bytes problem as the libraries, now in the application's own cryptography and image handling. Here the byte-for-byte gate described above was the solution, the crypto code was rewritten to operate on true bytes while reproducing the old stored formats exactly, and it was accepted only once it decrypted the Python 2 baseline unchanged.

The third was the session store. ICNML keeps user sessions in Redis, serialised with a mechanism that is both Python-2-specific and a known security risk if the Redis store is ever compromised. The migration switched it to the standard Python 3 mechanism, and rather than try to read old sessions with the new code, the plan is simply to clear the session store at deployment, which costs users one re-login and avoids the risk entirely.

Everything else was the ordinary work of a version bump. Every third-party dependency was moved from its last Python 2 release to a current one, and the container base image was moved from Python 2.7 to Python 3.11. The full list is in @appendix-python3-migration.

== Assessment

The migration achieved its two goals. ICNML now runs on a supported interpreter, and it does so without a data migration, existing hashes and encrypted images remain valid because the stored formats were preserved byte-for-byte. The application boots and serves against real PostgreSQL and Redis, and the passkey flow works against the rewritten library. In terms of the codebase, this is the single most consequential change made during the thesis, because it removes the constraints and vulnerabilities of the Python 2.7 version.
