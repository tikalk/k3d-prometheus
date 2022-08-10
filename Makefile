.PHONY: prep start-monitor helm-grafana helm-prometheus 
CLUSTER_NAME=prometheus
NS=prometheus-operator
REDIS_CHART_VERSION=16.3.1
PROMETHEUS_CHART_VERSION=14.11.0
GRAFANA_CHART_VERSION=6.17.3
ARGOCD_CHART_VERSION=3.26.3
LOKI_CHART_VERSION=2.6.0

start-monitor:
	k3d cluster create --config ./assets/k3d-config-registry.yaml --wait || k3d cluster list | grep $(CLUSTER_NAME) && k3d cluster start $(CLUSTER_NAME)
	k3d kubeconfig merge $(CLUSTER_NAME) --kubeconfig-merge-default --kubeconfig-switch-context
	# kubectx k3d-$(CLUSTER_NAME)

_create_ns:
	@kubectl get ns | grep $(NS) || kubectl create ns $(NS)

_create_redis_ns:
	@kubectl get ns | grep redis || kubectl create ns redis

helm-prometheus-stack: _create_ns
	@helm repo list | grep prometheus-community || \
	 helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	@helm search repo prometheus-community --version=$(PROMETHEUS_CHART_VERSION) || helm repo update
	@helm upgrade prometheus --install \
		--namespace $(NS) \
		--version $(PROMETHEUS_CHART_VERSION) \
	  prometheus-community/kube-prometheus-stack \
		-f assets/charts/kube-prometheus-stack/values.yaml \
		-f assets/charts/kube-prometheus-stack/override.yaml \
		-f assets/charts/kube-prometheus-stack/dev-mode.yaml

helm-redis: _create_redis_ns
	@helm repo list | grep bitnami || \
	 helm repo add bitnami https://charts.bitnami.com/bitnami
	@helm search repo bitnami/redis --version=$(REDIS_CHART_VERSION) || helm repo update
	@helm upgrade redis --install \
		--namespace redis \
		--version $(REDIS_CHART_VERSION) \
	  bitnami/redis \
		-f assets/charts/redis/values.yaml \
		-f assets/charts/redis/override.yaml \
		-f assets/charts/redis/dev-mode.yaml

# start-prom-stack: start-monitor helm-prometheus-stack
start-redis: helm-redis

helm-grafana: _create_ns
	@helm repo add grafana https://grafana.github.io/helm-charts
	@helm search repo grafana --version=$(GRAFANA_CHART_VERSION) || helm repo update
	helm upgrade grafana --install grafana/grafana \
		--namespace $(NS) \
		-f assets/charts/grafana/values.yaml \
		-f assets/charts/grafana/override.yaml \
		-f assets/charts/grafana/dev-mode.yaml

helm-loki-stack: _create_ns
	@helm search repo grafana --version=$(GRAFANA_CHART_VERSION) || helm repo update
	helm upgrade grafana --install grafana/grafana \
		--namespace $(NS) \
		-f assets/charts/grafana/values.yaml \
		-f assets/charts/grafana/override.yaml \
		-f assets/charts/grafana/dev-mode.yaml
		-f assets/charts/grafana/override-loki-stack.yaml 
	@helm search repo grafana --version=$(LOKI_CHART_VERSION) || helm repo update
	helm upgrade loki-stack --install grafana/loki-stack \
		--namespace $(NS) \
		-f assets/charts/grafana/values.yaml \
		-f assets/charts/grafana/override.yaml \
		-f assets/charts/grafana/dev-mode.yaml

helm-prometheus: _create_ns
	@helm repo list | grep prometheus-community || \
	 helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	@helm search repo prometheus-community --version=$(PROMETHEUS_CHART_VERSION) || helm repo update
	@helm upgrade prometheus --install \
		--namespace $(NS) \
		--version $(PROMETHEUS_CHART_VERSION) \
	  prometheus-community/prometheus \
		-f assets/charts/prometheus/values.yaml \
		-f assets/charts/prometheus/override.yaml

start-prom-stack: start-monitor helm-grafana helm-prometheus
start-loki-stack: start-monitor helm-loki-stack

restart:
	@k3d cluster stop 	$(CLUSTER_NAME)
	@k3d cluster start 	$(CLUSTER_NAME)

_destroy: 
	@k3d cluster delete $(CLUSTER_NAME)