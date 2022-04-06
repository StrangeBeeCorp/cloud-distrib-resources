#cloud-config 
manage_etc_hosts: localhost
hostname: ${hostname}
runcmd:
    - [ /opt/cortex/ops/scripts/ops-cortex-restore.sh, /dev/sdh, /dev/sdi ]
    