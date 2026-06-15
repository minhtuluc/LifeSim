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
