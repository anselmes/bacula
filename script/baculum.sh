#!/usr/bin/env sh

echo '===> Installing Baculum...'

rpm --import http://bacula.org/downloads/baculum/baculum.pub

cat << __EOF__ > /etc/yum.repos.d/baculum.repo
[Baculum]
name=CentOS - Baculum
baseurl=http://bacula.org/downloads/baculum/stable/fedora
gpgcheck=1
enabled=1
__EOF__

yum install -y \
  baculum-common \
  baculum-api \
  baculum-api-httpd \
  baculum-web \
  baculum-web-httpd

cat << __EOF__ > /etc/sudoers.d/baculum
Defaults:apache !requiretty
apache ALL=NOPASSWD: /usr/sbin/bconsole
apache ALL=NOPASSWD: /usr/sbin/bdirjson
apache ALL=NOPASSWD: /usr/sbin/bsdjson
apache ALL=NOPASSWD: /usr/sbin/bfdjson
apache ALL=NOPASSWD: /usr/sbin/bbconjson
__EOF__

chown -R apache /opt/bacula/etc

firewall-cmd --permanent --new-service=baculum
firewall-cmd --permanent --service=baculum --set-description=Bacula Web Console
firewall-cmd --permanent --service=baculum --set-short=Baculum
firewall-cmd --permanent --service=baculum --add-port=9095-9096/tcp
firewall-cmd --permanent --zone=public --add-service=baculum
firewall-cmd --reload

systemctl enable httpd.service
