# Tasks

## 1. Walkthrough honesty (R1)

- [x] 1.1 Rewrite `docs/WALKTHROUGH.md` Stage 1 so the `php://filter` read of
  `config.php` is presented as a legitimate known LFI shortcut, not deferred to
  the RCE.
- [x] 1.2 In `docs/WALKTHROUGH.md` Stage 2, add the direct-include shortcut for
  the `www-data` flag (`index.php?page=/var/www/web-user.txt`) alongside the RCE,
  and frame the RCE as the intended teaching primitive, not a hard requirement.
- [x] 1.3 In the `docs/WALKTHROUGH.md` Notes section, drop the "RCE is still
  required for the `www-data` flag" claim.

## 2. Offline-reproducible climax (R3)

- [x] 2.1 In `docs/WALKTHROUGH.md` Stage 5b, change the breakout command from
  `alpine` to `php:8.4-apache` (already in the outer engine from the inner build)
  and note any locally-present image works, so the step needs no network.

## 3. Deterministic inner sshd host keys (challenge-specific)

- [x] 3.1 Add `&& ssh-keygen -A` to the sshd `RUN` block in
  `docker-web/web.Dockerfile`.

## 4. Outer-image hygiene

- [x] 4.1 Remove the unused `nano` package from the outer `Dockerfile` apt install.
- [x] 4.2 Remove the redundant global `/bin/sh` to `/bin/bash` login-shell rewrite
  from the outer `Dockerfile` (victor and root already use bash).
- [x] 4.3 Set the inner deploy-key copy to `--chmod=600` in
  `docker-web/web.Dockerfile`.

## 5. Documentation and validation

- [x] 5.1 Add a `CHANGELOG.md` entry dated 2026-09-06 summarizing the integrity fixes.
- [x] 5.2 `bash -n entrypoint.sh` (and any edited shell) passes.
- [x] 5.3 `openspec validate improve-challenge-integrity --strict` passes.
