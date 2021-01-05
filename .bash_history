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
kubectl get nodes
vi job-ex1.yml
kubectl create -f  job-ex1.yml
kubectl get job
kubectl get pod
kubectl logs pod countdown-cl6p6
kubectl logs  countdown-cl6p6
vi cronjob-ex1.yml
kubectl create -f  cronjob-ex1.yml
kubectl get job
kubectl get pod
kubectl get job
kubectl get cronjob
kubectl get job
kubectl logs hello-1608905760
kubectl get job
kubectl logs hello-1608905760
kubectl get pod
kubectl logs hello-1608905820-bxcfv
kubectl logs hello-1608905760-n9629
kubectl get pod
kubectl delete cronjob hello
kubectl get job
kubectl get pods
kubectl delete job countdown
ls
kubectl get ds
kubectl delete ds mydaemonset
kubectl get pods
kubectl get deploy
kubectl delete deploy kubeserve
kubectl get pods
kubectl get rs
kubectl get rc
kubectl delete rc tomcatrc
kubectl get pods
kubectl api resources
kubectl api-resources
kubectl get ns
kubectl get all -n kube-system
kubectl get pod -n kube-system
kubectl get rs -n kube-system
kubectl get ds -n kube-system
kubectl get depoy -n kube-system
kubectl get deploy -n kube-system
kubectl get jobs -n kube-system
kubectl get job -n kube-system
kubectl get svc -n kube-system
kubectl get nodes
kubectl create ns sai
kubectl run pod-1 ns sai
kubectl run pod-1 -n sai
kubectl run pod-1 --image nginx -n sai
kubectl get pods -n sai
kubectl get ns
kubectl delete  ns sai
kubectl create ns dev
kubectl create ns prod
vi object-counts-demo.yml
kubectl create -f object-counts-demo.yml -n dev
kubectl get resourcequota 
kubectl get resourcequota -n dev
kubectl describe resourcequota -n dev
kubectl create -f deploy sai-deploy --image nginx -n dev
kubectl create  deploy sai-deploy --image nginx -n dev
kubectl create  deploy sai-deploy1 --image nginx -n dev
kubectl describe resourcequota -n dev
kubectl get resourcequota -n dev
kubectl get pods -n dev
kubectl create  deploy sai-deploy3 --image nginx -n dev
kubectl create  deploy sai-deploy --image nginx --replicas 5 -n dev 
kubectl scale  deploy sai-deploy --image nginx --replicas 5 -n dev 
kubectl scale  deploy sai-deploy --replicas 5 -n dev 
kubectl get deploy -n dev
kubectl get resourcequota -
kubectl describe resourcequota -n dev
kubectl delete all --all
kubectl delete  --all all
kubectl get  ns 
kubectl delete  ns 
kubectl get pods
kubectl get rs
kubectl get deploy
kubectl get  ns 
kubectl create ns prod
vi compute-resources-demo.yml
kubectl -n prod create -f compute-resources-demo.yml
kubectl describe resourcequota -n prod
kubectl -f prod run pod1 --image tomcat --requests='cpu=1,memory=1501mi' --limits='cpu=1,memory=1501mi'
kubectl -f prod run pod1 --image tomcat --requests='cpu=1,memory=1101mi' --limits='cpu=1,memory=1101mi'
kubectl -n prod run pod1 --image tomcat --requests='cpu=1,memory=1101mi' --limits='cpu=1,memory=1101mi'
kubectl -n prod run pod1 --image tomcat --requests='cpu=1,memory=1101Mi' --limits='cpu=1,memory=1101Mi'
kubectl -n prod run pod1 --image tomcat --requests='cpu=1,memory=1000Mi' --limits='cpu=1,memory=1000Mi'
kubectl describe resourcequota -n prod
kubectl get resourcequota -n prod
kubectl get resourcequota -n prod --dry-run=client -o yaml 
kubectl -n prod run pod1 --image tomcat --requests='cpu=1,memory=1000Mi' --limits='cpu=1,memory=1000Mi' --dry-run=client -o yaml
kubectl delete ns prod
kubectl get resourcequota -n prod
vi nodeName.yml
kubectl create -f nodeName.yml
kubectl get pods -o wide
kubectl describe pods kubeserve
kubectl get pods -o wide
kubectl describe pods kubeserve-cf9d7797c-c86z4
kubectl get pods 
kubectl label node node2 app=dev
kubectl get nodes
kubectl delete pods 
kubectl delete pods kubeserve-cf9d7797c-c86z4kubeserve-cf9d7797c-zmmm4
kubectl delete pods kubeserve-cf9d7797c-c86z4 kubeserve-cf9d7797c-zmmm4
kubectl get pods 
kubectl delete pods kubeserve
kubectl delete deploy kubeserve
kubectl get pods 
vi compute-resources-demo.yml
vi nodeName.yml
kubectl create -f nodeName.yml
kubectl get pods 
kubectl get pods -o wide
kubectl delete deploy kubeserve
kubectl create pod pod1 --image tomcat
kubectl create pod1 --image tomcat
kubectl run pod pod1 --image tomcat
kubectl get pods -o wide
vi nodeName.yml
kubectl create -f nodeName.yml
kubectl get pods -o wide
kubectl delete pod pod
