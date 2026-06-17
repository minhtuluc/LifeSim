extends Node
class_name NPCScheduleComponent

@export var entries: Array[ScheduleEntry] = []

func _ready() -> void:
	await get_tree().process_frame
	var parent: Node = get_parent()
	if parent and "npc_id" in parent:
		var npc_id: StringName = parent.get("npc_id") as StringName
		if npc_id != &"":
			NPCManager.register_schedule(npc_id, entries)
