#!/bin/sh

# Verifica versao pfSense
if [ "$(cat /etc/version)" != "2.2.6-RELEASE" ]; then
	echo "ERROR: You need the pfSense version 2.2.6 to apply this script"
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

/usr/sbin/pkg update -r pf2ad
/usr/sbin/pkg install -r pf2ad net/samba44

rm -rf /usr/local/etc/pkg/repos/pf2ad.conf
/usr/sbin/pkg update

mkdir -p /var/db/samba4/winbindd_privileged
chown -R :proxy /var/db/samba4/winbindd_privileged
chmod -R 0750 /var/db/samba4/winbindd_privileged

fetch -o /usr/local/pkg -q https://raw.githubusercontent.com/lgcosta/soren/10.1/pf2ad/samba.inc
fetch -o /usr/local/pkg -q https://raw.githubusercontent.com/lgcosta/soren/10.1/pf2ad/samba.xml

fetch -o - -q https://raw.githubusercontent.com/lgcosta/soren/10.1/pf2ad/script-config.php | /usr/local/sbin/pfSsh.php

mkdir -p /var/db/samba/winbindd_privileged
chown -R :proxy /var/db/samba/winbindd_privileged
chmod -R 0750 /var/db/samba/winbindd_privileged

if [ ! "$(/usr/local/sbin/pfSsh.php playback listpkg | grep 'squid3')" ]; then
	/usr/local/sbin/pfSsh.php playback installpkg "squid3"
fi
if [ ! "$(/usr/local/sbin/pfSsh.php playback listpkg | grep 'squidGuard-devel')" ]; then
    mkdir -p /usr/pbi/squidguard-devel-${arch}/etc/squidGuard
    touch /usr/pbi/squidguard-devel-${arch}/etc/squidGuard/squidguard_conf.xml
	/usr/local/sbin/pfSsh.php playback installpkg "squidGuard-devel"
fi

if [ -f "/usr/local/bin/squidGuard" ]; then
	if [ "$(md5 -q /usr/local/bin/squidGuard)" != "f889ffd71c25926d46cebd839e8ea117" ]; then
		pkg install db48
		rm -rf /usr/local/bin/squidGuard
		fetch -q -o /usr/local/bin/squidGuard https://raw.githubusercontent.com/lgcosta/soren/10.1/pf2ad/squidGuard-${arch}
		chmod +x /usr/local/bin/squidGuard
	fi
fi

if [ "$(md5 -q /usr/pbi/squidguard-devel-${arch}/bin/squidGuard)" != "f889ffd71c25926d46cebd839e8ea117" ]; then
	cp -f /usr/local/bin/squidGuard /usr/pbi/squidguard-devel-${arch}/bin/
	chmod +x /usr/pbi/squidguard-devel-${arch}/bin/squidGuard
fi

# Fix libs in pbi
cp -r /usr/local/lib/libdb* /usr/local/lib/db48 /usr/pbi/squidguard-devel-${arch}/local/lib/
cp -r /usr/local/lib/libdb* /usr/local/lib/db48 /usr/pbi/squid-${arch}/local/lib/

cd /usr/local/pkg
if [ "$(md5 -q squid.inc)" != "3cf3dba2988356b84d37b35916ff55f7" ]; then
	fetch -o squid.inc -q https://raw.githubusercontent.com/lgcosta/soren/10.1/pf2ad/squid.inc
fi
if [ "$(md5 -q squid_js.inc)" != "731f80158ad4321ab34b6fd8b2da477e" ]; then
	fetch -o squid_js.inc -q https://raw.githubusercontent.com/lgcosta/soren/10.1/pf2ad/squid_js.inc
fi
if [ "$(md5 -q squid_auth.xml)" != "8e4855999c48f5a36b125681fe49b3ca" ]; then
	fetch -o squid_auth.xml -q https://raw.githubusercontent.com/lgcosta/soren/10.1/pf2ad/squid_auth.xml
fi

if [ ! -f "/usr/local/etc/smb.conf" ]; then
	touch /usr/local/etc/smb.conf
fi
if [ ! -f "/usr/pbi/squid-${arch}/local/etc/smb.conf" ]; then
	ln /usr/local/etc/smb.conf /usr/pbi/squid-${arch}/local/etc/smb.conf
fi
if [ -f "/usr/pbi/squid-${arch}/local/libexec/squid/ntlm_auth" ]; then
    if [ "$(md5 -q /usr/pbi/squid-${arch}/local/libexec/squid/ntlm_auth)" != "7d0dec78872956dada2057fee81031aa" ]; then
	    cp -f /usr/local/bin/ntlm_auth /usr/pbi/squid-${arch}/local/libexec/squid/ntlm_auth
    fi
else
    cp -f /usr/local/bin/ntlm_auth /usr/pbi/squid-${arch}/local/libexec/squid/ntlm_auth
fi

/etc/rc.d/ldconfig restart

