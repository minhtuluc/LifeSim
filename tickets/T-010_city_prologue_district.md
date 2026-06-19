# 🎫 TICKET: T-010 — City Prologue District & Core Loop

**Phase:** 4 — Vertical Slice A (City Prologue)  
**Branch:** `feature/phase4-city-prologue`  
**Base:** `main`  
**Ước tính:** 3-4 giờ  
**Project:** LifeSim / Godot 4.4.3 / GDScript

---

## Ngữ Cảnh

Theo định hướng cốt truyện mới (`docs/adr/0001-nonlinear-city-prologue.md`), game sẽ không bắt đầu từ tuổi thơ (Hometown) mà sẽ bắt đầu bằng **City Prologue (Vertical Slice A)**. 
Đây là 30 phút gameplay đầu tiên mô tả sự cô đơn và vòng lặp mệt mỏi ở thành phố hiện tại, trước khi nhân vật "ngắm sao" và hồi tưởng về quê nhà.

Ticket này sẽ thiết lập bản đồ City đầu tiên và chứng minh vòng lặp (Core Loop): **Làm việc (mất sức, có tiền) -> Mua thức ăn (tốn tiền) -> Ăn (hồi sức) -> Ngủ (qua ngày)**.

---

## Tài Liệu Bắt Buộc Phải Đọc

- `agent_rulebook.md` — Tuân thủ tuyệt đối Golden Rules.
- `docs/adr/0001-nonlinear-city-prologue.md` — Nắm rõ lý do tại sao làm City trước.
- Code hiện tại trong:
  - `scripts/autoload/time_manager.gd`
  - `scripts/autoload/game_manager.gd`
  - `scripts/autoload/needs_manager.gd`
  - `components/interactable_area.gd`

---

## Golden Rules Cần Nhớ

- **Strict Decoupling:** Giao tiếp hoàn toàn qua EventBus. KHÔNG TẠO Autoload coupling.
- **100% Static Typing:** Mọi biến, mảng, tham số đều phải có kiểu dữ liệu.
- Changelog bắt buộc append ở cuối.

---

## Yêu Cầu Cụ Thể

### 1. Nâng cấp `TimeManager`
File: `scripts/autoload/time_manager.gd`

Hiện tại `TimeManager` chưa có chức năng tua nhanh thời gian (advance time) khi người chơi ngủ hoặc làm việc.
- Lắng nghe `EventBus.player_worked` và `EventBus.player_slept`.
- Khi `player_worked(hours, energy, money)` hoặc `player_slept(hours)` được gọi:
  - Tạo một hàm `advance_time(hours: int)` để cộng thêm giờ vào `current_hour`.
  - Cập nhật logic để nhảy qua ngày mới nếu `current_hour >= 24`. Đừng quên gọi các hàm update day/season đang có.

### 2. Xây dựng Bản đồ `city_prologue_district.tscn`
File: `scenes/world/city/city_prologue_district.tscn`

- Kế thừa cấu trúc cơ bản hoặc tạo một Node2D/TileMap. Map cần chia thành 3 khu vực (rất đơn giản, không cần đẹp lúc này):
  1. **Căn hộ (Apartment):** Có một cái Giường ngủ (Bed).
  2. **Góc phố (Street):** Có Máy bán hàng tự động (Vending Machine).
  3. **Chỗ làm (Workplace):** Một cái Bàn làm việc (Work Desk).
  4. **Ban công / Sân thượng:** Có điểm ngắm sao (Stargazing Spot).
- Đặt Scene `Player` vào trong map này.

### 3. Tạo Các Tương Tác Core Loop (Interactables)
Sử dụng `components/interactable_area.tscn` để tạo các điểm tương tác sau trong map:

- **Giường ngủ (Bed):** 
  - Gắn script `bed.gd`. 
  - Khi tương tác: `EventBus.player_slept.emit(8)`.
- **Bàn làm việc (Work Desk):**
  - Gắn script `work_desk.gd`.
  - Khi tương tác: `EventBus.player_worked.emit(4, 30.0, 500)` (Làm 4 tiếng, tốn 30 Energy, được 500 tiền).
- **Máy bán hàng (Vending Machine):**
  - Tương tự như `home_village`, tái sử dụng logic gọi `EventBus.ui_menu_opened.emit(&"shop_ui")` hoặc tương tự để người chơi mua thức ăn.
- **Điểm ngắm sao (Stargazing Spot):**
  - Tạm thời khi tương tác sẽ `print("Stargazing Transition Triggered -> Chuyển về tuổi thơ")` và bắn một signal mới `EventBus.scene_transition_requested.emit(&"home_village")`. (Tất nhiên lúc này ta chưa có SceneManager nên nó sẽ không làm gì cả, chỉ cần setup).

### 4. Thêm 3 City NPCs
Tạo 3 NPC (Dùng `NPCBase`) đặt trong map:
- **Boss (Sếp):** Đứng cạnh Bàn làm việc.
- **Neighbor (Hàng xóm):** Đứng cạnh cửa căn hộ.
- **Shopkeeper (Thu ngân):** Đứng gần Máy bán hàng.
- Tạo 3 file `DialogueData` đơn giản mang âm hưởng thành phố (nhấn mạnh sự bận rộn, mệt mỏi) cho 3 người này.
- Bật `NPCScheduleComponent` cho họ đi lại đơn giản (sử dụng lại `ScheduleEntry`).

---

## Definition of Done

- [ ] Bản đồ `city_prologue_district` có đủ 4 điểm: Giường, Bàn Làm Việc, Máy bán hàng, Điểm ngắm sao.
- [ ] Vòng lặp test thành công: Player đi làm -> thời gian nhảy lên 4 tiếng, trừ 30 Energy, cộng 500 tiền -> Đi ra máy bán thức ăn mua đồ -> Ăn đồ -> Đi ngủ hồi năng lượng và nhảy ngày.
- [ ] `TimeManager` xử lý đúng logic nhảy thời gian và nhảy ngày khi `player_worked` và `player_slept`.
- [ ] Có 3 NPC thành phố để tương tác và chạy đúng Schedule.
- [ ] **100% Static Typing**, không ngoại lệ.
- [ ] Cập nhật Changelog: "T-010: Xây dựng City Prologue District và kết nối hoàn chỉnh vòng lặp sinh tồn cơ bản".

---

## Lệnh Nên Chạy Trước Khi Nộp

```powershell
git status --short
rg "var .* =" scripts components scenes data -g "*.gd"
rg "\.connect" scripts components scenes -g "*.gd"
```
Kiểm tra xem toàn bộ các biến mới đã được gán kiểu tĩnh chưa. Nếu có lỗi, Tự động Fix!
