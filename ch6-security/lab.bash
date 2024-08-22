# Lab 6.1. Mutual TLS
kubectl label namespace default istio-injection=enabled
kubectl apply -f gateway.yaml
kubectl label namespace default istio-injection-

kubectl apply -f web-frontend.yaml
kubectl get pods

kubectl label namespace default istio-injection=enabled
kubectl apply -f customers-v1.yaml
kubectl get pods

export GATEWAY_IP=$(kubectl get svc -n istio-system istio-ingressgateway -ojsonpath='{.status.loadBalancer.ingress[0].hostname}')
istioctl dash kiali

kubectl apply -f vs-customers-gateway.yaml

curl -H "Host: customers.default.svc.cluster.local" http://$GATEWAY_IP

# Need two new bash terminals here:
# Terminal 1
export GATEWAY_IP=$(kubectl get svc -n istio-system istio-ingressgateway -ojsonpath='{.status.loadBalancer.ingress[0].hostname}')
while true; do curl -H "Host: customers.default.svc.cluster.local" http://$GATEWAY_IP; done
# Terminal 2
export GATEWAY_IP=$(kubectl get svc -n istio-system istio-ingressgateway -ojsonpath='{.status.loadBalancer.ingress[0].hostname}')
while true; do curl -v http://$GATEWAY_IP/; done

kubectl apply -f strict-mtls.yaml
kubectl delete peerauthentication default


kubectl delete deploy web-frontend customers-v1
kubectl delete svc customers web-frontend
kubectl delete vs customers web-frontend
kubectl delete gateway gateway


# Lab 6.2. Access Control
kubectl apply -f gateway.yaml
kubectl apply -f web-frontend.yaml
kubectl apply -f customers-v1.yaml

export GATEWAY_IP=$(kubectl get svc -n istio-system istio-ingressgateway -ojsonpath='{.status.loadBalancer.ingress[0].hostname}')
kubectl apply -f deny-all.yaml

curl $GATEWAY_IP

kubectl run curl --image=radial/busyboxplus:curl -i --tty

kubectl apply -f allow-ingress-frontend.yaml
curl $GATEWAY_IP

kubectl apply -f allow-web-frontend-customers.yaml
curl $GATEWAY_IP


kubectl delete sa customers-v1 web-frontend
kubectl delete deploy web-frontend customers-v1
kubectl delete svc customers web-frontend
kubectl delete vs customers web-frontend
kubectl delete gateway gateway
kubectl delete authorizationpolicy allow-ingress-frontend allow-web-frontend-customers deny-all
kubectl delete pod curl