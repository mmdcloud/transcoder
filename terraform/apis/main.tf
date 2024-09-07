# Enabling necessary Google Service APIs

data "google_project" "project" {}

resource "google_project_service" "pubsub_api_service" {
  project = data.google_project.project.number
  service = "pubsub.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy = false
}

resource "google_project_service" "storage_api_service" {
  project = data.google_project.project.number
  service = "storage-component.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_on_destroy = false
}

resource "google_project_service" "cloudrun_api_service" {
  project = data.google_project.project.number
  service = "run.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_on_destroy = false
}

resource "google_project_service" "cloudfunctions_api_service" {
  project = data.google_project.project.number
  service = "cloudfunctions.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy = false
}

resource "google_project_service" "artifactregistry_api_service" {
  project = data.google_project.project.number
  service = "artifactregistry.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy = false
}

resource "google_project_service" "transcoder_api_service" {
  project = data.google_project.project.number
  service = "transcoder.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy = false
}

resource "google_project_service" "iam_api_service" {
  project = data.google_project.project.number
  service = "iam.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy = false
}

resource "google_project_service" "dns_api_service" {
  project = data.google_project.project.number
  service = "dns.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy = false
}

resource "google_project_service" "cloudbuild_api_service" {
  project = data.google_project.project.number
  service = "cloudbuild.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy = false
}

resource "google_project_service" "apigateway_api_service" {
  project = data.google_project.project.number
  service = "apigateway.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy = false
}

resource "google_project_service" "certificatemanager_api_service" {
  project = data.google_project.project.number
  service = "certificatemanager.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy = false
}

resource "google_project_service" "secretmanager_api_service" {
  project = data.google_project.project.number
  service = "secretmanager.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy = false
}

resource "google_project_service" "firestore_api_service" {
  project = data.google_project.project.number
  service = "firestore.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy = false
}

resource "google_project_service" "serviceusage_api_service" {
  project = data.google_project.project.number
  service = "serviceusage.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy = false
}

resource "google_project_service" "servicecontrol_api_service" {
  project = data.google_project.project.number
  service = "servicecontrol.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy = false
}

resource "google_project_service" "servicemanagement_api_service" {
  project = data.google_project.project.number
  service = "servicemanagement.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy = false
}
