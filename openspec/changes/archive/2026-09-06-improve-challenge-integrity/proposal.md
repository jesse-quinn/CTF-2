# Improve challenge integrity

## Why

An adversarial review of this CTF on 2026-09-06 traced the five-flag chain end to
end against the files as built and confirmed it solves, but found three integrity
defects worth correcting:

- The walkthrough claims the log-poisoning RCE is "required for the `www-data`
  flag", yet the same unfiltered LFI that confirms the bug also directly includes
  `/var/www/web-user.txt` (a same-user, no-PHP-tags flag file) and dumps
  `config.php` (milo's reused credential) via `php://filter`. The featured
  vulnerability is therefore optional, and the documentation misleads the
  maintainer about what the challenge enforces.
- The final socket-breakout command runs `docker run ... alpine`, an image the
  outer engine does not have cached from the inner build, so the climax needs a
  live image pull and fails on a network-isolated or rate-limited solve host.
- The inner web image relies on the openssh-server apt postinst to generate sshd
  host keys at install time. That holds on the current Debian bookworm base but
  is an unhedged dependency: a base revision that defers keygen to a first-boot
  unit (which never fires in a container) would leave sshd unable to start and
  silently break the milo SSH lateral move.

## What Changes

- **ADDED** requirement: the documented solution path is reproducible and does
  not contradict the files (walkthrough honesty about the LFI direct-read
  shortcut; drop the false "RCE is required" claim).
- **ADDED** requirement: the socket-breakout climax reuses an image already
  present in the outer engine from the inner build (`php:8.4-apache`) rather than
  pulling a new image, so it needs no network at solve time.
- **ADDED** requirement (challenge-specific): the inner web image generates sshd
  host keys at build time (`ssh-keygen -A`) rather than relying on base-image
  package postinstall behaviour, so the SSH lateral-move stage stays reachable on
  any base revision.
- Minor outer-image hygiene folded into the same edits: drop the unused `nano`,
  remove the redundant global login-shell rewrite, and set the inner deploy-key
  copy to mode `0600`.

## Impact

- Affected: documentation (`docs/WALKTHROUGH.md`, `CHANGELOG.md`) and challenge
  content (`Dockerfile`, `docker-web/web.Dockerfile`).
- No scoring change and no flag-value change: every flag keeps its value and its
  intended reader; only a doc claim, one solve-time image name, a build-time
  keygen line, and minor image hygiene change.
- Out of scope: reworking the RCE into a genuinely load-bearing checkpoint (the
  same-user flag is inherently include-readable, so the honest fix is
  documentation, not a redesign); adding a checksum to the docker CLI fetch
  (already version-pinned; the checksum was not verifiable offline in this pass).
- No git commit is made; all edits are left uncommitted in the working tree.
