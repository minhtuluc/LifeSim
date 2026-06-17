extends CharacterBody2D
class_name NPCBase

@export var npc_id: StringName = &""
@export var dialogue_data: DialogueData

@onready var interactable_area: InteractableArea = $InteractableArea

func _ready() -> void:
	if interactable_area:
		interactable_area.interacted.connect(_on_interacted)
	EventBus.ui_npc_interaction_selected.connect(_on_interaction_selected)
	EventBus.npc_schedule_target_changed.connect(_on_schedule_changed)

func _on_interacted(_user: Node) -> void:
	if npc_id == &"":
		push_warning("NPC chưa được gán npc_id!")
		return
	if dialogue_data:
		EventBus.ui_npc_interaction_requested.emit(npc_id, dialogue_data)
	else:
		push_warning("NPC chưa có dữ liệu thoại!")

func _on_interaction_selected(id: StringName, action_id: StringName) -> void:
	if id != npc_id:
		return
		
	if action_id == &"talk":
		if dialogue_data:
			EventBus.npc_dialogue_started.emit(dialogue_data)
		else:
			push_warning("Không có dialogue_data để nói chuyện!")

func _on_schedule_changed(id: StringName, target_pos: Vector2, _activity: StringName) -> void:
	if id == npc_id:
		global_position = target_pos
