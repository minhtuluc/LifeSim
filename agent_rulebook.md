# 🤖 LifeSim: AI Agent Development Rulebook
### Phiên bản: v2.1 | Engine: Godot 4.4.3-stable | Cập nhật: 2026-06-16
### ⚠️ Tài liệu này là SOURCE OF TRUTH. Mọi Agent PHẢI đọc toàn bộ trước khi viết bất kỳ dòng code nào.

> **CHÍNH SÁCH SỬA RULEBOOK:** Agent chỉ được phép **APPEND** vào các bảng Registry (Phần 4, Phần 5). **NGHIÊM CẤM** thay đổi, xóa, hay diễn giải lại các RULE hiện có mà không có sự phê duyệt rõ ràng từ Project Lead. Nếu bạn thấy một rule mâu thuẫn với thực tế — ghi vào `changelog.md` mục `⚠️ Rule Conflict` và dừng lại, đừng tự sửa.

---

## MỤC LỤC NHANH
1. [Tổng quan dự án & Ngữ cảnh kỹ thuật](#phần-1)
2. [Sơ đồ kiến trúc hệ thống](#phần-2)
3. [Golden Rules — Nguyên tắc tuyệt đối](#phần-3)
4. [Autoload Registry — Danh sách & Thứ tự ưu tiên](#phần-4)
5. [EventBus — Hợp đồng giao tiếp](#phần-5)
6. [Scene Lifecycle & District Transition](#phần-6)
7. [NPC System — Vòng đời & Phân loại](#phần-7)
8. [Time System — Đồng hồ nội tại](#phần-8)
9. [Save/Load System — Kiến trúc mở rộng](#phần-9)
10. [GDExtension — Quy tắc tích hợp](#phần-10)
11. [Thread & Async — Quy tắc an toàn](#phần-11)
12. [Tiêu chuẩn code GDScript](#phần-12)
13. [Quy trình làm việc của Agent (Workflow)](#phần-13)
14. [Self-Check Checklist](#phần-14)

---

## PHẦN 1: TỔNG QUAN DỰ ÁN & NGỮ CẢNH KỸ THUẬT {#phần-1}

| Thuộc tính | Giá trị |
|---|---|
| **Tên dự án** | LifeSim |
| **Engine** | Godot 4.4.3-stable (Windows 64-bit) |
| **Ngôn ngữ chính** | GDScript (100% logic game) |
| **Ngôn ngữ phụ** | GDExtension / C++ (chỉ cho performance-critical: pathfinding, AI simulation nặng) |
| **Core Gameplay** | Life Simulation RPG, Social-focus, Slice-of-life. Không có Combat. |
| **Multiplayer** | Không — offline single-player hoàn toàn. Không cần Authority model. |
| **Quy mô** | Lớn — District-based map (nhiều scenes), NPC số lượng lớn, Time-driven simulation |
| **Target Platform** | PC (Windows primary) |

### Ngữ cảnh thiết kế quyết định kiến trúc
Các quyết định sau đây đã được xác nhận và **KHÔNG được thay đổi** bởi bất kỳ Agent nào mà không có sự phê duyệt rõ ràng từ Project Lead:

1. **Time-driven simulation**: Game có in-game clock chạy liên tục. Đây là hệ thống trung tâm, ảnh hưởng toàn bộ game.
2. **Hybrid NPC**: Có 2 loại NPC — NPC cố định (có schedule lưu trong `.tres`) và NPC phụ spawn ngẫu nhiên.
3. **SceneTree-based transition**: Districts load/unload qua Godot SceneTree. Cần quy tắc rõ về NPC lifecycle khi scene unload.
4. **Save/Load**: JSON plain text (hiện tại) với kiến trúc sẵn sàng cho encryption (tương lai).
5. **GDExtension one-way**: C++ chỉ expose API cho GDScript gọi vào — không emit signal ngược lại.
6. **Threading**: Có dùng Thread cho async scene loading và AI pathfinding — EventBus phải thread-aware.

---

## PHẦN 2: SƠ ĐỒ KIẾN TRÚC HỆ THỐNG {#phần-2}

```
┌─────────────────────────────────────────────────────────┐
│                    AUTOLOAD LAYER                        │
│  [1] TimeManager  →  đồng hồ nội tại (ưu tiên cao nhất) │
│  [2] EventBus     →  kênh giao tiếp duy nhất            │
│  [3] GameManager  →  global state (money, day, phase)   │
│  [4] SaveManager  →  đọc/ghi file JSON                  │
│  [5] SceneManager →  quản lý district transition        │
│  [6] NPCManager   →  registry NPC toàn cục              │
│  [7] NeedsManager →  hunger, energy, mood của player    │
│  [8] QuestManager →  theo dõi quest state               │
└──────────────┬──────────────────────────────────────────┘
               │  chỉ giao tiếp qua EventBus
               ▼
┌─────────────────────────────────────────────────────────┐
│                    SCENE LAYER                           │
│  District Scene  →  World (NPC, Objects, Player)        │
│  UI Scene        →  HUD, Panels (View only, Reactive)   │
└──────────────┬──────────────────────────────────────────┘
               │  gọi API một chiều
               ▼
┌─────────────────────────────────────────────────────────┐
│               GDEXTENSION LAYER (C++)                    │
│  PathfindingExt  →  expose calculate_path()             │
│  AISimExt        →  expose simulate_behavior()          │
│  (Không emit signal — chỉ return data)                  │
└─────────────────────────────────────────────────────────┘
```

---

## PHẦN 3: GOLDEN RULES — NGUYÊN TẮC TUYỆT ĐỐI {#phần-3}
> Vi phạm bất kỳ rule nào dưới đây = **FAILED TASK**. Không có ngoại lệ.

---

### RULE 1 — Strict Decoupling: Tuyệt đối không gọi chéo Autoload

**CẤM:**
```gdscript
# Agent B KHÔNG ĐƯỢC gọi thẳng vào Manager khác
NeedsManager.increase_hunger(10)
GameManager.money -= 50
QuestManager.complete_quest("quest_01")
```

**BẮT BUỘC** — Mọi giao tiếp phải qua `EventBus`:
```gdscript
# Agent A phát signal
EventBus.player_ate_food.emit(food_data)

# Agent B (NeedsManager) tự đăng ký lắng nghe trong _ready()
func _ready() -> void:
    EventBus.player_ate_food.connect(_on_player_ate_food)

func _on_player_ate_food(food_data: FoodData) -> void:
    _increase_hunger(food_data.nutrition_value)
```

**Ngoại lệ duy nhất được phép:** `TimeManager` có thể được đọc trực tiếp (không ghi) bởi các Manager khác để lấy current time vì nó là read-only global state:
```gdscript
# Được phép — chỉ đọc, không ghi
var current_hour: int = TimeManager.current_hour
```

---

### RULE 2 — Reactive UI: View thụ động tuyệt đối

**CẤM:**
```gdscript
# UI KHÔNG ĐƯỢC sửa data backend
buy_button.pressed.connect(func(): GameManager.money -= item.price)
```

**BẮT BUỘC:**
```gdscript
# UI phát signal khi user tương tác
signal purchase_requested(item: ItemData)

func _on_buy_button_pressed() -> void:
    purchase_requested.emit(current_item)

# UI lắng nghe EventBus để cập nhật hiển thị
func _ready() -> void:
    EventBus.money_changed.connect(_on_money_changed)

func _on_money_changed(new_amount: int) -> void:
    money_label.text = str(new_amount) + "đ"
```

---

### RULE 3 — Composition & FSM: Không kế thừa sâu

**CẤM:**
```gdscript
# Cây kế thừa sâu hơn 2 cấp
class_name Merchant extends NPC  # NPC extends Character -> 3 cấp = CẤM
```

**BẮT BUỘC — Dùng Component:**
```
CharacterBase (Node2D)
├── HealthComponent (Node)
├── MovementComponent (Node)
├── SocialComponent (Node)      ← chỉ NPC cố định có
├── InventoryComponent (Node)   ← chỉ Merchant có
└── FSM (Node)
    ├── IdleState (Node)
    ├── WalkState (Node)
    ├── TalkState (Node)
    └── WorkState (Node)        ← chỉ NPC có schedule
```

Kế thừa tối đa cho phép: `CharacterBase → PlayerCharacter` (2 cấp). Không hơn.

---

### RULE 4 — Static Data dùng `.tres`, Dynamic State dùng `.json`

| Loại dữ liệu | Format | Lý do |
|---|---|---|
| Item definitions, NPC schedule, Quest template, Shop catalog | `.tres` (Resource) | Type-safe, Editor-friendly, không parse lúc runtime |
| Player save state (money, inventory, quest progress, time) | `.json` | Dễ đọc, dễ migrate, sẵn sàng encrypt |
| Scene data, tilemap | `.tscn` / `.tres` | Godot native |

**CẤM dùng JSON cho data tĩnh:**
```gdscript
# CẤM
var items = JSON.parse_string(FileAccess.get_file_as_string("res://data/items.json"))
```

**BẮT BUỘC:**
```gdscript
# Đúng — Resource class
class_name ItemData extends Resource
@export var item_id: StringName
@export var display_name: String
@export var base_price: int
@export var nutrition_value: float = 0.0
```

---

### RULE 5 — Thread Safety: Signal chỉ emit từ Main Thread

Godot 4 signal **không thread-safe** theo mặc định. Mọi signal emit từ background Thread **PHẢI** được chuyển về main thread qua `call_deferred`:

**CẤM:**
```gdscript
# Từ trong Thread — gây crash hoặc race condition
func _thread_work() -> void:
    EventBus.scene_loaded.emit(scene_data)  # CẤM
```

**BẮT BUỘC:**
```gdscript
func _thread_work() -> void:
    var scene_data: SceneData = _do_heavy_work()
    # Chuyển về main thread trước khi emit
    call_deferred("_emit_on_main_thread", scene_data)

func _emit_on_main_thread(scene_data: SceneData) -> void:
    EventBus.scene_loaded.emit(scene_data)
```

---

### RULE 7 — Signal Lifecycle: `EventBus.connect()` chỉ được gọi trong `_ready()`

Trong Godot, nếu bạn connect signal từ `_init()` hoặc constructor (trước khi Node vào SceneTree), signal có thể fire trước khi Node ready, gây lỗi null reference khó trace.

**CẤM:**
```gdscript
func _init() -> void:
    EventBus.time_hour_changed.connect(_on_hour_changed)  # CẤM — Node chưa ready

var _connection_target: Node = null
func _some_autoload_method(node: Node) -> void:
    # Autoload connect trực tiếp vào Scene Node — CẤM
    EventBus.player_moved.connect(node._on_player_moved)
```

**BẮT BUỘC:**
```gdscript
# Scene Node tự connect vào EventBus trong _ready()
func _ready() -> void:
    EventBus.time_hour_changed.connect(_on_hour_changed)

# Nếu Autoload cần thông báo cho Scene Node — dùng signal, không connect ngược lại
# Nếu bắt buộc phải connect từ Autoload vào Node — dùng flag CONNECT_ONE_SHOT
# hoặc đảm bảo disconnect trong _exit_tree() của Node:
func _exit_tree() -> void:
    if EventBus.some_signal.is_connected(_my_handler):
        EventBus.some_signal.disconnect(_my_handler)
```

**Lý do:** Khi Scene Node bị `queue_free()`, Godot 4 tự động ngắt connection nếu Node là *source* của connect. Nhưng nếu Autoload là source (Autoload connect vào Node), connection không bị dọn — gây **dangling callable** và crash.

---

### RULE 8 — Scene Transition: Tuyệt đối không gọi `change_scene` trực tiếp từ Node

**CẤM:**
```gdscript
# Bất kỳ Node nào (Player, NPC, UI...) tự gọi change_scene — CẤM
func _on_door_entered() -> void:
    get_tree().change_scene_to_file("res://scenes/world/city/city_downtown.tscn")  # CẤM
    get_tree().change_scene_to_packed(packed_scene)  # CẤM
```

**BẮT BUỘC:**
```gdscript
# Node chỉ phát signal yêu cầu — SceneManager sẽ xử lý
func _on_door_entered() -> void:
    EventBus.scene_transition_requested.emit(&"city_downtown")

# SceneManager (Autoload) là nơi DUY NHẤT được phép gọi change_scene
# Xem flow chi tiết ở Phần 6
```

**Lý do:** SceneManager cần serialize NPC state, hiển thị loading screen, và quản lý memory trước khi thực sự unload scene. Gọi `change_scene` trực tiếp bỏ qua toàn bộ bước đó — gây mất dữ liệu NPC và crash.

---

### RULE 6 — GDExtension: One-way API, không sở hữu State

```gdscript
# Đúng — GDScript gọi C++, nhận kết quả, xử lý logic trong GDScript
var path: PackedVector2Array = PathfindingExt.calculate_path(start, end, nav_map)
if path.is_empty():
    EventBus.npc_path_failed.emit(npc_id)
    return
_movement_component.follow_path(path)
```

**Quy tắc cứng cho GDExtension:**
- C++ **không được** giữ reference đến Godot Node
- C++ **không được** emit signal
- C++ **không được** gọi `call_deferred`
- Mọi kết quả từ C++ phải là value type (PackedArray, Dictionary, primitive) — không phải Object

---

## PHẦN 4: AUTOLOAD REGISTRY {#phần-4}

> Danh sách này là **bất biến**. Agent không được tự thêm Autoload mới mà không cập nhật file này và ghi vào changelog.

### Thứ tự load trong Project Settings (quan trọng — không được đảo ngược):

| Thứ tự | Tên Autoload | File | Vai trò |
|---|---|---|---|
| 1 | `TimeManager` | `autoload/time_manager.gd` | In-game clock. Load đầu tiên vì mọi hệ thống phụ thuộc vào thời gian |
| 2 | `EventBus` | `autoload/event_bus.gd` | Kênh giao tiếp. Load thứ 2 vì mọi Manager cần nó trong `_ready()` |
| 3 | `GameManager` | `autoload/game_manager.gd` | Global state (tiền, ngày, phase) |
| 4 | `SaveManager` | `autoload/save_manager.gd` | Đọc/ghi save file |
| 5 | `SceneManager` | `autoload/scene_manager.gd` | Quản lý district transition |
| 6 | `NPCManager` | `autoload/npc_manager.gd` | Registry NPC toàn cục |
| 7 | `NeedsManager` | `autoload/needs_manager.gd` | Player needs (hunger, energy, mood) |
| 8 | `QuestManager` | `autoload/quest_manager.gd` | Quest state tracking |

**Lý do thứ tự quan trọng:** Trong `_ready()`, Autoload load theo thứ tự từ trên xuống. Nếu `EventBus` load sau `GameManager`, thì `GameManager._ready()` gọi `EventBus.connect()` sẽ crash vì `EventBus` chưa tồn tại.

---

## PHẦN 5: EVENTBUS — HỢP ĐỒNG GIAO TIẾP {#phần-5}

> File `autoload/event_bus.gd` là **hợp đồng giao tiếp công khai** giữa tất cả module. Mọi Agent thêm signal mới PHẢI ghi vào file này và cập nhật bảng dưới đây trong changelog.

### Quy tắc đặt tên Signal
- Đặt theo **thì quá khứ** — mô tả sự kiện đã xảy ra: `player_ate_food`, `npc_schedule_changed`
- Không đặt theo imperative: ~~`eat_food`~~, ~~`change_schedule`~~
- Group theo prefix hệ thống: `time_*`, `player_*`, `npc_*`, `scene_*`, `quest_*`, `ui_*`, `save_*`

### Registry Signal hiện tại (cập nhật khi thêm mới):

```gdscript
# ============================================================
# autoload/event_bus.gd
# ============================================================
extends Node

# --- TIME ---
signal time_hour_changed(new_hour: int)
signal time_day_changed(new_day: int)
signal time_season_changed(new_season: TimeManager.Season)

# --- PLAYER ---
signal player_moved(new_position: Vector2)
signal player_ate_food(food_data: FoodData)
signal player_money_changed(new_amount: int, delta: int)
signal player_need_critical(need_type: NeedsManager.NeedType)

# --- NPC ---
signal npc_spawned(npc_id: StringName, npc_ref: Node)
signal npc_despawned(npc_id: StringName)
signal npc_schedule_changed(npc_id: StringName, new_activity: StringName)
signal npc_path_failed(npc_id: StringName)
signal npc_dialogue_started(npc_id: StringName)
signal npc_dialogue_ended(npc_id: StringName, outcome: Dictionary)

# --- SCENE / DISTRICT ---
signal scene_transition_requested(target_district: StringName)
signal scene_transition_started(from: StringName, to: StringName)
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
signal ui_purchase_requested(item_data: ItemData)
signal ui_dialogue_choice_selected(choice_index: int)
signal ui_menu_opened(menu_id: StringName)
signal ui_menu_closed(menu_id: StringName)
```

---

## PHẦN 6: SCENE LIFECYCLE & DISTRICT TRANSITION {#phần-6}

### Quy tắc vòng đời khi Scene unload

Khi một District scene bị unload, **tất cả NPC trong scene đó sẽ bị freed**. Điều này có nghĩa:

1. **NPC cố định:** State (vị trí, trạng thái cảm xúc, schedule progress) phải được **serialized về NPCManager** trước khi scene unload — không lưu state trong Node.
2. **NPC phụ (random spawn):** Không cần lưu state. Khi quay lại district, respawn mới.

### Flow chuẩn của SceneManager:

```
[Player trigger transition]
        │
        ▼
EventBus.scene_transition_requested.emit(target)
        │
        ▼
SceneManager nhận signal
        │
        ├─→ NPCManager.serialize_district_npcs(current_district)  ← lưu state NPC
        ├─→ EventBus.scene_transition_started.emit(from, to)
        ├─→ Hiển thị loading screen (UI lắng nghe signal trên)
        ├─→ Thread: ResourceLoader.load_threaded_request(target_scene)
        │         └─→ EventBus.scene_load_progress.emit(progress)  [call_deferred]
        ├─→ SceneTree.change_scene_to_packed(loaded_scene)
        ├─→ NPCManager.restore_district_npcs(target_district)      ← khôi phục NPC cố định
        └─→ EventBus.scene_transition_completed.emit(target)
```

### Quy tắc cứng về Scene ownership:
- **Mọi Node trong scene KHÔNG ĐƯỢC** giữ reference đến Node thuộc scene khác
- **Mọi cross-scene data** phải đi qua Autoload Manager (không phải Node reference)
- **Khi scene unload**, tất cả connection đến EventBus của Node trong scene đó tự động bị ngắt (Godot tự dọn) — KHÔNG cần `disconnect` thủ công trừ khi connect từ Autoload vào scene Node

---

## PHẦN 7: NPC SYSTEM — VÒNG ĐỜI & PHÂN LOẠI {#phần-7}

### Phân loại NPC

| Loại | Mô tả | Dữ liệu tĩnh | State persistence |
|---|---|---|---|
| **Named NPC** | NPC có tên, có schedule, quan trọng với quest | `NPCData.tres` + `ScheduleData.tres` | Serialize về NPCManager khi district unload |
| **Generic NPC** | NPC phụ, spawn ngẫu nhiên để tạo không khí | `NPCTemplate.tres` (template pool) | Không lưu — respawn mới mỗi lần vào district |

### Cấu trúc Node của Named NPC:
```
NamedNPC (CharacterBase extends Node2D)
├── Sprite2D
├── CollisionShape2D
├── NavigationAgent2D
├── MovementComponent (Node)
├── SocialComponent (Node)        ← relationship data với player
├── EmotionComponent (Node)       ← mood state, reaction
├── FSM (Node)
│   ├── IdleState
│   ├── WalkToState
│   ├── WorkState
│   ├── RestState
│   └── TalkState
└── InteractionArea (Area2D)
```

### Quy tắc Schedule cho Named NPC:
- Schedule lưu trong `ScheduleData.tres` — danh sách `ScheduleEntry` theo giờ trong ngày
- `NPCManager` lắng nghe `EventBus.time_hour_changed` để trigger schedule update cho tất cả NPC cố định trong district hiện tại
- NPC **không tự lắng nghe** `time_hour_changed` — giảm số lượng signal listener

```gdscript
# ScheduleEntry — lưu trong .tres
class_name ScheduleEntry extends Resource
@export var hour: int               # 0-23
@export var activity: StringName    # "work", "eat", "rest", "walk_to_market"
@export var target_location: Vector2
@export var duration_hours: int = 1
```

### Object Pooling cho Generic NPC:
- NPCManager duy trì một **pool** của Generic NPC nodes (pre-instantiated)
- Khi district load: lấy từ pool, set position, activate
- Khi district unload: deactivate, trả về pool — không `queue_free()`
- Pool size tối đa: `@export var max_generic_pool_size: int = 20`

### NPCStateSnapshot — Contract lưu trạng thái Named NPC

Đây là struct **bắt buộc** để serialize state của Named NPC về NPCManager trước khi district unload. Mọi Agent build NPCManager hoặc Named NPC **phải** dùng đúng struct này — không tự định nghĩa schema khác.

```gdscript
## NPCStateSnapshot — Lưu trạng thái runtime của một Named NPC.
## Được NPCManager serialize trước khi district unload và restore khi district load lại.
class_name NPCStateSnapshot extends Resource

@export var npc_id: StringName              # ID định danh duy nhất — khớp với NPCData.tres
@export var district_id: StringName         # District NPC đang ở lúc serialize
@export var last_known_position: Vector2    # Vị trí cuối cùng trong district
@export var current_mood: float = 1.0       # Mood hiện tại [0.0 - 1.0]
@export var schedule_entry_index: int = 0   # Index trong ScheduleData đang thực hiện
@export var relationship_score: int = 0     # Điểm quan hệ với player [-100 đến 100]
@export var custom_flags: Dictionary = {}   # Flags tùy biến cho quest/event logic
```

**Quy tắc:** `custom_flags` chỉ được chứa primitive value (`bool`, `int`, `float`, `String`). Không lưu Node reference hay Object vào đây.

---

## PHẦN 8: TIME SYSTEM — ĐỒNG HỒ NỘI TẠI {#phần-8}

> TimeManager là **hệ thống tối quan trọng**. Mọi thứ trong game phụ thuộc vào nó.

### Cấu trúc thời gian:

```gdscript
# autoload/time_manager.gd
class_name TimeManagerClass extends Node

enum Season { SPRING, SUMMER, AUTUMN, WINTER }

# --- Cấu hình (tuỳ chỉnh qua Inspector) ---
@export var seconds_per_ingame_hour: float = 60.0   # 1 giờ game = 60 giây thực
@export var start_hour: int = 6                      # Bắt đầu ngày lúc 6h sáng
@export var start_day: int = 1
@export var start_season: Season = Season.SPRING
@export var days_per_season: int = 30

# --- State (chỉ đọc từ bên ngoài) ---
var current_hour: int = 6
var current_minute: int = 0
var current_day: int = 1
var current_season: Season = Season.SPRING
var total_days_elapsed: int = 0

# --- Nội bộ ---
var _time_accumulator: float = 0.0
var _is_paused: bool = false

func _process(delta: float) -> void:
    if _is_paused:
        return
    _time_accumulator += delta
    var seconds_per_minute: float = seconds_per_ingame_hour / 60.0
    while _time_accumulator >= seconds_per_minute:
        _time_accumulator -= seconds_per_minute
        _advance_minute()

func pause_time() -> void:
    _is_paused = true

func resume_time() -> void:
    _is_paused = false
```

### Quy tắc khi các hệ thống cần thời gian:
- **Đọc trực tiếp** `TimeManager.current_hour` — cho phép (read-only)
- **Phản ứng theo thời gian** — lắng nghe `EventBus.time_hour_changed`
- **Không** tự tính toán thời gian trong module khác — tất cả quy về TimeManager

### Thứ tự emit khi giờ thay đổi:
```
TimeManager._advance_hour()
    │
    ├─→ EventBus.time_hour_changed.emit(new_hour)
    │         ├─→ NPCManager: cập nhật schedule
    │         ├─→ NeedsManager: decay needs theo giờ
    │         └─→ QuestManager: check deadline
    │
    └─→ (nếu sang ngày mới) EventBus.time_day_changed.emit(new_day)
              ├─→ GameManager: reset daily counters
              └─→ (nếu đủ days_per_season) EventBus.time_season_changed.emit(new_season)
```

---

## PHẦN 9: SAVE/LOAD SYSTEM — KIẾN TRÚC MỞ RỘNG {#phần-9}

### Triết lý thiết kế
SaveManager được thiết kế **ngay từ đầu** để hỗ trợ encryption trong tương lai mà không cần refactor. Toàn bộ I/O đi qua một lớp adapter trừu tượng.

### Cấu trúc SaveManager:

```gdscript
# autoload/save_manager.gd
class_name SaveManagerClass extends Node

const SAVE_FILE_PATH: String = "user://save_data.json"
const SAVE_VERSION: int = 1   # Tăng lên khi format thay đổi — dùng để migrate

# --- Adapter pattern: thay thế hàm này để bật encryption ---
func _serialize(data: Dictionary) -> String:
    return JSON.stringify(data, "\t")  # plain text hiện tại

func _deserialize(raw: String) -> Dictionary:
    var result: Dictionary = {}
    var json := JSON.new()
    var err: Error = json.parse(raw)
    if err != OK:
        push_error("SaveManager: JSON parse failed — " + json.get_error_message())
        return result
    result = json.data
    return result

# --- API công khai ---
func save_game(save_data: Dictionary) -> void:
    save_data["_meta"] = {
        "version": SAVE_VERSION,
        "timestamp": Time.get_unix_time_from_system()
    }
    var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
    if file == null:
        push_error("SaveManager: Cannot open file for writing — " + str(FileAccess.get_open_error()))
        EventBus.save_completed.emit(false)
        return
    file.store_string(_serialize(save_data))
    file.close()
    EventBus.save_completed.emit(true)

func load_game() -> Dictionary:
    if not FileAccess.file_exists(SAVE_FILE_PATH):
        return {}
    var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
    if file == null:
        push_error("SaveManager: Cannot open file for reading")
        EventBus.load_completed.emit(false)
        return {}
    var raw: String = file.get_as_text()
    file.close()
    var data: Dictionary = _deserialize(raw)
    # Version migration hook
    data = _migrate_if_needed(data)
    EventBus.load_completed.emit(true)
    return data

func _migrate_if_needed(data: Dictionary) -> Dictionary:
    var version: int = data.get("_meta", {}).get("version", 0)
    if version < SAVE_VERSION:
        push_warning("SaveManager: Migrating save from v%d to v%d" % [version, SAVE_VERSION])
        # Thêm migration logic ở đây theo từng version
    return data
```

### Khi nào lưu gì:
- **Lưu vào JSON:** Player money, inventory state, quest progress, NPC relationship scores, current time/day/season, player position (district + coordinates)
- **Không lưu vào JSON:** Item definitions (lấy từ `.tres`), NPC dialogue (lấy từ `.tres`), map data

---

## PHẦN 10: GDEXTENSION — QUY TẮC TÍCH HỢP {#phần-10}

### Mô hình được phê duyệt: One-way API

```
GDScript (game logic)  ──gọi──▶  GDExtension (C++)
                       ◀──trả dữ liệu──
         (không có chiều ngược lại)
```

### Quy tắc cứng:
1. **GDExtension KHÔNG được** giữ reference đến bất kỳ Godot Object/Node nào
2. **GDExtension KHÔNG được** emit signal, gọi `call_deferred`, hay tương tác với SceneTree
3. **Kiểu trả về** chỉ được là: `bool`, `int`, `float`, `String`, `Vector2`, `Vector3`, `PackedVector2Array`, `PackedFloat32Array`, `Dictionary`, `Array` — KHÔNG phải `Object`, `Node`, hay `Resource`
4. **GDScript wrapper** là điểm duy nhất tương tác với GDExtension — không gọi GDExtension từ nhiều nơi

### Ví dụ pattern đúng:

```gdscript
# autoload hoặc component — GDScript wrapper
class_name PathfindingService extends Node

func request_path(npc_id: StringName, start: Vector2, end: Vector2) -> void:
    # Gọi C++ trên Thread để không block main thread
    var thread := Thread.new()
    thread.start(_calculate_on_thread.bind(npc_id, start, end, thread))

func _calculate_on_thread(npc_id: StringName, start: Vector2, end: Vector2, thread: Thread) -> void:
    var path: PackedVector2Array = PathfindingExt.calculate_path(start, end)
    # Chuyển kết quả về main thread
    call_deferred("_on_path_ready", npc_id, path, thread)

func _on_path_ready(npc_id: StringName, path: PackedVector2Array, thread: Thread) -> void:
    thread.wait_to_finish()
    if path.is_empty():
        EventBus.npc_path_failed.emit(npc_id)
    else:
        EventBus.npc_path_ready.emit(npc_id, path)
```

---

## PHẦN 11: THREAD & ASYNC — QUY TẮC AN TOÀN {#phần-11}

### Quy tắc bất biến:

| Rule | Chi tiết |
|---|---|
| **Signal chỉ emit từ Main Thread** | Dùng `call_deferred` nếu đang trong Thread |
| **Node không được truy cập từ Thread** | Node trong SceneTree không thread-safe — chỉ đọc/ghi data thuần |
| **Thread phải được wait_to_finish()** | Luôn gọi khi done để tránh memory leak |
| **Không dùng Thread cho logic ngắn** | Thread chỉ cho I/O nặng và GDExtension call tốn thời gian |

### Các trường hợp dùng Thread trong LifeSim:

| Use case | Pattern |
|---|---|
| Load scene mới (district transition) | `ResourceLoader.load_threaded_request()` + poll trong `_process()` |
| Pathfinding qua GDExtension | `Thread` + `call_deferred` kết quả về |
| Load save file (nếu file lớn) | `Thread` + `call_deferred` kết quả về |

### Template chuẩn cho async scene loading:

```gdscript
# Trong SceneManager
var _loading_scene_path: String = ""
var _is_loading: bool = false

func request_scene_load(scene_path: String) -> void:
    _loading_scene_path = scene_path
    _is_loading = true
    ResourceLoader.load_threaded_request(scene_path)

func _process(_delta: float) -> void:
    if not _is_loading:
        return
    var progress: Array = []
    var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(_loading_scene_path, progress)
    match status:
        ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            EventBus.scene_load_progress.emit(progress[0])
        ResourceLoader.THREAD_LOAD_LOADED:
            _is_loading = false
            var packed: PackedScene = ResourceLoader.load_threaded_get(_loading_scene_path)
            get_tree().change_scene_to_packed(packed)
            EventBus.scene_transition_completed.emit(_loading_scene_path)
        ResourceLoader.THREAD_LOAD_FAILED:
            _is_loading = false
            push_error("SceneManager: Failed to load scene — " + _loading_scene_path)
```

---

## PHẦN 12: TIÊU CHUẨN CODE GDSCRIPT {#phần-12}

### 1. Static Typing — BẮT BUỘC tuyệt đối

```gdscript
# CẤM
var health = 100
func do_damage(amount):
    health -= amount

# BẮT BUỘC
var health: int = 100
func do_damage(amount: int) -> void:
    health -= amount
```

Đối với giá trị nullable:
```gdscript
var current_target: CharacterBody2D = null  # OK — nullable node reference
var optional_data: Variant = null           # Dùng Variant nếu thực sự đa kiểu
```

### 2. Naming Conventions

| Loại | Convention | Ví dụ |
|---|---|---|
| File / Folder | `snake_case` | `player_controller.gd`, `home_district.tscn` |
| Class / Node | `PascalCase` | `class_name PlayerController`, node `HealthComponent` |
| Variable / Function | `snake_case` | `var current_health: int`, `func update_ui():` |
| Constant | `UPPER_SNAKE_CASE` | `const MAX_HUNGER: float = 100.0` |
| Signal | `snake_case` quá khứ | `signal item_picked_up(item: ItemData)` |
| Private member | Tiền tố `_` | `var _internal_timer: float`, `func _process_logic():` |
| Enum | `PascalCase` (type) + `UPPER_SNAKE_CASE` (value) | `enum Season { SPRING, SUMMER }` |
| Export var | `snake_case` + comment mô tả | `@export var interaction_range: float = 50.0` |

### 3. Assert cho Component dependency

```gdscript
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
    assert(_sprite != null, "[MovementComponent] Yêu cầu node con Sprite2D!")
    assert(_nav_agent != null, "[MovementComponent] Yêu cầu node con NavigationAgent2D!")
```

### 4. Không Magic Numbers

```gdscript
# CẤM
if distance < 50:
    _start_interaction()

# BẮT BUỘC
const INTERACT_RANGE: float = 50.0

# Hoặc nếu cần tuỳ chỉnh per-instance
@export var interact_range: float = 50.0

if distance < interact_range:
    _start_interaction()
```

### 5. DocString bắt buộc cho mọi class và hàm public

```gdscript
## NeedsManager — Quản lý các nhu cầu sinh lý của người chơi (hunger, energy, mood, hygiene).
## Lắng nghe EventBus để decay theo thời gian và phản ứng khi player thực hiện hành động.
## Phát signal [player_need_critical] khi bất kỳ need nào xuống dưới ngưỡng nguy hiểm.
class_name NeedsManagerClass extends Node

## Tăng giá trị hunger lên [amount]. Clamp trong [0.0, MAX_HUNGER].
## Được gọi nội bộ khi player ăn — không gọi trực tiếp từ bên ngoài.
func _increase_hunger(amount: float) -> void:
    pass
```

### 6. Error Handling — không im lặng

```gdscript
# CẤM — lỗi trôi qua im lặng
var file := FileAccess.open(path, FileAccess.READ)
var content := file.get_as_text()

# BẮT BUỘC
var file := FileAccess.open(path, FileAccess.READ)
if file == null:
    push_error("[SaveManager] Không thể mở file: %s — Error: %s" % [path, str(FileAccess.get_open_error())])
    return
var content: String = file.get_as_text()
```

### 7. `preload` vs `load` — Khi nào dùng cái nào

| | `preload` | `load` |
|---|---|---|
| **Thời điểm** | Compile time (khi script được parse) | Runtime (khi hàm được gọi) |
| **Dùng khi** | Path cố định, biết trước lúc viết code | Path động (tạo từ string, ID...) |
| **Ảnh hưởng startup** | Tăng thời gian load ban đầu | Không ảnh hưởng startup |
| **Dùng ở đâu** | Chỉ ở global scope hoặc const | Trong hàm, sau khi có đủ thông tin |

```gdscript
# preload — đúng cho resource tĩnh, biết trước
const APPLE_DATA: ItemData = preload("res://data/items/apple.tres")
const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")

# load — đúng cho resource động theo ID
func get_item_data(item_id: StringName) -> ItemData:
    var path: String = "res://data/items/%s.tres" % item_id
    if not ResourceLoader.exists(path):
        push_error("[ItemDB] Item không tồn tại: " + path)
        return null
    return load(path) as ItemData
```

**CẤM:**
```gdscript
# CẤM — preload với path động (không compile được)
var path: String = "res://data/items/" + item_id + ".tres"
const DATA = preload(path)  # syntax error

# CẤM — load ở global scope gây block main thread khi script load
var HEAVY_TEXTURE: Texture2D = load("res://assets/ui/background.png")  # ngoài hàm = CẤM
```

### 8. `_process` vs `_physics_process` — Quy tắc bắt buộc

| Callback | Dùng cho | Tần suất |
|---|---|---|
| `_process(delta)` | UI update, input polling, timer, animation, non-physics logic | Mỗi frame (vsync) |
| `_physics_process(delta)` | Movement của CharacterBody2D, collision detection, NavigationAgent | Cố định (default 60Hz) |

**Quy tắc cứng:**
- **Movement của NPC và Player** (có `CharacterBody2D`) → BẮT BUỘC dùng `_physics_process`
- **Poll trạng thái ResourceLoader** (async scene loading) → BẮT BUỘC dùng `_process`
- **UI update** → chỉ dùng `_process` hoặc signal-driven (không dùng `_physics_process`)
- **TimeManager tick** → dùng `_process` (time không phụ thuộc physics)

```gdscript
# CẤM — movement trong _process
func _process(delta: float) -> void:
    velocity = direction * SPEED
    move_and_slide()  # CẤM trong _process

# BẮT BUỘC
func _physics_process(delta: float) -> void:
    velocity = direction * SPEED
    move_and_slide()  # Đúng trong _physics_process
```

---

## PHẦN 13: QUY TRÌNH LÀM VIỆC CỦA AGENT {#phần-13}

Khi được giao một task/ticket, Agent PHẢI tuân thủ đúng 6 bước sau theo thứ tự:

### BƯỚC 1: XÁC MINH NGỮ CẢNH
- [ ] Đọc toàn bộ `agent_rulebook.md` (file này)
- [ ] Đọc `implementation_plan.md` — xác định Phase, dependency với hệ thống nào
- [ ] `grep`/search xem EventBus đã có signal liên quan chưa — **không tạo signal trùng lặp**
- [ ] Kiểm tra Autoload Registry (Phần 4) — xác nhận thứ tự load và Manager liên quan
- [ ] Đọc `changelog.md` — nắm bắt những gì Agent trước đã làm và cảnh báo nào còn đó

### BƯỚC 2: THIẾT KẾ MODULE
- [ ] Xác định signal mới cần thêm vào EventBus (nếu có)
- [ ] Vẽ cấu trúc Node tree cho scene/component mới
- [ ] Xác định `.tres` Resource class nào cần tạo
- [ ] Xác định module này **lắng nghe** signal nào và **phát** signal nào — ghi ra giấy trước khi code
- [ ] Đảm bảo module này hoàn toàn độc lập — không hardcode reference đến scene path hay node path ngoài module

### BƯỚC 3: THỰC THI
- [ ] Viết code với static typing đầy đủ
- [ ] Viết DocString cho class và mọi hàm public
- [ ] Xử lý error rõ ràng — dùng `push_error()` cho lỗi nghiêm trọng, `push_warning()` cho cảnh báo
- [ ] Nếu cần sửa `event_bus.gd` — chỉ APPEND signal mới, không xóa signal cũ
- [ ] Nếu cần sửa code của Agent khác — ghi chú rõ lý do trong comment và changelog

### BƯỚC 4: SELF-CHECK (Xem Phần 14)

### BƯỚC 5: TÀI LIỆU HOÁ
- [ ] Mọi class có DocString
- [ ] Signal mới đã cập nhật vào bảng Registry (Phần 5 của rulebook)
- [ ] Nếu thêm Autoload mới — cập nhật Autoload Registry (Phần 4) và ghi rõ thứ tự load

### BƯỚC 6: CẬP NHẬT CHANGELOG — BẮT BUỘC, KHÔNG ĐƯỢC BỎ QUA
- Mở `changelog.md`
- **CHỈ APPEND** vào cuối file — tuyệt đối không sửa log của Agent khác
- Dùng đúng format mẫu (xem changelog.md)
- Ghi rõ: signal nào mới, file nào tạo/sửa, hệ thống nào có thể bị ảnh hưởng
- Nếu có bug chưa fix hoặc việc chưa hoàn thiện — **BẮT BUỘC** ghi vào mục `⚠️ Known Issues / Handoff Notes`

---

## PHẦN 14: SELF-CHECK CHECKLIST {#phần-14}

Chạy checklist này trước khi đánh dấu task là Done:

### Kiến trúc
- [ ] Không có Autoload nào gọi trực tiếp hàm của Autoload khác (ngoại trừ đọc read-only từ TimeManager)
- [ ] Không có UI script nào thay đổi data backend trực tiếp
- [ ] Không có cây kế thừa nào sâu hơn 2 cấp
- [ ] Không có `.json` nào dùng cho data tĩnh
- [ ] Signal mới đã được thêm vào `event_bus.gd` và Registry trong rulebook

### Thread Safety
- [ ] Mọi `EventBus.*.emit()` đều được gọi từ main thread
- [ ] Nếu dùng Thread — đã có `call_deferred` để chuyển kết quả về main thread
- [ ] Mọi Thread đều có `wait_to_finish()` khi kết thúc

### GDExtension
- [ ] GDExtension không giữ reference đến Node
- [ ] GDExtension không emit signal
- [ ] Chỉ có một GDScript wrapper duy nhất tương tác với GDExtension

### Code Quality
- [ ] 100% static typing cho biến, tham số, return type
- [ ] Không có magic number — tất cả là `const` hoặc `@export`
- [ ] Mọi class public có DocString
- [ ] Mọi error có `push_error()` với message rõ ràng
- [ ] Tên file/folder đúng `snake_case`
- [ ] Tên class đúng `PascalCase` với `class_name`

### Scene Lifecycle
- [ ] Không có cross-scene Node reference
- [ ] NPC cố định có serialize state về NPCManager trước khi district unload (dùng `NPCStateSnapshot`)
- [ ] Generic NPC dùng Object Pool — không `queue_free()` khi unload
- [ ] Không có Node nào tự gọi `change_scene_to_file()` hoặc `change_scene_to_packed()` — chỉ SceneManager được phép
- [ ] Mọi `EventBus.*.connect()` chỉ được gọi trong `_ready()`, không trong `_init()`
- [ ] Nếu Autoload connect vào Scene Node — đã có `disconnect` trong `_exit_tree()` của Node đó

### Save System
- [ ] Chỉ lưu dynamic state vào JSON — không lưu static data
- [ ] Có trường `_meta.version` trong save file
- [ ] Có xử lý lỗi khi file không tồn tại hoặc parse thất bại

### Changelog
- [ ] Đã APPEND vào `changelog.md` với đầy đủ thông tin
- [ ] Đã ghi rõ Known Issues / Handoff Notes nếu có việc còn dang dở

---

> **LỜI NHẮC NHỞ TỚI AI AGENTS:**
> Bạn là kỹ sư hệ thống, không phải thợ code dạo. Code mọi thứ với tư duy:
> *"Module này sẽ được AI Agent khác đọc vào tuần sau trong một context mới hoàn toàn. Nó phải tự giải thích được chính nó."*
>
> Nếu bạn phải giải thích tại sao code của bạn hoạt động — đó là dấu hiệu code cần được viết lại rõ ràng hơn, không phải giải thích thêm.

---

*Rulebook v2.1 — Mọi thay đổi phải được ghi vào `changelog.md`. Mọi vi phạm Golden Rules là FAILED TASK.*