# Azure sample code

## Overview 

The sample Terraform code in this repository allows the creation of a complete SecOps virtual network (vnet) to host your TheHive and Cortex instances and expose them using an Application Gateway.

![SecOps virtual network overview](assets/overview.png)

The sample code is organised in two Terraform projects:

* [ug-secops-vnet](ug-secops-vnet/) --> to create and manage the SecOps virtual network and TheHive / Cortex data disks
* [ug-secops-instances](ug-secops-instances/) --> to launch and manage TheHive v5 and Cortex instances within a SecOps vnet

This code organisation allows the creation of all required vnet resources if you do not already operate a vnet (or if you want to create a new one for your SecOps needs), independently from TheHive and Cortex deployments.

The sample code to launch TheHive and Cortex instances defaults to this new vnet but can easily be adapted to fit your existing vnet by customising a few variables. Unless your architecture significantly differs from our reference vnet, you should not be required to modify the Terraform code itself.
