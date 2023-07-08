# local-prometheus

Command to start:
docker run --name myprometheus -d -p 9090:9090 --user prometheus --net=host -v /etc/prometheus:/etc/prometheus -v /data/prometheus:/data/prometheus prom/prometheus --config.file="/etc/prometheus/prometheus.yml" --storage.tsdb.path="/data/prometheus"

