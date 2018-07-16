This folder contains Terraform scripts and a deployment for Kubernetes that illustrates how to deploy an nginx container and expose it to the Internet.

Run like so:

 terraform init

 terraform apply

 gcloud container clusters get-credentials prod-main --zone us-central1-a --project $PROJECT_NAME

 kubectl apply -f deployment.yml
