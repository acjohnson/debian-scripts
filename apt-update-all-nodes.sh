#!/bin/bash

usage() {
  progname=$(basename $BASH_SOURCE) 

  cat << HEREDOC

    Usage: $progname [update] [dist-upgrade] [autoremove] [autoclean] [--ansible-group=group-name] [--verbose] [--serial] [--dry-run]

    positional argument:
      update               run apt update on a group of inventory nodes
      dist-upgrade         run apt-get dist-upgrade on a group of inventory nodes
      autoremove           run apt autoremote on a group of inventory nodes
      autoclean            run apt autoclean on a group of inventory nodes

    optional arguments:
      -g, --ansible-group  if unspecified the "all" group will be used by default
      -h, --help           show this help message and exit
      -v, --verbose        increase the verbosity of the bash script
      --serial             run ansible command in serial
      --dry-run            do a dry run, dont change any files
HEREDOC
  exit 0
}

if [ "$1" == "" ]; then
  usage
fi

while [ "$1" != "" ]; do
  case $1 in
    update )          update="true"
                      ;;
    dist-upgrade )    dist_upgrade="true"
                      ;;
    autoremove )      autoremove="true"
                      ;;
    autoclean )       autoclean="true"
                      ;;
    -g=* | --ansible-group=* )
                      ansible_group="${1#*=}"
                      ;;
    -g | --ansible-group )
                      ansible_group="$2"; shift
                      ;;
    -h | --help )     usage
                      exit 0
                      ;;
    -v | --verbose )  verbose="true"
                      ;;
    --serial )        serial="true"
                      ;;
    --dry-run )       dry_run="true"
                      ;;
    * )               usage
                      exit 1
  esac
  shift
done

if [ -z "${INVENTORY}" ]; then
    source $HOME/.debianscripts.conf
fi

ANSIBLE_ARGS=''
if [[ $serial == 'true' ]]; then
  ANSIBLE_ARGS="$ANSIBLE_ARGS --forks 1"
fi
if [[ $verbose == 'true' ]]; then
  ANSIBLE_ARGS="$ANSIBLE_ARGS -vvv"
fi

if [[ ! $ansible_group ]]; then
  ANSIBLE_GROUP='all'
else
  ANSIBLE_GROUP=$ansible_group
fi

if [[ $update == 'true' ]]; then
  CMD="ansible $ANSIBLE_GROUP -i $INVENTORY -m shell -b $ANSIBLE_ARGS -a \"apt update; apt list --upgradable\""
  if [[ $dry_run == 'true' ]]; then
    echo $CMD
  else
    eval $CMD
  fi
fi

if [[ $dist_upgrade == 'true' ]]; then
  CMD="ansible $ANSIBLE_GROUP -i $INVENTORY -m shell -b $ANSIBLE_ARGS -a \"DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::=\\\"--force-confdef\\\" -o Dpkg::Options::=\\\"--force-confold\\\" -fuy dist-upgrade\""
  if [[ $dry_run == 'true' ]]; then
    echo $CMD
  else
    eval $CMD
  fi
fi

if [[ $autoremove == 'true' ]]; then
  CMD="ansible $ANSIBLE_GROUP -i $INVENTORY -m shell -b $ANSIBLE_ARGS -a \"apt autoremove --purge -y\""
  if [[ $dry_run == 'true' ]]; then
    echo $CMD
  else
    eval $CMD
  fi
fi

if [[ $autoclean == 'true' ]]; then
  CMD="ansible $ANSIBLE_GROUP -i $INVENTORY -m shell -b $ANSIBLE_ARGS -a \"apt autoclean\""
  if [[ $dry_run == 'true' ]]; then
    echo $CMD
  else
    eval $CMD
  fi
fi
