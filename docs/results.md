# Terraform Drift Detection PoC 검증 보고서

## 1. 실험 목적
Terraform 외부(Docker CLI)에서 발생한 인프라 무단 변경(삭제)을 Terraform이 상태 파일(`terraform.tfstate`)과 실제 리소스 비교를 통해 감지(Drift Detection)하고, 계획(`plan`)과 적용(`apply`)을 통해 원하는 상태(Desired State)로 복구(Recovery)할 수 있음을 검증한다.

## 2. 기술 스택 및 환경
- **OS**: macOS (darwin_arm64, Apple Silicon)
- **IaC Tool**: Terraform v1.17.0
- **Provider**: kreuzwerker/docker v4.6.0
- **Runtime**: Docker Engine 29.6.1 (Docker Desktop)
- **Target Resource**: Nginx 1.27-alpine (`terraform-drift-web`, 포트 8090:80)

## 3. 검증 단계 및 실행 결과

### Step 1. 인프라 최초 배포
- 실행 명령: `terraform apply -auto-approve`
- 결과:
  - 이미지 생성: `nginx:1.27-alpine`
  - 컨테이너 생성: `0314e8796ccacde0c9508c6dd461ed411a7a28e17521225b17bed3be227304ac`
  - 상태: `Apply complete! Resources: 2 added, 0 changed, 0 destroyed.`
  - HTTP 200 검증: `curl -i http://localhost:8090/` (HTTP/1.1 200 OK)

### Step 2. 임의 삭제를 통한 드리프트(Drift) 유발
- 실행 명령: `docker rm -f terraform-drift-web`
- 결과: 컨테이너 강제 삭제 완료, `docker ps -a` 상에서 컨테이너 부재 확인

### Step 3. 드리프트 감지 (Drift Detection)
- 실행 명령: `terraform plan -out=drift.tfplan -no-color`
- 결과 로그 (`docs/drift-plan.log`):
  ```text
  Note: Objects have changed outside of Terraform

  Terraform detected the following changes made outside of Terraform since the
  last "terraform apply" which may have affected this plan:

    # docker_container.web has been deleted
    - resource "docker_container" "web" {
        - id = "0314e8796ccacde0c9508c6dd461ed411a7a28e17521225b17bed3be227304ac" -> null
        ...
      }

  Plan: 1 to add, 0 to change, 0 to destroy.
  ```

### Step 4. 자동 복구 및 상태 일치 검증
- 실행 명령: `terraform apply -no-color drift.tfplan`
- 복구 결과 (`docs/recovery.log`):
  - `docker_container.web: Creation complete after 23s [id=ac99b27a618ce8b8561660d3bbf44c247942c073928f70c10e2c359dd33bf474]`
  - `Apply complete! Resources: 1 added, 0 changed, 0 destroyed.`
- 컨테이너 ID 비교 (`diff docs/container-before.txt docs/container-after.txt`):
  - Before: `0314e8796ccacde0c9508c6dd461ed411a7a28e17521225b17bed3be227304ac`
  - After: `ac99b27a618ce8b8561660d3bbf44c247942c073928f70c10e2c359dd33bf474`
  - 컨테이너가 새로 생성되었음을 완전히 입증함.
- HTTP 검증: `curl -s -o /dev/null -w '%{http_code}\n' http://localhost:8090/` -> `200`
- 최종 상태 검증: `terraform plan -detailed-exitcode -no-color`
  - `No changes. Your infrastructure matches the configuration.` (종료 코드 0)

## 4. 결론
Terraform은 코드로 선언한 의도 상태(Desired State)와 실제 인프라 상태(Actual State)의 괴리(Drift)를 정확하게 감지하였으며, 저장된 실행 계획을 통해 무중단에 준하는 복구를 성공적으로 완료하였다.
Kubernetes의 자동 자가 치유(Self-Healing Daemon)와 달리, Terraform은 Plan/Apply 파이프라인 트리거 시점에 상태를 동기화하는 선언적 IaC 엔진임을 확인하였다.
