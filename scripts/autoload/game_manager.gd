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
	EventBus.player_worked.connect(_on_player_worked)
	EventBus.save_requested.connect(_on_save_requested)
	EventBus.load_completed.connect(_on_load_completed)
	EventBus.ui_purchase_requested.connect(_on_ui_purchase_requested)

func _on_save_requested(save_data: Dictionary) -> void:
	save_data["game"] = {
		"money": money,
		"district": current_district
	}

func _on_load_completed(load_data: Dictionary) -> void:
	if load_data.has("game"):
		var g: Dictionary = load_data["game"] as Dictionary
		money = int(g["money"])
		current_district = StringName(g["district"])
		EventBus.player_money_changed.emit(money, 0)

func _on_ui_purchase_requested(item_data: Resource) -> void:
	var item: ItemData = item_data as ItemData
	if not item: return
	if money >= item.base_price:
		var player: Node = get_tree().get_first_node_in_group("player")
		if player and player.has_node("InventoryComponent"):
			var inv: InventoryComponent = player.get_node("InventoryComponent")
			if inv.add_item(item):
				change_money(-item.base_price)

func _on_player_worked(_hours: int, _energy_cost: float, money_earned: int) -> void:
	change_money(money_earned)

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
