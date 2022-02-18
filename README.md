# Prometheus stack demo

## 🚀 QuickStart

```sh
make start-prom-stack
```
## ❓ Whats included 

- [X] k3d start a 2 node cluter 
  ```sh
  # k3d cluster list
  monitor      1/1       1/1      true
  ```
- [X] create `prometheus-operator` namespace

- [X] install `kube-prometheus-stack` helm chart
  - [X] configure ingress for `prometheus`, `alertmanager`, `grafana`
  - [X] ensure enabled
    - [X] node-exporter 
    - [X] kube-state-metrics 
  - [X] configure prometheus datasource in grafana

- [X] Use promehtues-operator
  - [X] install helm charts for bitnami/redis
  - [X] enable serviceMonitor for redis
  - [X] import redis grafana dashboard

## 🏗️ Architecture

![img](https://i.imgur.com/BSvuDNX.png)


## 🎚️ "Live" demo ...

[![asciicast](https://asciinema.org/a/V4xFkuWbwNfnaCbDgY1dX7FAf.svg)](https://asciinema.org/a/V4xFkuWbwNfnaCbDgY1dX7FAf)

Go to http://grafana.k3d.localhost/ `admin`:`password` see `./assets/charts/grafana/dev-mode.yaml` 

### 🔥 Promehteus

```sh
make start-prom-stack
```

### 🔛🆗 Cluster stop / start

```sh
make restart
```

