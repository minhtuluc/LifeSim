# 📝 LiferSim: Agent Changelog

> **QUY TẮC NGHIÊM NGẶT:** 
> - File này là **APPEND-ONLY** (Chỉ được thêm vào cuối file).
> - **NGHIÊM CẤM** bất kỳ Agent nào sửa đổi, xóa, hoặc ghi đè lên log của một Agent khác đã viết trước đó.
> - Mỗi entry phải có Date/Time, Agent/Session ID (nếu có), Tên Module, và chi tiết thay đổi để dễ dàng khoanh vùng lỗi.

---

## [Mẫu Entry - Vui lòng copy format này]
**Thời gian:** YYYY-MM-DD HH:MM
**Phase/Module:** [Tên hệ thống làm việc]
**Thay đổi chính:**
- Thêm file X, Y
- Sửa đổi signal Z trong EventBus
- (Ghi chú cảnh báo nếu có ảnh hưởng hệ thống khác)
---

**Thời gian:** 2026-06-16 01:30
**Phase/Module:** Phase 1 / T-001 Project Setup
**Thay đổi chính:**
- Khởi tạo dự án Godot 4 (project.godot, .gitignore).
- Tạo cấu trúc thư mục (có `.gdkeep` files).
- Tạo `scripts/autoload/event_bus.gd` với đầy đủ signal groups.
- Tạo `scripts/autoload/game_manager.gd` với logic tiền tệ.
- Đăng ký Autoloads (EventBus -> GameManager).
- Tạo root scene `scenes/main/main.tscn`.
- Init Git.
---

**Thời gian:** 2026-06-16 01:40
**Phase/Module:** Phase 1 / T-002 Time & Needs Management
**Thay đổi chính:**
- Tạo `TimeManager`: quản lý đồng hồ nội tại, phát signal `time_tick`, `time_hour_changed`, `time_day_changed`, `time_season_changed`.
- Tạo `NeedsManager`: quản lý 5 nhu cầu (Hunger, Energy, Mood, Hygiene, Social), decay theo giờ, phát signal `needs_updated` và `player_need_critical`.
- Đăng ký Autoloads `TimeManager` và `NeedsManager` vào `project.godot` theo thứ tự quy định.
- Cập nhật tạm thời `main.gd` để test time tick & needs decay.
---

**Thời gian:** 2026-06-16 01:45
**Phase/Module:** Phase 1 / T-003 Player Scene & Basic World
**Thay đổi chính:**
- Tạo `MovementComponent` để tách biệt logic di chuyển vật lý (Composition pattern).
- Tạo Player scene (`CharacterBody2D`) với `PlayerController` hỗ trợ di chuyển 8 hướng bằng WASD.
- Tạo `home_village.tscn` làm scene thế giới cơ bản có gắn tường (StaticBody2D) để test va chạm.
- Chuyển Main Scene từ `main.tscn` sang `home_village.tscn`.
---

**Thời gian:** 2026-06-16 01:50
**Phase/Module:** Phase 1 / T-004 HUD & i18n Setup
**Thay đổi chính:**
- Tạo `translations.csv` chứa các từ khóa cơ bản đa ngôn ngữ (Mùa, Ngày, Tiền, Nhu cầu).
- Cấu hình lại `main.tscn` làm root chứa 2 layer riêng biệt: `WorldContainer` (cho các district) và `HUD` (cho UI).
- Tạo `hud.tscn` hiển thị thông tin thời gian, tiền bạc, và 5 thanh trạng thái sinh lý (`ProgressBar`).
- Thêm logic `hud.gd` tuân thủ nguyên tắc Reactive UI: chỉ cập nhật giao diện khi có signal từ `EventBus`, không tự can thiệp thay đổi Data.
- Xóa file test cũ `main.gd`.
---

**Thời gian:** 2026-06-16 02:15
**Phase/Module:** Phase 2 / Core Loop (T-005, T-006, T-007)
**Thay đổi chính:**
- Tạo `InteractableArea` và `InteractionScanner` cho phép Player bấm `E` tương tác với môi trường.
- Tạo `Bed` object: Bấm E để ngủ, tua nhanh qua đêm tới 06:00 sáng hôm sau, phục hồi Energy & Mood.
- Tạo `Workstation` object: Bấm E để làm việc, tốn 2 giờ, trừ 25 Energy, cộng 80 G.
- Tạo `DayNightCycle` (`CanvasModulate`) đổi màu thế giới tự động theo `TimeManager.current_hour` (Đêm tối, ngày sáng).
---

**Thời gian:** 2026-06-16 02:25
**Phase/Module:** Phase 3 / Inventory & Shop (T-008, T-009, T-010)
**Thay đổi chính:**
- Thêm resource `ItemData` định nghĩa vật phẩm (Bánh mì, Cà phê) với thông số phục hồi Hunger/Energy.
- Tạo `InventoryComponent` cho Player và giao diện `InventoryUI` mở bằng phím `I`.
- Bổ sung `NeedsManager` bắt signal `player_ate_food` để cộng chỉ số khi ăn đồ ăn.
- Thêm `VendingMachine` trên map. Bấm E để mở `ShopUI`, cho phép mua thức ăn bằng tiền.
---

**Thời gian:** 2026-06-16 02:30
**Phase/Module:** Phase 4 / Save & Load System (T-011 -> T-014)
**Thay đổi chính:**
- Thêm `SaveManager` vào Autoload (chạy sau cùng).
- Hàm `save_game()`: Gom data từ TimeManager, GameManager, NeedsManager, InventoryComponent ghi ra `user://savegame.json`.
- Hàm `load_game()`: Đọc JSON và phục hồi trạng thái (kèm việc gán signal ép UI update theo thông số mới).
- Gán phím tắt: `F5` = Quicksave, `F9` = Quickload.
---

**Thời gian:** 2026-06-16 02:51
**Phase/Module:** Refactor / T-FIX-001
**Thay đổi chính:**
- Fix Rule 1: Chuyển Save/Load sang Event Sourcing. `SaveManager` không gọi trực tiếp các biến của Autoload khác nữa mà dùng `save_data` Dictionary truyền qua EventBus.
- Fix Rule 2: Reactive UI cho `shop_ui.gd` (không gọi trực tiếp `change_money`, chỉ emit signal `ui_purchase_requested`).
- Chuẩn hóa Static Typing 100% cho tất cả các biến toàn cục và cục bộ.
---

**Thời gian:** 2026-06-16 03:06
**Phase/Module:** 3 / T-008
**Thay đổi chính:**
- Tạo Resource `DialogueData` để lưu trữ kịch bản hội thoại.
- Xây dựng `NPCBase` với `InteractableArea` để kích hoạt hội thoại.
- Xây dựng `DialogueUI` theo kiến trúc Reactive, tự động đọc thoại khi nhận signal `npc_dialogue_started`.
- `PlayerController` tự động khoá di chuyển khi đang trong hội thoại thông qua EventBus.
---

**Thời gian:** 2026-06-17 20:25
**Phase/Module:** Phase 3 / T-009 NPC Social Foundation
**Thay đổi chính:**
- Tạo `NPCManager` quản lý friendship và save/load NPC social state.
- Thêm interaction menu cho NPC: nói chuyện và tặng quà.
- Thêm gift flow qua `EventBus.npc_gift_received` kết hợp `InventoryUI`.
- Thêm schedule cơ bản cho NPC qua `npc_schedule_target_changed` (`NPCManager` chứa schedule registry).
- Cập nhật `project.godot` để đăng ký `NPCManager`.
- Cập nhật `EventBus` với các signal social/schedule mới.
**Known Issues / Handoff Notes:**
- Schedule đang xử lý bằng teleport thay vì pathfinding (theo đúng design T-009).
---
