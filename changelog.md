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
