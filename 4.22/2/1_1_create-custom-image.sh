#!/bin/bash
# create-vm.sh에서 생성한 인스턴스를 중지 및 이미지 생성 및 재시작하는 스크립트입니다.

source ./config.sh

# 인스턴스 중지
gcloud compute instances stop $VM_NAME1 \
    --zone=asia-southeast3-a --quiet

# 인스턴스 중지까지 소요되는 시간만큼 대기
sleep 30
# -----------------------------
#gcloud compute images create st8-ex-custom-img \
    # --source-disk=인스턴스 이름 \
    # --family=이미지 그룹명 \
    # --source-disk-zone=가용영역 이름 \
    # --storage-location=리전 \
    # --labels=라벨 \
    # --quiet

# 이미지 생성
gcloud compute images create st8-ex-custom-img \
    --source-disk=$VM_NAME1 \
    --source-disk-zone=asia-southeast3-a \
    --family=st8-ex-board-img-group \
    --storage-location=asia-southeast3 \
    --labels=username=st8,classname=msp06 \
    --quiet

# -----------------------------
# 이미지 생성시간만큼 대기
sleep 180

# 인스턴스 재시작
gcloud compute instances start $VM_NAME1 \
--zone=asia-southeast3-a --quiet

