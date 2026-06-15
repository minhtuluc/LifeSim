extends CharacterBody2D
class_name NPCBase

@export var dialogue_data: DialogueData

@onready var interactable_area: InteractableArea = $InteractableArea

func _ready() -> void:
	if interactable_area:
		interactable_area.interacted.connect(_on_interacted)

func _on_interacted(_user: Node) -> void:
	if dialogue_data:
		EventBus.npc_dialogue_started.emit(dialogue_data)
	else:
		print("NPC chưa có dữ liệu thoại!")
