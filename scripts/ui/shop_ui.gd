extends PanelContainer

@onready var item_list: ItemList = %ItemList
@onready var buy_btn: Button = %BuyButton
@onready var close_btn: Button = %CloseButton

var current_items: Array[ItemData] = []
var current_money: int = 0

func _ready() -> void:
	add_to_group("shop_ui")
	buy_btn.pressed.connect(_on_buy_pressed)
	close_btn.pressed.connect(hide)
	item_list.item_selected.connect(_on_item_selected)
	hide()
	
	EventBus.player_money_changed.connect(_on_player_money_changed)
	current_money = GameManager.money

func _on_player_money_changed(new_amount: int, _delta: int) -> void:
	current_money = new_amount

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
	var selected: PackedInt32Array = item_list.get_selected_items()
	if selected.size() > 0:
		var index: int = selected[0]
		var item: ItemData = current_items[index]
		
		if current_money >= item.base_price:
			EventBus.ui_purchase_requested.emit(item)
		else:
			print("Không đủ tiền!")
