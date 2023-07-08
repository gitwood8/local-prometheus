#!/bin/bash
yum update
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
#below works like that &&
echo "alias d='sudo docker' \n alias ll='ls -lah'" >> /home/ec2-user/.bashrc && source /home/ec2-user/.bashrc
#useradd -rs /bin/false prometheus
mkdir -p /prometheus/data
#chown -R prometheus:prometheus /etc/prometheus/* /data/prometheus
mkdir /home/ec2-user/app/
touch /home/ec2-user/app/command.txt
cat <<EOF> /home/ec2-user/app/command.txt
sudo docker run --name myprometheus -d --rm -p 9090:9090 --user $(id -u nobody):$(id -g nobody) --net=host -v /etc/prometheus:/etc/prometheus -v /prometheus/data:/prometheus/data prom/prometheus --config.file="/etc/prometheus/prometheus.yml" --storage.tsdb.path="/prometheus/data" 
EOF
touch /home/ec2-user/app/Dockerfile
cat <<EOF> /home/ec2-user/app/Dockerfile
FROM prom/prometheus

USER $(id -u nobody):$(id -g nobody)

EXPOSE 9090

VOLUME ["/prometheus/data:/prometheus/data", "/etc/prometheus:/etc/prometheus"]

ENTRYPOINT [ "/bin/prometheus" ]

CMD [ "--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.path=/prometheus/data" ]
EOF
mkdir /etc/prometheus
touch /etc/prometheus/prometheus.yml
cat <<EOF> /etc/prometheus/prometheus.yml
global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']
EOF
chown -R nobody:nobody /etc/prometheus/ /prometheus/
chown -R ec2-user:ec2-user /home/ec2-user/* #/home/ec2-user
docker build -t prome /home/ec2-user/app/
docker run -d -p 9090:9090 --name myprometheus --net=host prome
