# 🎫 TICKET: T-FIX-002 — Fix T-009 Review Blockers

**Phase:** 3 — Social Foundation  
**Branch:** `fix/phase3-t009-review-fixes`  
**Base:** `main`  
**Mục tiêu:** Sửa các lỗi blocking sau khi T-009 đã bị merge vào `main` trước khi Project Lead review.

---

## Ngữ Cảnh

T-009 đã thêm `NPCManager`, gift flow, interaction menu, và schedule cơ bản. Tuy nhiên review hậu kiểm phát hiện một số lỗi vi phạm rulebook hoặc làm tính năng không chạy được trong game scene hiện tại.

Ticket này chỉ sửa blocker của T-009. Không thêm feature mới ngoài phạm vi bên dưới.

---

## Tài Liệu Bắt Buộc

- `agent_rulebook.md`
- `CONTEXT.md`
- `docs/adr/0001-nonlinear-city-prologue.md`
- `tickets/T-009_npc_relationship_schedule.md`

---

## Blockers Cần Sửa

### 1. `NPCInteractionMenu` chưa được instance vào main scene

File cần sửa:

- `scenes/main/main.tscn`

Hiện tại `scenes/ui/npc_interaction_menu.tscn` tồn tại nhưng không được add vào `CanvasLayer` của `main.tscn`, nên interaction với NPC không thể mở menu.

Yêu cầu:

- Add `NPCInteractionMenu` vào `Main/CanvasLayer`.
- Đảm bảo node ẩn mặc định khi game start.

---

### 2. Xóa direct Autoload coupling từ `NPCScheduleComponent`

File cần sửa:

- `scripts/npcs/npc_schedule_component.gd`
- `scripts/autoload/event_bus.gd`
- `scripts/autoload/npc_manager.gd`

Hiện tại:

```gdscript
NPCManager.register_schedule(npc_id, entries)
```

Vi phạm Rule 1: scene/component không gọi trực tiếp Autoload Manager để thay đổi state.

Yêu cầu:

- Append signal mới vào EventBus:

```gdscript
signal npc_schedule_registered(npc_id: StringName, entries: Array)
```

- `NPCScheduleComponent` emit:

```gdscript
EventBus.npc_schedule_registered.emit(npc_id, entries)
```

- `NPCManager` listen `npc_schedule_registered` trong `_ready()` và gọi handler nội bộ để lưu registry.
- Có thể giữ public `register_schedule()` nếu cần, nhưng component không được gọi thẳng nữa.

---

### 3. Gift flow không được để UI sửa inventory state trực tiếp

File cần sửa:

- `scripts/ui/inventory_ui.gd`
- `components/inventory_component.gd`
- `scripts/autoload/event_bus.gd`

Hiện tại `InventoryUI` đọc `inventory.items[index]` và gọi `inventory.remove_item(index)` khi tặng quà. Đây là UI sửa backend trực tiếp.

Yêu cầu:

- Dùng signal đã có hoặc append signal nếu cần:

```gdscript
signal ui_gift_item_selected(npc_id: StringName, item_index: int)
```

- `InventoryUI` khi gift mode chỉ emit `ui_gift_item_selected`.
- `InventoryComponent` listen signal này trong `_ready()`, kiểm tra index, lấy item, remove item, rồi emit:

```gdscript
EventBus.npc_gift_received.emit(npc_id, item)
```

- UI không truy cập `inventory.items` trực tiếp.
- UI không gọi `inventory.remove_item()` trong gift flow.

---

### 4. Add DocString tối thiểu cho class và public API mới

Files cần sửa:

- `scripts/autoload/npc_manager.gd`
- `scripts/npcs/npc_schedule_component.gd`
- `scripts/ui/npc_interaction_menu.gd`
- `data/npcs/schedule_entry.gd`

Yêu cầu:

- Thêm DocString `##` cho class.
- Thêm DocString cho public functions như `get_friendship()`, `change_friendship()`.

---

## Definition Of Done

- [ ] `NPCInteractionMenu` xuất hiện trong `main.tscn`.
- [ ] Không còn `NPCManager.` trong `scripts/npcs/npc_schedule_component.gd`.
- [ ] `InventoryUI` không đọc `inventory.items` trực tiếp.
- [ ] `InventoryUI` không gọi `inventory.remove_item()` trong gift flow.
- [ ] Gift flow vẫn hoạt động: chọn item -> item mất khỏi inventory -> `npc_gift_received` -> friendship tăng.
- [ ] Schedule registry vẫn hoạt động qua EventBus.
- [ ] Static typing giữ nguyên.
- [ ] Changelog append cuối file.

---

## Lệnh Review Bắt Buộc

```powershell
rg "NPCManager\\." scripts/npcs components scenes -g "*.gd"
rg "inventory\\.items|inventory\\.remove_item" scripts/ui -g "*.gd"
rg "npc_schedule_registered|ui_gift_item_selected" scripts components -g "*.gd"
git status --short
```

Nếu lệnh đầu hoặc lệnh thứ hai còn output liên quan T-009, ticket chưa đạt.

---

## Changelog Bắt Buộc

Append cuối `changelog.md`:

```markdown
---
**Thời gian:** YYYY-MM-DD HH:MM
**Phase/Module:** Phase 3 / T-FIX-002 T-009 Review Fixes
**Thay đổi chính:**
- Instance `NPCInteractionMenu` vào main scene.
- Chuyển schedule registration sang EventBus.
- Chuyển gift item removal từ UI sang InventoryComponent.
- Bổ sung DocString cho các class/public API mới.
**Known Issues / Handoff Notes:**
- [Ghi rõ nếu còn vấn đề.]
---
```
