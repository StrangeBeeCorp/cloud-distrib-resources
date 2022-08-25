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
    - filesystem: ext4
      device: '/dev/sdj'
      partition: auto
      overwrite: false
manage_etc_hosts: localhost
hostname: ${hostname}
runcmd:
    - [ /opt/thehive/ops/scripts/ops-thehive-init.sh, /dev/sdh, /dev/sdi, /dev/sdj ]
    