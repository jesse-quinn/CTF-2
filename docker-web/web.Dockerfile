FROM php:8.4-apache

ARG DOCKER_CLI_VERSION=29.8.0

# Software the challenge needs: sshd for the lateral move, sudo for the privesc,
# and a static Docker CLI for the final socket breakout.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        openssh-server sudo curl ca-certificates \
    && echo "Installing a static Docker CLI (used for the final socket breakout)" \
    && arch="$(uname -m)" \
    && curl -fsSL "https://download.docker.com/linux/static/stable/${arch}/docker-${DOCKER_CLI_VERSION}.tgz" -o /tmp/docker.tgz \
    && tar -xzf /tmp/docker.tgz -C /usr/local/bin --strip-components=1 docker/docker \
    && rm -f /tmp/docker.tgz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# The application user. Milo reuses his system password as the database account
# password in the webroot config, which is what makes the lateral move possible.
RUN useradd -m -s /bin/bash milo \
    && echo "milo:8EPYJySLj0JkertR" | chpasswd \
    && ln -sf /dev/null /home/milo/.bash_history \
    && ln -sf /dev/null /root/.bash_history

# Log poisoning primitive. The base image symlinks the access log to stdout, so
# it cannot be included through the LFI. Point it at a real file and let the PHP
# worker (www-data, in the adm group) read it. A poisoned User-Agent then lands
# in a log the LFI can include and execute.
# The default vhost already logs to /var/log/apache2/access.log; removing the
# symlink makes that path a real file instead of a redirect to stdout.
RUN usermod -aG adm www-data \
    && rm -f /var/log/apache2/access.log

# sshd: only the milo account is reachable, by password; root login is off.
RUN mkdir -p /run/sshd \
    && sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# The web application. Set modes explicitly: the build context is locked down on
# the outer host, so the source files arrive mode 0600 and would be unreadable by
# the www-data worker without this.
COPY --chmod=644 ./html/ /var/www/html/

# Milo's recovered deploy key opens the "victor" account on the outer host, and
# a note tells him where to point it.
COPY --chown=milo:milo --chmod=700 ./ssh/deploy_key /home/milo/.ssh/deploy_key
COPY --chown=milo:milo --chmod=644 ./ssh/deploy_key.pub /home/milo/.ssh/deploy_key.pub
COPY --chown=milo:milo --chmod=600 ./notes-milo.txt /home/milo/notes-milo.txt

# The privesc: milo may run find as root without a password.
COPY --chown=root:root --chmod=440 ./sudoers.d/milo /etc/sudoers.d/milo

# Flags, each readable only by its owner.
COPY --chown=www-data:www-data --chmod=400 ./flags/web-user.txt /var/www/web-user.txt
COPY --chown=milo:milo --chmod=400 ./flags/milo.txt /home/milo/milo.txt
COPY --chown=root:root --chmod=400 ./flags/web-root.txt /root/web-root.txt

RUN chown -R milo:milo /home/milo/.ssh && chmod 700 /home/milo/.ssh

EXPOSE 80 22

CMD service ssh start && apache2-foreground
