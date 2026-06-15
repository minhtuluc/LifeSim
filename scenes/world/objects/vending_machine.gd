extends Node2D

@onready var interactable_area: InteractableArea = $InteractableArea

@export var items_for_sale: Array[ItemData] = []

func _ready() -> void:
	interactable_area.interacted.connect(_on_interacted)

func _on_interacted(_user: Node) -> void:
	var shop_ui: Node = get_tree().get_first_node_in_group("shop_ui")
	if shop_ui:
		shop_ui.open_shop(items_for_sale)
