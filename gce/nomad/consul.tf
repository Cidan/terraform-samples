// https://releases.hashicorp.com/consul/1.2.3/consul_1.2.3_linux_amd64.zip
/* {
  "retry_join": ["provider=gce tag_value=consul-nomad"]
  }
*/
resource "google_compute_instance_template" "consul-nomad" {
  name        = "consul-nomad-template"
  description = "Template for consul leaders, nomad specific"

  tags = ["consul-nomad"]

  labels = {
    environment = "prod"
  }

  metadata_startup_script = "gsutil cp gs://${google_storage_bucket.nomad-scripts.name}/${google_storage_bucket_object.setup-consul.name} /tmp/ && bash /tmp/setup-consul.sh"

  instance_description = "consul server setup by nomad terraform"
  machine_type         = "n1-standard-1"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
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

resource "google_compute_region_instance_group_manager" "consul-nomad" {
  name = "consul-nomad"

  base_instance_name         = "consul-nomad"
  instance_template          = "${google_compute_instance_template.consul-nomad.self_link}"
  region                     = "us-central1"
  //distribution_policy_zones  = ["us-central1-a", "us-central1-f"]

  //target_pools = ["${google_compute_target_pool.appserver.self_link}"]
  target_size  = 5

  named_port {
    name = "consul"
    port = 8500
  }

/*
  auto_healing_policies {
    health_check      = "${google_compute_health_check.autohealing.self_link}"
    initial_delay_sec = 300
  }
*/
}