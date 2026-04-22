#!/bin/bash

# 1. 비관리형 인스턴스 그룹 생성
gcloud compute instance-groups unmanaged create st8-ex-ig \
    --zone=asia-southeast3-a

# 2. VM 2개를 그룹에 등록 (이름으로 등록, 내부는 ID로 관리)
gcloud compute instance-groups unmanaged add-instances st8-ex-ig \
    --instances=st8-ex1-vm,st8-ex2-vm \
    --zone=asia-southeast3-a

# 3. 인스턴스 그룹에 포트 이름 정의
gcloud compute instance-groups unmanaged set-named-ports st8-ex-ig \
    --named-ports http:80 \
    --zone=asia-southeast3-a

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
    --instance-group=st8-ex-ig \
    --instance-group-zone=asia-southeast3-a \
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