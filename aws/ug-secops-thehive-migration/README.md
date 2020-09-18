![TheHive official distribution](assets/logo-ami-thehive.png)

# Deploying TheHive with Terraform - launch new instance with existing data

Check our [detailed Medium post]() for more information on using this sample code.

The code itself is documented at lenght in our [AMI user guides](https://strangebee.com/aws).

This code will work out of the box with the reference *SecOps VPC* created with our sample code. You can nonetheless use it to deploy TheHive within your own preexisting VPC with minimal adjustments (only a few variable to update if your setup is similar to our reference architecture).

We provide two sets of sample code:

+ A first set to deploy a brand new TheHive install with an empty database - this is useful for an initial TheHive deployment.
+ A second set to deploy a new TheHive instance while restoring an existing database - this code is to be used for all other use-cases: TheHive update, instance type upgrade or downgrade, database restore, etc.

**This folder contains the code for the second use-case: launching a new TheHive instance while restoring data from an existing volume.**

# Overview

This is an overview of the resulting TheHive instance context and security group configuration when deployed with our Terraform sample code in our reference *SecOps VPC*.

![TheHive deployed in our SecOps reference architecture VPC with a public-facing Application Load Balancer](assets/ALB-TH.png)

## Information on the default data volume configuration
All TheHive data is stored on a dedicated EBS volume, not in the root EBS volume. This approach has many advantages:

+ Your root volume is disposable, you can replace your instance in seconds to update TheHive by launching a fresh AMI or to migrate to a more (or less) powerful instance.
+ Your data volume can be of any size while keeping the root volume to its default size. 
+ Increasing (or decreasing) the size of a data volume on an existing instance is a lot easier than changing the root volume size.
+ You can restore your database from a previous state using volume snapshots, see *Operations* section in the [AMI user guides](https://strangebee.com/aws). 

![TheHive data volume](assets/RestoreInstall-TH.png)

To restore existing data, you must provide the id of an existing TheHive data volume (set the `secops-thehive-data-volume_id` variable with the volume id). A snapshot will be performed and used to populate a new volume (the original volume remains untouched).

**The data volume will be attached as `/dev/sdh`.**

## About EBS volume management on Nitro based instances

In Nitro-based instances, `/dev/sdh` might be seen by the instance as something like `/dev/nvme0n1`. You need to take this into consideration for everything that is executed *inside* the instance. As far as the EC2 APIs are concerned, the volume is still known as `/dev/sdh`. More information on this is available in [Amazon EBS and NVMe on Linux Instances documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/nvme-ebs-volumes.html#identify-nvme-ebs-device).

To illustrate this important aspect, consider the automated deployment of an instance using Terraform and some cloud-init user data code. In Terraform, you may want to change the default volume size or base your EBS volume on an existing snapshot. Since Terraform is interacting with the EC2 APIs, the EBS volume will alway be `/dev/sdh`. However, if you want to partition and format the volume using cloud-init, you need to adapt your code to how the instance "sees" the volume. In pre-Nitro instances the volume will remain `/dev/sdh` but in Nitro instances, it will be known as something like `/dev/nvme0n1`. 

To mount the volumes, the included TheHive initialisation and restore scripts were designed to be "Nitro-aware". These scripts expect the *block device mapping* as argument (such as `/dev/sdh`) and will then mount the volume based on its UUID to avoid any confusion going forward. More detail on these scripts is provided in the *Operations* section of the [AMI user guides](https://strangebee.com/aws).

---
Terraform compatibility: v0.12.x