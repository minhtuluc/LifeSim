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
