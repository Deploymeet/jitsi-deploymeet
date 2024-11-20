# Jitsi installation through Terraform

This terraform repository aims to install a pool of Jitsi Meet server shards on Google Cloud Platform (GCP) or Amazon Web Services (AWS) with autoscaling capabilities for JVBs.

## Architecture and services

- firewalls
- HA-proxy
- Jitsi Meet Server (JMS)
- Jitsi Videobridge (JVB)
- Jibri for recording

## Prerequisites

### DNS

#### One shard

Create a DNS record in your domain pointing to the external IP of the JMS.

Let's say you have a domain called deploymeet.com and you want to create a subdomain called jitsi.deploymeet.com.

If you have only one shard, you will have the following DNS records:

```text
jitsi    A    1.2.3.4
```

You will need to update the variable `domain` in YOUR_VARIABLES.tfvars as well as the variable `jms0_static_ip` with the correct IP (here jitsi -> 1.2.3.4).

#### Multiple shards

Create a DNS record in your domain pointing to the external IP of each shard.

Create a DNS record in your domain pointing to the external IP of the HA-proxy.

Let's say you have a domain called deploymeet.com and you want to create a subdomain called jitsi.deploymeet.com.

If you have two shards, you will have the following DNS records:

```text
jitsi0    A    10.20.30.40
jitsi1    A    100.200.300.400
jitsi     A    1.2.3.4
```

You will need to update the variable `domain` in YOUR_VARIABLES.tfvars as well as the variable `number_of_shards` if according number of shards.

`jms0_static_ip` and `jms1_static_ip` are the external IPs of the JMSs (here jitsi0 -> 10.20.30.40 and jitsi1 -> 100.200.300.400).

`ha0_static_ip` is the external IP of the HA-proxy (here jitsi -> 1.2.3.4).

### GCP Prerequisites

#### SSH key

For the JMS installation, you will need to create an SSH key pair. It will be used to connect to the JMSs and transfer the installation files. The key will be deleted after the installation.

Create an SSH key pair:

```bash
cd ~/jitsi-deploymeet/GCP
ssh-keygen -t ed25519 -f modules/jitsi-jms/ssh/id_ed25519
```

#### Service account

A service account that will access Google Compute Engine (GCE) is needed:
<https://console.cloud.google.com/iam-admin/serviceaccounts/>

Download the associated json key (credentials.json) into the jitsi-deploymeet/GCP folder and change the variables `service_account_mail` and `credentials_json` in YOUR_VARIABLES.tfvars.

## Configuration

Modify the variables in YOUR_VARIABLES.tfvars to fit your needs.

## Installation

```bash
sudo su
cd ~/jitsi-deploymeet/GCP
terraform workspace new JITSI_DEPLOYEMENT
terraform workspace select JITSI_DEPLOYEMENT
terraform init
terraform plan -var-file="YOUR_VARIABLES.tfvars"
terraform apply -auto-approve -var-file="YOUR_VARIABLES.tfvars"
```

## Test

Open a browser and go to the URL you defined in the DNS records.

## Information

When using multiple shards and the full installation, all Jitsi goes on port 443 (JMS and Turn server included).

## TODO

- [ ] AWS Deployment
- [ ] JWT token authentication

## Contact

For any questions, please contact us:

[deploymeet.com](<https://www.deploymeet.com>)

[Send us a mail](<mailto:contact@deploymeet.com>)
