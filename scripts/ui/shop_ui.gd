extends PanelContainer

@onready var item_list: ItemList = %ItemList
@onready var buy_btn: Button = %BuyButton
@onready var close_btn: Button = %CloseButton

var current_items: Array[ItemData] = []
var player_inventory: InventoryComponent

func _ready() -> void:
	add_to_group("shop_ui")
	buy_btn.pressed.connect(_on_buy_pressed)
	close_btn.pressed.connect(hide)
	item_list.item_selected.connect(_on_item_selected)
	hide()
	
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("InventoryComponent"):
		player_inventory = player.get_node("InventoryComponent")

func open_shop(items: Array[ItemData]) -> void:
	current_items = items
	item_list.clear()
	for item in items:
		item_list.add_item(item.display_name + " - " + str(item.base_price) + "G", item.icon)
	show()
	buy_btn.disabled = true

func _on_item_selected(_index: int) -> void:
	buy_btn.disabled = false

func _on_buy_pressed() -> void:
	var selected = item_list.get_selected_items()
	if selected.size() > 0:
		var index = selected[0]
		var item = current_items[index]
		
		# Kiểm tra tiền
		if GameManager.money >= item.base_price:
			if player_inventory and player_inventory.add_item(item):
				GameManager.change_money(-item.base_price)
			else:
				print("Túi đồ đầy!")
		else:
			print("Không đủ tiền!")
