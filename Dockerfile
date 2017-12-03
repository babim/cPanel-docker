FROM centos:7
# Maintainer
# ----------
MAINTAINER babim <babim@matmagoc.com>

RUN rm -f /etc/motd && \
    echo "---" > /etc/motd && \
    echo "Support by Duc Anh Babim. Contact: babim@matmagoc.com" >> /etc/motd && \
    echo "---" >> /etc/motd && \
    touch "/(C) Babim"

ENV container docker

ENV LC_ALL en_US.UTF-8
ENV TZ Asia/Ho_Chi_Minh

RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs
RUN yum -y install openssh-server wget nano iputils htop telnet locales systemd systemd-libs
RUN yum -y update; yum clean all;
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

#RUN mkdir -p /etc/selinux/targeted/contexts/
#RUN echo '<busconfig><selinux></selinux></busconfig>' > /etc/selinux/targeted/contexts/dbus_contexts

#ADD dbus.service /etc/systemd/system/dbus.service
#RUN systemctl enable dbus.service

VOLUME ["/sys/fs/cgroup"]

COPY assets/wwwacct.conf /etc/wwwacct.conf
RUN mkdir /root/cpanel_profile/
COPY assets/cpanel.config /root/cpanel_profile/cpanel.config

RUN rm -f /etc/sysconfig/iptables
RUN wget -O /usr/local/src/latest.sh http://httpupdate.cpanel.net/latest
RUN chmod +x /usr/local/src/latest.sh && touch /etc/fstab
RUN /usr/local/src/latest.sh --target /usr/local/src/cpanel/ --noexec
RUN sed -i 's/check_hostname();/# check_hostname();/g' /usr/local/src/cpanel/install
RUN cd /usr/local/src/cpanel/ && ./bootstrap --force

COPY start.sh /root/start.sh
RUN chmod +x /root/start.sh

EXPOSE 20 21 22 25 53 80 110 143 443 465 587 993 995 2077 2078 2082 2083 2086 2087 2095 3306

ENTRYPOINT /root/start.sh
