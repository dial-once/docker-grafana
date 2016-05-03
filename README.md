# Grafana Docker image

This project builds a Docker image with the latest master build of Grafana.

## Running your Grafana container

Start your container binding the external port `3000`.

```
docker run -d --name=grafana -p 3000:3000 dialonce/grafana:latest
```

Try it out, default admin user is admin/changeme.

## Configuring your Grafana container

All options defined in conf/grafana.ini can be overriden using environment
variables, for example:

```
docker run \
  -d \
  -p 3000:3000 \
  --name=grafana \
  -e "GRAFANA_PASS=changeme" \
  -e "INFLUXDB_HOST=influxdb" \
  -e "INFLUXDB_USER=grafana" \
  -e "INFLUXDB_PASS=changeme" \
  dialonce/grafana:latest
```

## Grafana container with persistent storage (recommended)

```
# create /var/lib/grafana as persistent volume storage
docker run -d -v /var/lib/grafana --name grafana-storage busybox:latest

# start grafana
docker run \
  -d \
  -p 3000:3000 \
  --name=grafana \
  --volumes-from grafana-storage \
  dialonce/grafana:latest
```

Thanks to appcelerator (https://github.com/appcelerator/docker-grafana) for the migration to Alpine.
