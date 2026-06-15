extends Control

@onready var portrait_rect: TextureRect = %PortraitRect
@onready var name_label: Label = %NameLabel
@onready var text_label: RichTextLabel = %TextLabel

var current_dialogue: DialogueData = null
var current_line_index: int = 0

func _ready() -> void:
	hide()
	EventBus.npc_dialogue_started.connect(_on_dialogue_started)

func _on_dialogue_started(data: Resource) -> void:
	var dialogue_data: DialogueData = data as DialogueData
	if not dialogue_data or dialogue_data.lines.is_empty():
		return
		
	current_dialogue = dialogue_data
	current_line_index = 0
	
	name_label.text = current_dialogue.npc_name
	portrait_rect.texture = current_dialogue.portrait
	_show_current_line()
	
	show()

func _show_current_line() -> void:
	if current_line_index < current_dialogue.lines.size():
		text_label.text = current_dialogue.lines[current_line_index]
	else:
		_end_dialogue()

func _end_dialogue() -> void:
	hide()
	current_dialogue = null
	EventBus.npc_dialogue_ended.emit()

func _input(event: InputEvent) -> void:
	if not visible:
		return
		
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		get_viewport().set_input_as_handled()
		current_line_index += 1
		_show_current_line()
