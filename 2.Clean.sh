echo "#-------------------------------------------------------------------#"
echo "#                 Dang xoa cluster kubernetes.....                  #"
echo "#-------------------------------------------------------------------#"
printf "y\n" | gcloud container clusters delete ecoe-k8e || true

echo "#-------------------------------------------------------------------#"
echo "#                      Dang xoa VM Rancher.....                     #"
echo "#-------------------------------------------------------------------#"
printf "y\n" | gcloud compute instances delete rancher-k8s || true

