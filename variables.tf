/**
 * Copyright 2021 Taito United
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

variable "project_id" {
  type        = string
}

variable "app_engine_location_id" {
  type        = string
  default     = "europe-west"
}

variable "cloud_build_notify_enabled" {
  type        = bool
  default     = true
}

variable "cloud_sql_backups_enabled" {
  type        = bool
  default     = true
}

variable "functions_bucket" {
  type        = string
  default     = ""
}

variable "functions_region" {
  type        = string
  default     = ""
}

variable "cloud_sql_backup_bucket" {
  type        = string
  default     = ""
}

variable "cloud_sql_backup_path" {
  type        = string
  default     = ""
}

variable "slack_webhook_url" {
  type        = string
  default     = ""
}

variable "slack_builds_channel" {
  type        = string
  default     = ""
}

variable "postgresql_clusters" {
  type = list(object({
    name = string
    storageBackupSchedule = string
  }))
  default = []
}

variable "mysql_clusters" {
  type = list(object({
    name = string
    storageBackupSchedule = string
  }))
  default = []
}
