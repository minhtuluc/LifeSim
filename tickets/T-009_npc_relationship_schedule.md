# 🎫 TICKET: T-009 — NPCManager, Friendship, Gift & Basic Schedule

**Phase:** 3 — Social Foundation  
**Branch:** `feature/phase3-npc-social`  
**Base:** `main`  
**Ước tính:** 2-3 giờ  
**Project:** LifeSim / Godot 4.4.3 / GDScript

---

## Ngữ Cảnh

Hệ thống dialogue cơ bản đã có:

- `scripts/npcs/npc_base.gd`
- `scripts/ui/dialogue_ui.gd`
- `data/dialogues/dialogue_data.gd`
- `EventBus.npc_dialogue_started(dialogue_data: Resource)`
- `EventBus.npc_dialogue_ended()`

Ticket này mở rộng Phase 3 để NPC bắt đầu có trạng thái xã hội: friendship points, nhận quà, và schedule cơ bản.

Mục tiêu là làm nền móng sạch cho social system. Không làm romance, phone chat, NPC memory sâu, pathfinding phức tạp, hoặc quest trong ticket này.

---

## Tài Liệu Bắt Buộc Phải Đọc

- `agent_rulebook.md` — đọc toàn bộ trước khi code.
- `implementation_plan.md` — phần Phase 3 Social Foundation.
- `changelog.md` — nắm các module đã làm.
- Code hiện tại trong:
  - `scripts/autoload/event_bus.gd`
  - `scripts/npcs/npc_base.gd`
  - `components/inventory_component.gd`
  - `scripts/ui/dialogue_ui.gd`
  - `scripts/autoload/save_manager.gd`

---

## Golden Rules Cần Nhớ

- Không gọi chéo Autoload. Giao tiếp qua `EventBus`.
- UI không sửa backend trực tiếp.
- Static typing 100%.
- Signal connect chỉ trong `_ready()`.
- Chỉ append signal mới vào `event_bus.gd`, không xóa/đổi signature signal cũ.
- Changelog bắt buộc append cuối file.
- Static data dùng `.tres`; dynamic save state dùng `.json`.

---

## Yêu Cầu Cụ Thể

### 1. Tạo `NPCManager` Autoload

Tạo file:

- `scripts/autoload/npc_manager.gd`

Yêu cầu:

- `extends Node`
- Có `class_name NPCManagerClass`
- Lưu friendship points:

```gdscript
var _npc_friendships: Dictionary = {}
```

Key là `StringName`, value là `int`.

Public API:

```gdscript
func get_friendship(npc_id: StringName) -> int
func change_friendship(npc_id: StringName, delta: int) -> void
```

`change_friendship()` phải:

- Clamp friendship trong khoảng `-100` đến `100`.
- Emit `EventBus.npc_friendship_changed.emit(npc_id, new_amount, delta)`.

`NPCManager` phải listen trong `_ready()`:

- `EventBus.npc_gift_received`
- `EventBus.save_requested`
- `EventBus.load_completed`
- `EventBus.time_hour_changed`

Khi nhận `npc_gift_received`, tạm thời tăng `+10 friendship`.

---

### 2. Đăng Ký Autoload

Sửa `project.godot` để thêm:

```ini
NPCManager="*res://scripts/autoload/npc_manager.gd"
```

Thứ tự hiện tại trong project là:

```ini
TimeManager
EventBus
GameManager
NeedsManager
SaveManager
```

Sau ticket này, dùng thứ tự:

```ini
TimeManager
EventBus
GameManager
SaveManager
NPCManager
NeedsManager
```

Chưa thêm `SceneManager` hoặc `QuestManager` trong ticket này.

---

### 3. Append Signal Mới Vào EventBus

Sửa `scripts/autoload/event_bus.gd`.

Chỉ append signal mới trong group NPC/UI, không đổi signal cũ.

Thêm tối thiểu:

```gdscript
signal npc_friendship_changed(npc_id: StringName, new_amount: int, delta: int)
signal npc_gift_received(npc_id: StringName, item_data: Resource)
signal npc_schedule_target_changed(npc_id: StringName, target_position: Vector2, activity: StringName)
signal ui_npc_interaction_requested(npc_id: StringName, dialogue_data: Resource)
signal ui_npc_interaction_selected(npc_id: StringName, action_id: StringName)
signal ui_gift_item_selected(npc_id: StringName, item_index: int)
```

Nếu thấy signal nào không cần dùng, giải thích trong changelog. Không được tạo signal trùng ý nghĩa.

---

### 4. Mở Rộng `NPCBase`

Sửa:

- `scripts/npcs/npc_base.gd`

Yêu cầu:

- Thêm `@export var npc_id: StringName`.
- Vẫn giữ `dialogue_data: DialogueData`.
- Khi player tương tác NPC, không mở dialogue trực tiếp nữa.
- Thay vào đó emit request để UI mở interaction menu:

```gdscript
EventBus.ui_npc_interaction_requested.emit(npc_id, dialogue_data)
```

`NPCBase` listen `EventBus.ui_npc_interaction_selected`. Nếu `npc_id` khớp và `action_id == &"talk"`, emit:

```gdscript
EventBus.npc_dialogue_started.emit(dialogue_data)
```

Nếu `dialogue_data == null`, dùng `push_warning()`, không dùng `print()`.

NPC không được gọi UI trực tiếp.

---

### 5. Tạo NPC Interaction Menu UI

Tạo:

- `scenes/ui/npc_interaction_menu.tscn`
- `scripts/ui/npc_interaction_menu.gd`

UI gồm 2 nút:

- `Nói chuyện`
- `Tặng quà`

Yêu cầu:

- Ẩn mặc định.
- Khi nhận `ui_npc_interaction_requested`, lưu `current_npc_id`.
- Nút `Nói chuyện` emit:

```gdscript
EventBus.ui_npc_interaction_selected.emit(current_npc_id, &"talk")
```

- Nút `Tặng quà` mở inventory gift mode hoặc emit signal để chọn item.

Không được:

- UI tự sửa friendship.
- UI tự gọi `NPCManager`.
- UI tự trừ item nếu chưa đi qua signal hợp lệ.

---

### 6. Gift Flow Tối Thiểu

Dùng inventory hiện tại:

- `components/inventory_component.gd`
- `scripts/ui/inventory_ui.gd`

Yêu cầu tối thiểu:

- Cho phép chọn một item từ inventory để tặng NPC.
- Khi item được chọn để tặng:
  - Remove item khỏi inventory.
  - Emit:

```gdscript
EventBus.npc_gift_received.emit(npc_id, item)
```

Chấp nhận cách đơn giản:

- Thêm “gift mode” vào `InventoryUI`, nhận `npc_id`, chọn item là tặng luôn.
- Hoặc tạo UI nhỏ riêng liệt kê item.

Nhưng phải giữ nguyên rule:

- UI không gọi `NPCManager.change_friendship()`.
- `NPCManager` là nơi xử lý friendship sau khi nhận `npc_gift_received`.

---

### 7. Basic Schedule

Không làm pathfinding phức tạp.

Tạo resource hoặc component tối thiểu:

- `data/npcs/schedule_entry.gd` hoặc `scripts/npcs/npc_schedule_entry.gd`
- `scripts/npcs/npc_schedule_component.gd`

Schedule entry gồm:

```gdscript
@export var hour: int
@export var activity: StringName
@export var target_position: Vector2
```

Quan trọng:

- Theo `agent_rulebook.md`, NPC riêng lẻ không nên tự listen `time_hour_changed` nếu có thể tránh.
- `NPCManager` listen `EventBus.time_hour_changed`.
- Khi tới giờ, `NPCManager` hoặc schedule registry emit:

```gdscript
EventBus.npc_schedule_target_changed.emit(npc_id, target_position, activity)
```

`NPCBase` hoặc `NPCScheduleComponent` nhận signal này và chỉ xử lý nếu `npc_id` khớp.

Tạm thời NPC có thể teleport tới `target_position`. Không cần NavigationAgent/pathfinding.

---

### 8. Save/Load Friendship

`NPCManager` tích hợp Save/Load qua EventBus.

Khi save:

```gdscript
save_data["npc"] = {
	"friendships": ...
}
```

Khi load:

- Đọc lại friendship dictionary.
- Convert key về `StringName` nếu cần.
- Emit `npc_friendship_changed` cho từng NPC đã load để UI/debug có thể cập nhật.

Không lưu dialogue, schedule static data, hoặc Resource vào JSON.

---

### 9. Test Scene

Cập nhật scene hiện có để test:

- Đảm bảo có ít nhất 1 NPC có `npc_id`.
- NPC có dialogue data.
- Có `NPCInteractionMenu` trong UI/main scene.
- Có thể mua/lấy item rồi tặng NPC.
- Friendship tăng sau khi tặng quà.
- Save F5, Load F9 vẫn giữ friendship.

---

## Files Dự Kiến Tạo/Sửa

Tạo:

- `scripts/autoload/npc_manager.gd`
- `scripts/ui/npc_interaction_menu.gd`
- `scenes/ui/npc_interaction_menu.tscn`
- `scripts/npcs/npc_schedule_component.gd`
- `data/npcs/schedule_entry.gd` hoặc resource tương đương

Sửa:

- `project.godot`
- `scripts/autoload/event_bus.gd`
- `scripts/npcs/npc_base.gd`
- `components/inventory_component.gd`
- `scripts/ui/inventory_ui.gd`
- scene main/UI/world cần thiết để test
- `changelog.md`

---

## Definition Of Done

- [ ] Bấm tương tác NPC mở menu “Nói chuyện / Tặng quà”.
- [ ] Chọn “Nói chuyện” mở dialogue như trước.
- [ ] Chọn “Tặng quà” chọn được item từ inventory.
- [ ] Tặng quà remove item khỏi inventory.
- [ ] `NPCManager` nhận `npc_gift_received` và tăng friendship.
- [ ] Friendship save/load được qua F5/F9.
- [ ] NPC đổi vị trí khi tới giờ schedule test.
- [ ] `NPCManager` được đăng ký Autoload đúng thứ tự.
- [ ] Không có direct Autoload coupling mới.
- [ ] UI không sửa backend trực tiếp.
- [ ] 100% static typing.
- [ ] Không dùng JSON cho static NPC/schedule data.
- [ ] Đã append changelog cuối file.

---

## Changelog Bắt Buộc

Append cuối `changelog.md` theo format:

```markdown
---
**Thời gian:** YYYY-MM-DD HH:MM
**Phase/Module:** Phase 3 / T-009 NPC Social Foundation
**Thay đổi chính:**
- Tạo `NPCManager` quản lý friendship và save/load NPC social state.
- Thêm interaction menu cho NPC: nói chuyện và tặng quà.
- Thêm gift flow qua `EventBus.npc_gift_received`.
- Thêm schedule cơ bản cho NPC qua `npc_schedule_target_changed`.
- Cập nhật `project.godot` để đăng ký `NPCManager`.
- Cập nhật `EventBus` với các signal social/schedule mới.
**Known Issues / Handoff Notes:**
- [Ghi rõ nếu còn phần nào tạm thời, ví dụ schedule đang teleport thay vì pathfinding.]
---
```

---

## Lệnh Nên Chạy Trước Khi Nộp

```powershell
git status --short
rg "GameManager\\.|NeedsManager\\.|NPCManager\\." scripts components scenes -g "*.gd"
rg "change_scene" scripts components scenes -g "*.gd"
rg "var .* =" scripts components scenes data -g "*.gd"
```

Nếu có kết quả nghi vi phạm rule, phải sửa hoặc giải thích rõ trong changelog.
