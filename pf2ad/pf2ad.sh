#!/bin/sh

# Verify version of pfSense
if [ "$(cat /etc/version)" == "v3.1.15-S" ] || [ "$(cat /etc/version)" == "2.2.6-RELEASE" ]; then
	echo "Starting installation ... "
else
	echo "ERROR: You need the pfSense version 2.2.6 or v3.1.15-S to apply this script"
	exit 2
fi

arch="`uname -p`"

ASSUME_ALWAYS_YES=YES
export ASSUME_ALWAYS_YES

cat <<EOF > /etc/pkg/FreeBSD.conf
FreeBSD: {
  url: "https://pkg.freebsd.org/FreeBSD:10:amd64/release_1",
  mirror_type: "https",
  enabled: yes
}
EOF

/usr/sbin/pkg bootstrap
/usr/sbin/pkg update

mkdir -p /usr/local/etc/pkg/repos

cat <<EOF > /usr/local/etc/pkg/repos/pf2ad.conf
pf2ad: {
    url: "https://raw.githubusercontent.com/lgcosta/soren/10.1/packages",
    mirror_type: "https",
    enabled: yes
}
EOF

/usr/sbin/pkg update
/usr/sbin/pkg install -r pf2ad net/samba44 net/freeradius3

rm -rf /usr/local/etc/pkg/repos/pf2ad.conf
/usr/sbin/pkg update

mkdir -p /var/db/samba4/winbindd_privileged
chown -R :proxy /var/db/samba4/winbindd_privileged
chmod -R 0750 /var/db/samba4/winbindd_privileged

fetch -o /usr/local/pkg -q https://raw.githubusercontent.com/lgcosta/soren/10.1/pf2ad/samba.inc
fetch -o /usr/local/pkg -q https://raw.githubusercontent.com/lgcosta/soren/10.1/pf2ad/samba.xml

fetch -o /tmp/do_config.php -q https://raw.githubusercontent.com/lgcosta/soren/10.1/pf2ad/script-config.php
/usr/local/sbin/pfSsh.php < /tmp/do_config.php
rm -f /tmp/do_config

mkdir -p /var/db/samba/winbindd_privileged
chown -R :proxy /var/db/samba/winbindd_privileged
chmod -R 0750 /var/db/samba/winbindd_privileged

/etc/rc.d/ldconfig restart

