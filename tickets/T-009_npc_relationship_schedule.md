# 🎫 TICKET: T-009 — NPC Relationship & Schedule System (Phase 3)

**Phase:** 3 (Social Foundation)
**Branch:** `feature/phase3-social`
**Base:** `main`
**Ước tính:** 2-3 giờ

---

## NGỮ CẢNH
Hệ thống hội thoại cơ bản đã xong. Giờ là lúc biến NPC thành những thực thể sống động hơn: chúng có mức độ thân thiết (Friendship) và có thể di chuyển theo lịch trình (Schedule) tùy vào thời gian trong ngày.
Đồng thời, player có thể tặng quà cho NPC để tăng/giảm Friendship.

## TÀI LIỆU THAM KHẢO
- `agent_rulebook.md` — Tuân thủ 100% Static Typing và Strict Decoupling. Tuyệt đối không dùng Autoload gọi chéo nhau.

---

## YÊU CẦU CỤ THỂ

### 1. Tạo `NPCManager` (Autoload)
File: `scripts/autoload/npc_manager.gd`
- Quản lý global state của toàn bộ NPC.
- Lưu trữ dictionary: `var _npc_friendships: Dictionary = {}` (Key: StringName npc_id, Value: int friendship_points).
- Các hàm public: `get_friendship(npc_id)`, `change_friendship(npc_id, delta)`.
- Hàm `change_friendship` phải emit một signal (bạn cần định nghĩa trong `event_bus.gd` VD: `signal npc_friendship_changed(npc_id: StringName, new_amount: int)`).
- Tích hợp vào `SaveManager` bằng cách lắng nghe `EventBus.save_requested` và `EventBus.load_completed` giống như `NeedsManager` đã làm.
- Cập nhật file `project.godot` để thêm `NPCManager` vào Autoloads. Xem thứ tự load chuẩn trong file `agent_rulebook.md` (NPCManager đứng thứ 6, sau SceneManager và trước NeedsManager).

### 2. Mở rộng Hệ thống Tương tác (Interaction)
File: `scripts/npcs/npc_base.gd`
- Hiện tại NPC chỉ có thể nói chuyện. Bổ sung tính năng **Tặng quà**.
- Logic tạm thời: Nếu player đang cầm 1 item trên tay (truy xuất thông qua `InventoryComponent` hoăc `EventBus` signals, hoặc nếu phức tạp quá thì tạo 1 UI Popup nhỏ với 2 nút: "Nói chuyện" và "Tặng quà").
- **Cách đơn giản nhất (Reccomended):** Khi bấm tương tác, hiện lên một UI Menu nhỏ (Interaction Menu) ở giữa màn hình: "Nói chuyện" hoặc "Tặng quà". Chọn Nói chuyện -> `EventBus.npc_dialogue_started`. Chọn Tặng quà -> Mở kho đồ để chọn quà.
- Khi tặng quà thành công: Trừ item khỏi inventory, gọi `EventBus.npc_gift_received.emit(npc_id, item_data)`. `NPCManager` nghe thấy signal này sẽ tăng điểm tình bạn (+10 điểm).

### 3. Hệ thống Lịch trình cơ bản (Schedule)
File: `scripts/npcs/npc_schedule_component.gd` (Component mới)
- Gắn vào `NPCBase`.
- Export một danh sách lịch trình (Dictionary hoặc Array các Resources: `thời_gian -> vị_trí`).
- Connect vào `EventBus.time_hour_changed`.
- Khi đến giờ, Component sẽ cập nhật mục tiêu di chuyển (`target_position`) cho `NPCBase`.
- (Tạm thời chưa cần pathfinding phức tạp, chỉ cần NPC đi theo đường thẳng hoặc di chuyển tức thời tới vị trí mới bằng cách sửa `global_position`).

### 4. Cập nhật Save/Load System
File: Đảm bảo `SaveManager` và `NPCManager` giao tiếp được với nhau qua `save_data` Dictionary. Save Friendship points lại.

---

## DEFINITION OF DONE
- [ ] Mở Interaction Menu khi bấm vào NPC: Chọn Nói Chuyện hoặc Tặng Quà.
- [ ] Tặng quà tăng điểm tình bạn trong `NPCManager`.
- [ ] NPC đổi vị trí (hoặc di chuyển) khi đồng hồ nhảy sang giờ được lập lịch.
- [ ] Điểm tình bạn được lưu và tải thành công bằng tính năng Save/Load.
- [ ] `NPCManager` được load đúng thứ tự trong `project.godot`.
- [ ] **100% Static Typing**, không ngoại lệ.
- [ ] Không có Direct Autoload Coupling.
- [ ] Cập nhật Changelog: "T-009: NPCManager, Friendship points, Interaction Menu, Basic Schedule".
