output "external-ip" {
  value = length("${google_compute_instance.jitsi-jms}") > 0 ? "${google_compute_instance.jitsi-jms[0].network_interface.0.access_config.0.nat_ip}" : null
}

output "internal-ip" {
  value = length("${google_compute_instance.jitsi-jms}") > 0 ? "${google_compute_instance.jitsi-jms[0].network_interface.0.network_ip}" : null
}
