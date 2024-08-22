# Lab5.1. Gateways
kubectl apply -f gateway.yaml
kubectl get svc -l=istio=ingressgateway -n istio-system
# We are using Docker, so we only get the hostname. Otherwise, we would use ip.
export GATEWAY_IP=$(kubectl get svc -n istio-system istio-ingressgateway -ojsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo $GATEWAY_IP

kubectl apply -f hello-world.yaml
kubectl get po,svc -l=app=hello-world

kubectl apply -f vs-hello-world.yaml
kubectl get vs
curl -v http://$GATEWAY_IP/


kubectl delete deploy hello-world
kubectl delete service hello-world
kubectl delete vs hello-world
kubectl delete gateway gateway


# Lab 5.2. Weight-Based Traffic Routing
kubectl apply -f gateway.yaml
kubectl apply -f web-frontend.yaml
kubectl apply -f customers-v1.yaml
kubectl get po

kubectl apply -f web-frontend-vs.yaml
export GATEWAY_IP=$(kubectl get svc -n istio-system istio-ingressgateway -ojsonpath='{.status.loadBalancer.ingress[0].hostname}')

kubectl apply -f customers-dr.yaml
kubectl apply -f customers-vs.yaml
kubectl apply -f customers-v2.yaml
kubectl apply -f customers-50-50.yaml

kubectl delete deploy web-frontend customers-{v1,v2}
kubectl delete svc customers web-frontend
kubectl delete vs customers web-frontend
kubectl delete dr customers
kubectl delete gateway gateway

# Lab 5.3. Advanced Traffic Routing
kubectl apply -f gateway.yaml
kubectl get po,svc
kubectl apply -f web-frontend.yaml
kubectl apply -f web-frontend-vs.yaml
kubectl apply -f customers.yaml
kubectl apply -f customers-vs-headers.yaml

curl -H "user: debug" http://$GATEWAY_IP/ | grep -E 'CITY|NAME'

kubectl delete deploy web-frontend customers-{v1,v2}
kubectl delete svc customers web-frontend
kubectl delete vs customers web-frontend
kubectl delete dr customers
kubectl delete gateway gateway


# Lab 5.4. Observing Failure Injection and Delays in Grafana, Jaeger, and Kiali
kubectl apply -f gateway.yaml
kubectl apply -f web-frontend.yaml
kubectl apply -f web-frontend-vs.yaml
kubectl apply -f customers.yaml
kubectl apply -f customers-delay.yaml
export GATEWAY_IP=$(kubectl get svc -n istio-system istio-ingressgateway -ojsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl http://$GATEWAY_IP/ 

while true; do curl http://$GATEWAY_IP/; done

istioctl dash grafana
istioctl dash jaeger

kubectl apply -f customers-fault.yaml
istioctl dash grafana
istioctl dash kiali


kubectl delete deploy web-frontend customers-v1
kubectl delete svc customers web-frontend
kubectl delete vs customers web-frontend
kubectl delete gateway gateway


# Lab 5.5. Service Entries for Registry-Only Outbound Traffic Policy
istioctl install --set profile=demo --set meshConfig.outboundTrafficPolicy.mode=REGISTRY_ONLY
kubectl get cm -n istio-system istio -o yaml

cd /c/code/istio-1.23.0
kubectl apply -f samples/sleep/sleep.yaml
SLEEP_POD=$(kubectl get pod -l app=sleep -ojsonpath='{.items[0].metadata.name}')
echo $SLEEP_POD
kubectl exec $SLEEP_POD -it -- curl -v https://github.com/

cd /c/code/lfs144x/ch5-traffic-management
kubectl apply -f service-entry.yaml
kubectl exec $SLEEP_POD -it -- curl -v https://github.com/

kubectl delete -f /c/code/istio-1.23.0/samples/sleep/sleep.yaml
kubectl delete serviceentry github-external