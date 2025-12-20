# Sổ Thu Chi

**Purpose**: Tài liệu này là “luật chơi” (source of truth) cho dự án MVP app quản lý thu/chi (4 màn hình).  
**Scope MVP**: Local-only (offline by default), không sync cloud, không analytics.  
**Audience**: Flutter dev level Middle (~1 năm Flutter), mới dùng Spec Kit / SDD.  
**Version**: 1.0.0 | **Ratified**: 2025-12-18

---

## 1) Core Principles (MUST)

### 1.1 Spec-Driven Development
- **Spec trước, code sau**: Mọi thay đổi về yêu cầu phải cập nhật **spec.md** trước khi sửa code.
- **Không thêm ngoài scope**: AI/Dev không tự thêm tính năng (sync, login, chart phức tạp, notification…) nếu spec không yêu cầu.
- **Generated Integrity**: 
    - Không manual edit các file “spec artifacts” do Spec Kit tạo (spec/plan/tasks auto-gen). Constitution chỉ thay đổi qua amendment (PR + rationale).
    - Với code implement: Được phép viết tay logic, nhưng phải giữ đồng bộ với spec/plan; nếu chỉnh làm thay đổi contract/behavior thì update plan.md trước.
- **Consistency Check**: 
    - Plan.md nên định nghĩa public API / domain contracts / data model / navigation.
    - Code thực thi (Implementation) phải tuân thủ đầy đủ public contracts trong plan.md (entities, repository interfaces, use-cases, BLoC public events/states). 
    - UI widgets và helper/private methods không bắt buộc liệt kê trong plan.
- **Clarification Gate**: Khi gặp mơ hồ (vd: sửa/xóa transaction có hay không? category có default không?), bắt buộc cập nhật spec.md (Assumptions/Decisions) trước khi implement.
- **AC-Driven Verification**: Mỗi acceptance criteria quan trọng phải có cách verify rõ (unit/widget/manual checklist) và được track trong tasks.md.
- **Change control (Spec → Plan → Tasks)**:
    - Change business behavior → update spec.md
    - Change architecture/contract → update plan.md
    - Change implementation steps → update tasks.md

- **Artifacts bắt buộc** (commit vào repo):
  - `constitution.md`: project rules
  - `spec.md` (what/why + acceptance criteria)
  - `plan.md` (how + kiến trúc + data model)
  - `tasks.md` (task breakdown + DoD)

### 1.2 Maintainability over Cleverness
- **KISS (Keep It Simple, Stupid)**: Ưu tiên code dễ đọc, dễ bảo trì hơn là “kỹ thuật cao”. Một đoạn code "ngu ngơ" mà chạy đúng Spec tốt hơn một đoạn code "ảo diệu" mà khó test.
- **Explicit over Implicit**: Luồng dữ liệu và state phải nhìn là hiểu (events → states / input → output). Tránh “ngầm hiểu”. 
- **No Magic**: Tránh giải pháp khó đọc (ví dụ: lạm dụng generics quá sâu, dynamic types, reflection). Codegen chuẩn (freezed/json_serializable/build_runner) thì được phép. Không giấu logic quan trọng trong extension/utility “thần thánh”.
- **One Obvious Way**: Một pattern dùng xuyên suốt dự án (cùng style đặt tên, cùng style state management, cùng cách map model↔entity). Nếu đổi pattern phải cập nhật `plan.md` (Decision) trước.
- **Immutable State**: State (BLoC/Cubit) và Domain entities/value objects nên bất biến; mọi update tạo instance mới (copyWith/new). Không mutate state object sau khi emit.
- **Logic Isolation**: Business rules & use-cases nằm ở Domain. Presentation chỉ orchestration UI (thu input → gọi use-case → render state), không chứa quyết định nghiệp vụ.


### 1.3 Data Integrity & Local-Only
- **Offline-only**: MVP không có remote. Business logic thao tác dữ liệu qua Repository (local datasource), không gọi network.
- **Integer Currency**: Tất cả số tiền (`amount`) phải dùng kiểu `int`. Không dùng `double` để tránh sai số tài chính.
- **Reactive Single Source of Truth SSOT**: UI phải phản ứng (react) theo thay đổi của Database (thông qua Stream/ValueListenable). Luồng chuẩn: Action → Write DB → DB emits change → UI rebuild. Không cập nhật UI thủ công từ biến tạm.

---

## 2) Product Scope (MVP)

> Scope này là “hợp đồng sản phẩm” cho MVP.  
> Mọi thứ không nằm trong MUST/SHOULD mặc định là OUT OF SCOPE (trừ khi amend).

---

### 2.1 MUST (Bắt buộc có trong MVP)

#### A) App Navigation
- Có **2 tab** ở bottom bar:
  - **Sổ giao dịch** (Home)
  - **Cài đặt** (Settings)
- Có nút **( + )** ở giữa bottom bar để mở màn **Giao dịch mới** (Add Transaction).

#### B) Home (Sổ giao dịch)
- Header chào user dạng text (ví dụ: “Hi, DaoLQ”) + avatar (có thể static).
- Danh sách giao dịch:
  - **Group theo ngày** (header ngày + thứ như mock).
  - Sort theo `createdAt` giảm dần (mới nhất lên trên).
  - Mỗi item hiển thị tối thiểu:
    - icon category
    - `transactionName` (dòng 1)
    - `categoryName` (dòng 2, bên trái)
    - `amount` (bên phải, có dấu +/- theo type)
- Empty state khi chưa có giao dịch.
- Tap transaction item: show snackbar "No-op" (không mở detail screen)

#### C) Settings (Cài đặt)
- Màn settings có 2 lựa chọn:
  - **Ngôn ngữ**
  - **Quản lý thể loại (category)**

#### D) Language (Ngôn ngữ)
- Cho chọn 2 ngôn ngữ:
  - **English (UK)**
  - **Việt Nam**
- Lưu `languageCode` local; đổi ngôn ngữ có hiệu lực ngay và giữ sau khi restart app.

#### E) Manage Categories (Quản lý thể loại)
- Có 2 tab:
  - **Chi tiêu**
  - **Thu nhập**
- Category có tối thiểu: `id`, `name`, `type (expense|income)`, `iconKey`.
- Hiển thị category theo dạng **grid** (icon + label).
- Có tile/nút **( + )** để tạo mới category.
- **Seed categories mặc định** cho 2 tab khi cài app lần đầu:
  - chỉ seed nếu DB chưa có category
  - không tạo trùng lặp khi mở app lại
- Add new category (dialog):
  - Field **Tên nhóm phân loại*** — required - Input text ngắn tối đa 20 kí tự.
  - Hiển thị **Icon** - dùng `iconKey` từ danh sách preset
  - Actions: **HỦY / TẠO**
- Category tạo xong phải dùng được ngay ở modal chọn category của Add Transaction.

#### F) Add Transaction (Giao dịch mới)
- Mở từ nút **( + )**.
- Form gồm các field (đúng theo ảnh):
  - **Chọn nhóm giao dịch (category)**(*) — required - Modal chọn Category.
  - **Tên giao dịch**(*) — required - Input text ngắn tối đa 50 kí tự.
  - **Số tiền giao dịch**(*) — required, `int`, `> 0` - require input Number
  - **Đến hạn** — optional date - Date picker (mặc định ngày hiện tại)
  - **Ghi chú** — optional text - Text field vùng nhập liệu multiline.
- Actions:
  - **HỦY**: đóng màn hình, không ghi DB
  - **TẠO**: ghi DB
- Sau khi “TẠO” thành công: quay lại Home và cập nhật list theo **Reactive Single Source of Truth (SSOT)**
  - Flow: Action → Write DB → DB emits → UI rebuild

---

### 2.2 SHOULD (Nên có nếu kịp, không bắt buộc)

- **Hiển thị trạng thái selected** cho language (tick/highlight).
- **Validate nâng cao**:
  - chặn tên category trùng trong cùng tab (Chi tiêu hoặc Thu nhập)
  - chặn ký tự không hợp lệ ở amount
- UI polish:
  - format tiền theo locale (VI/EN) nhưng storage vẫn `int`
  - loading/saving state khi nhấn “TẠO”
- Due date:
  - chọn date picker + lưu `dueDate` (optional) và hiển thị lại (nếu bạn muốn dùng thật)

---

### 2.3 OUT OF SCOPE (Không làm trong MVP)

- Edit/Delete transaction
- Edit/Delete category (menu 3 chấm ở màn categories nếu có: để OUT OF SCOPE ở MVP)
- Sync/backup cloud, multi-device
- Login/user profile thật
- Export/Import CSV/Excel, share report
- Notification, OCR scan hoá đơn
- Đa tiền tệ, tỷ giá, số thập phân

---

### 2.4 Decisions & Assumptions (BẮT BUỘC ghi vào spec.md trước khi implement)

1) **Due date**:
- chỉ lưu cho có, hay có yêu cầu dùng (filter/sort/nhắc)?

2) **Critical Decisions**
- Logic phân loại: Transaction.type luôn bằng Category.type của category được chọn.
- Date handling: date dùng để định danh nhóm hiển thị và sắp xếp ở Home.
- Home grouping & sorting dùng Transaction.createdAt (local time). dueDate chỉ metadata, không ảnh hưởng group/sort trong MVP.
---

## 3) Technical Standards (MUST)

### 3.1 Architecture (simple & testable)
- Layered-first feature Architecture: Code phải được tổ chức theo tính năng (feature), trong mỗi feature chia thành 3 lớp:
  - **Presentation**: UI + State (Cubit/BLoC)
  - **Domain**: Entities (immutable), Use-cases, Repository interfaces
  - **Data**: Chứa Repository Impl và Data Sources.
- **Dependency Injection (DI)**: Sử dụng get_it làm Service Locator.
  - Quy tắc phụ thuộc: Presentation → Domain → Data (không ngược chiều)
  - Domain **không phụ thuộc Flutter** (pure Dart, không `BuildContext`, không `Material`, không `intl` UI)
- **Repository interfaces** đặt ở Domain; implementations đặt ở Data.
  - Mọi “decision” ảnh hưởng contract (fields, repository methods, navigation routes) phải được ghi trong `plan.md`.
- SDD Enforcement:
  - Sử dụng freezed để tạo ra các Immutable States (đúng tinh thần 1.2).

### 3.2 State Management
  - Primary Choice: flutter_bloc (ưu tiên Cubit cho sự đơn giản).
  - SDD Enforcement:
    - Sử dụng freezed để tạo ra các Immutable States
    - Cubit MUST gọi Use-cases. Chỉ trường hợp trivial read-only mới được gọi Repository trực tiếp và phải ghi trong plan.md.
    - Presentation chỉ orchestration UI: nhận input → gọi use-case → emit state. Không chứa business rules.
    - Không dùng global mutable state để giữ danh sách transactions/categories (tuân thủ SSOT).

### 3.3 Storage (local-only)
- **Database (MVP)**:
- Settings: Sử dụng shared_preferences để lưu cấu hình nhẹ (ngôn ngữ).
- Database (Core Data): Sử dụng **sqflite** phối hợp với Repository Pattern để đảm bảo tính Reactive.
  - Repository phải trả về Stream<List<Entity>> cho các danh sách để thực hiện Reactive SSOT.
  - Sử dụng StreamController trong Repository để phát tín hiệu (emit) khi dữ liệu thay đổi.
  - Repository/DataSource phải có dispose() và được đóng khi app terminate (hoặc singleton lifecycle rõ).
- Tables: categories, transactions
    - Fields: id/name/type/iconKey/createdAt; transactionName/amount/categoryId/note/createdAt/dueDate
- Mọi thay đổi về cấu trúc bảng trong sqflite phải đi kèm với việc cập nhật version database và script migration trong data layer.

- **Seeding categories (MUST)**:
  - Seed chạy **1 lần** (khi DB chưa có category).
  - Không tạo trùng lặp khi mở app lại.
  - Seed phải tạo đủ 2 `type`: expense/income.

### 3.4 Navigation
- Dùng `go_router`
- Routes tối thiểu:
  - `/home`
  - `/settings`
  - `/add-transaction`
  - `/settings/language`
  - `/settings/categories`

### 3.5 Localization
- Dùng `flutter_localizations` + `intl` + ARB.
- Currency Formatting: Sử dụng NumberFormat từ package intl để hiển thị tiền dựa trên languageCode.
  - Rule: Lưu trữ là int, hiển thị mới format thành String.
  - Parsing input: chỉ nhận digits, loại bỏ , . trước khi parse int; không lưu formatted string.
- Khi đổi language: UI cập nhật ngay (rebuild app) và lưu lại lựa chọn.

### 3.6 Code Quality
- Bắt buộc pass:
  - `dart format .`
  - `flutter analyze`
- Naming rõ ràng, tránh abbreviations khó hiểu.
- Mỗi file nên “vừa đủ”, ưu tiên chia nhỏ theo feature thay vì file khổng lồ.
- Formatting: Chạy dart format . tự động trước khi commit code.
- Folder Structure:
lib/
├── core/              # DI, Theme, Constants, Utils
├── features/
│   ├── home/          # UI, Cubit
│   ├── transaction/   # UI, Cubit
│   └── ...
├── domain/            # Entities & Repository Interfaces
└── data/              # Repositories Impl & DB Helpers

- Rules: Entities (Domain) không chứa logic fromJSON/toJSON. Việc chuyển đổi dữ liệu từ Database/JSON được thực hiện bởi các Data Models (Data layer) thông qua Factory methods.
---

## 4) Testing Standards (MUST)

> Mục tiêu: đảm bảo Implementation luôn “khớp Spec”, giảm regression, và enforce AC-Driven Verification.

### 4.1 Test Pyramid (MVP)
- Ưu tiên theo thứ tự:
  1) **Unit tests (MUST)**: Domain (use-cases, entities, validators)
  2) **Repository stream tests (MUST)**: đảm bảo Reactive SSOT (emit list mới sau write)
  3) **Widget tests (SHOULD)**: kiểm chứng 1–2 flow chính end-to-end ở UI layer

### 4.2 Tooling & Test Setup (MUST)
- Packages khuyến nghị:
  - `flutter_test` (mặc định)
  - `mocktail` (mock interfaces)
  - `bloc_test` (test Cubit/BLoC states)
  - `sqflite_common_ffi` (test repository với SQLite thật trên CI/local)
- Quy tắc test:
  - Test phải **deterministic** (không phụ thuộc thời gian thực/locale thực/mạng)
  - Không test UI pixel-perfect (không golden ở MVP) — tập trung behavior/logic
  - Dữ liệu test phải “tự setup/teardown” (không dùng chung DB file với local dev)

### 4.3 Minimum Test Set (MVP)

#### A) Domain Unit Tests (MUST)
Mỗi use-case quan trọng phải có unit test (mock repository interface):
- **AddTransactionUseCase**
  - amount > 0
  - required fields (name/category)
  - lưu đúng `Transaction.type` = `Category.type`
- **WatchTransactionsUseCase / ListTransactionsUseCase**
  - đảm bảo sort theo `createdAt` desc (mới nhất lên trước)
  - group key theo ngày dựa trên `createdAt` (local time)
- **CreateCategoryUseCase**
  - name required + max length (≤ 20)
  - type expense/income đúng theo tab
- **WatchCategoriesUseCase**
  - trả đúng list theo `type`
- **LanguageSettingUseCases**
  - save/read `languageCode` (EN/VI)
- Nếu có validators (amount/name), phải có unit tests riêng.

#### B) Repository Reactive SSOT Tests (MUST)
Test với SQLite thật (sqflite_common_ffi) để bảo đảm contract “Action → Write DB → emit → UI rebuild”:
- `watchCategories()`:
  - subscribe stream → insert category → stream emit list mới (list lấy từ DB query)
- `watchTransactions()`:
  - subscribe stream → insert transaction → stream emit list mới đúng sort desc
- Migration/DB version (nếu có onUpgrade):
  - ít nhất 1 test sanity: open DB version N → upgrade → vẫn query được (MVP có thể tối giản)

**Rules bắt buộc verify trong test**:
- Stream là **broadcast** (nhiều listeners không crash)
- Sau write: repository **re-query DB** và emit list mới (không emit từ cache biến tạm)

#### C) Presentation State Tests (SHOULD)
Dùng `bloc_test` cho các Cubit chính (mock use-cases):
- HomeCubit: load/watch → emit state có list grouped
- AddTransactionCubit: validate → saving → success/failure
- CategoriesCubit: create category → list update
- LanguageCubit: change language → state update

#### D) Widget Tests (SHOULD)
Tối thiểu 1–2 flow quan trọng:
1) **Add Transaction → Save → Home hiển thị item mới**
   - nhập name/amount, chọn category, nhấn TẠO
   - quay lại Home thấy item mới xuất hiện (reactive)
2) **Change Language → UI cập nhật**
   - vào Settings → Language → chọn EN/VI → kiểm tra text/locale đổi (ở mức smoke)

### 4.4 AC-Driven Verification (MUST)
- Mỗi Acceptance Criteria quan trọng trong `spec.md` phải có “Verification method” và được track trong `tasks.md`:
  - `UNIT` (domain/repo)
  - `WIDGET` (UI flow)
  - `MANUAL` (checklist)
- Nếu một AC không cover bằng test (ví dụ UX nhỏ), bắt buộc có **manual checklist** rõ ràng trong tasks.md.

### 4.5 Definition of Done cho 1 task/PR (MUST)
- [ ] Update đúng luồng SDD: spec/plan/tasks (nếu có thay đổi behavior/contract)
- [ ] Unit tests liên quan được bổ sung/updated và pass (`flutter test`)
- [ ] Repo reactive tests pass (nếu có thay đổi data/repository)
- [ ] `flutter analyze` sạch, `dart format .` chạy
- [ ] Manual sanity check 4 màn hình (Home/Add/Categories/Settings) pass
- [ ] Không thêm dependency “toàn năng” khi chưa cần (phải có rationale trong PR nếu thêm)

---

## 5) UX Standards (MUST)

- UI dùng Material 3, theme thống nhất (colors/typography/spacing).
- Có:
  - Empty state (Home rỗng)
  - Validation message (amount/category bắt buộc)
  - Feedback sau khi save (snackbar/toast)
- Accessibility cơ bản:
  - Touch target hợp lý
  - Semantics cho nút chính (Add/Save)

---

## 6) Performance Standards (MUST)

- Home list dùng `ListView.builder` (không render toàn bộ).
- Sorting/filtering thực hiện ở layer phù hợp (ưu tiên DB query nếu có thể).
- App vẫn scroll mượt với **~1000 transactions** trên máy tầm trung.

---

## 7) Workflow & Quality Gates (MUST)

### SDD Flow (theo Spec Kit)
1. `/speckit.specify` → cập nhật `spec.md`
2. `/speckit.plan` → cập nhật `plan.md`
3. `/speckit.tasks` → cập nhật `tasks.md`
4. Implement theo tasks (không nhảy bước)

### Merge Gate (PR MUST pass)
- [ ] `spec.md / plan.md / tasks.md` đồng bộ với thay đổi code (nếu có thay đổi requirement)
- [ ] `flutter analyze` sạch
- [ ] `flutter test` pass
- [ ] Manual sanity check 4 màn hình (Home/Add/Categories/Settings)

---

## 8) Amendments
- Mọi thay đổi constitution phải có:
  - Lý do (rationale)
  - Phần bị ảnh hưởng (spec/plan/tasks)
  - Version bump theo semantic (MAJOR/MINOR/PATCH)

**End of Constitution**
