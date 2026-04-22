#!/bin/bash

# 1. 관리형 인스턴스 그룹(MIG) 먼저 삭제 (템플릿이 MIG에 참조되므로 MIG 먼저)
gcloud compute instance-groups managed delete st8-ex-mig --region=asia-southeast3 --quiet
# 2. 인스턴스 템플릿 삭제 (MIG 삭제 후 가능)
gcloud compute instance-templates delete st8-ex-template --quiet