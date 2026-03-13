# Auto-Trade Pro

자동 트레이딩 시스템 - Poly Market API 기반

## 📋 프로젝트 개요

Week 1 서버 환경 구축 및 Poly Market API 연동 테스트 프로젝트

### 주요 기능
- Poly Market API 연동
- Docker 컨테이너화
- AWS EC2 배포 지원

## 🚀 빠른 시작

### 로컬 개발 환경

```bash
# 1. 저장소 클론
git clone https://github.com/dataofmen/auto-trade-pro.git
cd auto-trade-pro

# 2. 가상환경 생성 및 활성화
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# venv\Scripts\activate  # Windows

# 3. 의존성 설치
pip install -r requirements.txt

# 4. 환경 변수 설정
cp .env.example .env
# .env 파일을 편집하여 API 키 등을 설정

# 5. API 연동 테스트
python poly_market_api.py
```

### Docker 실행

```bash
# 이미지 빌드
docker build -t auto-trade-pro .

# 컨테이너 실행
docker run -d --name auto-trade-pro --env-file .env auto-trade-pro

# 또는 docker-compose 사용
docker-compose up -d
```

### AWS EC2 배포 (Terraform)

```bash
# 1. Terraform 초기화
terraform init

# 2. 인프라 계획 확인
terraform plan

# 3. 인프라 생성
terraform apply

# 4. 출력된 IP로 접속
# terraform output instance_public_ip
```

## 📁 프로젝트 구조

```
auto-trade-pro/
├── main.py                 # 메인 애플리케이션 진입점
├── poly_market_api.py      # Poly Market API 클라이언트
├── Dockerfile              # Docker 이미지 설정
├── docker-compose.yml      # Docker Compose 설정
├── requirements.txt        # Python 의존성
├── main.tf                 # Terraform AWS 인프라 정의
├── terraform.tfvars        # Terraform 변수 설정
├── .env.example            # 환경 변수 템플릿
├── data/                   # 데이터 저장 디렉토리
└── logs/                   # 로그 저장 디렉토리
```

## 🔧 설정

### 환경 변수

| 변수명 | 설명 | 필수 |
|--------|------|------|
| `POLY_MARKET_API_KEY` | Poly Market API 키 | 예 |
| `AWS_ACCESS_KEY_ID` | AWS 액세스 키 | 배포 시 |
| `AWS_SECRET_ACCESS_KEY` | AWS 시크릿 키 | 배포 시 |
| `AWS_REGION` | AWS 리전 | 아니오 (기본값: ap-northeast-2) |
| `LOG_LEVEL` | 로그 레벨 | 아니오 (기본값: INFO) |

## 📊 Poly Market API

### 지원하는 기능

- **마켓 조회**: 전체 마켓 목록, 특정 마켓 정보
- **주문서**: 매수/매도 호가 조회
- **거래 내역**: 마켓별 거래 내역
- **포지션**: 지갑별 포지션 조회
- **주문**: 주문 생성 및 취소

### API 사용 예시

```python
from poly_market_api import PolyMarketAPI

# API 클라이언트 초기화
api = PolyMarketAPI(api_key="your_api_key")

# 마켓 목록 조회
markets = api.get_markets(limit=10)

# 특정 마켓 정보 조회
market_info = api.get_market_by_id("market_id")

# 주문서 조회
orderbook = api.get_orderbook("market_id")
```

## 🧪 테스트

```bash
# API 연동 테스트
python poly_market_api.py

# pytest를 사용한 단위 테스트 (향후 추가)
pytest tests/
```

## 📅 개발 일정

### Week 1 (완료)
- ✅ GitHub repo 생성
- ✅ Docker 환경 구성
- ✅ AWS EC2 Terraform 스크립트
- ✅ Poly Market API 연동 테스트 코드

### Week 2 (예정)
- 트레이딩 전략 구현
- 백테스팅 시스템
- 리스크 관리 모듈

## 🔐 보안

- API 키는 `.env` 파일에 저장 (`.gitignore`에 추가됨)
- AWS 자격 증명은 Terraform 변수 또는 환경 변수로 관리
- 프로덕션 배포 시 보안 그룹 규칙 검토 필요

## 📝 라이선스

MIT License

## 👤 관리자

- **Project Owner**: 혁민
- **Developer Agent**: Andrej 🧠