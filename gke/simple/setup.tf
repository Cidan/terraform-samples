// Create a k8s cluster
resource "google_container_cluster" "prod-main" {
  name               = "prod-main"
  zone               = "us-central1-a"
  min_master_version = "1.10.5-gke.0"

  master_auth {
    username = "nouser"
    password = "DKH89sahdsdBXZqq9oDa="
  }

  additional_zones = [
    "us-central1-b"
  ]

  // Main pool for the cluster
  node_pool {
    name = "default"
    node_count = 3

    management = {
      auto_repair = true
      auto_upgrade = true
    }
    
    autoscaling = {
      min_node_count = 6
      max_node_count = 24
    }

		// This will give all nodes complete access to the project
		// Do not do this in production, unless you mean to!
    node_config {
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform",
      ]

      disk_size_gb = 30
      machine_type = "n1-standard-8"
    }
  }
}

