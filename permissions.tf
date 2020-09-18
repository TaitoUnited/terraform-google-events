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

resource "google_service_account" "cloud_sql_backup" {
  count        = var.cloud_sql_backups_enabled ? 1 : 0
  account_id   = "cloud-sql-backup"
  display_name = "Cloud SQL Backup"
}

resource "google_project_iam_member" "cloud_sql_backup" {
  count    = var.cloud_sql_backups_enabled ? 1 : 0
  member   = "serviceAccount:${google_service_account.cloud_sql_backup[0].email}"
  role     = "roles/cloudsql.client"
}

data "google_sql_database_instance" "database" {
  count    = var.cloud_build_notify_enabled ? length(local.sqlBackupSchedules) : 0
  name     = local.sqlBackupSchedules[count.index].instance
}

resource "google_storage_bucket_iam_member" "cloud_sql_backup" {
  count = var.cloud_build_notify_enabled ? length(local.sqlBackupSchedules) : 0

  bucket        = var.cloud_sql_backup_bucket
  role          = "roles/storage.legacyBucketWriter"
  member        = data.google_sql_database_instance.database[count.index].service_account_email_address
}
