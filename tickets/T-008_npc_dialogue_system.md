# 🎫 TICKET: T-008 — NPC Base & Dialogue System (Phase 3)

**Phase:** 3 (Social Foundation)
**Branch:** `feature/phase3-dialogue`
**Base:** `main`
**Ước tính:** 2-3 giờ

---

## NGỮ CẢNH
Chúng ta bắt đầu Phase 3: Social Foundation. Game LifeSim đặt trọng tâm vào tương tác xã hội.
Ticket này yêu cầu bạn tạo ra nền tảng cho các NPC và hệ thống hội thoại (Dialogue System).

## TÀI LIỆU BẮT BUỘC PHẢI ĐỌC
1. `agent_rulebook.md` — Tuân thủ tuyệt đối Golden Rules.
2. Bạn ĐÃ BỊ CẢNH CÁO ở ticket T-FIX-001 về việc chọc ngoáy trực tiếp giữa các file và thiếu Static Typing. Lần này phải code cực kỳ cẩn thận: **100% Static Typing** và **Strict Decoupling qua EventBus**.

---

## YÊU CẦU CỤ THỂ

### 1. Tạo Resource Data cho Hội Thoại (Dialogue)
File: `data/dialogues/dialogue_data.gd`
- Tạo script kế thừa `Resource` tên là `DialogueData`.
- Gồm: `npc_name: String`, `portrait: Texture2D`, `lines: Array[String]`.

### 2. Tạo NPCBase
File: `scenes/npcs/npc_base.tscn` và `scripts/npcs/npc_base.gd`
- Kế thừa `CharacterBody2D` (để sau này di chuyển được).
- Gắn node `InteractableArea` (trong `components/interactable_area.tscn`) vào NPC. Chỉnh `prompt_text = "Nói chuyện"`.
- Gắn một `Sprite2D` tạm làm ngoại hình NPC.
- Gắn script `npc_base.gd`. Script này export một `dialogue_data: DialogueData`.
- Bắt signal `interacted` từ `InteractableArea`. Khi player tương tác, NPC sẽ phát signal: `EventBus.npc_dialogue_started.emit(npc_id)` (hoặc truyền data nếu cần, hãy xem danh sách signal trong `event_bus.gd`).

### 3. Cập nhật EventBus
File: `scripts/autoload/event_bus.gd`
- Kiểm tra xem đã có signal cho dialogue chưa. Nếu chưa có / chưa đúng tham số, hãy cập nhật.
- Gợi ý signal: `signal npc_dialogue_started(dialogue_data: Resource)`

### 4. Tạo Dialogue UI (Reactive UI)
File: `scenes/ui/dialogue_ui.tscn` và `scripts/ui/dialogue_ui.gd`
- UI tĩnh, nằm ở bottom màn hình (Panel, Label cho tên, RichTextLabel cho nội dung thoại, TextureRect cho avatar).
- Ẩn mặc định (`visible = false`).
- Trong `_ready()`, connect vào `EventBus.npc_dialogue_started`.
- Khi nhận signal, hiện UI lên (`show()`), load dòng đầu tiên của thoại.
- Bắt input (Click chuột hoặc phím Space) để next thoại. Hết thoại thì `hide()` và phát signal `EventBus.npc_dialogue_ended.emit(...)`.
- **Tuyệt đối không:** Cho UI tự truy cập vào player để đóng băng (freeze) player. UI chỉ việc phát signal.

### 5. Xử lý Trạng thái Player khi nói chuyện
File: `scripts/player/player_controller.gd`
- Connect vào `EventBus.npc_dialogue_started` và `npc_dialogue_ended`.
- Khi dialogue started, thiết lập trạng thái `_is_in_dialogue = true` để không cho player di chuyển (return early trong `_physics_process`).
- Khi ended, trả lại `_is_in_dialogue = false`.

### 6. Bố trí Test Scene
- Đặt 1-2 NPC vào `home_village.tscn`.
- Tạo một file `.tres` (DialogueData) ném vào NPC để test.
- Đặt `DialogueUI` vào màn hình `main.tscn` hoặc `hud.tscn`.

---

## DEFINITION OF DONE
- [ ] Tới gần NPC, bấm E, khung thoại hiện lên. Player không thể di chuyển.
- [ ] Bấm Space/Click chuột để chuyển dòng thoại.
- [ ] Hết thoại thì khung thoại biến mất, player di chuyển lại bình thường.
- [ ] **100% Static Typing.**
- [ ] Code tuân thủ strict decoupling (NPC không chọc vào UI, UI không chọc vào Player).
- [ ] Đã chạy Self-Check Checklist trong Rulebook.
- [ ] Ghi changelog: "T-008: Xây dựng hệ thống hội thoại cơ bản và NPCBase".
