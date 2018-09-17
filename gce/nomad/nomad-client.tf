resource "google_compute_instance_template" "nomad-client" {
  name        = "nomad-client-template"
  description = "Template for nomad servers"

  tags = ["nomad-client"]

  labels = {
    environment = "prod"
  }

  metadata_startup_script = <<EOF
gsutil cp gs://${google_storage_bucket.nomad-scripts.name}/${google_storage_bucket_object.setup-consul.name} /tmp/ && bash /tmp/setup-consul.sh
gsutil cp gs://${google_storage_bucket.nomad-scripts.name}/${google_storage_bucket_object.setup-nomad.name} /tmp/ && bash /tmp/setup-nomad.sh
EOF

  instance_description = "nomad-client template setup"
  machine_type         = "${var.nomad-client-type}"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "debian-cloud/debian-9"
    auto_delete  = false
    boot         = true
  }

  network_interface {
    subnetwork = "default"
    access_config = {}
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "google_compute_region_instance_group_manager" "nomad-client" {
  name = "nomad-client"

  base_instance_name         = "nomad-client"
  instance_template          = "${google_compute_instance_template.nomad-client.self_link}"
  region                     = "us-central1"

  target_size  = "${var.nomad-client-count}"

}