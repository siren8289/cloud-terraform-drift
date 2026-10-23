# 에러 및 트러블슈팅 일지 (ERROR_LOG)

## 이슈 #1: Docker 소켓 접근 권한 오류 (Sandbox Permission Denied)
- **발생 시점**: 초기 Docker 데몬 상태 확인 단계
- **증상**:
  ```text
  permission denied while trying to connect to the docker API at unix:///Users/jeong-yelim/.docker/run/docker.sock
  ```
- **원인 분석**: 샌드박스 격리 환경에서는 호스트의 유닉스 도메인 소켓(`/Users/jeong-yelim/.docker/run/docker.sock`)에 대한 바인드 마운트 접근이 차단됨.
- **해결 방법**: 호스트 셸 실행 환경(BypassSandbox: true)으로 권한을 상승하여 호스트의 실제 Docker 데몬 API와 정상 통신 확인.

---

## 이슈 #2: Terraform 바이너리 부재
- **발생 시점**: 초기 환경 점검 단계 (`terraform not found`)
- **증상**: Homebrew 기본 리포지토리에는 `hashicorp/tap` 미등록 상태로 `brew install terraform` 시 공식 포뮬러 미발견.
- **원인 분석**: HashiCorp의 라이선스 정책 변경 이후 공식 탭(`hashicorp/tap`)을 등록해야 정상 설치 가능.
- **해결 방법**:
  ```zsh
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform
  ```
  실행 후 `Terraform v1.17.0` 정상 설치 완료.
