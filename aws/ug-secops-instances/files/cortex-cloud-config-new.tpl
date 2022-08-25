#cloud-config 
bootcmd:
    - [ /usr/sbin/nvme-to-block-mapping ]
fs_setup:
    - filesystem: ext4
      device: '/dev/sdh'
      partition: auto
      overwrite: false
    - filesystem: ext4
      device: '/dev/sdi'
      partition: auto
      overwrite: false
manage_etc_hosts: localhost
hostname: ${hostname}
runcmd:
    - [ /opt/cortex/ops/scripts/ops-cortex-init.sh, /dev/sdh, /dev/sdi ]
