variable "project" {}

variable "cluster-datacenters" {
  default = ["us-central1"]
}
variable "nomad-client-count" {
  default = "4"
}
variable "nomad-client-type" {
  default = "n1-standard-8"
}
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
