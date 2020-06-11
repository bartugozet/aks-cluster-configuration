helm install --name prometheus stable/prometheus-operator -f values.yaml --namespace monitoring

kubectl apply -n monitoring -f configmap-grafana.json
