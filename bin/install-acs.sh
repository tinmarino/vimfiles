#!/usr/bin/env bash
# Print APT commands to install for Alma Common Software"

# sudo add-apt-repository ppa:glasen/freetype2
pg=(
ksh
gcc
libx11-dev
libffi-dev
perl
libreadline-dev
bzip2
openssl
slapd ldap-utils
libxml2-dev
libfreetype6-dev
libxslt-dev
sqlite
expat
bison
flex
autoconf
unzip
dos2unix
tcl-dev
tk-dev
openjdk-11-jdk
docker docker.io containerd runc docker-compose
git-lfs
)

# Print out
echo -n "sudo apt install -y "
for prog in "${pg[@]}" ; do echo -n "$prog " ; done
echo
