#!/bin/bash

LOGFILE="reinstallationlog.txt"

for pkg in `dpkg --get-selections | egrep -v deinstall | awk '{print $1}' | egrep -v '(x11-common|libc|libss2|libstdc|libpam|libgcc|liblaunch pad|libtext-wrap|lsb-base|passwd|upstart|dpkg|debconf|perl-base|python|apt|initscripts|sysv|coreutils|bash|my sql|virtuoso|mythtv|anjuta|dash|diff)'` ; do
  pkgs="$pkgs $pkg";
done

echo "The Following Apt-Get Command Will Be Run:" | tee $LOGFILE
echo "------------------------------------------" | tee -a $LOGFILE
echo "apt-get -y -m --force-yes install --reinstall ${pkgs}" | tee -a $LOGFILE
echo "Command Output Log:" | tee -a $LOGFILE
echo "-------------------" | tee -a $LOGFILE
echo "" | tee -a $LOGFILE

apt-get -y -m --force-yes install --reinstall $pkgs | tee -a $LOGFILE
