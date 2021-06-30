#!/bin/bash

usage() {
  progname=$(basename $BASH_SOURCE) 

  cat << HEREDOC

    Usage: $progname [update] [dist-upgrade] [autoremove] [--verbose] [--dry-run]

    positional argument:
      update               run apt update on all inventory nodes
      dist-upgrade         run apt-get dist-upgrade on all inventory nodes
      autoremove           run apt autoremote on all inventory nodes

    optional arguments:
      -h, --help           show this help message and exit
      -v, --verbose        increase the verbosity of the bash script
      --dry-run            do a dry run, dont change any files
HEREDOC
  exit 0
}

if [ "$1" == "" ]; then
  usage
fi

while [ "$1" != "" ]; do
  case $1 in
    update )          shift
	              update="true"
	              ;;
    dist-upgrade )    dist_upgrade="true"
                      ;;
    autoremove )      autoremove="true"
                      ;;
    -v | --verbose )  verbose="true"
                      ;;
    -h | --help )     usage
                      exit 0
                      ;;
    --dry-run )       dry_run="true"
                      ;;
    * )               usage
                      exit 1
  esac
  shift
done

source $HOME/.debianscripts.conf

if [[ $update == 'true' ]]; then
  CMD='ansible all -i $INVENTORY -m shell -b -a "apt update; apt list --upgradable"'
  if [[ $dry_run == 'true' ]]; then
    echo $CMD
  else
    if [[ $verbose == 'true' ]]; then
        eval "${CMD} -vvv"
      else
        eval $CMD
    fi
  fi
fi

if [[ $dist_upgrade == 'true' ]]; then
  CMD='ansible all -i $INVENTORY -m shell -b -a "apt-get -o Dpkg::Options::=\"--force-confold\" -fuy dist-upgrade"'
  if [[ $dry_run == 'true' ]]; then
    echo $CMD
  else
    if [[ $verbose == 'true' ]]; then
        eval "${CMD} -vvv"
      else
        eval $CMD
    fi
  fi
fi

if [[ $autoremove == 'true' ]]; then
  CMD='ansible all -i $INVENTORY -m shell -b -a "apt autoremove --purge -y"'
  if [[ $dry_run == 'true' ]]; then
    echo $CMD
  else
    if [[ $verbose == 'true' ]]; then
        eval "${CMD} -vvv"
      else
        eval $CMD
    fi
  fi
fi
