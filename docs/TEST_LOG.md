# 테스트 및 검증 로그 (TEST_LOG)

## 1. 검증 요약 매트릭스

| 검증 항목 | 검증 대상 / 명령 | 기대 결과 | 실제 결과 | 판정 |
| :--- | :--- | :--- | :--- | :---: |
| Terraform 설치 | `terraform version` | v1.5.0 이상 출력 | `Terraform v1.17.0` | **PASS** |
| Docker 연결성 | `docker ps` | 러닝 컨테이너 목록 확인 | 정상 조회 (데몬 연결 확인) | **PASS** |
| HCL 문법 유효성 | `terraform validate` | Success 메시지 | `Success! The configuration is valid.` | **PASS** |
| 최초 프로비저닝 | `terraform apply` | 2개 리소스 추가 (이미지, 컨테이너) | `Apply complete! Resources: 2 added` | **PASS** |
| Nginx 웹 서비스 | `curl -i http://localhost:8090/` | HTTP 200 OK | `HTTP/1.1 200 OK`, Nginx Welcome | **PASS** |
| 외부 강제 삭제 | `docker rm -f terraform-drift-web` | 컨테이너 제거 | 컨테이너 목록에서 삭제 확인 | **PASS** |
| 드리프트 감지 | `terraform plan` | 삭제 감지 및 1 to add | `Objects have changed outside of Terraform` 감지 | **PASS** |
| 인프라 복구 | `terraform apply drift.tfplan` | 1 added, 새 컨테이너 생성 | `Creation complete after 23s`, `1 added` | **PASS** |
| 식별자 변경 검증 | `diff container-before.txt container-after.txt` | ID 불일치 (재생성 입증) | Before: `0314e...`, After: `ac99b...` | **PASS** |
| 복구 후 서비스 | `curl http://localhost:8090/` | HTTP 200 OK | HTTP 응답 코드 `200` 수신 | **PASS** |
| 최종 구성 일치 | `terraform plan -detailed-exitcode` | 변경 사항 없음 (코드 0) | `No changes. Your infrastructure matches` | **PASS** |

## 2. 미검증 항목
- AWS/GCP 등 실제 퍼블릭 클라우드 원격 리소스 드리프트 감지 (로컬 Docker 프로바이더 PoC 범위이므로 제외)
- 원격 S3 Backend 연동 및 DynamoDB State Locking (단일 로컬 State 환경으로 진행)

## 3. 원본 증적 로그 파일
- 드리프트 감지 로그: `docs/drift-plan.log`
- 복구 실행 로그: `docs/recovery.log`
- 삭제 전 컨테이너 ID: `docs/container-before.txt` (`0314e8796ccacde0c9508c6dd461ed411a7a28e17521225b17bed3be227304ac`)
- 복구 후 컨테이너 ID: `docs/container-after.txt` (`ac99b27a618ce8b8561660d3bbf44c247942c073928f70c10e2c359dd33bf474`)
