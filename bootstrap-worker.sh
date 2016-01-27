#!/usr/bin/bash
set -e

IPS=$(jq -s -R -M -c 'split("\n")' < /etc/mantl/leaders)

### CONSUL ###
yum install -y consul-0.6.3

jq --argjson ips $IPS \
   --arg id $(cat /etc/mantl/id) \
   '.bootstrap_expect = ($ips | length)
    | .retry_join = $ips
    | .node_name = $id' \
   > /etc/consul/consul.json \
   <<EOF
{
    "server": false,
    "data_dir": "/var/lib/consul",
    "log_level": "INFO"
}
EOF

systemctl reload consul

sleep 5

consul join $(cat /etc/mantl/leaders)

### NOMAD ###
yum install -y nomad-0.2.3 docker-1.8.2
systemctl start docker

jq --argjson ips $IPS \
   --arg id $(cat /etc/mantl/id) \
   --arg private_ip $(cat /etc/mantl/private_ip) \
   --arg public_ip $(cat /etc/mantl/public_ip) \
   --arg role $(cat /etc/mantl/role) \
   '.bind_addr = $private_ip
    | .client.servers = [$ips | .[] | "\(.):4647"]
    | .client.node_id = $id
    | .client.node_class = $role
    | .client.meta.public_ip = $public_ip
    | .client.meta.private_ip = $private_ip' \
   > /etc/nomad/nomad.json \
   <<EOF
{
    "data_dir": "/var/lib/nomad",
    "log_level": "INFO",
    "server": {
        "enabled": false
    },
    "client": {
        "enabled": true,
        "options": {
          "driver.whitelist": "docker,exec,raw_exec"
        }
    }
}
EOF

systemctl restart nomad

sleep 5

echo export NOMAD_ADDR=http://$(cat /etc/mantl/private_ip):4646 > /etc/profile.d/nomad.sh
