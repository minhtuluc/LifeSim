## Quản lý các trạng thái xã hội của NPC như Friendship, Schedule.
## Xử lý save/load tự động thông qua EventBus.
extends Node
class_name NPCManagerClass

var _npc_friendships: Dictionary = {}
var _schedule_registry: Dictionary = {}

func _ready() -> void:
	EventBus.npc_gift_received.connect(_on_gift_received)
	EventBus.npc_schedule_registered.connect(register_schedule)
	EventBus.save_requested.connect(_on_save_requested)
	EventBus.load_completed.connect(_on_load_completed)
	EventBus.time_hour_changed.connect(_on_hour_changed)
	EventBus.ui_phone_opened.connect(_on_ui_phone_opened)

## Trả về điểm thân thiết hiện tại của NPC.
func get_friendship(npc_id: StringName) -> int:
	return _npc_friendships.get(npc_id, 0)

## Thay đổi điểm thân thiết của NPC. Giá trị được giới hạn từ -100 đến 100.
func change_friendship(npc_id: StringName, delta: int) -> void:
	var old_val: int = get_friendship(npc_id)
	var new_val: int = clampi(old_val + delta, -100, 100)
	var actual_delta: int = new_val - old_val
	
	if actual_delta != 0:
		_npc_friendships[npc_id] = new_val
		EventBus.npc_friendship_changed.emit(npc_id, new_val, actual_delta)

func _on_gift_received(npc_id: StringName, _item_data: Resource) -> void:
	change_friendship(npc_id, 10)

func register_schedule(npc_id: StringName, entries: Array) -> void:
	_schedule_registry[npc_id] = entries

func _on_hour_changed(hour: int) -> void:
	for npc_id in _schedule_registry:
		var id: StringName = npc_id as StringName
		var entries: Array = _schedule_registry[id]
		for entry in entries:
			var sched_entry: Resource = entry as Resource # assuming ScheduleEntry
			var e_hour: int = sched_entry.get("hour")
			if e_hour == hour:
				EventBus.npc_schedule_target_changed.emit(id, sched_entry.get("target_position"), sched_entry.get("activity"))
				break

func _on_save_requested(save_data: Dictionary) -> void:
	var friendship_data: Dictionary = {}
	for npc_id in _npc_friendships:
		friendship_data[str(npc_id)] = _npc_friendships[npc_id]
		
	save_data["npc"] = {
		"friendships": friendship_data
	}

func _on_load_completed(load_data: Dictionary) -> void:
	_npc_friendships.clear()
	if load_data.has("npc"):
		var npc_data: Dictionary = load_data["npc"] as Dictionary
		if npc_data.has("friendships"):
			var f_data: Dictionary = npc_data["friendships"] as Dictionary
			for key in f_data:
				var str_key: StringName = StringName(key as String)
				var val: int = f_data[key] as int
				_npc_friendships[str_key] = val
				EventBus.npc_friendship_changed.emit(str_key, val, 0)

func _on_ui_phone_opened() -> void:
	var data: Dictionary = {}
	var npcs: Array = get_tree().get_nodes_in_group("npcs")
	for node in npcs:
		if node and "npc_id" in node:
			var npc_id: StringName = node.get("npc_id") as StringName
			if npc_id != &"":
				var dialogue_data: Resource = node.get("dialogue_data") as Resource
				var p_name: String = str(npc_id)
				var portrait: Texture2D = null
				if dialogue_data:
					p_name = dialogue_data.get("npc_name") as String
					portrait = dialogue_data.get("portrait") as Texture2D
				
				data[npc_id] = {
					"name": p_name,
					"portrait": portrait,
					"friendship_points": get_friendship(npc_id)
				}
	EventBus.phone_contacts_updated.emit(data)
