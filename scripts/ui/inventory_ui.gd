extends PanelContainer

@onready var item_list: ItemList = %ItemList
@onready var consume_btn: Button = %ConsumeButton
@onready var close_btn: Button = %CloseButton

var inventory: InventoryComponent
var _gift_mode: bool = false
var _gift_npc_id: StringName = &""

func _ready() -> void:
	consume_btn.pressed.connect(_on_consume_pressed)
	close_btn.pressed.connect(_hide_ui)
	item_list.item_activated.connect(_on_item_activated)
	item_list.item_selected.connect(_on_item_selected)
	
	EventBus.ui_npc_interaction_selected.connect(_on_interaction_selected)
	
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
				_hide_ui()
			else:
				show()
				_refresh_ui()
			get_viewport().set_input_as_handled()

func _hide_ui() -> void:
	_gift_mode = false
	_gift_npc_id = &""
	hide()

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
	if _gift_mode:
		consume_btn.text = "Tặng quà"
	else:
		consume_btn.text = "Sử dụng"

func _on_interaction_selected(npc_id: StringName, action_id: StringName) -> void:
	if action_id == &"gift":
		_gift_mode = true
		_gift_npc_id = npc_id
		show()
		_refresh_ui()

func _on_item_selected(_index: int) -> void:
	consume_btn.disabled = false

func _use_selected_item(index: int) -> void:
	if not inventory or index < 0 or index >= inventory.items.size():
		return
		
	if _gift_mode:
		var item: ItemData = inventory.items[index]
		EventBus.npc_gift_received.emit(_gift_npc_id, item)
		inventory.remove_item(index)
		_hide_ui()
	else:
		inventory.consume_item(index)

func _on_item_activated(index: int) -> void:
	_use_selected_item(index)

func _on_consume_pressed() -> void:
	var selected: PackedInt32Array = item_list.get_selected_items()
	if selected.size() > 0:
		_use_selected_item(selected[0])
