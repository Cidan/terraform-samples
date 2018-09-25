resource "google_compute_instance_template" "postgres-primary" {
  name        = "postgres"
  description = "Template for postgres"

  tags = ["postgres-primary"]

  labels = {
    environment = "prod"
  }

  metadata_startup_script = "gsutil cp gs://${google_storage_bucket.postgres-scripts.name}/${google_storage_bucket_object.setup-postgres.name} /tmp/ && bash /tmp/setup-postgres.sh primary"

  instance_description = "postgres primary server"
  machine_type         = "n1-standard-8" // TODO: Config var
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

resource "google_compute_region_instance_group_manager" "postgres-primary" {
  name = "postgres-primary"
  count = "${length(var.cluster-datacenters)}"
  base_instance_name         = "postgres-primary"
  instance_template          = "${google_compute_instance_template.postgres-primary.self_link}"
  region                     = "${var.cluster-datacenters[count.index]}"

  target_size  = 5

  named_port {
    name = "postgres"
    port = 5432
  }

}