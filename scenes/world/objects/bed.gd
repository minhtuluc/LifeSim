extends Node2D

@onready var interactable_area: InteractableArea = $InteractableArea

func _ready() -> void:
	interactable_area.interacted.connect(_on_interacted)

func _on_interacted(_user: Node) -> void:
	# Tính toán số giờ cần ngủ để đến 6h sáng hôm sau
	var hours_to_skip: int = 0
	
	if TimeManager.current_hour >= 22:
		hours_to_skip = (24 - TimeManager.current_hour) + 6
	else:
		hours_to_skip = 6 - TimeManager.current_hour
	
	if hours_to_skip <= 0:
		hours_to_skip = 24
		
	EventBus.player_slept.emit(hours_to_skip)
