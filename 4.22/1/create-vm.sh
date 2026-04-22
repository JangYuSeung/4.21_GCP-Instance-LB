#!/bin/bash
source ./config.sh

echo "인스턴스를 생성 중입니다..."

# public 인스턴스 2개 생성 (외부 IP 포함)
gcloud compute instances create $VM_NAME1 \
    --zone=asia-southeast3-a \
    --network-interface=subnet=st8-ex-public-subnet \
    --machine-type=n4-standard-2 \
    --tags=web-server,ssh-server \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --boot-disk-size=20GB \
    --metadata-from-file startup-script=init-scripts-docker-compose.sh

echo "인스턴스 생성 완료!"