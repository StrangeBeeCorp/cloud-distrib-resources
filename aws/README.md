# AWS sample code

## Overview 

The sample Terraform code in this repository allows the creation of a complete SecOps VPC to host your TheHive and Cortex instances and expose them using a load balancer.

![SecOps VPC overview](assets/ALB.png)

The sample code is organised in two Terraform projects:

* [ug-secops-vpc](ug-secops-vpc/) --> to create and manage the SecOps VPC
* [ug-secops-instances](ug-secops-instances/) --> to launch and manage TheHive v4/v5 and Cortex instances within a SecOps VPC

This code organisation allows the creation of all required VPC resources if you do not already operate a VPC (or if you want to create a new one for your SecOps needs), independently from TheHive and Cortex deployments.

The sample code to launch TheHive and Cortex instances defaults to this new VPC but can easily be adapted to fit your existing VPC by customising a few variables. Unless your architecture significantly differs from our reference VPC, you should not be required to modify the Terraform code itself.
