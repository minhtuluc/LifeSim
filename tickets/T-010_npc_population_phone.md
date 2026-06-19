# 🎫 TICKET: T-010 — NPC Population & Phone System (Phase 3)

**Phase:** 3 (Social Foundation)
**Branch:** `feature/phase3-population`
**Base:** `main`
**Ước tính:** 2-3 giờ

---

## NGỮ CẢNH
Hệ thống Social (NPCBase, Dialogue, Interaction Menu, Schedule Component, Friendship) đã hoàn thiện ở ticket trước.
Ticket này có nhiệm vụ "thổi hồn" vào thế giới bằng cách tạo ra các NPC thực sự đầu tiên, đồng thời thêm một chiếc điện thoại (Phone UI) cơ bản để người chơi theo dõi mối quan hệ.

Theo định hướng cốt truyện mới nhất (tham khảo `childhood-chapter-milestones.md`), nhân vật bắt đầu từ quê nhà (Hometown).

## TÀI LIỆU THAM KHẢO
- `agent_rulebook.md` — Tuân thủ 100% Static Typing và Strict Decoupling. Tuyệt đối không dùng Autoload gọi chéo nhau.

---

## YÊU CẦU CỤ THỂ

### 1. Tạo 3 NPC Đầu Tiên cho `home_village.tscn`
Thay vì tạo NPC trắng, bạn cần tạo 3 Inherited Scene từ `npc_base.tscn` và đặt chúng vào map `home_village.tscn`.
- **NPC 1: Mẹ (Mom)**
  - Data: Thích được nhận quà, ở nhà vào ban đêm, ra vườn vào ban ngày.
- **NPC 2: Bạn thân (Best Friend)**
  - Data: Thường chạy loăng quăng hoặc đứng đợi ở quảng trường.
- **NPC 3: Chủ Tiệm (Shopkeeper)**
  - Data: Đứng bán hàng cạnh máy bán hàng tự động, lịch trình cố định.
  
👉 **Nhiệm vụ cho mỗi NPC:**
1. Tạo 1 file `DialogueData` (.tres) chứa vài câu thoại cơ bản. Ném vào NPC.
2. Thiết lập `ScheduleComponent` (đã có ở T-009) cho từng NPC để chúng thay đổi vị trí lúc 6:00 (Sáng) và 18:00 (Tối). Bạn có thể tái sử dụng hoặc tạo mới các file `ScheduleEntry`.
3. Đổi màu `Sprite2D` (sửa thuộc tính `modulate`) để dễ phân biệt 3 NPC nếu chưa có asset.

### 2. Tạo Điện Thoại Cơ Bản (Phone UI)
File: `scenes/ui/phone_ui.tscn` và `scripts/ui/phone_ui.gd`
- Tạo một Panel nhỏ, giả lập màn hình điện thoại (hiện ra khi bấm phím `P` hoặc bấm nút trên HUD).
- Chức năng duy nhất hiện tại: **Ứng dụng Danh Bạ (Contacts/Relationships)**.
- Giao diện: Hiển thị danh sách các NPC mà player đã gặp, kèm theo số điểm Friendship.
- **Lấy dữ liệu ở đâu?** 
  - `NPCManager` hiện đang lưu `_npc_friendships`. 
  - UI KHÔNG ĐƯỢC CHỌC TRỰC TIẾP vào biến này (Golden Rule 2).
  - Cách làm: `phone_ui.gd` emit signal `EventBus.ui_phone_opened.emit()`. Sau đó `NPCManager` lắng nghe và emit ngược lại `EventBus.phone_contacts_updated.emit(friendships_dict)`. UI bắt signal này và render.
- Ẩn/Hiện điện thoại bằng `hide()` và `show()`.

### 3. Tích hợp Phone UI vào Game
- Đặt `PhoneUI` vào `main.tscn` hoặc `hud.tscn`.
- Chắc chắn rằng khi tắt điện thoại, player mới có thể tiếp tục di chuyển. (Tận dụng state `is_game_paused` của `GameManager` hoặc tạo state mới `is_in_ui`).

---

## DEFINITION OF DONE
- [ ] Trong `home_village`, có đúng 3 NPC đang đi lại theo lịch trình thời gian thực.
- [ ] Có thể bấm tương tác và nói chuyện/tặng quà cho 3 NPC này (tên và hình ảnh hiển thị đúng theo DialogueData).
- [ ] Bấm P mở Điện thoại. Thấy danh sách 3 NPC và điểm tình bạn tương ứng.
- [ ] Tặng quà cho NPC -> Mở lại điện thoại -> Điểm tình bạn thay đổi.
- [ ] **100% Static Typing**, không ngoại lệ.
- [ ] UI lấy dữ liệu gián tiếp qua EventBus, KHÔNG gọi thẳng `NPCManager.get_friendships()`.
- [ ] Cập nhật Changelog: "T-010: Thêm 3 NPC mẫu và Phone UI cơ bản".
