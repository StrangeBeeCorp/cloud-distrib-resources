#cloud-config 
manage_etc_hosts: localhost
hostname: ${hostname}
runcmd:
    - [ /opt/thehive/ops/scripts/ops-thehive-restore.sh, /dev/sdh, /dev/sdi, /dev/sdj ]
