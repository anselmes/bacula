#!/usr/bin/env sh

echo '===> Installing Bacula...'

bacula_version="9.2.2"
bacula_key="5beeadd7bb141"

yum install -y \
  zip \
  wget \
  apt-transport-https \
  bzip2

wget -c https://www.bacula.org/downloads/Bacula-4096-Distribution-Verification-key.asc -O /tmp/Bacula-4096-Distribution-Verification-key.asc
rpm --import /tmp/Bacula-4096-Distribution-Verification-key.asc

cat << __EOF__ > /etc/yum.repos.d/bacula-community.repo
[Bacula-Community]
name=CentOS - Bacula - Community
baseurl=http://www.bacula.org/packages/${bacula_key}/rpms/${bacula_version}/el7/x86_64/
enabled=1
protect=0
gpgcheck=0
__EOF__

yum install -y \
  postgresql-server \
  bacula-postgresql --exclude=bacula-mysql

postgresql-setup initdb

systemctl enable postgresql
systemctl start postgresql

su - postgres -c "/opt/bacula/scripts/create_postgresql_database"
su - postgres -c "/opt/bacula/scripts/make_postgresql_tables"
su - postgres -c "/opt/bacula/scripts/grant_postgresql_privileges"

systemctl enable bacula-fd.service
systemctl enable bacula-sd.service
systemctl enable bacula-dir.service

systemctl start bacula-fd.service
systemctl start bacula-sd.service
systemctl start bacula-dir.service

for i in $(ls /opt/bacula/bin); do
  ln -s /opt/bacula/bin/$i /usr/sbin/$i;
done

sed '/[Aa]ddress/s/=\s.*/= localhost/g' -i /opt/bacula/etc/bconsole.conf
