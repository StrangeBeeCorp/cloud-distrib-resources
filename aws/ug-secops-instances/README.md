# Deploying TheHive v5 and Cortex with Terraform

This code will work out of the box with the reference *SecOps VPC* created with our [sample code](../ug-secops-vpc/README.md). You can nonetheless use it to deploy TheHive and Cortex within your own preexisting VPC with minimal adjustments (only a few variables to update if your setup is similar to our reference architecture).

Our sample code can handle two use-cases:

+ Deploying brand new **TheHive and Cortex instances** with empty databases - this is useful for an initial deployment.
+ Deploying **TheHive and Cortex instances** while restoring existing databases - this is to be used for all other use-cases: AMI updates, instance type upgrades or downgrades, database restore, etc.

**To switch between both use-cases, simply update the `secops_thehive_init` and/or `secops_cortex_init` variable values between `true` and `false` (`true` being the empty database, initialisation use-case).**

## TL;DR;
+ Clone this repository
+ Set the required variables
+ `terraform init` && `terraform apply`
+ Once the `terraform apply` is over, wait up to 5 minutes for both instances to be fully operational. You can check the initiatisation or restore progress by tailing the `/var/log/cloud-init-output.log` file on each instance.

## Overview

This is an overview of the resulting TheHive and Cortex instances when deployed with our Terraform sample code in our reference *SecOps VPC*.

![TheHive and Cortex deployed in our SecOps reference architecture VPC with a public-facing Application Load Balancer](../assets/ALB.png)

## Information on the default data volumes configuration
All data is stored on dedicated EBS volumes, not in the root EBS volume. This approach has many advantages:

+ Your root volume is disposable, you can replace your instances in seconds to update TheHive and Cortex by launching a fresh AMI or to migrate to a more (or less) powerful instance.
+ Your data volumes can be of any size while keeping the root volume to its default size. 
+ Increasing (or decreasing) the size of data volumes on an existing instance is a lot easier than changing the root volume size.
+ You can easily restore your data from a previous states using volume snapshots. 

### About EBS volume management on Nitro based instances

In Nitro-based instances, block devide mappings such as `/dev/sdh` will be seen by the instance as something like `/dev/nvme0n1`. You need to take this into consideration for everything that is executed *inside* the instance. As far as the EC2 APIs are concerned, the volume is still known as `/dev/sdh`. More information on this is available in [Amazon EBS and NVMe on Linux Instances documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/nvme-ebs-volumes.html#identify-nvme-ebs-device).

To illustrate this important aspect, consider the automated deployment of an instance using Terraform and some cloud-init user data code. In Terraform, you may want to change the default volume size or base your EBS volume on an existing snapshot. Since Terraform is interacting with the EC2 APIs, the EBS volume will alway be `/dev/sdh`. However, if you want to partition and format the volume using cloud-init, you need to adapt your code to how the instance "sees" the volume. In pre-Nitro instances the volume will remain `/dev/sdh` but in Nitro instances, it will be known as something like `/dev/nvme0n1`. 

To mount the volumes, the included initialisation and restore cloud-init bootstrap scripts were designed to be "Nitro-aware". These scripts expect the *block device mapping* as argument (such as `/dev/sdh`, `/dev/sdi` and `/dev/sdj`) and will then mount the volume based on its UUID to avoid any confusion going forward.

# Deploying new TheHive and Cortex instances
When the `secops_thehive_init` and/or `secops_cortex_init` variable are set to `true`, the AMIs will create new empty EBS data volumes at launch that will not be deleted when the instances are terminated so that your data isn't accidentally lost.

# Replacing existing TheHive and Cortex instances to use a new AMI version
When the `secops_thehive_init` and/or `secops_cortex_init` variable are set to `false`, the AMIs will create new EBS volumes at launch based on snapshots of volumes from the previous instances. The original volumes (from previous instances) are not automatically deleted. We recommend you keep them at least until the upgrade to the new AMI is completed.

# Restoring data from earlier snapshots instead of latest instance volume snapshots
If for any reason you wish to restore from specific snapshots and not from the latest volume state, you can edit the code and set the snapshot id for each volume. 

For example, to restore the TheHive data volume from a specific snapshot, the sample code should be edited to update the `snapshot_id` value.

**Original sample code:**

```
  ebs_block_device {
    device_name = "/dev/sdh"
    snapshot_id = aws_ebs_snapshot.secops-thehive-data-snapshot[count.index].id
    volume_type = "gp2"
    volume_size = var.secops_thehive_instance_data_volume_size
    delete_on_termination = false
    tags = {
      Name = "${var.secops_thehive_instance_name}-data"
      SourceInstance = var.secops_thehive_instance_name
      SourceInstanceVolume = "/dev/sdh"
      Environment = var.secops_vpc_name
    }  
  } 
```
**Update code:**
```
  ebs_block_device {
    device_name = "/dev/sdh"
    snapshot_id = "snap-1234567890"
    volume_type = "gp2"
    volume_size = var.secops_thehive_instance_data_volume_size
    delete_on_termination = false
    tags = {
      Name = "${var.secops_thehive_instance_name}-data"
      SourceInstance = var.secops_thehive_instance_name
      SourceInstanceVolume = "/dev/sdh"
      Environment = var.secops_vpc_name
    }  
  } 
```


# Connecting to your instances with SSH
Since our TheHive and Cortex instance are located in a private subnet, we cannot directly SSH into them using their private IP addresses. If you have set up a bastion host configuration similarly to our reference architecture, you can seamlessly connect to private instances using the *proxyjump* functionality of the ssh client. The bastion host will be able to perform the hostname resolution with the private DNS zone we have set up in the VPC.

The easiest way to do that is to create (or update) the `~/.ssh/config` file. Use the example below as a reference and replace the ip addresses and private key information.

The default username is `ubuntu` in all our AMIs.

```
Host bastion
				HostName 1.2.3.4 (public ip)
				User ubuntu
				Port 22
				IdentityFile ~/.ssh/id_rsa_private_key_for_bastion

Host thehive
				HostName thehive.secops0.privatevpc
				User ubuntu
				Port 22
				ProxyJump bastion
				IdentityFile ~/.ssh/id_rsa_private_key_for_thehive

Host cortex
				HostName cortex.secops0.privatevpc
				User ubuntu
				Port 22
				ProxyJump bastion
				IdentityFile ~/.ssh/id_rsa_private_key_for_cortex
```

> *We use the secops0.privatevpc domain as an example but the best security practice is to use a domain name you own even for private DNS resolution in split-horizon.*

You will now be able to SSH into your instances directly using the bastion host as a proxy:

```
ssh thehive
```
or
```
ssh cortex
```

> Remember to autorize your local public IP address in the bastion SSH security group. In our sample code for the SecOps VPC, this is the `secops0-public-ssh-sg` security group.

---
Terraform compatibility: v1.x
