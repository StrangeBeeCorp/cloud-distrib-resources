#cloud-config 
write_files:
    - path: /opt/thehive/ops/templates/cortex.address
      content: |
           ${cortexaddress}
    - path: /opt/thehive/ops/templates/cortex.context
      content: |
           ${cortexcontext}
    - path: /opt/thehive/ops/templates/service.conf
      content: |
           play.http.context="${thehivecontext}"
runcmd:
    - [ /opt/thehive/ops/scripts/ops-thehive4-restore.sh, /dev/xvdh, /dev/xvdi, /dev/xvdj ]
