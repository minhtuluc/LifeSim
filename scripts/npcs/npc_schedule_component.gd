## Component gắn vào NPC để định nghĩa lịch trình.
## Tự động đăng ký lịch trình qua EventBus khi khởi tạo.
extends Node
class_name NPCScheduleComponent

@export var entries: Array[ScheduleEntry] = []

func _ready() -> void:
	await get_tree().process_frame
	var parent: Node = get_parent()
	if parent and "npc_id" in parent:
		var npc_id: StringName = parent.get("npc_id") as StringName
		if npc_id != &"":
			EventBus.npc_schedule_registered.emit(npc_id, entries)
