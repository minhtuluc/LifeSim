# 🎫 TICKET: T-010 — City Prologue District & Core Loop

**Phase:** 4 — Vertical Slice A (City Prologue)  
**Branch:** `feature/phase4-city-prologue`  
**Base:** `main`  
**Ước tính:** 3-4 giờ  
**Project:** LifeSim / Godot 4.4.3 / GDScript

---

## Ngữ Cảnh

Tài liệu thiết kế mới (`docs/adr/0001-nonlinear-city-prologue.md`) quyết định: Game sẽ không mở đầu bằng tuổi thơ mà bằng **Vertical Slice A (City Prologue)**.
Đây là 20-30 phút đầu tiên của game để người chơi trải nghiệm vòng lặp sinh tồn: đi làm, mệt mỏi, mua đồ ăn, tương tác nhẹ, đi ngủ, và cuối cùng "Ngắm Sao" (Stargazing) để chuyển cảnh về quá khứ (Hometown).

Mục tiêu ticket này: Thiết lập một bản đồ thành phố nhỏ, và nối tất cả các hệ thống (Tiền, Thời Gian, Năng Lượng) lại với nhau thành 1 vòng lặp có thể chơi được. Mọi hệ thống thừa (như Điện thoại, Nông trại) KHÔNG được làm.

---

## Tài Liệu Bắt Buộc Phải Đọc

- `agent_rulebook.md` — Đọc toàn bộ trước khi code.
- `docs/adr/0001-nonlinear-city-prologue.md` — Bắt buộc phải hiểu tại sao tạo thành phố trước.
- Code hiện tại trong:
  - `scripts/autoload/time_manager.gd`
  - `scripts/autoload/game_manager.gd`
  - `scripts/autoload/needs_manager.gd`
  - `components/interactable_area.gd`

---

## Golden Rules Cần Nhớ

- Không gọi chéo Autoload. Giao tiếp qua `EventBus`.
- Static typing 100%. (VD: `var my_node: Node2D = $MyNode`).
- Signal connect chỉ trong `_ready()`.
- Chỉ append signal mới vào `event_bus.gd`.
- Changelog bắt buộc append cuối file.

---

## Yêu Cầu Cụ Thể

### 1. Nâng Cấp `TimeManager`

Sửa:
- `scripts/autoload/time_manager.gd`

Yêu cầu:
- Hiện tại game chưa tua thời gian khi player ngủ hoặc làm việc.
- Thêm các kết nối trong `_ready()`:
```gdscript
EventBus.player_worked.connect(_on_player_worked)
EventBus.player_slept.connect(_on_player_slept)
```
- Viết hàm xử lý để cộng giờ (hours) vào `current_hour`. Cần xử lý logic nhảy qua ngày hôm sau nếu `current_hour >= 24` (tận dụng lại logic nhảy ngày đang có trong `_process` hoặc gỡ nó ra thành hàm dùng chung `advance_time(hours: int)`).

---

### 2. Xây Dựng Bản Đồ `city_prologue_district.tscn`

Tạo:
- `scenes/world/city/city_prologue_district.tscn`

Yêu cầu:
- `extends Node2D`.
- Dùng `TileMap` hoặc `Sprite2D` để dựng một không gian gồm 4 khu vực:
  1. Căn hộ nhỏ (Có Giường)
  2. Bàn làm việc (Có Work Desk)
  3. Góc đường phố (Có Vending Machine)
  4. Sân thượng / Ban công (Có chỗ Ngắm Sao)
- Spawn `Player` vào bản đồ này.

---

### 3. Tạo Tương Tác Core Loop (Interactables)

Sử dụng lại `scenes/components/interactable_area.tscn` (hoặc custom component tương tự) để gắn vào các vật thể trong cảnh:

**A. Giường ngủ (Bed):**
- Thêm node tương tác, `prompt_text = "Ngủ"`.
- Khi tương tác, gọi:
```gdscript
EventBus.player_slept.emit(8) # Ngủ 8 tiếng
```

**B. Bàn làm việc (Work Desk):**
- Thêm node tương tác, `prompt_text = "Làm việc"`.
- Khi tương tác, gọi:
```gdscript
# 4 tiếng làm việc, trừ 30 energy, nhận 500 tiền
EventBus.player_worked.emit(4, 30.0, 500) 
```
*(Ghi chú: `GameManager` và `NeedsManager` đã có sẵn hàm bắt signal này ở ticket trước. Bạn chỉ cần emit nó).*

**C. Máy bán hàng tự động (Vending Machine):**
- Thêm node tương tác, `prompt_text = "Mua đồ"`.
- Gọi UI Shop:
```gdscript
EventBus.ui_menu_opened.emit(&"shop_ui")
```
- Đảm bảo `ShopUI` được đưa vào `city_prologue_district` hoặc `HUD` để player có thể mua thức ăn.

**D. Điểm ngắm sao (Stargazing Spot):**
- Đặt trên ban công, `prompt_text = "Ngắm sao"`.
- Khi tương tác, in ra màn hình hoặc gọi:
```gdscript
print("Stargazing Transition Triggered -> Hồi tưởng về tuổi thơ")
EventBus.scene_transition_requested.emit(&"home_village")
```
*(Chưa cần code `SceneManager` để load map thật, chỉ cần phát signal).*

---

### 4. Thêm 3 City NPCs

Tạo 3 file Resource `DialogueData` trong `data/dialogues/`:
- `dialogue_boss.tres` (Sếp)
- `dialogue_neighbor.tres` (Hàng xóm)
- `dialogue_clerk.tres` (Thu ngân)

Sử dụng lại `scenes/npcs/npc_base.tscn` (tạo 3 phiên bản hoặc 3 Inherited Scene), gán các file thoại trên vào biến `dialogue_data`.
Đổi `modulate` color để phân biệt 3 nhân vật này, đặt họ vào 3 góc trong map `city_prologue_district.tscn`.
Sử dụng `ScheduleEntry` để tạo file lịch trình cho họ đi lại hoặc đứng yên (như T-009 đã làm).

---

## Definition of Done

- [ ] Khi chạy `city_prologue_district.tscn`, có đủ: Giường, Bàn Làm Việc, Máy bán hàng, Điểm ngắm sao và 3 NPC.
- [ ] Vòng lặp test thành công: 
  - Lại gần Bàn làm việc bấm E -> Giờ đồng hồ nhảy thêm 4 tiếng, Năng lượng giảm, Tiền tăng.
  - Lại Máy bán hàng bấm E -> Mở shop mua được đồ, tiền giảm. Mở túi đồ ăn món ăn -> Năng lượng tăng.
  - Lại Giường bấm E -> Đồng hồ nhảy 8 tiếng, sang ngày mới.
- [ ] Điểm Ngắm Sao phát đúng signal `scene_transition_requested`.
- [ ] Code tuân thủ 100% Static Typing. Không xài biến ngầm định kiểu `var x = 1` mà phải là `var x: int = 1`.
- [ ] Không có Direct Autoload Coupling. Mọi tương tác xài qua `EventBus`.
- [ ] Changelog được cập nhật chi tiết.

---

## Lệnh Nên Chạy Trước Khi Nộp

```powershell
git status --short
rg "\.connect" scripts components scenes -g "*.gd"
rg "var .* =" scripts components scenes data -g "*.gd"
```

1. Kiểm tra lệnh `rg "\.connect"` xem có cái nào nằm ngoài `_ready()` không.
2. Kiểm tra lệnh `rg "var .* ="` xem có sót biến nào thiếu Static Type không (ngoại trừ file cũ chưa fix).
3. Bất kỳ lỗi vi phạm Rule nào đều sẽ khiến ticket bị REJECT ngay lập tức.
