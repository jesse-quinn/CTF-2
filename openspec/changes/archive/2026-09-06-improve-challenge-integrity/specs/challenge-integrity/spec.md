# Challenge integrity

## ADDED Requirements

### Requirement: Documented solution path is reproducible

The challenge SHALL provide a WALKTHROUGH whose every documented stage succeeds
against the files as built, with no stage that dead-ends or contradicts the files.
In particular, where the LFI directly reads a flag or a credential, the WALKTHROUGH
SHALL document that direct read as a known shortcut and SHALL NOT claim a stage
(such as the log-poisoning RCE) is required when the files do not enforce it.

#### Scenario: Direct-read shortcut is documented, not contradicted

- **WHEN** a maintainer follows the WALKTHROUGH against the built images and the
  unfiltered LFI can include the same-user `www-data` flag file directly and dump
  `config.php` via a `php://filter` wrapper
- **THEN** the WALKTHROUGH lists both direct reads as known LFI shortcuts and does
  not state that the log-poisoning RCE is required to obtain the `www-data` flag

#### Scenario: Every documented stage still solves

- **WHEN** a maintainer executes each WALKTHROUGH stage in order against the built
  images
- **THEN** each stage produces the described result and no stage instructs an
  action that the files do not support

### Requirement: Offline-reproducible climax

The socket-breakout step SHALL reuse a container image already present in the outer
engine from the inner build, rather than pulling a new image that requires network
access at solve time.

#### Scenario: Breakout uses a locally-present image

- **WHEN** a solver runs the documented socket-breakout command on a
  network-isolated host after the inner stack has built
- **THEN** the command references an image the outer engine already holds (for
  example the inner web image base `php:8.4-apache`) and reads the outer root flag
  without pulling any new image

### Requirement: Deterministic inner sshd host keys

The inner web image SHALL generate its sshd host keys at build time (`ssh-keygen -A`)
rather than relying on base-image package postinstall behaviour, so the SSH
lateral-move stage is reachable regardless of the base distribution revision.

#### Scenario: Host keys exist at build time

- **WHEN** the inner web image is built and its sshd is started at container start
- **THEN** host keys are present because they were generated during the build, and
  sshd starts successfully to serve the milo SSH lateral move even on a base
  revision whose openssh postinstall defers key generation to first boot
