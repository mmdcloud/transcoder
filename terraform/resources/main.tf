data "google_client_config" "config" {}

# Pub/Sub Topic for Transcoder job notfications
resource "google_pubsub_topic" "transcoder-topic" {
  name                       = "transcoder-topic"
  message_retention_duration = "86600s"
}

# ---------------------------------------------------------------------------------
# Cloud Storage buckets for source and destination
resource "google_storage_bucket" "transcoder_source" {
  name                        = "transcoder-source-madmax"
  location                    = data.google_client_config.config.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "transcoder_destination" {
  name                        = "transcoder-destination-madmax"
  location                    = data.google_client_config.config.region
  force_destroy               = true
  uniform_bucket_level_access = true

}

# ---------------------------------------------------------------------------------
# Cloud Functions
# 1 . Transcode Function
resource "google_storage_bucket" "transcoder_bucket" {
  name                        = "transcoder-madmax"
  force_destroy               = true
  location                    = data.google_client_config.config.region
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "transcoder_object" {
  name   = "transcoder"
  bucket = google_storage_bucket.transcoder_bucket.name
  source = "${path.module}/../../cloud-functions/transcode-function/file.zip"
}

data "google_storage_project_service_account" "gcs_account" {}

resource "google_project_iam_member" "gcs-pubsub-publishing" {
  project = data.google_client_config.config.project
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}

resource "google_service_account" "account" {
  account_id   = "gcf-sa"
  display_name = "Test Service Account - used for both the cloud function and eventarc trigger in the test"
}

resource "google_project_iam_member" "invoking" {
  project    = data.google_client_config.config.project
  role       = "roles/run.invoker"
  member     = "serviceAccount:${google_service_account.account.email}"
  depends_on = [google_project_iam_member.gcs-pubsub-publishing]
}

resource "google_project_iam_member" "event-receiving" {
  project    = data.google_client_config.config.project
  role       = "roles/eventarc.eventReceiver"
  member     = "serviceAccount:${google_service_account.account.email}"
  depends_on = [google_project_iam_member.invoking]
}

resource "google_project_iam_member" "artifactregistry-reader" {
  project    = data.google_client_config.config.project
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.account.email}"
  depends_on = [google_project_iam_member.event-receiving]
}

resource "google_cloudfunctions2_function" "transcoder_function" {
  depends_on = [
    google_project_iam_member.event-receiving,
    google_project_iam_member.artifactregistry-reader,
  ]
  name        = "transcoder"
  location    = data.google_client_config.config.region
  description = "transcoder"

  build_config {
    runtime     = "nodejs20"
    entry_point = "transcodeVideoFunction"
    source {
      storage_source {
        bucket = google_storage_bucket.transcoder_bucket.name
        object = google_storage_bucket_object.transcoder_object.name
      }
    }
  }

  service_config {
    max_instance_count    = 1
    available_memory      = "256M"
    timeout_seconds       = 60
    service_account_email = google_service_account.account.email
  }

  event_trigger {
    event_type            = "google.cloud.storage.object.v1.finalized"
    trigger_region        = data.google_client_config.config.region
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.account.email
    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.transcoder_source.name
    }
  }
}

# ---------------------------------------------------------------------------------

# 2 . Ad Break Insertion 
resource "google_storage_bucket" "transcoder_ad_break_insertion_bucket" {
  name                        = "transcoder-ad-break-insertion-madmax"
  location                    = data.google_client_config.config.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "transcoder_ad_break_insertion_object" {
  name   = "transcoder-ad-break-insertion"
  bucket = google_storage_bucket.transcoder_ad_break_insertion_bucket.name
  source = "${path.module}/../../cloud-functions/ad-break-insertion/file.zip"
}

resource "google_cloudfunctions2_function" "transcoder_ad_break_insertion_function" {
  name        = "transcoder-ad-break-insertion"
  location    = data.google_client_config.config.region
  description = "transcoder-ad-break-insertion"

  build_config {
    runtime     = "nodejs20"
    entry_point = "adBreakInsertionFunction"
    source {
      storage_source {
        bucket = google_storage_bucket.transcoder_ad_break_insertion_bucket.name
        object = google_storage_bucket_object.transcoder_ad_break_insertion_object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

# 3 . Captions & Subtitles
resource "google_storage_bucket" "transcoder_captions_subtitles_bucket" {
  name                        = "transcoder-captions-subtitles-madmax"
  location                    = data.google_client_config.config.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "transcoder_captions_subtitles_object" {
  name   = "transcoder-captions-subtitles"
  bucket = google_storage_bucket.transcoder_captions_subtitles_bucket.name
  source = "${path.module}/../../cloud-functions/captions-subtitles/file.zip"
}

resource "google_cloudfunctions2_function" "transcoder_captions_subtitles_function" {
  name        = "transcoder-captions-subtitles"
  location    = data.google_client_config.config.region
  description = "transcoder-captions-subtitles"

  build_config {
    runtime     = "nodejs20"
    entry_point = "captionsAndSubtitlesFunction"
    source {
      storage_source {
        bucket = google_storage_bucket.transcoder_captions_subtitles_bucket.name
        object = google_storage_bucket_object.transcoder_captions_subtitles_object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

# 4 . Concatenate multiple video input
resource "google_storage_bucket" "transcoder_concatenate_multiple_video_input_bucket" {
  name                        = "transcoder-concatenate-multiple-video-input-madmax"
  location                    = data.google_client_config.config.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "transcoder_concatenate_multiple_video_input_object" {
  name   = "transcoder-concatenate-multiple-video-input"
  bucket = google_storage_bucket.transcoder_concatenate_multiple_video_input_bucket.name
  source = "${path.module}/../../cloud-functions/concatenate-multiple-video-input/file.zip"
}

resource "google_cloudfunctions2_function" "transcoder_concatenate_multiple_video_input_function" {
  name        = "transcoder-concatenate-multiple-video-input"
  location    = data.google_client_config.config.region
  description = "transcoder-concatenate-multiple-video-input"

  build_config {
    runtime     = "nodejs20"
    entry_point = "concatenateMultipleInputsFunction"
    source {
      storage_source {
        bucket = google_storage_bucket.transcoder_concatenate_multiple_video_input_bucket.name
        object = google_storage_bucket_object.transcoder_concatenate_multiple_video_input_object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

# 5 . Crop Video
resource "google_storage_bucket" "transcoder_crop_video_bucket" {
  name                        = "transcoder-crop-video-madmax"
  location                    = data.google_client_config.config.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "transcoder_crop_video_object" {
  name   = "transcoder-crop-video"
  bucket = google_storage_bucket.transcoder_crop_video_bucket.name
  source = "${path.module}/../../cloud-functions/crop-video/file.zip"
}

resource "google_cloudfunctions2_function" "transcoder_crop_video_function" {
  name        = "transcoder-crop-video"
  location    = data.google_client_config.config.region
  description = "transcoder-crop-video"

  build_config {
    runtime     = "nodejs20"
    entry_point = "cropVideoFunction"
    source {
      storage_source {
        bucket = google_storage_bucket.transcoder_crop_video_bucket.name
        object = google_storage_bucket_object.transcoder_crop_video_object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

# 6 . Generate Thumbnails
resource "google_storage_bucket" "transcoder_generate_thumbnails_bucket" {
  name                        = "transcoder-generate-thumbnails-madmax"
  location                    = data.google_client_config.config.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "transcoder_generate_thumbnails_object" {
  name   = "transcoder-generate-thumbnails"
  bucket = google_storage_bucket.transcoder_generate_thumbnails_bucket.name
  source = "${path.module}/../../cloud-functions/generate-thumbnails/file.zip"
}

resource "google_cloudfunctions2_function" "transcoder_generate_thumbnails_function" {
  name        = "transcoder-generate-thumbnails"
  location    = data.google_client_config.config.region
  description = "transcoder-generate-thumbnails"

  build_config {
    runtime     = "nodejs20"
    entry_point = "generateThumbnailsFunction"
    source {
      storage_source {
        bucket = google_storage_bucket.transcoder_generate_thumbnails_bucket.name
        object = google_storage_bucket_object.transcoder_generate_thumbnails_object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

# 7 . Overlay Creation
resource "google_storage_bucket" "transcoder_overlay_creation_bucket" {
  name                        = "transcoder-overlay-creation-madmax"
  location                    = data.google_client_config.config.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "transcoder_overlay_creation_object" {
  name   = "transcoder-overlay-creation"
  bucket = google_storage_bucket.transcoder_overlay_creation_bucket.name
  source = "${path.module}/../../cloud-functions/overlay-creation/file.zip"
}

resource "google_cloudfunctions2_function" "function" {
  name        = "transcoder-overlay-creation"
  location    = data.google_client_config.config.region
  description = "transcoder-overlay-creation"

  build_config {
    runtime     = "nodejs20"
    entry_point = "overlayCreationFunction"
    source {
      storage_source {
        bucket = google_storage_bucket.transcoder_overlay_creation_bucket.name
        object = google_storage_bucket_object.transcoder_overlay_creation_object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

# ---------------------------------------------------------------------------------

# Artifact registry to store Docker artifacts for frontend
resource "google_artifact_registry_repository" "transcoder_frontend" {
  location      = data.google_client_config.config.region
  repository_id = "transcoderfrontendmadmax"
  description   = "transcoder_frontend"
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }
}

# ---------------------------------------------------------------------------------
# Cloud Run service for hosting frontend
# resource "google_cloud_run_v2_service" "transcoder_frontend" {
#   name     = "transcoder-frontend"
#   location = data.google_client_config.config.region
#   ingress  = "INGRESS_TRAFFIC_ALL"

#   template {
#     scaling {
#       min_instance_count = 1
#       max_instance_count = 10
#     }
#     containers {
#       image = "${data.google_client_config.config.region}-docker.pkg.dev/${data.google_client_config.config.project}/${google_artifact_registry_repository.transcoder_frontend.name}/IMAGE:latest"
#       ports {
#         container_port = 3000
#       }
#     }
#   }
# }

# ---------------------------------------------------------------------------------
# Firestore database
# resource "google_firestore_database" "database" {
#   project                           = data.google_client_config.config.project
#   name                              = "database-id"
#   location_id                       = "nam5"
#   type                              = "FIRESTORE_NATIVE"
#   concurrency_mode                  = "OPTIMISTIC"
#   app_engine_integration_mode       = "DISABLED"
#   point_in_time_recovery_enablement = "POINT_IN_TIME_RECOVERY_ENABLED"
#   delete_protection_state           = "DELETE_PROTECTION_ENABLED"
#   deletion_policy                   = "DELETE"
# }

# ---------------------------------------------------------------------------------
# Firebase App
# resource "google_firebase_project" "default" {
#   provider = google-beta
#   project  = google_project.default.project_id
# }

# resource "google_firebase_android_app" "basic" {
#   provider      = google-beta
#   project       = data.google_client_config.config.project
#   display_name  = "Display Name Basic"
#   package_name  = "android.package.app"
#   sha1_hashes   = ["2145bdf698b8715039bd0e83f2069bed435ac21c"]
#   sha256_hashes = ["2145bdf698b8715039bd0e83f2069bed435ac21ca1b2c3d4e5f6123456789abc"]
# }

# ---------------------------------------------------------------------------------
# Secret Manager 
# resource "google_secret_manager_secret" "secret-basic" {
#   secret_id = "secret"

#   labels = {
#     label = "my-label"
#   }

#   replication {
#     user_managed {
#       replicas {
#         location = data.google_client_config.config.region
#       }
#       replicas {
#         location = "us-east1"
#       }
#     }
#   }
# }

# ---------------------------------------------------------------------------------
# Certificate Manager 
# resource "google_certificate_manager_certificate" "default" {
#   name        = "dns-cert"
#   description = "The default cert"
#   scope       = "EDGE_CACHE"
#   labels = {
#     env = "test"
#   }
#   managed {
#     domains = [
#       google_certificate_manager_dns_authorization.instance.domain,
#       google_certificate_manager_dns_authorization.instance2.domain,
#     ]
#     dns_authorizations = [
#       google_certificate_manager_dns_authorization.instance.id,
#       google_certificate_manager_dns_authorization.instance2.id,
#     ]
#   }
# }

# resource "google_certificate_manager_dns_authorization" "instance" {
#   name        = "dns-auth"
#   description = "The default dnss"
#   domain      = "subdomain.hashicorptest.com"
# }

# resource "google_certificate_manager_dns_authorization" "instance2" {
#   name        = "dns-auth2"
#   description = "The default dnss"
#   domain      = "subdomain2.hashicorptest.com"
# }

# ---------------------------------------------------------------------------------
# Cloud DNS
# resource "google_dns_managed_zone" "example-zone" {
#   name        = "example-zone"
#   dns_name    = "example-${random_id.rnd.hex}.com."
#   description = "Example DNS zone"
#   labels = {
#     foo = "bar"
#   }
# }

# resource "random_id" "rnd" {
#   byte_length = 4
# }

# resource "google_dns_record_set" "frontend" {
#   name = "frontend.${google_dns_managed_zone.prod.dns_name}"
#   type = "A"
#   ttl  = 300

#   managed_zone = google_dns_managed_zone.prod.name

#   rrdatas = [google_compute_instance.frontend.network_interface[0].access_config[0].nat_ip]
# }

# ---------------------------------------------------------------------------------
# Cloud Build
# resource "google_cloudbuild_trigger" "filename-trigger" {
#   location = data.google_client_config.config.region

#   trigger_template {
#     branch_name = "main"
#     repo_name   = "my-repo"
#   }

#   substitutions = {
#     _FOO = "bar"
#     _BAZ = "qux"
#   }

#   filename = "cloudbuild.yaml"
# }

#---------------------------------------------------------------------------------
# API Gateway
resource "google_api_gateway_api" "transcoder_api" {
  provider = google-beta
  api_id   = "transcoder-api"
}

resource "google_api_gateway_api_config" "transcoder_api_config" {
  provider      = google-beta
  api           = google_api_gateway_api.transcoder_api.api_id
  api_config_id = "transcoder-api-config"
  openapi_documents {
    document {
      path     = "config.yaml"
      contents = filebase64("${path.module}/../../api-gateway/config.yaml")
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "transcoder_api_gateway" {
  provider   = google-beta
  api_config = google_api_gateway_api_config.transcoder_api_config.id
  gateway_id = "transcoder-api-gateway"
}
