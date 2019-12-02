FROM centos:8
MAINTAINER Cedric DELGEHIER <cedric.delgehier@laposte.net>

ENV LANG fr_FR.UTF-8
ENV container docker

# https://hub.docker.com/_/centos/
RUN \
    (cd /lib/systemd/system/sysinit.target.wants/ || exit; for i in *; do [ "$i" = systemd-tmpfiles-setup.service ] || rm -f "$i"; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*; \
    rm -f /etc/systemd/system/*.wants/*; \
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*; \
    systemctl mask dev-mqueue.mount dev-hugepages.mount \
      systemd-remount-fs.service sys-kernel-config.mount \
      sys-kernel-debug.mount sys-fs-fuse-connections.mount \
      systemd-logind.service getty.service getty.target; \
    yum -y upgrade; \
    yum -y install epel-release; \
    yum -y install git sudo python3 python3-libselinux iproute python3-netaddr rsyslog; \
    yum clean all; \
    : Can't log kernel messages unless we're privileged; \
    sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf; \
    python3 -m pip install --upgrade pip; \
    python3 -m pip install "ansible>=2.9,<2.10"; \
    sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers; \
    install -d -o root -g root -m 755 /etc/ansible/roles; \
    echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts; \
    echo -e '[defaults]\nretry_files_enabled = False\nstdout_callback = yaml\ncallback_whitelist = profile_tasks\ndeprecation_warnings = True\n[colors]\ndiff_remove = purple\n[diff]\nalways = yes' > /etc/ansible/ansible.cfg

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/sbin/init"]
