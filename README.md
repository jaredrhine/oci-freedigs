# oci-freedigs

Repository URL: https://github.com/jaredrhine/oci-freedigs

Author: Jared Rhine <jared@wordzoo.com>

Keywords: Terraform, Oracle Cloud Infrastructure, OCI, Tailscale, free, cloud computing, ARM

## Purpose

The code in this repository uses Terraform to build a small server
cluster hosted by Oracle Cloud Infrastructure (OCI). The configuration
is opinionated and tailored to the goals of Jared Rhine, the
author. The cluster resources are designed to fit within OCI's free
tier, and so uses their ARM-based servers to unlock the attractive
24GB RAM allocation. The cluster connects to a Tailscale virtual
network instance.

## Goals

- Use OCI's free services efficiently
- Provide commercial-cloud grade network edge services including HTTP
  and ssh proxying, suitable for connection to private backend hosting
- Connect to Tailscale (Wireguard) automatically
- No-hands provisioning, low-hassle, and resilient to being deleted
- Encode knowledge about how to build a useful OCI-based network
  appliance, to minimize relearning later (Infrastructure as Code)
- Match the author's preferred configuration. Not intended to be
  generally reusable or highly configurable for multiple use cases.

## Background

Oracle provides generous (when compared to competitors' offerings)
free networking services. In particular, their free RAM allocation of
24GB for ARM-based servers is attractive.

Oracle provides a [free pricing tier](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm) supporting a
single always-on arm64 server with 4x CPU, 24 GB RAM, 200 GB disk, and
healthy bandwidth allotment. You can create up to four smaller servers
that add up to these limits, which can include 2x "micro" sized (2 core, 1GB RAM) Intel
servers and various other cloud services.

Running ARM servers adds some hassles and limitations depending on
your hosting use case (particular around running Intel-built Docker
containers and workloads), but this repo provides a basic hosting
pattern for those willing to admin such a cluster.

## Cluster specification

Standards:
- ARM (arm64/aarch64) for primary CPU architecture (amd64 free resources also created)
- Ubuntu 20.04 for OS
- Bash for shell
- [Tailscale](https://tailscale.com/) ([Wireguard](https://www.wireguard.com/)) for VPN. Tailscale DNS integration supported.
- [`ufw`](https://en.wikipedia.org/wiki/Uncomplicated_Firewall) for firewall rules. TCP open on ports 22 (all interfaces) for ssh inbound. UDP open on 41641 for tailscale. Provider network passes all traffic.
- Minimal language frameworks installed: go, java, lua, nodejs, perl, python2, python3, ruby, rust
- Extra packages installed: ag, autossh, awscli, aws-shell, bmon, buffer, build-essential, ctop, direnv, docker, dstat, emacs-nox, fakeroot, fswatch, fzf, git, hwinfo, iotop, jq, keychain, kubeadm, kubectl, mosh, netcat, nmap, p7zip, procps, psutils, pv, pwgen, rclone, runit, s3cmd, s3fuse, s4cmd, socat, sshfs, ssh-tools, swaks, tig, tmux, tree, tshark, unicorn, unintended-upgrades, uuid, zip, zsh. Libraries for bz, curl, readline, sqlite, openssl.

Terraform components:
- Compute instance (`oci_core_instance.freedigs_compute`)
  - Shape: CPU arch, core count, RAM size
  - Boot volume
    - Block device size
    - Initial image
  - Network interface (VNIC)
  - cloud-init `user_data`
  - User account
    - Username
    - SSH public key
- Network
  - VCN (`oci_core_vcn.freedigs_vcn_main`)
  - Subnet (`oci_core_subnet.freedigs_subnet_main`)
  - Gateway (`oci_core_internet_gateway.freedigs_gateway_main`)
  - Routes (`oci_core_default_route_table.freedigs_routes_main`)
  - Security groups (`oci_core_network_security_group.freedigs_security_group`)
  - Network rule (`oci_core_network_security_group_security_rule.freedigs_rules_ingress`)

## Recommended setup procedure

This repo's Terraform code does not use the `oci` CLI tool or its
configuration files. Instead, this procedure uses the OCI web
interface to lookup the needed config. This is done to minimize the
number of external dependencies and the need for the user to interact
more deeply with the OCI stack.

The following procedures assume you log into the OCI web console using
an administrator account. Some steps will be different if you are an
OCI regular user. You can also create a dedicated IAM user for use by
Terraform.

1. Set up accounts with hosted services
   1. Oracle
      1. Create [Oracle account](https://profile.oracle.com/)
      1. Create [Oracle Cloud account](https://cloud.oracle.com/)
      1. Set up a payment method. If you don't, your first VM will be deleted after 30 days.
   1. Tailscale
      1. Create a [Tailscale account](https://tailscale.com/)
      1. Set up Tailscale. Use it to connect your computer or phone or whatever. Further details are outside the scope of this document.
      1. Create a Tailscale auth key from the [Tailscale admin console](https://login.tailscale.com/admin/settings/keys). Use this when asked for `tailscale_auth_key` later.
1. Install Terraform
   1. Use your own Terraform procedures if you'd like. Otherwise:
   1. Install and configure [`asdf`](https://asdf-vm.com/) for your shell.
   1. Install `terraform` `asdf` plugin: `asdf plugin-add terraform https://github.com/asdf-community/asdf-hashicorp.git`
   1. Run `asdf` to install Terraform: `asdf install`
1. Create an OCI signing key ([docs](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm))
   1. You can use `openssl` or other CLI approaches to creating a 2048 bit RSA key pair in PEM format. If you do that, modify these steps as needed.
   1. Visit the OCI [web console](https://cloud.oracle.com/)
   1. Under the hamburger menu, "Identity & Security" --> "Identity" --> "Users". Click on the link for the federated account to reach the "User Details" page. In the lower left, switch to the "API Keys" section.
   1. Click "Add API Key". Confirm the "Generate API Key Pair" option is selected.
   1. Click "Download Private Key" and put the result into a local file (the `oci` CLI tool uses `~/.oci/ORACLESOMETHING.pem`). Remove public permissions using `chmod 600 ORACLESOMETHING.pem`.
   1. Click "Add".
   1. From the "Configuration File Preview". Extract the "user", "tenancy", and "fingerprint" values. Optionally, place the entire contents into a `~/.oci/config` file.
   1. Upload the public key to the OCI web console
1. Create an OCI compartment to isolate resources
   1. Visit the OCI [web console](https://cloud.oracle.com/)
   1. Under the upper-left-hand hamburger menu, "Identity & Security" --> "Identity" --> "Compartments".
   1. Click "Create Compartment". Give it a name such as "oci-freedigs" and a description. Click the "Create Compartment" button.
   1. Wait a few seconds, as the new compartment is not shown immediately.
   1. Click into the new compartment.
   1. Under the "OCID" field, select "show" or "copy".
1. Put secrets into Terraform file
   1. Copy the `secrets.auto.tfvars.example` file to `secrets.auto.tfvars`
   1. Create `key = "value"` lines in `secrets.auto.tfvars` for each of the required configuration variables. Paste the correct value between the quotes.
      - `tenancy_ocid`
      - `user_ocid`
      - `compartment_ocid`
      - `signing_key_fingerprint`
      - `signing_key_private_path`
      - `compute_username`
      - `compute_ssh_public_key`
      - `tailscale_auth_key`
1. Configure the cluster
   1. Copy the `config.auto.tfvars.example` file to `config.auto.tfvars`.
   1. Visit the OCI [web console](https://cloud.oracle.com/) and look up your availability domain for your region.
   1. Set the `availability_domain_map` variable to match your OCI-provided availability group.
   1. Configure the `compute_hosts` variable. See the example. Include at least one entry. Give each entry a label. Set all of `hostname`, `arch`, `cores`, `ram_gb`, `disk_gb` parameters for each block.
1. Run `terraform init -upgrade; terraform destroy; while ! terraform apply -auto-approve; do echo again; done`
   - ...or any Terraform plan management and rollout scheme you prefer
   - You may very well have to apply multiple times to successfully create all resources. Oracle can return an "Out of host capacity" error.
1. Copy the IP address shown at the end of the Terraform run and ssh to it: `ssh COMPUTE_USERNAME@IP.ADD.RESS`

## Inspiration

- OCI free Terraform projects
  - https://github.com/stealthybox/tf-oci-arm
  - https://github.com/gruberdev/tf-free
  - https://github.com/chadgeary/cloudblock/tree/master/oci
  - https://github.com/MrDionysus/foundry-vtt-oci-terraform
- OCI documentation
  - https://docs.oracle.com/en-us/iaas/developer-tutorials/tutorials/tf-provider/01-summary.htm
  - https://registry.terraform.io/providers/hashicorp/oci/latest/docs
  - https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_instance
- Terraform
  - https://github.com/hashicorp/terraform
- Tailscale
  - https://tailscale.com/kb/1149/cloud-oracle/
- Kubernetes
  - https://faun.pub/free-ha-multi-architecture-kubernetes-cluster-from-oracle-c66b8ce7cc37
  - https://carlosedp.medium.com/building-a-hybrid-x86-64-and-arm-kubernetes-cluster-e7f94ff6e51d

## TODO

- Document use of URL-based configuration
- Support multiple ssh keys
- OCI budget monitoring
- HTTP/S edge server, Letsencrypt for Caddy
- Persistent block volumes would be great
- Add hostname override for tailscaled setup
- OCI NAT setup
