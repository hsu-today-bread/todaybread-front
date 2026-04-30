# 프런트 API 미연동 현황

기준

- API 문서: `docs/API.md`
- 프런트 코드: `lib/**`
- 작성일: `2026-04-30`

이 문서는 `docs/API.md`에 정의된 API 중 현재 프런트에 아직 붙지 않았거나, 클라이언트 레이어는 있으나 화면까지 연결되지 않은 항목을 정리한 문서입니다.

`리뷰`, `매출`처럼 현재 화면에는 있지만 `docs/API.md`에 스펙이 없는 기능은 마지막 참고 섹션으로 분리했습니다.

## 요약

- 연동 완료: 인증, 회원가입/로그인/계정복구, 사장님 등록, 근처 빵/매장 조회, 매장 상세, 키워드, 단골 가게, 장바구니 조회/수정/삭제, 사장님 매장 등록/수정, 사장님 메뉴 조회/등록
- 부분 연동: 장바구니 담기, 찜목록
- 미연동: 주문 전체, 결제 전체, 사장님 메뉴 수정/재고/삭제, 일반 유저용 가게별 메뉴 단독 조회 API

## 문서 기준 미연동 API

| 구분 | API | 상태 | 근거 | 비고 |
|------|-----|------|------|------|
| Bread | `GET /api/bread/{storeId}` | 미구현 | `lib/services/bread/bread_api.dart`에 없음 | 현재 가게 메뉴는 `GET /api/store/{storeId}` 응답의 `breads`로 사용 중 |
| Bread Boss | `PUT /api/boss/bread/{breadId}` | 미구현 | `lib/services/bread/bread_api.dart`, `lib/services/bread/bread_service.dart`, `lib/providers/bread/bread_provider.dart`에 메서드 없음 | 사장님 메뉴 수정 동선 없음 |
| Bread Boss | `PATCH /api/boss/bread/{breadId}/stock` | 미구현 | 동일 | 재고 변경/품절 처리 동선 없음 |
| Bread Boss | `DELETE /api/boss/bread/{breadId}` | 미구현 | 동일 | 메뉴 삭제 동선 없음 |
| Wishlist | `GET /api/wishlist` | 미연동 | `lib/screens/wish/wish_screen.dart:21-22` | 현재는 키워드 API와 단골 가게 API를 각각 호출 |
| Order | `POST /api/orders/cart` | 미구현 | `lib/services` 하위에 `order_api.dart`, `order_service.dart` 없음 | `Idempotency-Key` 처리도 없음 |
| Order | `POST /api/orders/direct` | 미구현 | 동일 | 바로 구매 흐름이 UI-only 상태 |
| Order | `POST /api/orders/{orderId}/cancel` | 미구현 | 동일 | 주문 취소 화면/서비스 없음 |
| Order | `GET /api/orders?page=&size=` | 미구현 | 동일 | 마이페이지 주문내역, 사장님 주문내역 모두 실데이터 미사용 |
| Order | `GET /api/orders/{orderId}` | 미구현 | 동일 | 주문 상세 화면/서비스 없음 |
| Payment | `POST /api/payments` | 미구현 | `lib/services` 하위에 `payment_api.dart`, `payment_service.dart` 없음 | `Idempotency-Key` 처리도 없음 |

## API는 있으나 화면 연결이 안 된 항목

| API | 상태 | 근거 | 영향 |
|-----|------|------|------|
| `POST /api/cart` | 부분 연동 | `lib/services/cart/cart_service.dart:17`에는 `addItem()`이 있지만 호출처가 없음 | 상품 상세에서 장바구니 담기가 실제 서버 호출로 이어지지 않음 |
| `POST /api/cart` | 화면 미연동 | `lib/screens/bread/bread_detail_screen.dart:371` | "장바구니 기능은 연결 예정입니다." 스낵바만 표시 |
| `POST /api/cart` | 화면 미연동 | `lib/screens/store/store_detail_screen.dart:98-100` | 상단 카트 버튼이 장바구니 화면으로 이동하지 않음 |
| `GET /api/wishlist` | 우회 사용 중 | `lib/screens/wish/wish_screen.dart:21-22` | 통합 조회 대신 `GET /api/keywords`, `GET /api/favourite-stores`를 별도 호출 |

## 화면 기준으로 바로 보이는 미연동 상태

### 1. 구매하기는 서버 주문/결제로 이어지지 않음

- `lib/screens/cart/cart_screen.dart:643-654`
  - 장바구니 아이템을 `PurchaseItem`으로 변환한 뒤 구매 화면만 엽니다.
- `lib/screens/bread/bread_detail_screen.dart:399-408`
  - 바로 구매도 동일하게 구매 화면만 엽니다.
- `lib/screens/order/purchase_screen.dart:231-256`
  - 결제 버튼이 각각 `"토스페이 결제는 연결 예정입니다."`, `"일반 결제는 연결 예정입니다."` 스낵바만 띄웁니다.

즉, 현재 구매 플로우는 `주문 생성 API -> 결제 API -> 주문내역 반영`으로 이어지지 않습니다.

### 2. 마이페이지 주문내역은 실제 주문 데이터와 연결되어 있지 않음

- `lib/screens/myPage/my_page_home_screen.dart:23`
  - `_reviewList`가 빈 배열로 고정돼 있습니다.
- `lib/screens/myPage/my_page_home_screen.dart:232`
  - 배열이 비어 있으면 항상 `"주문 내역이 없습니다"`를 보여줍니다.

즉, `GET /api/orders?page=&size=`가 없어서 마이페이지 주문내역은 현재 항상 비어 있습니다.

### 3. 사장님 주문내역도 목업 상태

- `lib/screens/boss/boss_order_history_screen.dart:23-27`
  - 검색 대상이 서버 응답이 아니라 `_dummyOrders`입니다.
- `lib/screens/boss/boss_order_history_screen.dart:249-252`
  - 픽업 확인도 `"추후 연결 예정"` 스낵바만 띄웁니다.
- `lib/screens/boss/boss_order_history_screen.dart:285-326`
  - 더미 주문 목록이 하드코딩돼 있습니다.

즉, 주문 조회/상태 변경 API가 프런트에 아직 없습니다.

### 4. 사장님 메뉴관리는 조회/등록까지만 됨

- `lib/services/bread/bread_api.dart:30-38`
  - 사장님 메뉴 API는 `GET /api/boss/bread`, `POST /api/boss/bread`만 구현돼 있습니다.
- `lib/screens/boss/boss_bread_management_screen.dart:49-156`
  - 목록 노출과 등록 화면 이동만 있고 수정/삭제/재고 변경 액션은 없습니다.

## 참고: API 문서 범위 밖이지만 현재 목업인 화면

아래 기능은 `docs/API.md`에 대응 스펙이 없어서 본문 집계에서는 제외했지만, 현재 화면은 실데이터 연동 상태가 아닙니다.

- `lib/screens/store/store_detail_screen.dart:234-248`
  - 리뷰 프리뷰와 "모든 리뷰 보기"가 더미/미연동 상태
- `lib/screens/boss/boss_review_management_screen.dart:387`
  - 사장님 리뷰 관리가 더미 데이터 기준
- `lib/screens/boss/boss_sales_screen.dart:228`
  - 매출 화면이 더미 데이터 기준

## 우선순위 제안

1. `OrderApi` / `OrderService` / 주문 DTO 추가
2. `PaymentApi` / `PaymentService` 추가 및 `Idempotency-Key` 처리
3. 구매 화면에서 주문 생성 -> 결제 -> 성공 후 주문내역 재조회 흐름 연결
4. 마이페이지 주문내역, 사장님 주문내역을 `GET /api/orders` 계열로 연결
5. 상품 상세의 장바구니 담기를 `POST /api/cart`와 연결
6. 사장님 메뉴 수정/재고/삭제 API 추가
7. 필요하면 `GET /api/wishlist`로 찜목록 통합 조회로 단순화
