#cloud-config 
disk_setup:
    - /dev/nvme0n1:
          table_type: 'mbr'
          layout: True
          overwrite: False
    - /dev/nvme1n1:
          table_type: 'mbr'
          layout: True
          overwrite: False
    - /dev/nvme2n1:
          table_type: 'mbr'
          layout: True
          overwrite: False
fs_setup:
    - filesystem: ext4
      device: '/dev/nvme0n1'
      partition: auto
    - filesystem: ext4
      device: '/dev/nvme1n1'
      partition: auto
    - filesystem: ext4
      device: '/dev/nvme2n1'
      partition: auto
manage_etc_hosts: localhost
hostname: ${hostname}
runcmd:
    - [ /opt/cortex/ops/scripts/ops-cortex-init.sh, /dev/sdh, /dev/sdi ]