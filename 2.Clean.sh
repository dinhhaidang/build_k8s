echo "#-------------------------------------------------------------------#"
echo "#                 Dang xoa cluster kubernetes.....                  #"
echo "#-------------------------------------------------------------------#"
printf "y\n" | gcloud container clusters delete ecoe-k8e || true

