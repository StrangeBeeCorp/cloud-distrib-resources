#cloud-config 
runcmd:
    - [ sed, -i, -e, '$aMatch all', /etc/ssh/sshd_config ]
    - [ sed, -i, 's/^PermitTunnel.*/PermitTunnel yes/', /etc/ssh/sshd_config ]
    - [ sed, -i, 's/^AllowTcpForwarding.*/AllowTcpForwarding yes/', /etc/ssh/sshd_config ]
    - [ systemctl, daemon-reload ]
    - [ systemctl, restart, --no-block, sshd.service ]
    - [ sed, -i, 's/FIX-DOMAIN/${caddydomain}/', /var/lib/caddy/docker-compose/docker-compose.yml ]
    - [ sed, -i, 's/FIX-EMAIL/${caddyemail}/', /var/lib/caddy/docker-compose/docker-compose.yml ]
    - [ sed, -i, 's/FIX-THEHIVEHOST/${caddythehivehost}/', /var/lib/caddy/docker-compose/docker-compose.yml ]
    - [ sed, -i, 's/FIX-CORTEXHOST/${caddycortexhost}/', /var/lib/caddy/docker-compose/docker-compose.yml ]
    - [ systemctl, enable, docker-caddy.service ]
    - [ systemctl, start, docker-caddy.service ]
