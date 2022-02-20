#!/bin/sh

# https://cloudinit.readthedocs.io/en/latest/topics/format.html

# This cloud-init boothook script will be one of the very
# first things run on a newly-provisioned oci-freedigs server.

STATEDIR=/var/local/oci-freedigs/cloudinit/
mkdir -p $STATEDIR

STATEFILE=$STATEDIR/cloudinit.boothook.done

date > $STATEFILE
