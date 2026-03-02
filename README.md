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

## 🖇 Pull Request Template

```markdown
## 📌 개요
- 작업 내용 요약

## 👩‍💻 작업 사항
- 상세 변경 내용 1
- 상세 변경 내용 2

## ✅ 체크리스트
- [ ] 컨벤션 준수 여부
