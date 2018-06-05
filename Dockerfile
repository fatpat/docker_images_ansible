FROM debian:9
MAINTAINER Cedric DELGEHIER <cedric.delgehier@laposte.net>

ENV container docker

# Install Ansible
RUN \
    (cd /lib/systemd/system/sysinit.target.wants/ || exit; for i in *; do [ "$i" = systemd-tmpfiles-setup.service ] || rm -f "$i"; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*; \
    rm -f /etc/systemd/system/*.wants/*; \
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*; \
    apt update; \
    apt install -y git python-pip python-netaddr rsyslog systemd-sysv; \
    : Can't log kernel messages unless we're privileged; \
    sed -i 's/^\(module(load="imklog")\)/#\1/' /etc/rsyslog.conf; \
    echo 'deb http://http.debian.net/debian stretch-backports main' > /etc/apt/sources.list.d/backports.list; \
    apt update; \
    rm -rf /var/lib/apt/lists/*; \
    rm -Rf /usr/share/doc && rm -Rf /usr/share/man; \
    apt clean; \
    pip install "ansible>=2.5,<2.6"; \
    install -d -o root -g root -m 755 /etc/ansible/roles; \
    echo '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts; \
    echo '[defaults]\nretry_files_enabled = False' > /etc/ansible/ansible.cfg

VOLUME ["/sys/fs/cgroup"]
CMD ["/sbin/init"]
