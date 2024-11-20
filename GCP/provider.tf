# Specify the provider (GCP, AWS, Azure)

provider "google" {
  credentials = "${file(var.credentials_json)}"
  project = var.project_name
}
