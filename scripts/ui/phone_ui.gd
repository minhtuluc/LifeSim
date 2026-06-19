extends PanelContainer
class_name PhoneUI

@onready var contacts_container: VBoxContainer = %ContactsContainer
@onready var close_button: Button = %CloseButton

func _ready() -> void:
	hide()
	close_button.pressed.connect(_on_close_pressed)
	EventBus.phone_contacts_updated.connect(_on_contacts_updated)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_P:
			if visible:
				_on_close_pressed()
			else:
				show()
				EventBus.ui_phone_opened.emit()
			get_viewport().set_input_as_handled()

func _on_close_pressed() -> void:
	hide()
	EventBus.ui_phone_closed.emit()

func _on_contacts_updated(contacts_data: Dictionary) -> void:
	for child in contacts_container.get_children():
		child.queue_free()
		
	for npc_id in contacts_data:
		var data: Dictionary = contacts_data[npc_id] as Dictionary
		var item: HBoxContainer = HBoxContainer.new()
		
		# Portrait (optional, if missing just skip or use placeholder)
		if data.get("portrait"):
			var tex_rect: TextureRect = TextureRect.new()
			tex_rect.texture = data["portrait"] as Texture2D
			tex_rect.custom_minimum_size = Vector2(32, 32)
			tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			item.add_child(tex_rect)
			
		var label: Label = Label.new()
		var p_name: String = data.get("name", str(npc_id)) as String
		var fp: int = data.get("friendship_points", 0) as int
		label.text = "%s: %d FP" % [p_name, fp]
		
		item.add_child(label)
		contacts_container.add_child(item)
