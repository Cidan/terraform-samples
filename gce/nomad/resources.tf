resource "google_storage_bucket" "nomad-scripts" {
  name     = "${var.project}-nomad-scripts"
  location = "us-central1"
  storage_class = "REGIONAL"
  force_destroy = true
}

resource "google_storage_bucket_object" "setup-consul" {
  name   = "setup-consul.sh"
  source = "scripts/setup-consul.sh"
  bucket = "${google_storage_bucket.nomad-scripts.name}"
}