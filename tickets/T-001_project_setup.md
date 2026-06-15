# 🎫 TICKET: T-001 — Project Setup + EventBus + GameManager

**Phase:** 1 (Foundation)
**Branch:** `feature/phase1-setup`
**Base:** `main`
**Ước tính:** 30-60 phút
**Dependency:** Không — đây là ticket đầu tiên

---

## Ngữ cảnh dự án

Bạn đang xây dựng nền tảng cho **LifeSim** — một Life Simulation RPG (pixel art 2D, top-down, Godot 4.4.3, GDScript). Game lấy cảm hứng từ Stardew Valley (visual) kết hợp Nobody: The Turnaround (life sim mechanics). Core gameplay là trải nghiệm xã hội và quản lý cuộc sống, **không có combat**.

Đây là ticket **đầu tiên** — mọi ticket sau đều phụ thuộc vào kết quả của ticket này. Bạn đang tạo bộ xương (skeleton) cho toàn bộ dự án.

---

## Tài liệu bắt buộc phải đọc TRƯỚC KHI CODE

> ⚠️ **QUAN TRỌNG:** Đọc file `agent_rulebook.md` trong thư mục game TRƯỚC KHI viết bất kỳ dòng code nào. File đó chứa Golden Rules — vi phạm bất kỳ rule nào = FAILED TASK.

Các file tham chiếu (đã có sẵn trong workspace):
- `agent_rulebook.md` — **ĐỌC TOÀN BỘ** — Quy chuẩn kiến trúc, coding standards, workflow
- `implementation_plan.md` — Phần "Cấu trúc dự án Godot 4" và "Phase 1"
- `changelog.md` — Ghi log sau khi hoàn thành

---

## Yêu cầu cụ thể

### 1. Setup Godot 4 Project
- Khởi tạo project Godot 4 tại `c:\Users\tumin\Downloads\game\`
- Tạo file `project.godot` với cấu hình:
  - **Window size:** 1920×1080
  - **Viewport size:** 480×270
  - **Stretch mode:** `viewport`
  - **Stretch aspect:** `keep`
  - **Texture filter:** `Nearest` (pixel perfect)
  - **Physics ticks:** 60
- Tạo `.gitignore` phù hợp cho Godot 4 (ignore `.godot/`, `*.import` reimport cache)

### 2. Tạo cấu trúc thư mục
```
game/
├── project.godot
├── .gitignore
├── assets/
│   ├── sprites/
│   │   ├── player/
│   │   ├── npcs/
│   │   ├── items/
│   │   └── buildings/
│   ├── tilesets/
│   ├── ui/
│   ├── audio/
│   │   ├── bgm/
│   │   └── sfx/
│   └── fonts/
├── scenes/
│   ├── main/
│   ├── player/
│   ├── ui/
│   ├── world/
│   │   ├── hometown/
│   │   └── city/
│   ├── npcs/
│   └── objects/
├── scripts/
│   ├── autoload/
│   ├── player/
│   ├── world/
│   ├── social/
│   ├── jobs/
│   ├── housing/
│   ├── farming/
│   └── ui/
├── data/
│   ├── items/
│   ├── jobs/
│   ├── npcs/
│   ├── locales/
│   ├── events/
│   ├── housing/
│   ├── recipes/
│   └── world/
├── components/
│   ├── movement_component.gd
│   └── interactable_component.gd
└── addons/
```
- Tạo các thư mục trống (đặt file `.gdkeep` hoặc placeholder nếu cần giữ thư mục trong Git)

### 3. Tạo `EventBus.gd` (Autoload)
File: `scripts/autoload/event_bus.gd`

Đây là **signal hub trung tâm** — nơi DUY NHẤT khai báo signal giao tiếp giữa các hệ thống. Tham khảo danh sách signal đầy đủ trong `agent_rulebook.md` Phần 5 (EventBus Registry).

```gdscript
## EventBus — Kênh giao tiếp trung tâm (Signal Hub).
## Tất cả module giao tiếp với nhau thông qua file này.
## RULE: Chỉ APPEND signal mới — KHÔNG được xóa hoặc đổi tên signal cũ.
extends Node

# --- TIME ---
signal time_tick(current_hour: int, current_minute: int)
signal time_hour_changed(new_hour: int)
signal time_day_changed(new_day: int)
signal time_season_changed(new_season: int)

# --- PLAYER ---
signal player_moved(new_position: Vector2)
signal player_ate_food(food_data: Resource)
signal player_money_changed(new_amount: int, delta: int)
signal player_need_critical(need_type: int)

# --- NPC ---
signal npc_spawned(npc_id: StringName, npc_ref: Node)
signal npc_despawned(npc_id: StringName)
signal npc_schedule_changed(npc_id: StringName, new_activity: StringName)
signal npc_path_failed(npc_id: StringName)
signal npc_path_ready(npc_id: StringName, path: PackedVector2Array)
signal npc_dialogue_started(npc_id: StringName)
signal npc_dialogue_ended(npc_id: StringName, outcome: Dictionary)

# --- SCENE / DISTRICT ---
signal scene_transition_requested(target_district: StringName)
signal scene_transition_started(from_district: StringName, to_district: StringName)
signal scene_transition_completed(district_name: StringName)
signal scene_load_progress(progress: float)

# --- QUEST ---
signal quest_started(quest_id: StringName)
signal quest_objective_updated(quest_id: StringName, objective_id: StringName, progress: int)
signal quest_completed(quest_id: StringName)
signal quest_failed(quest_id: StringName)

# --- SAVE ---
signal save_requested()
signal save_completed(success: bool)
signal load_completed(success: bool)

# --- UI (từ UI lên backend) ---
signal ui_purchase_requested(item_data: Resource)
signal ui_dialogue_choice_selected(choice_index: int)
signal ui_menu_opened(menu_id: StringName)
signal ui_menu_closed(menu_id: StringName)

# --- NEEDS ---
signal needs_updated(need_type: int, new_value: float)
signal needs_all_updated(hunger: float, energy: float, mood: float, hygiene: float, social: float)
```

**Lưu ý:** Signal type dùng `Resource` thay vì custom class name (VD: `FoodData`) vì các class đó chưa tồn tại trong ticket này. Agent xây dựng module sau sẽ cast type khi dùng.

### 4. Tạo `GameManager.gd` (Autoload)
File: `scripts/autoload/game_manager.gd`

```gdscript
## GameManager — Quản lý global state.
## Lưu trữ: tiền, ngày hiện tại, game phase, trạng thái pause.
## KHÔNG chứa logic xử lý — chỉ lưu state và phát signal khi state thay đổi.
extends Node

# --- Constants ---
const STARTING_MONEY: int = 500

# --- State (chỉ đọc từ bên ngoài, thay đổi qua hàm nội bộ) ---
var money: int = STARTING_MONEY
var is_game_paused: bool = false
var current_district: StringName = &"home_village"

func _ready() -> void:
    # Lắng nghe EventBus — KHÔNG gọi Manager khác trực tiếp
    pass

## Thay đổi tiền — phát signal thông qua EventBus.
## delta > 0: nhận tiền. delta < 0: mất tiền.
func change_money(delta: int) -> void:
    money += delta
    money = max(money, 0)
    EventBus.player_money_changed.emit(money, delta)

## Pause/Resume game — ảnh hưởng TimeManager và NPC.
func set_pause(paused: bool) -> void:
    is_game_paused = paused
    get_tree().paused = paused
```

### 5. Đăng ký Autoloads trong `project.godot`

Thứ tự load (quan trọng — không được đảo ngược):
1. `EventBus` → `scripts/autoload/event_bus.gd`
2. `GameManager` → `scripts/autoload/game_manager.gd`

(TimeManager, NeedsManager, v.v. sẽ được thêm bởi ticket sau)

### 6. Tạo Main Scene
File: `scenes/main/main.tscn` + `scenes/main/main.gd`

Scene cơ bản nhất — chỉ cần là Node2D trống làm root scene cho project. Set nó làm Main Scene trong Project Settings.

```gdscript
## Main — Root scene của game.
## Sẽ được mở rộng khi có thêm hệ thống (UI layer, World layer, v.v.).
extends Node2D

func _ready() -> void:
    print("[Main] LifeSim started. EventBus: OK, GameManager: OK")
    print("[Main] Starting money: %d" % GameManager.money)
```

### 7. Git Init
- `git init`
- `git add .`
- `git commit -m "T-001: Project setup, EventBus, GameManager"`

---

## Definition of Done

- [ ] Project Godot 4 chạy được (nhấn F5 ra màn hình trống, không crash)
- [ ] Console in ra `[Main] LifeSim started...` khi chạy
- [ ] Cấu trúc thư mục đầy đủ (assets/, scenes/, scripts/, data/, components/)
- [ ] `EventBus.gd` có đầy đủ signal groups (TIME, PLAYER, NPC, SCENE, QUEST, SAVE, UI, NEEDS)
- [ ] `GameManager.gd` có `change_money()` phát signal qua EventBus
- [ ] Autoloads đăng ký đúng thứ tự: EventBus → GameManager
- [ ] Viewport: 480×270, stretch viewport, texture nearest
- [ ] `.gitignore` có ignore `.godot/` folder
- [ ] Git repo đã init với initial commit
- [ ] Static typing 100% (mọi var, func param, return type)
- [ ] DocString cho mọi class và hàm public
- [ ] Không có magic numbers
- [ ] Đã APPEND vào `changelog.md`

---

## Self-Check trước khi nộp (từ Rulebook Phần 14)

- [ ] Không có Autoload gọi trực tiếp hàm Autoload khác
- [ ] Tên file `snake_case`, tên class `PascalCase`
- [ ] Mọi error có `push_error()` với message rõ ràng
- [ ] `EventBus.connect()` chỉ gọi trong `_ready()`
- [ ] Đã ghi changelog với format đúng

---

*Ticket tạo bởi Project Lead. Mọi thắc mắc ghi vào changelog mục `⚠️ Questions/Handoff Notes`.*
