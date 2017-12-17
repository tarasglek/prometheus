docker rm -f power-exporter 
docker rm -f node-ping
docker rm -f prometheus
docker rm -f grafana
set -x -e
docker run --restart on-failure -d -p 3000:3000 --name node-ping tarasglek/node-ping  
docker run --restart on-failure -d -p 8080:8080 --name power-exporter -e RAINFOREST=192.168.1.215 tarasglek/power-exporter:1
docker run --restart on-failure -d -p 81:9090 -v /home/taras/prom:/prometheus \
  --name prometheus --link power-exporter \
  --link node-ping \
  prom/prometheus -config.file=/prometheus/prometheus.yml -storage.local.retention 1460h0m0s
docker run \
  -d \
  -p 80:3000 \
  --name=grafana \
  -e "GF_SERVER_ROOT_URL=http://swarm" \
  -e "GF_SECURITY_ADMIN_PASSWORD=secret" \
  -v /home/taras/prom/grafana/lib:/var/lib/grafana \
  -v /home/taras/prom/grafana/log:/var/log/grafana \
  -v /home/taras/prom/grafana/etc:/etc/grafana \
  --link prometheus \
  grafana/grafana
