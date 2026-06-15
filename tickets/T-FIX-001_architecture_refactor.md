# 🎫 TICKET: T-FIX-001 — Architecture & Standards Refactoring

**Phase:** Refactor
**Branch:** `fix/architecture-refactor`
**Base:** `main`
**Ước tính:** 1-2 giờ
**Mục tiêu:** Cứu vãn codebase hiện tại khỏi các lỗi vi phạm Golden Rules và chuẩn hóa lại Static Typing. TUYỆT ĐỐI không thêm tính năng mới trong ticket này.

---

## NGỮ CẢNH CỨU HỘ & CÁC LỖI ĐÃ PHÁT HIỆN

Bạn vừa hoàn thành một khối lượng công việc lớn (kết hợp code của nhiều module vào một), nhưng Project Lead đã scan codebase và quyết định **REJECT** do phát hiện hàng loạt vi phạm nghiêm trọng **Golden Rules** trong file `agent_rulebook.md`. 

Cụ thể các vi phạm đã bị Project Lead "bắt quả tang":
1. **Vi phạm Rule 1 (Strict Decoupling):** `SaveManager.gd` tự ý gọi thẳng vào `NeedsManager.hunger` và `GameManager.money`. 
2. **Vi phạm Rule 2 (Reactive UI):** `shop_ui.gd` (dòng 42) tự gọi hàm trừ tiền `GameManager.change_money()`.
3. **Vi phạm Chuẩn Code (Thiếu Static Typing):** Phát hiện ít nhất 27 biến dạng `var name =` thiếu định kiểu, nằm rải rác khắp các file UI và Autoloads.

Dự án không thể scale nếu giữ nguyên tình trạng này. Bạn được giao nhiệm vụ phải dọn dẹp, tái cấu trúc và chuẩn hóa lại toàn bộ codebase theo chuẩn Production.

---

## YÊU CẦU CỤ THỂ

### 1. Fix Golden Rule 1 (Strict Decoupling) trong Save/Load System
Hiện tại `SaveManager` đang chọc thẳng vào `NeedsManager` và `GameManager` để đọc/ghi biến (VD: `NeedsManager.hunger = ...`, `GameManager.money = ...`). Điều này BỊ CẤM.

**Cách sửa (Dictionary Reference passing):**
- **Khi Save:**
  1. Trong `SaveManager.save_game()`, tạo một `var save_data: Dictionary = {}`
  2. Emit signal để gom data: `EventBus.save_requested.emit(save_data)` (Signal này cần update trong EventBus có truyền tham số `save_data: Dictionary`)
  3. Trong `NeedsManager` và `GameManager`, connect vào `save_requested`. Hàm xử lý sẽ nhận `save_data` và tự nhét data của mình vào: `save_data["needs"] = { "hunger": hunger, ... }`
  4. `SaveManager` tiến hành ghi `save_data` ra file JSON.
- **Khi Load:**
  1. `SaveManager.load_game()` đọc JSON thành `var load_data: Dictionary`.
  2. Emit signal để phân phát data: `EventBus.load_completed.emit(load_data)` (Update EventBus)
  3. `NeedsManager` và `GameManager` lắng nghe signal này, tự động lấy `load_data["needs"]` và `load_data["game"]` để update nội bộ.

### 2. Fix Golden Rule 2 (Reactive UI) trong UI Scripts
`shop_ui.gd` (và có thể các file UI khác) đang chọc trực tiếp vào `GameManager.money` để check điều kiện và gọi `GameManager.change_money()`. Điều này BỊ CẤM.

**Cách sửa (Reactive View):**
1. **Theo dõi tiền:** Trong `shop_ui.gd`, khai báo một biến `var current_money: int = 0`. Connect vào `EventBus.player_money_changed` ở `_ready()`. Khi signal nổ, update `current_money = new_amount`. Dùng biến nội bộ này để check điều kiện `if current_money >= item.base_price:`
2. **Khi bấm mua:** KHÔNG được gọi `GameManager.change_money()`. Chỉ được phát signal: `EventBus.ui_purchase_requested.emit(item)`
3. **Logic xử lý:** Tạo một script mới hoặc dùng script phù hợp (có thể là `InventoryManager` hoặc `GameManager`) lắng nghe `ui_purchase_requested`. Backend tự check lại tiền một lần nữa (để chống lỗi logic), nếu đủ thì tự gọi `change_money()` và add item vào inventory.

### 3. Phủ 100% Static Typing (Chuẩn Godot)
Rất nhiều biến đang được khai báo dạng dynamic (thiếu dấu `:`). Trình biên dịch của Godot 4 sẽ không tối ưu được.
- Mở TẤT CẢ các file `.gd`.
- Tìm các dòng có dạng `var tên_biến =` và sửa thành `var tên_biến: Kiểu_Dữ_Liệu =`
- **Ví dụ cần fix:**
  - `var player = get_tree()....` -> Sửa thành `var player: Node = ...`
  - `var json = JSON.new()` -> Sửa thành `var json: JSON = JSON.new()`
  - `var save_data = json.data` -> Sửa thành `var save_data: Dictionary = json.data`
  - `var item = food as ItemData` -> Sửa thành `var item: ItemData = food as ItemData`

### 4. Dọn dẹp Cảnh Báo Của Editor
Nếu bạn thấy bất kỳ icon cảnh báo (vàng/đỏ) nào trong cửa sổ Script của Godot, bạn phải fix nó. Code sạch là code không có Warning.

---

## FILES CẦN CHỈNH SỬA
- `scripts/autoload/save_manager.gd`
- `scripts/autoload/needs_manager.gd`
- `scripts/autoload/game_manager.gd`
- `scripts/autoload/event_bus.gd` (sửa tham số của `save_requested` và `load_completed`)
- `scripts/ui/shop_ui.gd`, `scripts/ui/hud.gd`, `scripts/ui/inventory_ui.gd`
- Toàn bộ các file `.gd` khác (để update Static Typing).

---

## DEFINITION OF DONE
- [ ] Chạy lệnh Text Search (Ctrl+Shift+F) với từ khóa `Manager.` không ra kết quả nào ngoại trừ đọc `TimeManager.current_hour` (Rule 1).
- [ ] `shop_ui.gd` không chứa bất kỳ logic tính toán hay thay đổi backend nào (Rule 2).
- [ ] KHÔNG còn biến dynamic (tất cả đều có `:`).
- [ ] Game vẫn chạy F5 thành công, tính năng Save/Load vẫn hoạt động chuẩn.
- [ ] Ghi Changelog: "T-FIX-001: Architecture refactoring (Save system decoupling, Reactive UI fix, 100% Static Typing)".
