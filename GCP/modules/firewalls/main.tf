resource "google_compute_firewall" "allow-jms" {
  name    = "allow-jms-terraform"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "5222", "5347", "3478", "5349", "9090", "4096"]
  }

  allow {
    protocol = "udp"
    ports    = ["3478", "10000-20000"]
  }

  // Allow traffic from everywhere to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-jms-terraform"]
}
