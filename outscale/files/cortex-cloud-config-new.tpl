#cloud-config 
disk_setup:
    - /dev/xvdh:
          table_type: 'mbr'
          layout: True
          overwrite: False
    - /dev/xvdi:
          table_type: 'mbr'
          layout: True
          overwrite: False
fs_setup:
    - filesystem: ext4
      device: '/dev/xvdh'
      partition: auto
    - filesystem: ext4
      device: '/dev/xvdi'
      partition: auto
runcmd:
    - [ /opt/cortex/ops/scripts/ops-cortex-init.sh, /dev/xvdh, /dev/xvdi ]