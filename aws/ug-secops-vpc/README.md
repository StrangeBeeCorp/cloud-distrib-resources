# Creating a new SecOps VPC

Check our [detailed Medium post]() for more information on using this sample code.

The code itself is documented at lenght in our [AMI user guides](https://strangebee.com/aws).

If you do not already have a VPC at hand to deploy TheHive and Cortex into, using our sample code will allow you to build a production-ready VPC very easily.

# Overview
The reference architecture VPC consists of the following resources

![SecOps VPC overview](assets/VPC.png)

The VPC will include:

+ Two **public subnets** (only one is depicted - two public subnets will be created in different availability zones since they are required for the Application Load Balancer configuration)
+ Two **private subnets** (only one is depicted - we will not be using the second private subnet but it will be ready to use if you need it and it does not incur additional costs)
+ Five **security groups** 
+ An **internet gateway** (IG)
+ A **NAT gateway** in the first public subnet
+ **Route tables** for both public and private subnets
+ An **Application Load Balancer** (ALB) with a listener on port 443  using ACM-managed public certificates and two target groups for TheHive and Cortex
+ **Public Route53 DNS records** for TheHive and Cortex to point to the ALB
+ A **private Route53 DNS zone** for internal VPC name resolution
+ A **bastion host** for remote SSH administration

Since we will be building a new VPC from scratch, we will use AWS-managed services to expose our TheHive and Cortex instances:

+ **Application Load Balancer** to handle secured TLS sessions with end-users. A single load balancer with a single listener on port 443 can forward traffic to both TheHive and Cortex instances based on forward rules.
+ **AWS Certificate Manager** to issue and renew valid public certificates to enable TLS sessions between end-users and the load balancer. Once attached to an AWS-managed service such as the Application Load Balancer, public certificates are automatically renewed when nearing expiration. If you operate both TheHive and Cortex, you can share a single certificate for both services by including multiple hostnames in the certificate. You can also use separate certificates as the ALB supports attaching several certificates to a listener.
+ **Amazon Route53** to manage your public DNS records. You will need Route53 to manage at least one public DNS zone, but not necessarily a whole domain name. It can be a subdomain of an existing domain, such as *aws.mydomain.com*. Having Route53 manage your DNS records enables a lot of automation such as automatic certificate validation and renewal, automatic DNS registration of your load balancer and so on. We also recommend you use Route53 to manage a private DNS zone attached to your VPC to enable local name resolution within the private subnet (this is how TheHive can easily find its Cortex instance and it allows to SSH into private instances without having to bother with their private IPs).

## Security Groups
There are no default iptables rules implemented in the AMIs for either TheHive or Cortex (no OS-based IP filtering). Since we built the AMIs to be replaceable at each application update, somewhat like a container, we recommend limiting OS customisations to benefit from the easy update process. For that reason, filtering should be based on security groups or Network ACLs only.

Keep in mind that the applications are listening on http, *not https*. Even though the default AMI security groups allow incoming traffic on the http ports (TCP 9000 for TheHive, TCP 9001 for Cortex), be careful not to expose them on a public-facing network interface.

The required security groups depicted above are created automatically along with the SecOps VPC and and fully documented in the [AMI user guides](https://strangebee.com/aws)

## Bastion host
We launch a small instance to act as a bastion host. **Bastion host hardening is not covered in this guide** but you should definitely harden this host going forward if you will use it in a production context. We do however strictly limit access to and from this host.

The bastion host will run the latest Ubuntu AMI from Canonical. The default sudoer user is *ubuntu*.

# SecOps VPC prerequisites

While most VPC resources will be provisioned with Terraform, there are a **two exceptions that should be created beforehand**:

* The Route53 public DNS zone to register the load balancer
* The ACM (AWS Certificate Manager) certificate for the https listener

You must provide the ARNs for these resources before creating the VPC (populate the variables with the associated values).

These resources could be created with Terraform but we considered it made more sense to manage them independently to avoid destroying them along with the VPC since they can take a while to create / validate / propagate. Also, your public DNS zone might be shared with other services!

We will use a single load balancer and a single https listener for both TheHive and Cortex. While multiple certificates can be attached to the ALB https listener (using Server Name Indication), our sample code will use a single certificate, so remember to include both hostnames for TheHive and Cortex when you create it. Otherwise, you will need to attach both certificates to the listener and manage the SNI configuration yourself.

---
Terraform compatibility: v0.12.x