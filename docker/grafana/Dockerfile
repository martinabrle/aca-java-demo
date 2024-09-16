FROM grafana/grafana:5.2.4
ADD ./provisioning /etc/grafana/provisioning
ADD ./grafana.ini /etc/grafana/grafana.ini
ADD ./dashboards /var/lib/grafana/dashboards

ENV BUILD_VERSION=${VERSION_ARG}
ENV ARTIFACT_NAME=${ARTIFACT_NAME_ARG}

ENV PORT=3000
