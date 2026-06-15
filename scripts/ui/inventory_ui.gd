extends PanelContainer

@onready var item_list: ItemList = %ItemList
@onready var consume_btn: Button = %ConsumeButton
@onready var close_btn: Button = %CloseButton

var inventory: InventoryComponent

func _ready() -> void:
	consume_btn.pressed.connect(_on_consume_pressed)
	close_btn.pressed.connect(hide)
	item_list.item_activated.connect(_on_item_activated)
	item_list.item_selected.connect(_on_item_selected)
	hide()
	
	# Đợi 1 frame để đảm bảo Player đã spawn
	await get_tree().process_frame
	var player: Node = get_tree().get_first_node_in_group("player")
	if player and player.has_node("InventoryComponent"):
		setup(player.get_node("InventoryComponent"))

func setup(inv: InventoryComponent) -> void:
	inventory = inv
	inventory.inventory_changed.connect(_refresh_ui)
	_refresh_ui()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_I:
			if visible:
				hide()
			else:
				show()
				_refresh_ui()
			get_viewport().set_input_as_handled()

func _refresh_ui() -> void:
	if not is_inside_tree() or not visible:
		return
	item_list.clear()
	if not inventory:
		return
		
	var items: Array[ItemData] = inventory.get_items()
	for item in items:
		item_list.add_item(item.display_name, item.icon)
	
	consume_btn.disabled = true

func _on_item_selected(_index: int) -> void:
	consume_btn.disabled = false

func _on_item_activated(index: int) -> void:
	if inventory:
		inventory.consume_item(index)

func _on_consume_pressed() -> void:
	var selected: PackedInt32Array = item_list.get_selected_items()
	if selected.size() > 0:
		var index: int = selected[0]
		inventory.consume_item(index)
