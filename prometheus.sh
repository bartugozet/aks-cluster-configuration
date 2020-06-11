# Install prometheus with helm
helm install --name prometheus stable/prometheus-operator -f values.yaml --namespace monitoring

# Export linkerd metrics to external prometheus
kubectl apply -f export-prom-metrics.yaml
# Import Linkerd dashboards with configmap
kubectl apply -n monitoring -f linkerd-dashboard-configmap.yaml
