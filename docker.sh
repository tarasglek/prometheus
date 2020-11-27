docker rm -f node-ping
docker rm -f prometheus
docker rm -f dhcp-leases2file_sd
docker rm -f alertmanager
set -x -e
docker run --restart on-failure -d -p 3000:3000 --name node-ping node-ping  
docker run --restart on-failure -d -v /export/firewalls:/input -v /tmp:/output  --name dhcp-leases2file_sd  dhcp-leases2file_sd
docker run --restart on-failure -d -p 9093:9093 -v /home/taras/prom:/prometheus --name alertmanager prom/alertmanager --config.file=/prometheus/alertmanager.yml
docker run --restart on-failure -d -p 81:9090 -v /home/taras/prom:/prometheus \
  -v /tmp:/tmp \
  --name prometheus --link node-ping  --link alertmanager \
  prom/prometheus --config.file=/prometheus/prometheus.yml --storage.tsdb.retention.size=100GB --storage.tsdb.retention.time=365d
# docker run \
#   -d \
#   -p 80:3000 \
#   --name=grafana \
#   -e "GF_SERVER_ROOT_URL=http://swarm" \
#   -e "GF_SECURITY_ADMIN_PASSWORD=secret" \
#   -v /home/taras/prom/grafana/lib:/var/lib/grafana \
#   -v /home/taras/prom/grafana/log:/var/log/grafana \
#   -v /home/taras/prom/grafana/etc:/etc/grafana \
#   --link prometheus \
#   grafana/grafana
