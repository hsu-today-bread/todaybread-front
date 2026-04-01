# TodayBread 프론트 구조 및 백엔드 `main` 기준 갭 분석

작성일: 2026-04-01

## 1. 분석 범위

- 프론트엔드 기준: `todaybread-front` 현재 작업 트리 (`develop` 기반)
- 백엔드 기준: `../todaybread-backend/todaybread-backend` 의 `main`
- 참고: 프론트 `main` 브랜치는 거의 Flutter 초기 스캐폴드 수준이라, 실제 구현 현황 평가는 프론트 현재 작업 트리를 기준으로 보는 것이 맞다.

## 2. 한 줄 결론

현재 프론트는 `로그인/회원가입`, `토큰 재발급`, `마이페이지 프로필 수정`, `사업자 전환`, `사장님 매장 등록/수정`, `사장님 메뉴 조회/등록`까지는 실제 백엔드와 꽤 잘 맞춰져 있다. 반면 `키워드`, `계정 복구`, `사장님 메뉴 수정/삭제/품절`, `유저용 매장/빵 조회`, `주문/리뷰/매출`은 아직 빠져 있거나 로컬/더미 상태라서 다음 작업 우선순위가 분명하다.

## 3. 현재 프론트 구조 요약

현재 구조는 크게 아래 레이어로 나뉜다.

- `lib/models`: 백엔드 DTO 대응 모델
- `lib/services`: Dio/Retrofit 기반 API 통신
- `lib/providers`: 화면 상태 관리
- `lib/screens`: 화면 단위 UI
- `lib/services/local`: Hive 기반 로컬 저장
- `lib/widgets`, `lib/utils`: 공통 UI/상수

구조 자체는 "화면 -> provider -> service -> api/model" 흐름을 만들려는 방향이 보인다. 특히 인증, 매장, 메뉴 쪽은 이 흐름이 어느 정도 잡혀 있다.

## 4. 현재 구현되어 있는 부분

### 4.1 인증/사용자

구현 완료 또는 실제 연동된 부분:

- 회원가입: `/api/user/register`
- 로그인: `/api/user/login`
- 이메일/닉네임/전화번호 중복 확인:
  - `/api/user/exist/email`
  - `/api/user/exist/nickname`
  - `/api/user/exist/phone`
- 토큰 저장 및 세션 복구
- 토큰 재발급: `/api/auth/reissue`
- 로그아웃: `/api/auth/logout`
- 프로필 수정: `/api/user/update-profile`
- 사업자 전환: `/api/user/boss-approve`
- JWT role 기반으로 일반 사용자 / 사장님 탭 분기

관련 파일 예시:

- `lib/providers/login/login_provider.dart`
- `lib/providers/user/user_profile_provider.dart`
- `lib/services/auth/auth_service.dart`
- `lib/services/login/login_service.dart`
- `lib/services/user/user_service.dart`
- `lib/screens/login/login_screen.dart`
- `lib/screens/login/sign_up_screen.dart`
- `lib/screens/myPage/my_page_edit_screen.dart`

### 4.2 사장님 매장 관리

구현 완료 또는 실제 연동된 부분:

- 사장님 매장 등록 여부 조회: `/api/boss/store/status`
- 내 매장 정보 + 이미지 조회: `/api/boss/store`
- 매장 등록: `POST /api/boss/store`
- 매장 정보 수정: `PUT /api/boss/store`
- 매장 이미지 교체: `PUT /api/boss/store/images`
- 매장 등록 step UI
- 매장 수정 UI

관련 파일 예시:

- `lib/providers/store/store_provider.dart`
- `lib/providers/boss/boss_store_create_provider.dart`
- `lib/services/store/store_service.dart`
- `lib/screens/boss/boss_store_management_screen.dart`
- `lib/screens/boss/boss_store_create_screen.dart`
- `lib/screens/boss/boss_store_edit_screen.dart`

### 4.3 사장님 메뉴 관리

구현 완료 또는 실제 연동된 부분:

- 내 메뉴 목록 조회: `GET /api/boss/bread`
- 메뉴 등록: `POST /api/boss/bread`
- 메뉴 등록 step UI
- 등록 후 목록 재조회

관련 파일 예시:

- `lib/providers/bread/bread_provider.dart`
- `lib/providers/boss/boss_bread_create_provider.dart`
- `lib/services/bread/bread_service.dart`
- `lib/screens/boss/boss_bread_management_screen.dart`
- `lib/screens/boss/boss_bread_create_screen.dart`

### 4.4 화면은 있으나 서버 연동이 아닌 부분

- 홈 화면: 더미 상품 목록 기반
- 지도 화면: 현재 위치만 표시
- 키워드 관리: 서버가 아니라 Hive 로컬 저장 기반
- 마이페이지 주문 내역/리뷰: 빈 리스트 placeholder
- 사장님 매출/리뷰/주문 화면: 진입점 수준 또는 placeholder

## 5. 백엔드 `main` 기준으로 프론트에 추가해야 할 부분

아래는 "백엔드에는 이미 있는데 프론트에 아직 없거나 덜 붙은 것"이다.

| 영역 | 백엔드 상태 | 프론트 상태 | 추가 필요 작업 |
| --- | --- | --- | --- |
| 계정 복구 | `/api/user/find-email`, `/api/user/verify-identity`, `/api/user/reset-password` 존재 | `account_recovery_screen.dart` UI만 있고 TODO 상태 | 모델, 서비스, provider 추가 후 `AccountRecoveryScreen` 연동 |
| 키워드 | `/api/keywords/add`, `/api/keywords/get-keyword`, `/api/keywords/delete/{userKeywordId}` 존재 | 현재 `KeywordProvider` + Hive 로컬 저장만 사용 | 서버 DTO, API, 서비스, provider 재구성 후 서버 동기화로 전환 |
| 사장님 메뉴 수정 | `PUT /api/boss/bread/{breadId}` 존재 | 프론트 미구현 | 메뉴 수정 화면 및 서비스 메서드 추가 |
| 사장님 메뉴 품절/재고 변경 | `PATCH /api/boss/bread/{breadId}/stock` 존재 | 프론트 미구현 | 재고 수정 request 모델, 버튼/토글 UI, provider/service 추가 |
| 사장님 메뉴 삭제 | `DELETE /api/boss/bread/{breadId}` 존재 | 프론트 미구현 | 삭제 액션, confirm dialog, provider/service 추가 |
| 서버 상태 확인 | `GET /api/system/health` 존재 | 프론트 미사용 | 선택사항이지만 개발 환경 확인용으로 붙여두면 유용 |
| 유저용 빵 조회 | `GET /api/bread/{storeId}` 존재 | 프론트 미구현 | 매장 상세 또는 매장별 메뉴 화면 생기면 연결 필요 |

## 6. 현재 구조에서 실제로 추가하면 좋은 파일 단위 제안

지금 구조를 유지한다는 전제로 보면 아래 정도를 추가하는 게 가장 자연스럽다.

### 6.1 계정 복구 도메인 추가

추천 추가 파일:

- `lib/models/users/user_find_email_response.dart`
- `lib/models/users/verify_identity_response.dart`
- `lib/models/users/reset_password_request.dart`
- `lib/models/users/reset_password_response.dart`
- `lib/services/user_recovery/user_recovery_api.dart`
- `lib/services/user_recovery/user_recovery_service.dart`
- `lib/providers/user/user_recovery_provider.dart`

이유:

- 현재 `AccountRecoveryScreen`이 UI만 있고 실제 백엔드 API를 하나도 안 타고 있다.
- 계정 복구는 로그인 도메인과 묶여 보이지만 책임상 `login_service.dart`에 계속 몰아넣기보다 별도 도메인으로 나누는 게 낫다.

### 6.2 키워드 도메인 서버 연동으로 전환

추천 추가/수정 파일:

- `lib/models/keyword/keyword_create_request.dart`
- `lib/models/keyword/keyword_create_response.dart`
- `lib/models/keyword/keyword_response.dart`
- `lib/models/keyword/keyword_delete_response.dart`
- `lib/services/keyword/keyword_api.dart`
- `lib/services/keyword/keyword_service.dart`
- `lib/providers/keyword/keyword_provider.dart` 개편
- `lib/services/local/keyword_local_store.dart` 는 캐시 용도로만 축소하거나 제거

이유:

- 백엔드에 이미 키워드 API가 있는데 프론트가 로컬 상태만 보고 있어서 데이터 소스가 어긋나 있다.
- 지금처럼 로컬만 쓰면 로그인한 사용자별 동기화가 안 된다.
- 백엔드 응답에는 `userKeywordId`가 있으므로 삭제도 문자열 텍스트가 아니라 서버 ID 기준으로 관리해야 한다.

### 6.3 사장님 메뉴 관리 완성

추천 추가/수정 파일:

- `lib/models/bread/bread_stock_update_request.dart`
- `lib/services/bread/bread_api.dart` 확장
- `lib/services/bread/bread_service.dart` 확장
- `lib/providers/bread/bread_provider.dart` 확장
- `lib/screens/boss/boss_bread_edit_screen.dart`
- `lib/screens/boss/boss_bread_management_screen.dart` 액션 버튼 추가

이유:

- 지금 메뉴관리 화면은 조회와 등록만 되고, 실제 운영에서 필요한 수정/품절/삭제가 빠져 있다.
- 백엔드 `main` 기준으로 이미 가능한 기능이라 프론트 우선순위가 높다.

## 7. 백엔드도 아직 부족해서 프론트가 바로 붙기 어려운 부분

아래는 프론트가 아직 비어 있는 게 맞지만, 백엔드 `main`도 같이 비어 있거나 API 노출이 부족한 부분이다.

### 7.1 홈 화면 / 지도 화면

현재 백엔드 `StoreController`는 실제 유저용 조회 API가 아직 없다.

- `GET /api/store/nearby?lat=...&lng=...`
- `GET /api/store/{storeId}`

같은 API가 주석으로만 남아 있다.

즉, 아래 기능은 프론트만 먼저 완성하기 어렵다.

- 홈의 매장/상품 리스트
- 검색
- 거리/가격/할인 정렬
- 지도 위 매장 마커
- 매장 상세 진입

### 7.2 주문 / 리뷰 / 매출

프론트에는 주문내역, 리뷰관리, 매출관리 화면 진입점이 있지만 백엔드 `main`에는 해당 도메인 컨트롤러가 없다. 그래서 아래는 placeholder 상태가 맞다.

- 마이페이지 주문 내역
- 사장님 주문내역
- 사장님 리뷰관리
- 사장님 매출관리

### 7.3 찜(즐겨찾기) 매장

백엔드에는 `FavouriteStoreEntity`, `FavouriteStoreService`가 있지만 현재 공개된 컨트롤러 API는 없다. 즉 도메인 흔적은 있으나 프론트가 붙일 수 있는 엔드포인트까지는 아직 안 나온 상태다.

## 8. 구조상 아쉬운 점 / 고쳐야 할 것

### 8.1 화면 파일명이 의미를 설명하지 못함

현재:

- `boss_dashboard_screen.dart`
- `boss_store_management_screen.dart`
- `boss_bread_management_screen.dart`
- `my_page_home_screen.dart`
- `my_profile_screen.dart`
- `boss_account_verification_screen.dart`

이 방식은 지금은 버틸 수 있어도 화면 수가 늘면 바로 유지보수가 어려워진다.

권장:

- `boss_dashboard_screen.dart`
- `boss_store_management_screen.dart`
- `boss_bread_management_screen.dart`
- `my_page_home_screen.dart`
- `my_profile_screen.dart`
- `boss_approval_screen.dart`

### 8.2 레이어 규칙이 완전히 통일돼 있지 않음

좋은 흐름:

- `screen -> provider -> service -> api`

현재 어긋난 부분:

- 이전 구조의 `login_screen2.dart` 는 `LoginService`를 직접 호출했다.
- 반면 로그인 화면은 `AuthProvider`를 통해 간다.

이렇게 섞이면 화면마다 상태 처리 방식이 달라지고, 로딩/에러/재시도 정책이 일관되지 않게 된다.

권장:

- 인증/회원가입/계정복구는 전부 provider를 거치게 통일
- screen은 입력/렌더링만 하고 네트워크 호출은 provider/service에 집중

### 8.3 키워드 도메인이 로컬 저장에 갇혀 있음

지금은 `WishScreen`과 `KeywordProvider`가 Hive 만 본다. 하지만 백엔드에는 이미 키워드 API가 있다. 이 상태는 프론트 구조보다 "도메인 설계 불일치" 문제에 가깝다.

권장:

- 서버를 source of truth 로 사용
- 필요하면 로컬은 캐시로만 사용

### 8.4 환경 설정이 하드코딩되어 있음

현재 `DioClient`의 base URL 은 고정값이다.

- `http://10.0.2.2:8080`

이 값은 Android emulator 에서는 맞지만 iOS 시뮬레이터, 실기기, 배포 환경에서는 바로 깨질 수 있다.

권장:

- `--dart-define=API_BASE_URL=...`
- dev / stage / prod 분리
- Naver Map Client ID 처럼 API base URL 도 환경 주입 방식으로 맞추기

### 8.5 앱 시작점이 점점 비대해질 가능성이 큼

`main.dart` 에서 아래가 한 파일에 몰려 있다.

- 로컬 저장소 초기화
- 지도 SDK 초기화
- 전역 provider 등록
- 앱 theme/start screen

지금 규모에서는 괜찮지만 기능이 늘면 `bootstrap` 과 `app` 책임을 분리하는 편이 낫다.

권장:

- `app/app.dart`
- `app/bootstrap.dart`
- `app/providers.dart`

정도로 나누기

### 8.6 생성 산출물/중복 파일이 Git 에 포함되어 있음

확인된 파일:

- `.flutter-plugins-dependencies 2`
- `android/build/reports/problems/problems-report.html`
- `ios/Flutter/Flutter 2.podspec`
- `ios/Flutter/Generated 2.xcconfig`
- `ios/Flutter/flutter_export_environment 2.sh`

이런 파일은 협업 품질을 떨어뜨린다.

- merge noise 증가
- 실제 소스와 생성물 구분 어려움
- 환경마다 다른 파일이 들어올 가능성 큼

권장:

- `.gitignore` 정리
- suffix 가 붙은 중복 생성 파일 제거
- 빌드 산출물은 추적 제외

### 8.7 테스트가 거의 없음

현재 테스트는 앱 시작 시 `"오늘의 빵"` 텍스트가 보이는지 확인하는 수준이다.

추가가 필요한 테스트:

- `AuthService` 토큰 재발급 흐름
- `StoreProvider` 상태 전이
- `BreadProvider` 등록/조회 상태 전이
- `UserProfileProvider` 프로필 수정 반영

## 9. 우선순위 추천

### 1순위

- `AccountRecoveryScreen` 에 백엔드 계정 복구 API 연결
- 키워드 로컬 저장을 서버 연동 구조로 전환
- 사장님 메뉴 수정/삭제/품절 기능 완성

### 2순위

- 홈/지도 도메인용 provider/service 뼈대 먼저 정리
- 다만 실제 데이터 연동은 백엔드 유저용 store API 준비 후 진행

### 3순위

- 파일명 정리
- 환경 변수 주입 구조 정리
- 테스트 추가
- 생성 산출물 정리

## 10. 최종 판단

지금 구조는 "완전히 엉망"은 아니다. 인증, 프로필, 사장님 매장/메뉴 등록 흐름은 이미 계층이 어느 정도 잡혀 있고, 이 방향 자체는 유지해도 된다.

다만 아래 세 가지는 빨리 손보는 게 좋다.

1. 숫자형 화면 파일명 정리
2. 로컬 키워드 구조를 서버 기준으로 전환
3. 회원가입/계정복구/메뉴관리의 상태 흐름을 provider 중심으로 통일

이 세 가지를 먼저 정리하면 이후 홈/지도/주문/리뷰 도메인이 붙어도 구조가 덜 무너진다.
