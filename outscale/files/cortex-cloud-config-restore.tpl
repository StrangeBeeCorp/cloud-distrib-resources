#cloud-config 
write_files:
    - path: /opt/cortex/ops/templates/service.conf
      content: |
           play.http.context="${cortexcontext}"
runcmd:
    - [ /opt/cortex/ops/scripts/ops-cortex-restore.sh, /dev/xvdh, /dev/xvdi ]