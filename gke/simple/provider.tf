variable "project" {}
// Configure the Google Cloud provider
provider "google" {
  project     = "${var.project}"
  region      = "us-central1"
}

## Fill in your bucket for your backend here!
#terraform {
#  backend "gcs" {
#    bucket  = "BUCKET_NAME"
#    prefix  = "BUCKET_PREFIX"
#  }
#}
