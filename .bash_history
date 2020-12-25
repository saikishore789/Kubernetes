sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update ; clear
sudo apt-get install -y docker-ce
sudo service docker start ; clear
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-get update ; clear
sudo apt-get install -y kubelet kubeadm kubectl 
sudo kubeadm init --ignore-preflight-errors=all
sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl get nodes
kubectl get all --all-namespaces
kubectl get nodes
kubectl get all --all-namespaces
kubectl get nodes
kubectl get pods --all-namespaces
vi pod.yml
kubectl create -f pod.yml
kubectl get pods
vi pod2.yml
kubectl create -f pod2.yml
kubectl get pods
vi multi-cont-pod-ex1.yml
kubectl create -f multi-cont-pod-ex1.yml
kubectl get pods
vi multi-cont-pod-ex2.yml
kubectl create -f multi-cont-pod-ex2.yml
kubectl get pods
vi pod3.yml
rm pod3.yml
ls
kubectl get pods -l app=tomcat
kubectl get pods -l app=alpine
kubectl get pods -l app=nginx
kubectl get pods -l app=nettools
kubectl get pods
kubectl get nodes
kubectl get pods
sudo sud -
sudo su -
kubectl get nodes
kubectl get pods
ls
cat pod2.yml
kubectl get pods
kubectl delete pod staticpod-ip-172-31-46-225
kubectl get pods
cat multi-cont-pod-ex2.yml
kubectl get pods
vi initContainer.yml
kubectl create -f initContainer.yml
kubectl get pods
kubectl get nodes
vi init-cont-pod.yml
kubectl create -f init-cont-pod.yml
kubectl get pods
kubectl get pods -o wide
curl 10.36.0.3
111111111111111111111111111111111
kubectl get po
kubectl delete pod multi-cont pod3 
kubectl run pod2 --image nginx --labels='app=sai, env=prod'
kubectl run pod2 --image nginx --labels='app=sai,env=prod'
kubectl get po
kubectl get po -o wide
curl 10.44.0.1
kubectl expose pod pod2 --name svc --Port 80 --type NodePort
kubectl expose pod pod2 --name svc --port 80 --type NodePort
kubectl get po -o wide
172-31-45-156
kubectl get svc
kubectl expose pod pod2 --name svc --port 80 --type NodePort --dry-run=client -o yml
kubectl expose pod pod2 --name svc --port 80 --type NodePort --dry-run=client -o yaml
kubectl describe svc svc1
kubectl describe svc svc
kubectl edit pod pod2
kubectl get pods
kubectl describe pods pod2
kubectl get pod pod2 -o yaml > pod2.yaml
vi pod2.yaml
kubectl apply -f pod2.yaml
kubectl describe pods pod2
kubectl apply -f pod2.yaml
kubectl apply -f pod2.yaml --save-config
vi pod2.yaml
kubectl apply -f pod2.yaml
vi pod2.yaml

vi pod2.yaml
kubectl apply -f pod2.yaml
kubectl get pods
kubectl edit pods pod2
ls
cat pod2.yaml
kubectl get pods
kubectl delete pod pod2
vi pod2.yaml 
kubectl create -f  pod2.yaml 
kubectl get pods
vi pod2.yaml 
kubectl apply -f  pod2.yaml 
kubectl delete pod pod2
sudo rm pod2.yaml
ls
kubectl run pod3 --image nginx --labels='app=sai,env=dev'
kubectl get pods
kubectl get pods pod3 -o yaml > pod3.yml
cat pod3.yml
kubectl delete svc svc
kubectl expose pod pod3 --name svc1 --port 80 --type ClusterIp
kubectl expose pod pod3 --name svc1 --port 80 --type ClusterIP
kubectl get svc
curl 10.102.205.84
vi replicationController.yml
kubectl create -f replicationController.yml
kubectl get pods
vi replicationController.yml
kubectl get pods
vi replicationController.yml
kubectl apply -f replicationController.yml
kubectl get pods
vi rs-ex.yml
kubectl create -f  rs-ex.yml
kubectl get pods
kubectl get nodes
ls
cat re-ex.yml
cat rs-ex.yml
kubectl get pods
cat replicationController.yml
kubectl describe pod test
kubectl delete pod test
vi rs-ex.yml
kubectl apply -f  rs-ex.yml
kubectl get pods
kubectl describe pod test
kubectl create -f  rs-ex.yml
kubectl delete pod test
kubectl get po
cat rs-ex.yml
kubectl delete po test-9d64z
kubectl get po
kubectl delete rs test
kubectl get po
kubectl create -f  rs-ex.yml
kubectl get po
vi service-ex.yml
kubectl create -f  service-ex.yml
vi service-ex.yml
kubectl create -f  service-ex.yml
kubectl get svc
kubectl get po
kubectl get svc
kubectl describe svc frondendsvc
