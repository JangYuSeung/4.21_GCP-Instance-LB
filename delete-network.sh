#!/bin/bash

# 1. Cloud NAT 삭제
echo "Deleting Cloud NAT..."
gcloud compute routers nats delete st8-ex-nat \
    --router=st8-ex-nat-router \
    --region=asia-southeast3 \
    --quiet

sleep 2

# 2. NAT Router 삭제
echo "Deleting NAT Router..."
gcloud compute routers delete st8-ex-nat-router \
    --region=asia-southeast3 \
    --quiet

sleep 2

# 3. 방화벽 규칙 삭제 (allow-gcp-health-check → st8-ex-allow-health-check 수정)
echo "Deleting Firewall Rules..."
gcloud compute firewall-rules delete \
    st8-ex-allow-ssh-ingress \
    st8-ex-allow-health-check \
    st8-ex-allow-web-ingress \
    st8-ex-allow-was-ingress \
    st8-ex-allow-mysql-ingress \
    --quiet

sleep 2

# 4. 서브넷 전체 삭제
echo "Deleting Subnets..."
gcloud compute networks subnets delete \
    st8-ex-db-subnet \
    st8-ex-private-subnet \
    st8-ex-public-subnet \
    st8-ex-proxy-backup-subnet \
    st8-ex-proxy-only-subnet \
    --region=asia-southeast3 \
    --quiet

echo "Waiting for subnets to be fully purged..."
sleep 5

# 5. VPC 삭제
echo "Deleting VPC..."
gcloud compute networks delete st8-ex-vpc \
    --quiet

echo "Cleanup Complete!"