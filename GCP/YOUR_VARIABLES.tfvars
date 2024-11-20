project_name                            = "jitsi-meet-GCP-deployment"
credentials_json                        = "credentials.json"
domain_name                             = "deploymeet.com"
meet_prefix                             = "jitsi"
jitsi_jvb_username                      = "jvb"
jitsi_jvb_secret                        = "01234567890123456789012345678901234567890123456789012345678901234567890123456789WWXXYYZZ/3gQ3ZzGPMSZ/bT0TGRpnD74WkxBGJVw=="
jms_machine_type                        = "n2-standard-4"

# JMS
region_shard0                           = "us-central1"
zone_shard0                             = "us-central1-a"
jms0_static_ip                          = "1.2.3.4"

# service account
service_account_mail                    = "000000000000-compute@developer.gserviceaccount.com"

# Let's Encrypt contact email
letsencrypt_account_mail                = "benjamin@deploymeet.com"
