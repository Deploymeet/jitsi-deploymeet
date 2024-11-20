locals {
  vm_name        = "${var.vm_name}-${var.project_name}"
  jitsi_hostname = "${var.meet_prefix}.${var.domain_name}"
}

resource "google_compute_instance" "jitsi-jms" {
  count = 1

  machine_type = var.machine_type
  name         = local.vm_name
  tags         = ["allow-jms-terraform"]
  zone         = var.zone

  # Starting or stopping the instance: RUNNING or TERMINATED
  desired_status = "RUNNING"

  boot_disk {
    auto_delete = true
    device_name = "disk-${local.vm_name}"

    initialize_params {
      image = "projects/debian-cloud/global/images/debian-12-bookworm-v20240617"
      size  = 30
      type  = "pd-standard"
    }

    mode = "READ_WRITE"
  }

  labels = {
    goog-ec-src = "vm_add-tf"
    jitsi       = "jms"
  }

  metadata_startup_script = templatefile("${path.module}/startup_script.sh", {JITSI_HOSTNAME=local.jitsi_hostname, JITSI_JVB_USERNAME=var.jitsi_jvb_username, JITSI_JVB_SECRET=var.jitsi_jvb_secret, LETSENCRYPT_ACCOUNT_MAIL=var.letsencrypt_account_mail} )

  network_interface {
    access_config {
      nat_ip       = var.static_ip
      network_tier = "PREMIUM"
    }

    subnetwork = "projects/${var.project_name}/regions/${var.region}/subnetworks/default"
  }

  service_account {
    email  = var.service_account_mail
    scopes = ["https://www.googleapis.com/auth/compute.readonly", "https://www.googleapis.com/auth/devstorage.full_control", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append", "https://www.googleapis.com/auth/cloud-platform"]
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  metadata = {
    ssh-keys = "prov:${file("${path.module}/ssh/id_ed25519.pub")}"
  }

  provisioner "file" {
    source = "${path.module}/installation_files"
    destination = "/home/prov"
    connection {
      type        = "ssh"
      host        = "${var.static_ip}"
      user        = "prov"
      private_key = "${file("${path.module}/ssh/id_ed25519")}"
    }
  }

}
