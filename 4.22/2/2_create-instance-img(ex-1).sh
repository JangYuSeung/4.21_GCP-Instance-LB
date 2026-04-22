#!/bin/bash
# 인스턴스 생성부터 이미지 생성까지 한 번에 실행하는 스크립트입니다.
gcloud compute instances create st8-ex-vm1 \
    --zone=asia-southeast3-a \
    --network-interface=subnet=st8-ex-public-subnet \
    --machine-type=n4-standard-2 \
    --tags=web-server,ssh-server \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --boot-disk-size=20GB \
    --metadata-from-file startup-script=init-scripts-docker-compose.sh

# startup-script(Docker + 앱 기동) 완료 대기
sleep 180

# 인스턴스 중지
gcloud compute instances stop st8-ex-vm1 \
    --zone=asia-southeast3-a --quiet

# 중지 완료 대기
sleep 30

# 이미지 생성: 위에서 생성된 인스턴스를 사용
gcloud compute images create st8-ex-custom-img \
    --source-disk=st8-ex-vm1 \
    --source-disk-zone=asia-southeast3-a \
    --family=st8-ex-board-img-group \
    --storage-location=asia-southeast3 \
    --labels=username=st8,classname=msp06 \
    --quiet
