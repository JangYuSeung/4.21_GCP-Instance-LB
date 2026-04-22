#!/bin/bash
# create-vm.sh에서 startup-script로 사용하는 스크립트
# 인스턴스에 도커 및 도커 컴포즈 설치
# 핵심: 생성된 인스턴스에서 Github에 있는 docker-compose-gcp.yaml을 다운로드하여
#       docker compose로 실행.
# => Github 파일 위치: https://github.com/JangYuSeung/docker-network/tree/main/ex-board/docker-compose-gcp.yaml
# 참고: 해당 docker-compose-gcp.yaml은 도커허브의 reoyuza 레포에서 이미지를 pull하여 컨테이너 배포하는 구조
 
FLAG_FILE="/var/log/first-boot-done"

if [ -f "$FLAG_FILE" ]; then
    echo "이미 초기 설정이 완료되었습니다. 스크립트를 종료합니다."
    exit 0
fi

# 1. 패키지 업데이트 및 필요 도구 설치
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# 2. Docker 공식 GPG 키 및 저장소 추가
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# 3. Docker + Compose plugin 설치
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 4. 작업 디렉토리 생성
mkdir -p /app
cd /app

# 5. GitHub에서 GCP용 compose.yaml 다운로드
curl -o /app/docker-compose.yaml \
    https://raw.githubusercontent.com/JangYuSeung/docker-network/main/ex-board/docker-compose-gcp.yaml

# 6. .env 파일 생성
cat > /app/.env << 'EOF'
MYSQL_ROOT_PASSWORD=ian1234!
MYSQL_DATABASE=iandb
MYSQL_USER=ian
MYSQL_PASSWORD=ian1234!
MYSQL_TZ=Asia/Seoul
DB_HOST=mysql-primary-container
DB_USER=ian
DB_PASSWORD=ian1234!
DB_NAME=iandb
EOF

# 7. docker compose 실행
# --pull always 옵션으로 항상 최신 이미지로 실행하도록 변경
docker compose -f /app/docker-compose.yaml --env-file /app/.env up -d --pull always

# 8. 완료 플래그
touch $FLAG_FILE
echo "초기 설정 완료"