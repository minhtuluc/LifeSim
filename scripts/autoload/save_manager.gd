extends Node
class_name SaveManagerClass

const SAVE_PATH = "user://savegame.json"

func _ready() -> void:
	pass

func save_game() -> void:
	EventBus.save_requested.emit()
	
	var save_data = {
		"time": {
			"hour": TimeManager.current_hour,
			"minute": TimeManager.current_minute,
			"day": TimeManager.current_day,
			"season": TimeManager.current_season,
			"total_days": TimeManager.total_days_elapsed
		},
		"game": {
			"money": GameManager.money,
			"district": GameManager.current_district
		},
		"needs": {
			"hunger": NeedsManager.hunger,
			"energy": NeedsManager.energy,
			"mood": NeedsManager.mood,
			"hygiene": NeedsManager.hygiene,
			"social": NeedsManager.social
		},
		"inventory": _get_inventory_data()
	}
	
	var json_string = JSON.stringify(save_data, "\t")
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		EventBus.save_completed.emit(true)
		print("Lưu game thành công: ", SAVE_PATH)
	else:
		EventBus.save_completed.emit(false)
		print("Lỗi lưu game!")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Không tìm thấy file save!")
		EventBus.load_completed.emit(false)
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			var save_data = json.data
			_restore_data(save_data)
			EventBus.load_completed.emit(true)
			print("Tải game thành công!")
		else:
			EventBus.load_completed.emit(false)
			print("Lỗi parse JSON!")

func _get_inventory_data() -> Array:
	var inv_data = []
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("InventoryComponent"):
		var inv = player.get_node("InventoryComponent")
		for item in inv.get_items():
			inv_data.append(item.resource_path)
	return inv_data

func _restore_data(data: Dictionary) -> void:
	if data.has("time"):
		var t = data["time"]
		TimeManager.current_hour = int(t["hour"])
		TimeManager.current_minute = int(t["minute"])
		TimeManager.current_day = int(t["day"])
		TimeManager.current_season = int(t["season"])
		TimeManager.total_days_elapsed = int(t["total_days"])
		EventBus.time_hour_changed.emit(TimeManager.current_hour)
		EventBus.time_tick.emit(TimeManager.current_hour, TimeManager.current_minute)
		
	if data.has("game"):
		var g = data["game"]
		GameManager.money = int(g["money"])
		GameManager.current_district = StringName(g["district"])
		EventBus.player_money_changed.emit(GameManager.money, 0)
		
	if data.has("needs"):
		var n = data["needs"]
		NeedsManager.hunger = float(n["hunger"])
		NeedsManager.energy = float(n["energy"])
		NeedsManager.mood = float(n["mood"])
		NeedsManager.hygiene = float(n["hygiene"])
		NeedsManager.social = float(n["social"])
		EventBus.needs_all_updated.emit(NeedsManager.hunger, NeedsManager.energy, NeedsManager.mood, NeedsManager.hygiene, NeedsManager.social)
		
	if data.has("inventory"):
		var inv_data = data["inventory"]
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_node("InventoryComponent"):
			var inv = player.get_node("InventoryComponent")
			inv.items.clear()
			for path in inv_data:
				var item = load(path)
				if item:
					inv.items.append(item)
			inv.inventory_changed.emit()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_F5:
			save_game()
		elif event.physical_keycode == KEY_F9:
			load_game()
