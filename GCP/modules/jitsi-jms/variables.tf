variable "vm_name" {
  type        = string
  default     = "jitsi-jms"
}

variable "domain_name" {
  type        = string
  default     = "deploymeet.com"
  description = "The domain name of meet installation eg: deploymeet.com"
}

variable "project_name" {
  type        = string
  default     = "jitsi-meet-GCP-deployment"
  description = "The GCP project's name: jitsi-meet-GCP-deployment"
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

variable "region" {
  type        = string
  default     = "us-central1"
}

variable "zone" {
  type        = string
  default     = "us-central1-a"
}

variable "static_ip" {
  type        = string
  default     = ""
}

variable "machine_type" {
  type        = string
  default     = "n2-standard-2"
}

variable "service_account_mail" {
  type        = string
  default     = "000000000000-compute@developer.gserviceaccount.com"
}

variable "letsencrypt_account_mail" {
  type        = string
  default     = "account@developer.com"
}
