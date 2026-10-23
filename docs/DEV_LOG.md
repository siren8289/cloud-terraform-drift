# 개발 작업 일지 (DEV_LOG)

## 작업 일자: 2026-10-23
## 작업명: PoC 02 — Terraform IaC & Drift Detection

### 1. 환경 구성
- Homebrew를 통한 HashiCorp 공식 Terraform 설치:
  ```zsh
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform
  ```
- 설치 버전 확인: `Terraform v1.17.0 (darwin_arm64)`
- Docker 데몬 및 컨테이너 런타임 정상 동작 확인: `Docker 29.6.1`

### 2. 코드베이스 구성
- `.gitignore`: `terraform.tfstate`, `.terraform/`, `*.tfplan` 등 보안 및 임시 파일 제외
- `main.tf`:
  - Terraform v1.5.0 이상 요구사항 명시
  - Provider: `kreuzwerker/docker` (v4.6.0)
  - Resources: `docker_image.nginx` (1.27-alpine), `docker_container.web` (포트 8090:80)
- `outputs.tf`:
  - `container_id`: 생성된 컨테이너 고유 식별자
  - `web_url`: 로컬 브라우저 접근 주소 (`http://localhost:8090`)

### 3. 작업 사이클 진행
1. **초기화 및 검증**:
   - `terraform init`: Docker Provider 플러그인 다운로드 및 `.terraform.lock.hcl` 잠금 파일 생성
   - `terraform fmt`: 코드 표준 스타일 정렬
   - `terraform validate`: 문법 및 리소스 속성 무결성 통과
2. **최초 프로비저닝**:
   - `terraform apply -auto-approve` 실행
   - Nginx alpine 이미지 다운로드 및 `terraform-drift-web` 컨테이너 생성 완료
3. **드리프트 유발 및 감지**:
   - `docker rm -f terraform-drift-web` 명령으로 Terraform 몰래 컨테이너 수동 삭제
   - `terraform plan -out=drift.tfplan`을 통해 `docker_container.web has been deleted` 감지 확인
4. **선언적 복구**:
   - `terraform apply drift.tfplan`을 통해 동일 스펙의 새 컨테이너 생성
   - HTTP 200 OK 응답 및 `terraform plan -detailed-exitcode` 무변경(코드 0) 확인
