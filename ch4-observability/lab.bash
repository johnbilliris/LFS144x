
# Lab 4.1. How Istio Exposes Workload Metrics
istioctl install --set profile=demo
kubectl label ns default istio-injection=enabled
kubectl get ns -Listio-injection

cd /c/code/istio-1.23.0
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/sleep/sleep.yaml


kubectl get pods
PRODUCTPAGE_POD=$(kubectl get pod -l app=productpage -ojsonpath='{.items[0].metadata.name}')
SLEEP_POD=$(kubectl get pod -l app=sleep -ojsonpath='{.items[0].metadata.name}')

kubectl exec $SLEEP_POD -it -- curl productpage:9080/productpage | head

kubectl get pod $PRODUCTPAGE_POD -ojsonpath='{.spec.containers[*].name}'
kubectl exec $PRODUCTPAGE_POD -c istio-proxy curl localhost:15090/stats/prometheus
istioctl dashboard envoy deploy/productpage-v1.default

# Lab 4.2. See the Metrics Collected in Prometheus
cd /c/code/istio-1.23.0
kubectl apply -f samples/addons/prometheus.yaml

SLEEP_POD=$(kubectl get pod -l app=sleep -ojsonpath='{.items[0].metadata.name}')

kubectl exec $SLEEP_POD -it -- curl productpage:9080/productpage | head
istioctl dashboard prometheus

SLEEP_POD=$(kubectl get pod -l app=sleep -ojsonpath='{.items[0].metadata.name}')

# Lab 4.4. Deploy Jaeger and Review Some Traces
kubectl apply -f samples/addons/jaeger.yaml
istioctl dashboard jaeger


# Lab 4.5. Discover the Kiali Console
kubectl apply -f samples/addons/kiali.yaml
istioctl dashboard kiali

kubectl delete -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl delete -f samples/sleep/sleep.yaml