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
    - /dev/xvdj:
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
    - filesystem: ext4
      device: '/dev/xvdj'
      partition: auto
runcmd:
    - [ /opt/thehive/ops/scripts/ops-thehive4-init.sh, /dev/xvdh, /dev/xvdi, /dev/xvdj ]