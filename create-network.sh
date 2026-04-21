#!/bin/bash

# 1. VPC 생성
gcloud compute networks create st8-ex-vpc \
    --subnet-mode=custom \
    --bgp-routing-mode=regional \
    --mtu=1460 \
    --description="Educational Network (VPC)"

sleep 2

# 2. Proxy-only Subnet 생성 (Active)
gcloud compute networks subnets create st8-ex-proxy-only-subnet \
    --purpose=REGIONAL_MANAGED_PROXY \
    --role=ACTIVE \
    --network=st8-ex-vpc \
    --region=asia-southeast3 \
    --range=10.0.0.0/24 \
    --description="ALB Proxy Subnet"

sleep 2

# 3. Proxy-backup Subnet 생성 (Backup)
gcloud compute networks subnets create st8-ex-proxy-backup-subnet \
    --purpose=REGIONAL_MANAGED_PROXY \
    --role=BACKUP \
    --network=st8-ex-vpc \
    --region=asia-southeast3 \
    --range=10.0.1.0/24 \
    --description="ALB Proxy Backup Subnet"

sleep 2

# 4. Public Subnet
gcloud compute networks subnets create st8-ex-public-subnet \
    --network=st8-ex-vpc \
    --range=10.0.2.0/24 \
    --region=asia-southeast3 \
    --description="Bastion or Public Instance Subnet"

sleep 2

# 5. Private(App) Subnet
gcloud compute networks subnets create st8-ex-private-subnet \
    --network=st8-ex-vpc \
    --range=10.0.11.0/24 \
    --region=asia-southeast3 \
    --secondary-range=st8-ex-pod-range=10.1.0.0/16,st8-ex-svc-range=10.2.0.0/20 \
    --enable-private-ip-google-access \
    --description="Application Instance Private Subnet"

sleep 2

# 6. Private(DB) Subnet
gcloud compute networks subnets create st8-ex-db-subnet \
    --network=st8-ex-vpc \
    --range=10.0.21.0/24 \
    --region=asia-southeast3 \
    --enable-private-ip-google-access \
    --description="Database Cluster Private Subnet"

sleep 2

# 7. NAT Router 생성
gcloud compute routers create st8-ex-nat-router \
    --network=st8-ex-vpc \
    --region=asia-southeast3 \
    --description="NAT Router for Private Subnet"

sleep 2

# 8. Cloud NAT 생성
gcloud compute routers nats create st8-ex-nat \
    --router=st8-ex-nat-router \
    --region=asia-southeast3 \
    --auto-allocate-nat-external-ips \
    --nat-all-subnet-ip-ranges

sleep 2

# 방화벽 규칙 1 — SSH
gcloud compute firewall-rules create st8-ex-allow-ssh-ingress \
    --network=st8-ex-vpc \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=ssh-server \
    --description="Allow SSH from anywhere"

sleep 2

# 방화벽 규칙 2 — 헬스체크
gcloud compute firewall-rules create st8-ex-allow-health-check \
    --network=st8-ex-vpc \
    --action=ALLOW \
    --direction=INGRESS \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --rules=tcp:80

sleep 2

# 방화벽 규칙 3 — Web
gcloud compute firewall-rules create st8-ex-allow-web-ingress \
    --network=st8-ex-vpc \
    --allow=tcp:80 \
    --source-ranges=0.0.0.0/0,10.0.0.0/24,130.211.0.0/22,35.191.0.0/16 \
    --target-tags=web-server \
    --description="Allow Web from ALB Proxy Subnet"

sleep 2

# 방화벽 규칙 4 — WAS
gcloud compute firewall-rules create st8-ex-allow-was-ingress \
    --network=st8-ex-vpc \
    --allow=tcp:8000 \
    --source-ranges=10.0.11.0/24,10.1.0.0/16,10.2.0.0/20 \
    --target-tags=was-server \
    --description="Allow fastAPI from Web Server Subnet"

sleep 2

# 방화벽 규칙 5 — MySQL
gcloud compute firewall-rules create st8-ex-allow-mysql-ingress \
    --network=st8-ex-vpc \
    --allow=tcp:3306 \
    --source-ranges=10.0.11.0/24,10.1.0.0/16,10.2.0.0/20 \
    --target-tags=mysql-server \
    --description="Allow MySQL from App Subnet"

# 방화벽 규칙 6 - ICMP
gcloud compute firewall-rules create st8-ex-allow-icmp-internal \
    --network=st8-ex-vpc \
    --allow=icmp \
    --source-ranges=10.0.0.0/8 \
    --description="Allow ICMP ping between internal subnets"