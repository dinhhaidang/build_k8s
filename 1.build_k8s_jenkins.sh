#!/bin/sh
# This is a comment!
# Day la file de build moi truong de chay he thong CI/CD:
# 1. Setup K8S tren GCP
# 2. Setup jenskin. authencication
# 3. 

#----------------Setup moi truong K8S--------------------#
#Cau hinh zone mac dinh tren GCP
echo "#-------------------------------------------------------------------#"
echo "#                 Tao VM Rancher quan ly Cluster                    #"
echo "#-------------------------------------------------------------------#"
gcloud config set compute/zone asia-east1-a
gcloud compute instances create rancher-k8s \
   --custom-cpu 2 \
   --custom-memory 4 \
   --boot-disk-size 10 \
   --boot-disk-type pd-ssd \
   

echo "#-------------------------------------------------------------------#"
echo "#                 Dang tao network: ecoe-k8s                        #"
echo "#-------------------------------------------------------------------#"
gcloud compute networks create ecoe-k8s

#Tao he thong K8S
echo "#-------------------------------------------------------------------#"
echo "#                 Dang tao cluster kubernetes                       #"
echo "#-------------------------------------------------------------------#"
gcloud beta container clusters create ecoe-k8s \
--num-nodes 3 \
--network ecoe-k8s \
--machine-type n1-standard-2 \
--disk-type pd-ssd \
--disk-size 10 \
--scopes "https://www.googleapis.com/auth/projecthosting,storage-rw,cloud-platform"
gcloud container clusters list
sleep 15s

kubectl get nodes

#Chung thuc cum cluster vua moi tao
gcloud container clusters get-credentials ecoe-k8s

#-----------------Setup Helm------------------------#
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
chmod 755 get_helm.sh
./get_helm.sh
helm init
echo "\n"

#-----------------Setup Permissions in the cluster for Helm (install packet in helm)-------#
echo "------------Setup Permissions tren K8S de cai packet tren Helm------------------------"
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

#tao storage class ssd cho k8s
kubectl apply -f ssd_storageclass.yaml
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.beta.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass faster-ssd -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
echo "\n"


echo "#-------------------------------------------------------------------#"
echo "#         Chuan bi setup jenkins, se bat dau trong 1 phut...        #"
echo "#-------------------------------------------------------------------#"
sleep 1m
echo "#-----------------Setup Jenkins----------------------#"
helm install -n cd stable/jenkins -f jenkins/values.yaml --version 0.16.6 --wait
echo "\n"

echo "----------------Setup Cockpit - Visual Pod on K8S-----------------------"
kubectl create namespace cockpit-demo
kubectl create -f cockpit.json -n cockpit-demo
echo "\n"

echo "#----------------Thong tin truy cap Jenkins UI------------------#"
kubectl get svc
echo "\n"

echo "#------------------Mat khau dang nhap Jenkins-----------------------#"
printf $(kubectl get secret cd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
echo "#-------------------------------------------------------------------#"
echo "\n"

echo "#-----------------Thong tin web UI Cockpit-------------------#"
kubectl get svc -n cockpit-demo
echo "\n"

export POD_NAME=$(kubectl get pods -l "component=cd-jenkins-master" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:8080 >> /dev/null &

echo "#-------------------------------------------------------------------#"
echo "#            HE THONG DA HOAN THANH XAY DUNG MOI TRUONG!            #"
echo "#                      --------Thanks-------                        #"
echo "#-------------------------------------------------------------------#"
