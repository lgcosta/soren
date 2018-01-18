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

cat <<EOF > /usr/local/etc/pkg/repos/soren.conf
pf2ad: {
    url: "https://raw.githubusercontent.com/lgcosta/soren/ipsec-10.1/packages",
    mirror_type: "https",
    enabled: yes
}
EOF

/usr/sbin/pkg update
/usr/sbin/pkg install -r soren net/mpd5 security/ipsec-tools security/strongswan

rm -rf /usr/local/etc/pkg/repos/soren.conf
/usr/sbin/pkg update

/etc/rc.d/ldconfig restart

