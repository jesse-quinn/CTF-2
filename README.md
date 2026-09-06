# LFI-to-RCE Docker-in-Docker CTF

This is a Capture The Flag challenge that runs as a single privileged Docker
container. Inside it, an outer host runs its own Docker engine and deploys a
small PHP web application with Docker Compose. The web application has a Local
File Inclusion bug in its page router; the intended path turns that into remote
code execution through Apache log poisoning, moves laterally to a system user,
escalates to root inside the container, and finally breaks back out to the outer
host through an exposed Docker socket.

There are five flags:

| Flag file | Location | Prefix |
|---|---|---|
| web-user.txt | web container, user `www-data` | `FLAG{...}` |
| milo.txt | web container, user `milo` | `FLAG{...}` |
| web-root.txt | web container, `root` | `WEB_FLAG{...}` |
| user.txt | outer host, user `victor` | `MAIN_FLAG{...}` |
| root.txt | outer host, `root` | `MAIN_FLAG{...}` |

## Requirements

- Docker Engine that can run a privileged container (Docker Desktop works).
- Internet access on the first run: the inner stack pulls its base image
  (php:8.4-apache) and a static Docker client at build time.
- Works on both amd64 and arm64 hosts.

## Running the challenge

```bash
git clone https://github.com/jesse-quinn/CTF-2.git
cd CTF-2
docker image build -t docker-ctf2:latest .
docker container run -it --rm --privileged \
  --hostname docker-ctf2 --name docker-ctf2 \
  -p 8080:8080 -p 22:22 -p 23:23 \
  docker-ctf2:latest
```

Run the build and run from inside the cloned `CTF-2` directory. On Docker
Desktop (macOS, Windows) do not use `sudo`; on a Linux host, prefix both
commands with `sudo` or add your user to the `docker` group.

Then wait for the inner Docker Compose stack to finish deploying. The web
application is served on port 8080, the outer host SSH on port 22, and the web
container SSH on port 23.

Note: if you use `-d`, you will not see the inner Compose deployment progress.

If some of those host ports are already in use on your machine, remap the left
side of each `-p` flag (for example `-p 18080:8080 -p 2222:22 -p 2323:23`); the
challenge itself is unaffected.

## Rules

- Do not read the flag files or the solution notes during setup. The challenge
  is finding them through gameplay.
- The intended solution path is documented, for maintainers, in
  `docs/WALKTHROUGH.md`. It is a spoiler; do not open it if you want to play.

## Credits

This is an original challenge, inspired by the Himanshukr000/CTF-DOCKERS
collection (<https://github.com/Himanshukr000/CTF-DOCKERS>) and themed on web
Local File Inclusion leading to remote code execution via log poisoning. The
docker-in-docker packaging follows the same pattern as its sibling challenge
CTF-1.
