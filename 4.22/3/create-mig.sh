#!/bin/bash
# ------------------------------
# 인스턴스 템플릿 구성
# 디스크 크기는 주지 말기 => 디스크 크기는 이미지 생성 시점의 디스크 크기를 따라가기 때문.
# 이미지 크기보다 같거나 그 이상이어야 한다. 따라서 디스크 크기 안 주는 게 안전.
gcloud compute instance-templates create st8-ex-template \
    --region=asia-southeast3 \
    --machine-type=n4-standard-2 \
    --network-interface=subnet=st8-ex-public-subnet \
    --image-family=st8-ex-board-img-group \
    --image-project=named-foundry-486921-r5 \
    --tags=web-server,was-server,ssh-server \
    --labels=username=st8,classname=msp06 \
    --quiet
# 원래는 --no-address 위에 들어가야 하지만, 이번 실습에선 public으로 진행

# ------------------------------
# 관리형 인스턴스 그룹(MIG) 생성
# gcloud compute instance-groups create st8-ex-mig \
#     --base-instance-name=인스턴스에 부여할 이름 \
#     --template=사용할 템플릿 이름 \
#     --size=인스턴스 개수 \
#     --zone=asia-southeast3-a \
#     --labels=username=st8,classname=msp06 \
#     --quiet
# labels 속성을 지원하지 않음 => MIG 생성 시에는 labels 속성을 제거
gcloud compute instance-groups managed create st8-ex-mig \
    --base-instance-name=st8-ex-mig-vm \
    --template=st8-ex-template \
    --size=1 \
    --region=asia-southeast3 \
    --quiet


# ------------------------------
# 오토 스케일 설정
# set-autoscaling 뒤에 사용할 MIG 이름(st8-ex-mig)이 들어가야 함.
# gcloud compute instance-groups managed set-autoscaling st8-ex-mig \
#     --max-num-replicas=2 \
#     --min-num-replicas=1 \
#     --target-cpu-utilization=0.6 \
#     --cool-down-period=60 \
#     --zone=asia-southeast3-a \
#     --quiet
gcloud compute instance-groups managed set-autoscaling st8-ex-mig \
    --max-num-replicas=2 \
    --min-num-replicas=1 \
    --target-cpu-utilization=0.6 \
    --cool-down-period=60 \
    --region=asia-southeast3 \
    --quiet

#