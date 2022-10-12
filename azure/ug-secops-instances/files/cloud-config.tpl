#cloud-config 
disk_setup:
  /dev/disk/azure/scsi1/lun0:
    table_type: gpt
    layout: True
    overwrite: True
  /dev/disk/azure/scsi1/lun1:
    table_type: gpt
    layout: True
    overwrite: True
fs_setup:
  - device: /dev/disk/azure/scsi1/lun0
    partition: auto
    filesystem: ext4
  - device: /dev/disk/azure/scsi1/lun1
    partition: auto
    filesystem: ext4
write_files:
    - path: /opt/strangebee/ops/templates/nomad/tasks/thehive/application.conf.d/service.conf
      content: |
           application.baseUrl="${thehivebaseurl}${thehivecontext}"
           play.http.context="${thehivecontext}"
    - path: /opt/strangebee/ops/templates/nomad/tasks/cortex/application.conf.d/service.conf
      content: |
           play.http.context="${cortexcontext}"
    - path: /opt/strangebee/ops/templates/nomad/jobs/thehive-cortex-job.vars
      content: |
           thehivecontext = "${thehivecontext}"
           cortexcontext = "${cortexcontext}"
           image_cassandra = "${imagecassandra}"
           image_elasticsearch = "${imageelasticsearch}"
           image_nginx = "${imagenginx}"
           image_thehive = "${imagethehive}"
           image_cortex = "${imagecortex}"
    - path: /opt/strangebee/ops/templates/nomad/jobs/thehive-job.vars
      content: |
           thehivecontext = "${thehivecontext}"
           image_cassandra = "${imagecassandra}"
           image_elasticsearch = "${imageelasticsearch}"
           image_nginx = "${imagenginx}"
           image_thehive = "${imagethehive}"
    - path: /opt/strangebee/ops/templates/nomad/jobs/cortex-job.vars
      content: |
           cortexcontext = "${cortexcontext}"
           image_elasticsearch = "${imageelasticsearch}"
           image_nginx = "${imagenginx}"
           image_cortex = "${imagecortex}"
manage_etc_hosts: localhost
hostname: ${hostname}
runcmd:
    - [ sed, -i, 's/^AllowTcpForwarding.*/AllowTcpForwarding yes/', /etc/ssh/sshd_config ]
    - [ systemctl, daemon-reload ]
    - [ systemctl, restart, --no-block, sshd.service ]
    - [ /opt/strangebee/ops/scripts/ops-launch.sh, "-t ${installthehive}", "-c ${installcortex}", "-p /dev/sdh", "-d /dev/sdi", "-l 1" ]
    # - [ /opt/strangebee/ops/scripts/ops-migrate.sh, "-t ${installthehive}", "-c ${installcortex}", "-p /dev/sdh", "-d /dev/sdi", "-x /dev/sdj", "-y /dev/sdk", "-z /dev/sdl", "-l 1" ]
    