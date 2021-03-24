# Google Cloud events

> TODO: rename this module to "Google Cloud integrations"

Provides some custom jobs and notifications for your infrastructure:

- Cloud SQL long-term backups
- Cloud Build slack notifications

Example usage:

```
provider "google" {
  project      = "my-infrastructure"
  region       = "europe-west1"
  zone         = "europe-west1-b"
}

# Enable Google APIs

resource "google_project_service" "compute" {
  service      = "compute.googleapis.com"
}

resource "google_project_service" "cloudfunctions" {
  service      = "cloudfunctions.googleapis.com"
}

resource "google_project_service" "cloudscheduler" {
  service      = "cloudscheduler.googleapis.com"
}

resource "google_project_service" "pubsub" {
  service      = "pubsub.googleapis.com"
}

resource "google_project_service" "sqladmin" {
  service      = "sqladmin.googleapis.com"
}

# Events

module "events" {
  source           = "TaitoUnited/events/google"
  version          = "1.0.0"
  depends_on       = [
    google_project_service.compute,
    google_project_service.cloudfunctions,
    google_project_service.cloudscheduler,
    google_project_service.pubsub,
    google_project_service.sqladmin,
  ]

  cloud_build_notify_enabled = true
  cloud_sql_backups_enabled  = true

  functions_bucket           = "my-functions-bucket"
  functions_region           = "europe-west1"
  cloud_sql_backup_bucket    = "my-sql-backup-bucket"
  cloud_sql_backup_path      = "/backups"
  slack_webhook_url          = "https://hooks.slack.com/services/T00000000/B0000..."
  slack_builds_channel       = "builds"

  postgresql_clusters = yamldecode(file("${path.root}/../infra.yaml"))["postgresqlClusters"]
  mysql_clusters      = yamldecode(file("${path.root}/../infra.yaml"))["mysqlClusters"]
}
```

Example YAML:

```
postgresqlClusters:
  - name: my-common-postgres
    storageBackupSchedule: 0 0 * * 0

mysqlClusters:
  - name: my-common-mysql
    storageBackupSchedule: 0 0 * * 0
```

Combine with the following modules to get a complete infrastructure defined by YAML:

- [Admin](https://registry.terraform.io/modules/TaitoUnited/admin/google)
- [DNS](https://registry.terraform.io/modules/TaitoUnited/dns/google)
- [Network](https://registry.terraform.io/modules/TaitoUnited/network/google)
- [Kubernetes](https://registry.terraform.io/modules/TaitoUnited/kubernetes/google)
- [Databases](https://registry.terraform.io/modules/TaitoUnited/databases/google)
- [Storage](https://registry.terraform.io/modules/TaitoUnited/storage/google)
- [Monitoring](https://registry.terraform.io/modules/TaitoUnited/monitoring/google)
- [Integrations](https://registry.terraform.io/modules/TaitoUnited/integrations/google)
- [PostgreSQL privileges](https://registry.terraform.io/modules/TaitoUnited/privileges/postgresql)
- [MySQL privileges](https://registry.terraform.io/modules/TaitoUnited/privileges/mysql)

TIP: Similar modules are also available for AWS, Azure, and DigitalOcean. All modules are used by [infrastructure templates](https://taitounited.github.io/taito-cli/templates#infrastructure-templates) of [Taito CLI](https://taitounited.github.io/taito-cli/). See also [Google Cloud project resources](https://registry.terraform.io/modules/TaitoUnited/project-resources/google), [Full Stack Helm Chart](https://github.com/TaitoUnited/taito-charts/blob/master/full-stack), and [full-stack-template](https://github.com/TaitoUnited/full-stack-template).

Contributions are welcome!
