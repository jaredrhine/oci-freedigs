#!/bin/sh

# https://cloudinit.readthedocs.io/en/latest/topics/format.html

# This cloud-init "user-data script" will run in the main body of
# cloud-init execution on a newly-provisioned oci-freedigs server.

STATEDIR=/var/local/oci-freedigs/cloudinit/
mkdir -p $STATEDIR

STATEFILE=$STATEDIR/cloudinit.script.done

date > $STATEFILE
