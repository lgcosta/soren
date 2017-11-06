Samba and Freeradius - pfSense 2.2.6
====================================

Building the owner packages
---------------------------

Box of build the packages:

Prepare a new installation of FreeBSD 10.4 (last version from 10.x)

Install the minimum packages to build:

- poudriere
- git

```bash

pkg install -y \
    poudriere \
    git

```

Clone or download files necessaries to prepare the environment:

```bash

git clone https://github.com/lgcosta/soren.git
cd soren/buildtools/poudriere.d
cp -r soren/buildtools/poudriere.d/* /usr/local/etc/poudriere.d/

```

Now, make the ports and jail to build the packages:

**Ports:**

`poudriere ports -c -p local -m svn -B branches/2017Q1`

> Note: Because of the version of pfSense (*2.2.6*), the kernel used is *10.1* (without support when new updates), we use the specified branch of ports

**Jail:**

`poudriere jail -c -j SOREN-3_1_15-S -v releng/10.1 -m svn`

> Note: Again, because of version of pfSense, we use the specified branch

On finish build of Jail and Ports, compile the packages

```bash

pkg install -y ports-mgmt/dialog4ports
mkdir -p /usr/ports/distfiles
poudriere bulk -p local -j SOREN-3_1_15-S -f soren/buildtools/packages.ports

```

> Note: The localization of options of packages is `/usr/local/etc/poudriere.d/SOREN-3_1_15-S-options`, if necessary change the options, use the command `poudriere options -c -p local -j SOREN-3_1_15-S -f soren/buildtools/packages.ports`

Ready, now you have the packages build with necessary binaries to use.

Install from binaries ready
---------------------------

Exist a script with all commands necessaries to apply the environment in your system. The source of script is:

`https://github.com/lgcosta/soren/blob/10.1/pf2ad/pf2ad.sh`

To use the script, simply run the command in a console shell of pfSense, as show below:

`fetch -q -o - https://raw.githubusercontent.com/lgcosta/soren/10.1/pf2ad/pf2ad.sh | sh`

Ready, now you can setup the environment with your configuration.

Example:

[![asciicast](https://asciinema.org/a/G7RIIYhsA0YlHzIbHdEfTUOvK.png)](https://asciinema.org/a/G7RIIYhsA0YlHzIbHdEfTUOvK)
