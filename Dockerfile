FROM prom/prometheus

USER 998:998

EXPOSE 9090

VOLUME ["/data/prometheus:data/prometheus", "/etc/prometheus:etc/prometheus"]

ENTRYPOINT [ "/bin/prometheus" ]

CMD [ "--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.path=/data/prometheus" ]