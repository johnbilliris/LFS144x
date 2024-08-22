# Lab 8.1. Sidecars for Improved Service Mesh Performance

cd /c/code/istio-1.23.0
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

istioctl proxy-config endpoints deploy/productpage-v1.default
istioctl proxy-config endpoints deploy/ratings-v1.default

cd /c/code/lfs144x/ch8-advanced-topics
kubectl apply -f sidecars.yaml
istioctl proxy-config endpoints deploy/productpage-v1.default

kubectl delete -f /c/code/istio-1.23.0/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl delete sidecar {details,productpage,ratings,reviews-v1,reviews-v2,reviews-v3}-sidecar

