docker rm -f node-ping
docker rm -f prometheus
docker rm -f dhcp-leases2file_sd
docker rm -f alertmanager
docker rm -f alertmanager2esphome
docker rm -f loki
docker rm -f grafana
docker rm -f moztts2googlehome
set -x -e
docker run --restart on-failure -d -p 80:3000 --name=grafana -v $(pwd)/grafana:/var/lib/grafana grafana/grafana
docker run --restart on-failure -d --name loki -v $(pwd):/mnt/config -v $(pwd)/loki:/tmp/loki -v $(pwd)/loki-alerts.yaml:/tmp/loki/rules/subdir/loki-alerts.yaml  -p 3100:3100 grafana/loki:2.0.0 -config.file=/mnt/config/loki-config.yaml -log.level=error
docker run --restart on-failure -d -p 5002:5002 --net host --name moztts2googlehome moztts2googlehome
docker run --restart on-failure -d -p 3000:3000 --name node-ping node-ping  
docker run --restart on-failure -d -v /export/firewalls:/input -v /tmp:/output  --name dhcp-leases2file_sd  dhcp-leases2file_sd
docker run --restart on-failure -d --name alertmanager2esphome alertmanager2esphome_webhook
docker run --restart on-failure -d -p 9093:9093 -v /home/taras/prom:/prometheus --link alertmanager2esphome --name alertmanager prom/alertmanager --config.file=/prometheus/alertmanager.yml
docker run --restart on-failure -d -p 81:9090 -p 9090 -v /home/taras/prom:/prometheus \
  -v /tmp:/tmp \
  --name prometheus --link node-ping  --link alertmanager \
  prom/prometheus --config.file=/prometheus/prometheus.yml --storage.tsdb.retention.size=100GB --storage.tsdb.retention.time=365d --web.enable-lifecycle
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
