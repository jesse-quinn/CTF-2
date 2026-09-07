# Changelog

## 2026-09-06 - Integrity fixes

Corrections from an adversarial review that traced the five-flag chain end to end.
No flag values changed and no scoring changed.

- Walkthrough honesty: the unfiltered LFI directly reads the `www-data` flag
  (`index.php?page=/var/www/web-user.txt`) and dumps milo's credential
  (`config.php` via `php://filter`), so the log-poisoning RCE is optional. The
  walkthrough now documents both direct-read shortcuts and no longer claims the
  RCE is required for the `www-data` flag; the RCE remains the intended teaching
  primitive.
- Offline-reproducible climax: the socket-breakout command reuses `php:8.4-apache`
  (already in the outer engine from the inner build) instead of pulling `alpine`,
  so the final step needs no network at solve time.
- Deterministic inner sshd host keys: `web.Dockerfile` now runs `ssh-keygen -A` at
  build time so the milo SSH lateral move stays reachable even if a future base
  revision defers openssh key generation to a first-boot unit.
- Outer-image hygiene: dropped the unused `nano`, removed the redundant global
  `/bin/sh` to `/bin/bash` rewrite (victor and root already use bash), and set the
  inner deploy-key copy to mode `0600`.

## Initial release

An original docker-in-docker CTF themed on web Local File Inclusion leading to
remote code execution through Apache log poisoning. It follows the same
packaging pattern as its sibling challenge CTF-1: one privileged outer container
runs its own Docker engine and deploys the vulnerable stack with Docker Compose.

### Challenge design

- Single inner web service on `php:8.4-apache`, so PHP executes as `www-data` in
  the same container that holds the lateral-move and privilege-escalation
  targets. This keeps the whole chain coherent inside one container.
- Five flags across two layers: three inside the web container (`www-data`,
  `milo`, container `root`) and two on the outer host (`victor`, `root`).
- Solve chain: LFI in the `index.php` page router, confirmed against
  `/etc/passwd`; log poisoning of the Apache access log via a crafted User-Agent
  for RCE as `www-data`; a reused credential in the webroot config that logs in
  as `milo` over SSH; a `sudo NOPASSWD` rule on `find` for container root; a
  recovered deploy key that opens the outer `victor` account; and the mounted
  outer Docker socket for the final breakout to outer root.

### Build hygiene

- The inner stack pulls its base image and a static Docker client at build time,
  so the challenge is multi-arch (amd64 and arm64) with no baked image tarballs.
- The outer Dockerfile declares `VOLUME /var/lib/docker` so the nested engine
  does not run overlay-on-overlay, which otherwise breaks inner builds on hosts
  whose `/var/lib/docker` is itself an overlay filesystem (Docker Desktop).
- The base `php:8.4-apache` image symlinks the access log to stdout; the inner
  image replaces it with a real file and adds `www-data` to the `adm` group so
  the log poisoning primitive is reachable through the LFI.
- The outer build context is locked down so the `victor` user cannot read the
  inner build files and shortcut the game; the inner web image sets webroot file
  modes explicitly so `www-data` can still serve and read them.
- `.dockerignore` keeps git history, docs, license, and the README out of the
  build context. `.gitignore` excludes runtime state.

### Conventions

- Fresh random flag values and credentials.
- The intended solution is documented for maintainers in `docs/WALKTHROUGH.md`.
