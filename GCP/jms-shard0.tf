module "jms-shard0" {
  source                   = "./modules/jitsi-jms"
  domain_name              = var.domain_name
  project_name             = var.project_name
  meet_prefix              = var.meet_prefix
  zone                     = var.zone_shard0
  region                   = var.region_shard0
  static_ip                = var.jms0_static_ip
  jitsi_jvb_username       = var.jitsi_jvb_username
  jitsi_jvb_secret         = var.jitsi_jvb_secret
  machine_type             = var.jms_machine_type
  service_account_mail     = var.service_account_mail
  letsencrypt_account_mail = var.letsencrypt_account_mail
}

output "jms-shard0-external-ip-output" {
  value = length(module.jms-shard0) > 0 ? module.jms-shard0.external-ip : null
}

output "jms-shard0-internal-ip-output" {
  value = length(module.jms-shard0) > 0 ? module.jms-shard0.internal-ip : null
}
