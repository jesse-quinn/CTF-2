FROM ubuntu:24.04

# Base packages for the outer CTF host: its own Docker engine plus sshd.
RUN apt-get update \
    && apt-get install -y docker.io docker-compose-v2 openssh-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo "Setup docker env + ssh env" \
    && mkdir -p /var/lib/docker /run/sshd \
    && sed -i "s/#PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config \
    && sed -i "s/#PasswordAuthentication.*/PasswordAuthentication yes/" /etc/ssh/sshd_config \
    && ssh-keygen -A \
    && echo "Adding user victor" \
    && useradd -m -s /bin/bash victor \
    && echo -n "victor:pEF2E5m3xXSKbC3v/HSW3p84" | chpasswd \
    && userdel -r ubuntu 2>/dev/null || true \
    && echo "Bash history discarded (victor and root already use /bin/bash)" \
    && ln -sf /dev/null /root/.bash_history \
    && ln -sf /dev/null /home/victor/.bash_history

# Flags and the inner stack build context.
COPY ./main_flags/root.txt /root/root.txt
COPY ./main_flags/user.txt /home/victor/user.txt
COPY ./docker-web /home/victor/docker-web

# victor accepts the deploy key that the inner web container hands out. Only key
# auth is intended for victor; the password above is a random value, not a hint.
COPY ./docker-web/ssh/deploy_key.pub /home/victor/.ssh/authorized_keys

RUN echo "Permissions for flags" \
    && chown root:root /root/root.txt && chmod 0400 /root/root.txt \
    && chown victor:victor /home/victor/user.txt && chmod 0400 /home/victor/user.txt \
    && echo "Permissions for the deploy key login" \
    && chown -R victor:victor /home/victor/.ssh \
    && chmod 0700 /home/victor/.ssh \
    && chmod 0600 /home/victor/.ssh/authorized_keys \
    && echo "Lock down the build context so victor cannot shortcut past the game" \
    && chown -R root:root /home/victor/docker-web \
    && chmod -R go-rwx /home/victor/docker-web

# Store the inner Docker engine's data on a volume so the nested engine does not
# run overlay-on-overlay (matches the official docker:dind image). Without this,
# inner image builds fail on hosts whose /var/lib/docker is itself an overlay
# filesystem (for example Docker Desktop).
VOLUME /var/lib/docker

EXPOSE 22 23 8080

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["docker", "compose", "-f", "/home/victor/docker-web/docker-compose.yaml", "up"]
