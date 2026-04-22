#!/bin/bash
# 커스텀 이미지로 인스턴스를 생성하는 스크립트
source ./config.sh

echo "Nginx Docker 인스턴스를 생성 중입니다..."

# public 인스턴스 생성
gcloud compute instances create st8-ex-vm2 \
    --zone=asia-southeast3-a \
    --network-interface=subnet=st8-ex-public-subnet \
    --machine-type=n4-standard-2 \
    --tags=web-server,ssh-server \
    --image-family=st8-ex-board-img-group \
    --boot-disk-size=20GB \
    --labels=username=st8,classname=msp06

echo "이미지로 인스턴스 생성 완료!"