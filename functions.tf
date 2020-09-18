/**
 * Copyright 2020 Taito United
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

data "archive_file" "cloud_build_notify" {
  count       = var.cloud_build_notify_enabled ? 1 : 0
  type        = "zip"
  source_dir  = "${path.module}/cloud-build-notify"
  output_path = "${path.module}/cloud-build-notify.zip"
}

data "archive_file" "cloud_sql_backup" {
  count       = var.cloud_sql_backups_enabled ? 1 : 0
  type        = "zip"
  source_dir  = "${path.module}/cloud-sql-backup"
  output_path = "${path.module}/cloud-sql-backup.zip"
}

resource "google_storage_bucket_object" "cloud_build_notify" {
  count       = var.cloud_build_notify_enabled ? 1 : 0
  bucket      = var.functions_bucket
  name        = "events/cloud-build-notify.zip"
  source      = "${path.module}/cloud-build-notify.zip"
}

resource "google_storage_bucket_object" "cloud_sql_backup" {
  count       = var.cloud_sql_backups_enabled ? 1 : 0
  bucket      = var.functions_bucket
  name        = "events/cloud-sql-backup.zip"
  source      = "${path.module}/cloud-sql-backup.zip"
}

resource "google_cloudfunctions_function" "cloud_build_notify" {
  count                 = var.cloud_build_notify_enabled ? 1 : 0

  name                  = "cloud-build-notify"
  runtime               = "nodejs12"
  available_memory_mb   = 128

  project               = data.google_project.project.project_id
  region                = var.functions_region
  source_archive_bucket = var.functions_bucket
  source_archive_object = "events/cloud-build-notify.zip"

  entry_point           = "main"
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = "projects/${data.google_project.project.project_id}/topics/cloud-builds"
    failure_policy {
      retry = false
    }
  }

  environment_variables = {
    SLACK_WEBHOOK_URL    = var.slack_webhook_url
    SLACK_BUILDS_CHANNEL = var.slack_builds_channel
  }
}

resource "google_cloudfunctions_function" "cloud_sql_backup" {
  count                 = var.cloud_sql_backups_enabled ? 1 : 0

  name                  = "cloud-sql-backup"
  runtime               = "nodejs12"
  available_memory_mb   = 128

  project               = data.google_project.project.project_id
  region                = var.functions_region
  source_archive_bucket = var.functions_bucket
  source_archive_object = "events/cloud-sql-backup.zip"

  service_account_email = google_service_account.cloud_sql_backup[0].email

  entry_point           = "main"
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = "projects/${data.google_project.project.project_id}/topics/${google_pubsub_topic.cloud_sql_backup[0].name}"
    failure_policy {
      retry = false
    }
  }
}
