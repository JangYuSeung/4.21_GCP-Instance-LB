#!/bin/bash

# 1. 전달 규칙 삭제 (Forwarding Rule)
gcloud compute forwarding-rules delete st8-ex-http-rule --global --quiet

# 2. 전역 고정 IP 삭제
gcloud compute addresses delete st8-ex-lb-ip --global --quiet

# 3. 대상 HTTP 프록시 삭제
gcloud compute target-http-proxies delete st8-ex-http-proxy --quiet

# 4. URL 맵 삭제
gcloud compute url-maps delete st8-ex-url-map --quiet

# 5. 백엔드 서비스 삭제
gcloud compute backend-services delete st8-ex-backend --global --quiet

# 6. 헬스체크 삭제
gcloud compute health-checks delete st8-ex-hc --quiet

# 7. 관리형 인스턴스 그룹(MIG) 삭제
# (주의: 그룹을 삭제하면 생성된 VM 인스턴스들도 함께 삭제됩니다.)
gcloud compute instance-groups managed delete st8-ex-mig --region=asia-southeast3 --quiet

# 8. 인스턴스 템플릿 삭제
gcloud compute instance-templates delete st8-ex-template --quiet