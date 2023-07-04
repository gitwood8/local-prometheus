#!/usr/bin/bash
sudo yum update
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
echo "alias d='sudo docker'" >> ~/.bashrc
source ~/.bashrc
sudo useradd -rs /bin/false prometheus
echo $(id -u prometheus):$(id -g prometheus) 
sudo mkdir /etc/prometheus
sudo touch /etc/prometheus/prometheus.yml
sudo mkdir -p /data/prometheus
sudo chown prometheus:prometheus /etc/prometheus/* /data/prometheus
sudo tee /etc/prometheus/prometheus.yml << EOF 
global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']
EOF

mkdir ~/app && touch ~/app/def.txt && tee ~/app/def.txt << EOF
sudo docker run --name myprometheus -d --rm -p 9090:9090 --user 998:998 --net=host -v /etc/prometheus:/etc/prometheus -v /data/prometheus:/data/prometheus prom/prometheus --config.file="/etc/prometheus/prometheus.yml" --storage.tsdb.path="/data/prometheus"  
------------------
FROM prom/prometheus

USER 998:998

EXPOSE 9090

VOLUME ["/data/prometheus:data/prometheus", "/etc/prometheus:etc/prometheus"]

ENTRYPOINT [ "/bin/prometheus" ]

CMD [ "--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.path=/data/prometheus" ]
EOF
