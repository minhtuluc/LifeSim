# 🎫 TICKET: T-010 — NPC Population & Phone UI

**Phase:** 3 — Social Foundation  
**Branch:** `feature/phase3-population`  
**Base:** `main`  
**Ước tính:** 2-3 giờ  
**Project:** LifeSim / Godot 4.4.3 / GDScript

---

## Ngữ Cảnh

Hệ thống Social cốt lõi đã hoàn thiện ở ticket T-009, bao gồm:
- `NPCBase`, `InteractableArea`, `NPCScheduleComponent`.
- `NPCManager` quản lý Friendship.
- `NPCInteractionMenu` cho phép chọn "Talk" hoặc "Gift".

Theo tài liệu cốt truyện (`docs/notes/childhood-chapter-milestones.md`), chương đầu tiên diễn ra ở quê nhà (Hometown) khi nhân vật chính còn nhỏ. 

Ticket này có 2 mục tiêu:
1. Thổi hồn vào map `home_village` bằng cách tạo ra **3 NPC thực sự đầu tiên** thay vì các khối test trống.
2. Xây dựng một chiếc **Phone UI (Giao diện Điện Thoại)** để người chơi xem danh sách liên lạc (Contacts) và mức độ thân thiết (Friendship Points) của từng NPC.

---

## Tài Liệu Bắt Buộc Phải Đọc

- `agent_rulebook.md` — Tuân thủ tuyệt đối Golden Rules.
- `docs/notes/childhood-chapter-milestones.md` — Hiểu bối cảnh nhân vật để viết hội thoại.
- Code hiện tại trong:
  - `scripts/autoload/event_bus.gd`
  - `scripts/autoload/npc_manager.gd`
  - `scripts/npcs/npc_base.gd`
  - `scripts/npcs/npc_schedule_component.gd`
  - `data/dialogues/dialogue_data.gd`
  - `data/npcs/schedule_entry.gd`

---

## Golden Rules Cần Nhớ

- **Strict Decoupling:** Không gọi chéo Autoload. Giao tiếp qua `EventBus`.
- **Reactive UI:** Phone UI KHÔNG ĐƯỢC đọc biến trực tiếp từ `NPCManager` (như `NPCManager.get_friendship()`). UI phải dùng cơ chế signal (emit "tôi mở điện thoại" -> backend trả "đây là data").
- **Static Typing 100%:** Khai báo kiểu dữ liệu cho tất cả các biến (VD: `var phone: Control = $PhoneUI`).
- Signal connect chỉ trong `_ready()`.
- Chỉ append signal mới vào `event_bus.gd`, không xóa/đổi signature signal cũ.

---

## Yêu Cầu Cụ Thể

### 1. Cập nhật `EventBus.gd`
File: `scripts/autoload/event_bus.gd`

Bổ sung các signal cho Phone UI (nằm trong phần `# --- UI ---`):
```gdscript
signal ui_phone_opened()
signal ui_phone_closed()
signal phone_contacts_updated(contacts_data: Dictionary) # Key: npc_id (StringName), Value: Dictionary (chứa name, portrait, friendship_points)
```

---

### 2. Tạo Data & Resource cho 3 NPC

Tạo 3 file `DialogueData` (.tres) trong thư mục `data/dialogues/`:
1. `dialogue_mom.tres` (npc_id: `mom`, name: `Mẹ`, lines: chứa 2-3 câu dặn dò ở nhà).
2. `dialogue_friend.tres` (npc_id: `friend`, name: `Bạn Thân`, lines: rủ đi chơi).
3. `dialogue_shopkeeper.tres` (npc_id: `shopkeeper`, name: `Bác Bán Hàng`, lines: chào hỏi thân thiện).

Sử dụng lại `data/npcs/schedule_entry.gd` để tạo mảng `ScheduleEntry` cho mỗi NPC (Có thể thiết lập thẳng trên Scene Inspector hoặc tạo file `.tres` riêng). Lịch trình gợi ý:
- Mẹ: 6h sáng ở tọa độ vườn (VD: 100, 100), 18h tối ở trong nhà (VD: 200, 150).
- Bạn thân: Di chuyển quanh quảng trường làng.
- Bác Bán Hàng: Đứng im 1 chỗ cố định gần Vending Machine (hoặc quầy hàng).

---

### 3. Khởi tạo 3 Scene NPC trong Map
1. Tạo 3 file Scene kế thừa (Inherited Scene) từ `scenes/npcs/npc_base.tscn`, hoặc tạo mới nhưng attach đúng script `npc_base.gd`:
   - `scenes/npcs/mom_npc.tscn`
   - `scenes/npcs/friend_npc.tscn`
   - `scenes/npcs/shopkeeper_npc.tscn`
2. Cấu hình cho mỗi Scene:
   - Thay đổi `modulate` color của Sprite2D để phân biệt (Đỏ = Mẹ, Xanh = Bạn, Vàng = Bác Bán Hàng).
   - Gắn file `DialogueData` tương ứng vào Export Variable.
   - Thêm node `NPCScheduleComponent` và thiết lập mảng `ScheduleEntry`.
   - Set đúng `npc_id` (nếu script `npc_base.gd` yêu cầu, hãy đảm bảo NPC có một danh tính cụ thể).
3. Mở `scenes/world/hometown/home_village.tscn` và đặt cả 3 NPC này vào map. Đảm bảo chúng ở vị trí dễ nhìn thấy và tương tác được.

---

### 4. Xây dựng Phone UI (Điện Thoại)
File: `scenes/ui/phone_ui.tscn` và `scripts/ui/phone_ui.gd`

**Cấu trúc UI:**
- `Panel` giả lập màn hình điện thoại ở góc phải màn hình.
- Có nút Tắt (`CloseButton`).
- Một `ScrollContainer` -> `VBoxContainer` để chứa danh sách liên lạc (Contacts).

**Logic `phone_ui.gd`:**
- UI mặc định `hide()`.
- Bắt phím bấm (VD: Phím `P` hoặc Tab) trong `_unhandled_input()` hoặc `_process()` để mở/đóng điện thoại.
- Khi mở: Gọi `EventBus.ui_phone_opened.emit()` và `show()`. Đừng quên dừng di chuyển của player (dùng state của `GameManager` nếu có, hoặc phát signal).
- Lắng nghe `EventBus.phone_contacts_updated`. Khi nhận được `contacts_data`:
  - `for child in vbox_container.get_children(): child.queue_free()` (xóa danh sách cũ).
  - Lặp qua `contacts_data`, instantiate một UI con (ví dụ `contact_item.tscn`) hoặc tạo `Label`/`HBoxContainer` bằng code hiển thị: `[Avatar] Tên NPC: Điểm Friendship`.

---

### 5. Cập nhật `NPCManager` cung cấp Data cho Phone
File: `scripts/autoload/npc_manager.gd`

- Lắng nghe signal `EventBus.ui_phone_opened` trong `_ready()`.
- Tạo hàm `_on_ui_phone_opened()`:
  - Cần lấy thông tin tên (Name) và hình ảnh (Portrait) của các NPC.
  - Vấn đề: `NPCManager` hiện tại chỉ có `npc_id` và `friendship_points` (int), không giữ file `DialogueData`.
  - Giải pháp 1: Duyệt qua group `npcs` trong `SceneTree`, thu thập `dialogue_data.npc_name` và `friendship_points`, đóng gói thành một Dictionary rồi `EventBus.phone_contacts_updated.emit(data)`.
  - Giải pháp 2: Export một array chứa toàn bộ `DialogueData` vào `NPCManager` để nó làm Registry tổng, từ đó nó map được `npc_id` -> Tên/Portrait.
  *(Khuyến nghị dùng Giải pháp 1 để đơn giản, hoặc kết hợp Registry tùy theo bạn thấy kiến trúc nào sạch hơn).*

---

## Definition of Done

- [ ] Trong map `home_village`, có đúng 3 NPC đang đi lại theo lịch trình thời gian thực.
- [ ] Lại gần tương tác (phím E), tên và thoại hiển thị chuẩn theo từng người.
- [ ] Bấm phím `P` mở Điện thoại.
- [ ] Trong điện thoại hiển thị đúng danh sách 3 NPC kèm số điểm Friendship hiện tại.
- [ ] Tặng quà cho NPC, mở lại điện thoại, thấy điểm Friendship tăng.
- [ ] Đóng điện thoại thì player mới di chuyển được.
- [ ] **100% Static Typing**, không ngoại lệ.
- [ ] Chạy mượt mà, không error, không Warning vàng/đỏ trong Editor.
- [ ] Ghi changelog: "T-010: Thêm 3 NPC mẫu (Mom, Friend, Shopkeeper) và Phone UI cơ bản hiển thị danh bạ qua EventBus".

---

## Lệnh Nên Chạy Trước Khi Nộp

```powershell
git status --short
rg "NPCManager\." scripts components scenes -g "*.gd"
rg "var .* =" scripts components scenes data -g "*.gd"
```

Nếu lệnh grep `NPCManager.` tìm thấy dòng code nào không nằm trong thư mục autoload (đặc biệt là trong `scripts/ui/`), bạn đang vi phạm Golden Rule 2 và ticket sẽ bị REJECT. Mọi thay đổi đều phải qua EventBus!
