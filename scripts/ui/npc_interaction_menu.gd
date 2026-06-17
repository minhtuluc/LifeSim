extends Control

@onready var talk_button: Button = %TalkButton
@onready var gift_button: Button = %GiftButton
@onready var close_button: Button = %CloseButton

var current_npc_id: StringName = &""

func _ready() -> void:
	hide()
	EventBus.ui_npc_interaction_requested.connect(_on_interaction_requested)
	talk_button.pressed.connect(_on_talk_pressed)
	gift_button.pressed.connect(_on_gift_pressed)
	close_button.pressed.connect(hide)

func _on_interaction_requested(npc_id: StringName, _dialogue_data: Resource) -> void:
	current_npc_id = npc_id
	show()

func _on_talk_pressed() -> void:
	if current_npc_id != &"":
		EventBus.ui_npc_interaction_selected.emit(current_npc_id, &"talk")
		hide()

func _on_gift_pressed() -> void:
	if current_npc_id != &"":
		EventBus.ui_npc_interaction_selected.emit(current_npc_id, &"gift")
		hide()
