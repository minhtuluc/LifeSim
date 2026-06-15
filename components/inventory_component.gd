extends Node
class_name InventoryComponent

signal inventory_changed

@export var max_slots: int = 16
var items: Array[ItemData] = []

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
