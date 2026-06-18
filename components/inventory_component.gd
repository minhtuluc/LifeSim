extends Node
class_name InventoryComponent

signal inventory_changed

@export var max_slots: int = 16
var items: Array[ItemData] = []

func _ready() -> void:
	EventBus.save_requested.connect(_on_save_requested)
	EventBus.load_completed.connect(_on_load_completed)
	EventBus.ui_gift_item_selected.connect(_on_gift_item_selected)

func _on_gift_item_selected(npc_id: StringName, item_index: int) -> void:
	if item_index >= 0 and item_index < items.size():
		var item: ItemData = items[item_index]
		remove_item(item_index)
		EventBus.npc_gift_received.emit(npc_id, item)

func _on_save_requested(save_data: Dictionary) -> void:
	var inv_data: Array = []
	for item in items:
		inv_data.append(item.resource_path)
	save_data["inventory"] = inv_data

func _on_load_completed(load_data: Dictionary) -> void:
	if load_data.has("inventory"):
		var inv_data: Array = load_data["inventory"] as Array
		items.clear()
		for path in inv_data:
			var path_str: String = path as String
			var item: Resource = load(path_str)
			if item and item is ItemData:
				items.append(item as ItemData)
		inventory_changed.emit()

func add_item(item: ItemData) -> bool:
	if items.size() < max_slots:
		items.append(item)
		inventory_changed.emit()
		return true
	return false

func remove_item(index: int) -> void:
	if index >= 0 and index < items.size():
		items.remove_at(index)
		inventory_changed.emit()

func get_items() -> Array[ItemData]:
	return items

func consume_item(index: int) -> void:
	if index >= 0 and index < items.size():
		var item: ItemData = items[index]
		if item.is_consumable:
			EventBus.player_ate_food.emit(item)
			remove_item(index)
