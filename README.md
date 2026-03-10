# todaybread-front(Flutter)
> **Flutter를 이용한 프론트엔드 레포지토리입니다.**

---

## 🛠 Tech Stack

### Framework & Environment
| Category | Stack | Version |
| :--- | :--- | :--- |
| **Framework** | ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=Flutter&logoColor=white) | 3.38.0 |
| **Language** | ![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=Dart&logoColor=white) | Latest |
| **IDE** | ![Xcode](https://img.shields.io/badge/Xcode-147EFB?style=flat-square&logo=Xcode&logoColor=white) / ![Android Studio](https://img.shields.io/badge/Android%20Studio-3DDC84?style=flat-square&logo=AndroidStudio&logoColor=white) | - |

### Platform Specification
| Platform | Target SDK / Version | Minimum SDK / Version |
| :--- | :--- | :--- |
| **Android** | API 35 (Android 15) 이상 | API 26 (8.0) or 28 (9.0) |
| **iOS** | iOS 26 SDK (Xcode 26 필수) | iOS 15.0 or 16.0 이상 |

---

## 📦 Libraries
- [ ] 상태 관리 (미정)
- [ ] 네트워크 (미정)
- [ ] 로컬 DB (미정)

---

## 📁 폴더 구조
```
lib/
├── models/        # 데이터 구조 정의 (서버 JSON ↔ Dart 객체 변환)
├── providers/     # 상태 관리 (여러 화면에서 공유되는 데이터)
├── screens/       # 화면(페이지) 단위 UI
├── services/      # REST API 통신 전담
├── utils/         # 공통 상수, 테마, 유틸 함수
├── widgets/       # 재사용 가능한 UI 컴포넌트
└── main.dart      # 앱 진입점
```
---

## 📌 폴더별 역할

| 폴더 | 역할 |
|------|------|
| models/ | 서버에서 받은 JSON 데이터를 앱에서 사용할 수 있는 형태(Dart 객체)로 변환하는 곳 |
| providers/ | 앱 전체에서 공유되는 상태(로그인 정보, 장바구니 등)를 저장하고 관리하는 곳 |
| screens/ | 사용자에게 실제로 보여지는 화면(UI 페이지)을 구성하는 곳 |
| services/ | 서버와 통신하며 데이터를 요청하거나 보내는(API 호출) 로직을 담당하는 곳 |
| utils/ | 여러 곳에서 반복 사용되는 공통 코드(상수, 테마, 함수 등)를 모아둔 곳 |
| widgets/ | 여러 화면에서 재사용할 수 있는 UI 조각(버튼, 카드 등)을 모아둔 곳 |


---

## 🌿 Branch Strategy
- **main**: 프로덕션 출시 브랜치
- **develop**: 개발 메인 브랜치
- **feature/기능명**: 신규 기능 개발 (ex. `feature/login`, `feature/mainpage`)
- **fix/버그명**: 버그 수정

---

## 📝 Convention

### Commit Message 규칙

- `feat`: 새로운 기능 추가
- `fix`: 버그 수정
- `docs`: 문서 수정
- `style`: 코드 포맷팅 (로직 변경 없음)
- `refactor`: 코드 리팩토링
- `chore`: 빌드 업무, 패키지 매니저 설정 등

## 📝 Code Convention

### 1. Naming Convention (명명 규칙)

| 대상 | 규칙 | 예시 | 설명 |
| :--- | :--- | :--- | :--- |
| **Classes / Enums** | `UpperCamelCase` | `class UserProfile`, `enum Status` | 모든 단어의 시작을 대문자로 작성합니다. |
| **Variables / Methods** | `lowerCamelCase` | `String userName`, `void fetchData()` | 첫 단어는 소문자, 이후 단어는 대문자로 시작합니다. |
| **Files / Folders** | `lower_snake_case` | `login_page.dart`, `models/` | 소문자만 사용하며 단어 사이는 `_`로 연결합니다. |

---

# Pull Request

## 요약
- 이 PR에서 변경한 내용을 1~3줄로 작성해주세요.

## 배경/목적
- 왜 이 변경이 필요한지 작성해주세요.

## PR 유형
- [ ] `feature` 새 기능 추가
- [ ] `fix` 버그 수정
- [ ] `refactor` 리팩터링(동작 변경 없음)
- [ ] `chore` 빌드/설정/의존성 변경
- [ ] `docs` 문서 변경

## 변경 내용
- 핵심 변경 사항을 핵심이 드러나게 정리해주세요.

## 영향 범위

### 화면(UI) 영향
- [ ] 있음
- [ ] 없음
- 설명: 화면 레이아웃/컴포넌트/디자인 변경 영향입니다. (예: `login_screen2`, `onboarding_screen`)
- 상세: (있으면 작성, 없으면 `없음`)

### 상태관리 영향
- [ ] 있음
- [ ] 없음
- 설명: Provider/상태 흐름 변경 영향입니다. (예: `AuthProvider`, loading/error state)
- 상세: (있으면 작성, 없으면 `없음`)

### API 연동 영향
- [ ] 있음
- [ ] 없음
- 설명: API 요청/응답 스펙, 에러 처리, endpoint 사용 변경 영향입니다.
- 상세: (있으면 작성, 없으면 `없음`)

### 에셋/리소스 영향
- [ ] 있음
- [ ] 없음
- 설명: 이미지/폰트/로티/컬러/텍스트 스타일 등 리소스 변경 영향입니다.
- 상세: (있으면 작성, 없으면 `없음`)

### Breaking change 여부
- [ ] 있음
- [ ] 없음
- 설명: 기존 앱 동작/사용자 플로우가 업데이트 없이 깨지는 변경입니다.
- 상세(필요 시 마이그레이션/공지): (있으면 작성, 없으면 `없음`)

## 테스트 방법/결과
- [ ] `flutter analyze` 통과
- [ ] `flutter test` 통과
- [ ] 주요 시나리오 수동 확인 (Android)
- [ ] 주요 시나리오 수동 확인 (iOS)
- 테스트/검증 결과:

## 리뷰 포인트
- 리뷰어가 집중해서 봐야 할 부분을 작성해주세요.

## 비고
- 스크린샷, 화면 녹화, 추가 참고사항이 있으면 작성해주세요.

---
## 예시 (실제 PR시 삭제 부탁드립니다.)
```markdown
## 예시 (실제 PR 작성 시 삭제)

## 요약
- 회원가입 화면 유효성 검사 및 에러 메시지 처리를 추가했습니다.

## 배경/목적
- 입력값 누락 상태에서 버튼이 눌려도 사용자 피드백이 없어 UX가 좋지 않았습니다.
- 서버 에러 메시지를 그대로 노출해 실패 원인을 명확히 전달하려고 변경했습니다.

## PR 유형
- [x] `feature` 새 기능 추가
- [x] `fix` 버그 수정
- [ ] `refactor` 리팩터링(동작 변경 없음)
- [ ] `chore` 빌드/설정/의존성 변경
- [ ] `docs` 문서 변경

## 변경 내용
- `LoginScreen1`, `LoginScreen2` 입력값 검증 및 스낵바 메시지 처리
- 공통 `ApiException` 추가 및 `Dio` 인터셉터에서 서버 에러 파싱 적용
- 회원가입/중복확인 API 실패 시 서버 `message`를 그대로 노출

## 영향 범위

### 화면(UI) 영향
- [x] 있음
- [ ] 없음
- 상세: `login_screen1`, `login_screen2`

### 상태관리 영향
- [x] 있음
- [ ] 없음
- 상세: `AuthProvider`의 에러 메시지 처리 로직 변경

### API 연동 영향
- [x] 있음
- [ ] 없음
- 상세: 서버 `ErrorResponse(code, message)` 기준 에러 파싱 적용

### 에셋/리소스 영향
- [ ] 있음
- [x] 없음
- 상세: 없음

### Breaking change 여부
- [ ] 있음
- [x] 없음
- 상세: 없음

## 테스트 방법/결과
- [x] `flutter analyze` 통과
- [x] `flutter test` 통과
- [x] 주요 시나리오 수동 확인 (Android)
- [ ] 주요 시나리오 수동 확인 (iOS)
- 테스트/검증 결과: 빈 입력, 중복/실패 응답, 정상 응답 시나리오 확인

## 리뷰 포인트
- 에러 메시지 우선순위(서버 메시지 > 네트워크 메시지 > 기본 메시지)가 적절한지 확인 부탁드립니다.

## 비고
- UI 캡처는 추후 첨부 예정
```
