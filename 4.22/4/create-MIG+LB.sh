#!/bin/bash
# MIG 생성 + 글로벌 HTTP 로드밸런서 구성을 한 번에 실행하는 스크립트
# =한 번에 ASG와 로드밸런서 구성
# 이전 create-lb.sh(비관리형 IG 버전)와 달리 MIG+글로벌 HTTP LB를 한번에 구성함

# 1-2. 인스턴스 템플릿과 MIG 생성
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

# 관리형 인스턴스 그룹(MIG) 생성
# labels 속성을 지원하지 않음 => MIG 생성 시에는 labels 속성을 제거
gcloud compute instance-groups managed create st8-ex-mig \
    --base-instance-name=st8-ex-mig-vm \
    --template=st8-ex-template \
    --size=1 \
    --region=asia-southeast3 \
    --quiet

# 오토 스케일 설정
gcloud compute instance-groups managed set-autoscaling st8-ex-mig \
    --max-num-replicas=2 \
    --min-num-replicas=1 \
    --target-cpu-utilization=0.6 \
    --cool-down-period=60 \
    --region=asia-southeast3 \
    --quiet

# 3. 인스턴스 그룹에 포트 이름 정의
gcloud compute instance-groups managed set-named-ports st8-ex-mig \
    --named-ports http:80 \
    --region=asia-southeast3

# 4. 헬스체크 생성
gcloud compute health-checks create http st8-ex-hc \
    --port 80 --global

# 5. 백엔드 서비스 생성
gcloud compute backend-services create st8-ex-backend \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=st8-ex-hc \
    --global

# 6. 백엔드 서비스에 인스턴스 그룹 연결
gcloud compute backend-services add-backend st8-ex-backend \
    --instance-group=st8-ex-mig \
    --instance-group-region=asia-southeast3 \
    --global

# 7. URL 맵 생성
gcloud compute url-maps create st8-ex-url-map \
    --default-service=st8-ex-backend

# 8. 대상 HTTP 프록시 생성
gcloud compute target-http-proxies create st8-ex-http-proxy \
    --url-map=st8-ex-url-map

# 9. 전역 고정 IP 할당
gcloud compute addresses create st8-ex-lb-ip --global

# 10. 전달 규칙 생성
gcloud compute forwarding-rules create st8-ex-http-rule \
    --address=st8-ex-lb-ip \
    --global \
    --target-http-proxy=st8-ex-http-proxy \
    --ports=80