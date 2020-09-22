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

resource "google_pubsub_topic" "cloud_sql_backup" {
  count    = var.cloud_sql_backups_enabled ? 1 : 0
  name     = "cloud-sql-backup"
}

# google_app_engine_application is required by google_cloud_scheduler_job
resource "google_app_engine_application" "app" {
  count       = var.cloud_sql_backups_enabled ? 1 : 0

  project     = var.project_id
  location_id = var.app_engine_location_id
}

resource "google_cloud_scheduler_job" "cloud_sql_backup" {
  depends_on = [ google_app_engine_application.app ]

  count    = var.cloud_sql_backups_enabled ? length(local.sqlBackupSchedules) : 0
  name     = "cloud-sql-backup-${local.sqlBackupSchedules[count.index].instance}"
  schedule = local.sqlBackupSchedules[count.index].schedule
  region   = var.functions_region

  pubsub_target {
    topic_name = "projects/${var.project_id}/topics/${google_pubsub_topic.cloud_sql_backup[0].name}"
    data = base64encode(jsonencode(local.sqlBackupSchedules[count.index]))
  }
}
