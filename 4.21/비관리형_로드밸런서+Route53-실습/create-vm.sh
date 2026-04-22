#!/bin/bash
source ./config.sh

echo "인스턴스를 생성 중입니다..."

# private 인스턴스 2개 생성
gcloud compute instances create $VM_NAME1 $VM_NAME2 \
    --zone=asia-southeast3-a \
    --network-interface=subnet=st8-ex-private-subnet,no-address \
    --machine-type=n4-standard-2 \
    --tags=web-server,ssh-server \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --boot-disk-size=20GB \
    --metadata-from-file startup-script=init-scripts-docker-compose.sh

echo "인스턴스 생성 완료!"
echo "외부 IP가 없으므로 LB를 통해 접속하세요."