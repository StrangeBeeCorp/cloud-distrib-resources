![Cortex official distribution](assets/logo-cloud-cortex.png)

# Deploying Cortex with Terraform - launch new instance with existing data

This code will work out of the box with the reference *SecOps vnet* created with our sample code. You can nonetheless use it to deploy Cortex within your own preexisting vnet with minimal adjustments (only a few variables to update if your setup is similar to our reference architecture).

We provide two sets of sample code:

+ A first set to deploy a brand new Cortex install with an empty database - this is useful for an initial Cortex deployment.
+ A second set to deploy a new Cortex instance while restoring an existing database - this code is to be used for all other use-cases: Cortex update, instance type upgrade or downgrade, database restore, etc.

**This folder contains the code for the second use-case: launching a new Cortex instance while restoring data from existing disks.**

## Overview

This is an overview of the resulting Cortex instance context and security group configuration when deployed with our Terraform sample code in our reference *SecOps vnet*.

![Cortex deployed in our SecOps reference architecture vnet with a public-facing Application Gateway](assets/cortex.png)

## Information on the default data disks configuration
All Cortex data is stored on dedicated data disks (one for the ElasticSearch database and one for Docker images), not in the OS disk. This approach has many advantages:

+ Your OS disk is disposable, you can replace your instance in seconds to update Cortex by launching a fresh image or to migrate to a more (or less) powerful instance.
+ Your data disks can be of any size while keeping the OS disk to its default size. 
+ Increasing (or decreasing) the size of a data disks on an existing instance is a lot easier than changing the OS disk size.
+ You can restore your database from a previous state using disk snapshots.

**!!! WARNING !!!**  -- By default, the sample code will attach the existing Cortex data disks you set in the variables. Make sure to snapshot your data disks before attaching them to a new instance to avoid any data loss resulting from technical or human errors.

**The ElasticSearch data disk will be mounted at `/var/lib/elasticsearch` and the Docker data disk at `/var/lib/docker`.**


## Connecting to your Cortex instance with SSH
Since our Cortex instance is located in a private subnet, we cannot directly SSH into it using its private IP address. If you have set up a bastion host configuration similarly to our reference architecture, you can seamlessly connect to private instances using the *proxyjump* functionality of the ssh client. The bastion host will be able to perform the hostname resolution with the private DNS zone we have set up in the vnet. 

The easiest way to do that is to create (or update) the `~/.ssh/config` file. Use the example below as a reference and replace the ip addresses and private key information.

The default username for both the bastion host and Cortex instance is `ubuntu`.

```
Host bastion
				HostName 1.2.3.4 (public ip)
				User ubuntu
				Port 22
				IdentityFile ~/.ssh/id_rsa_private_key_for_bastion

Host cortex
				HostName cortex.secops.cloud
				User ubuntu
				Port 22
				ProxyJump bastion
				IdentityFile ~/.ssh/id_rsa_private_key_for_cortex
```

> *We use the secops.cloud domain as an example but the best security practice is to use a domain name you own even for private DNS resolution in split-horizon.*

You will now be able to SSH into the Cortex instance directly using the bastion host as a proxy:

```
ssh cortex 
```

**Note**: Remember to whitelist your local public IP address in the bastion security group. 

---
Terraform compatibility: v0.12.x