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

locals {
  postgresqlBackupSchedules = flatten([
    for db in concat(var.postgresql_clusters):
    db.storageBackupSchedule == "" ? [ ] : [
      {
        project = var.project_id
        instance = db.name
        type = "postgresql"
        schedule = db.storageBackupSchedule
        backupBucket = var.cloud_sql_backup_bucket
        backupPath = "/${db.name}"
      },
    ]
  ])

  mysqlBackupSchedules = flatten([
    for db in concat(var.mysql_clusters):
    db.storageBackupSchedule == "" ? [ ] : [
      {
        project = var.project_id
        instance = db.name
        type = "mysql"
        schedule = db.storageBackupSchedule
        backupBucket = var.cloud_sql_backup_bucket
        backupPath = "/${db.name}"
      },
    ]
  ])

  sqlBackupSchedules = concat(
    local.postgresqlBackupSchedules,
    local.mysqlBackupSchedules,
  )
}
