#################################################
### THEHIVE & CORTEX INSTANCE CREATION - INIT ###
#################################################

######################################
### GET DATA TO EXISTING RESOURCES ###
######################################

# We look for the latest TheHive OMI based on search filters so that we can refer to its ID later on
data "outscale_image" "secops_thehive_omi" {
  filter {
    name   = "image_names"
    values = [var.secops_thehive_omi_name]
  }
}

# We look for the latest Cortex OMI based on search filters so that we can refer to its ID later on
data "outscale_image" "secops_cortex_omi" {
  filter {
    name   = "image_names"
    values = [var.secops_cortex_omi_name]
  }
}

########################
### THEHIVE INSTANCE ###
########################

# We create the TheHive instance
resource "outscale_vm" "secops-th4-instance" {
  image_id                 = data.outscale_image.secops_thehive_omi.image_id
  vm_type                  = var.secops_thehive_ec2_instance_type
  keypair_name             = var.secops_key_pair_name
  subnet_id                = outscale_subnet.secops-private-subnet-1.subnet_id
  security_group_ids       = [outscale_security_group.secops-ssh-sg.security_group_id, outscale_security_group.secops-private-th-sg.security_group_id]    
  user_data = base64encode(templatefile("files/thehive-cloud-config-new.tpl", {
  }))

  block_device_mappings {
    device_name = "/dev/sdh"
    bsu  {
      volume_size           = 20
      volume_type           = "gp2"
      delete_on_vm_deletion = false
    }
  }

  block_device_mappings {
    device_name = "/dev/sdi"
    bsu  {
      volume_size           = 10
      volume_type           = "gp2"
      delete_on_vm_deletion = false
    }
  }

  block_device_mappings {
    device_name = "/dev/sdj"
    bsu  {
      volume_size           = 5
      volume_type           = "gp2"
      delete_on_vm_deletion = false
    }
  }
}

########################
### CORTEX INSTANCE  ###
########################

# We create the Cortex instance
resource "outscale_vm" "secops-cortex3-instance" {
  image_id                 = data.outscale_image.secops_cortex_omi.image_id
  vm_type                  = var.secops_cortex_ec2_instance_type
  keypair_name             = var.secops_key_pair_name
  subnet_id                = outscale_subnet.secops-private-subnet-1.subnet_id
  security_group_ids       = [outscale_security_group.secops-ssh-sg.security_group_id, outscale_security_group.secops-private-cortex-sg.security_group_id]    
  user_data = base64encode(templatefile("files/cortex-cloud-config-new.tpl", {
  }))

  block_device_mappings {
    device_name = "/dev/sdh"
    bsu  {
      volume_size           = 20
      volume_type           = "gp2"
      delete_on_vm_deletion = false
    }
  }

  block_device_mappings {
    device_name = "/dev/sdi"
    bsu  {
      volume_size           = 10
      volume_type           = "gp2"
      delete_on_vm_deletion = false
    }
  }
}
