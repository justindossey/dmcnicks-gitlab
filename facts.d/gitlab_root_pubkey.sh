#!/bin/sh

PUBKEYS="id_rsa.pub id_dsa.pub"
SSHDIR="/root/.ssh"

for KEYFILE in $PUBKEYS
do
  if [ -f "$SSHDIR/$KEYFILE" ]
  then
    KEY=`cat $SSHDIR/$KEYFILE`
    echo "gitlab_root_pubkey: $KEY"
    exit
  fi
done
