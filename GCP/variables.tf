variable "project_name" {
  type        = string
  default     = "jitsi-meet-GCP-deployment"
  description = "The GCP project's name: jitsi-meet-GCP-deployment"
}

variable "credentials_json" {
  type        = string
  default     = "credentials.json"
}

variable "domain_name" {
  type        = string
  default     = "deploymeet.com"
  description = "The domain name of meet installation eg: deploymeet.com"
}

variable "meet_prefix" {
  type        = string
  default     = "jitsi"
  description = "The jitsi meet server prefix for the domain name: jitsi.deploymeet.com"
}

variable "jitsi_jvb_username" {
  type        = string
  default     = "jvb"
}

variable "jitsi_jvb_secret" {
  type        = string
  default     = "01234567890123456789012345678901234567890123456789012345678901234567890123456789WWXXYYZZ"
}

variable "jms_machine_type" {
  type        = string
  default     = "n2-standard-2"
}

variable "region_shard0" {
  type        = string
  default     = "us-central1"
}

variable "zone_shard0" {
  type        = string
  default     = "us-central1-a"
}

variable "jms0_static_ip" {
  type        = string
  default     = ""
}

variable "service_account_mail" {
  type        = string
  default     = "000000000000-compute@developer.gserviceaccount.com"
}

variable "letsencrypt_account_mail" {
  type        = string
  default     = "account@developer.com"
}
