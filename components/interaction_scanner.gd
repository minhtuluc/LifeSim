extends Area2D
class_name InteractionScanner

## Label dùng để hiển thị prompt (VD: "E - Ngủ")
@export var prompt_label: Label

var interactables: Array[InteractableArea] = []

func _ready() -> void:
	# Scanner nằm ở layer 0, quét mask 2 (mask của InteractableArea)
	collision_layer = 0
	collision_mask = 2
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	if prompt_label:
		prompt_label.hide()

func _on_area_entered(area: Area2D) -> void:
	if area is InteractableArea:
		interactables.append(area)
		_update_prompt()

func _on_area_exited(area: Area2D) -> void:
	if area is InteractableArea:
		interactables.erase(area)
		_update_prompt()

func _update_prompt() -> void:
	if not prompt_label:
		return
		
	if interactables.is_empty():
		prompt_label.hide()
	else:
		var target: InteractableArea = interactables.back()
		prompt_label.text = "[E] " + target.prompt_text
		prompt_label.show()

func _unhandled_input(event: InputEvent) -> void:
	# Dùng trực tiếp KEY_E thay vì định nghĩa trong Input Map để nhanh gọn
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_E:
			if not interactables.is_empty():
				var target: InteractableArea = interactables.back()
				# Gọi interact và truyền parent (người dùng) vào
				target.interact(get_parent())
				get_viewport().set_input_as_handled()
