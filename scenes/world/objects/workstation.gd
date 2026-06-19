extends Node2D

@onready var interactable_area: InteractableArea = $InteractableArea

func _ready() -> void:
	interactable_area.interacted.connect(_on_interacted)

func _on_interacted(_user: Node) -> void:
	# Nếu Energy quá thấp thì không cho làm việc
	var hours: int = 2
	var energy_cost: float = 25.0
	var money_earned: int = 80
	
	EventBus.player_worked.emit(hours, energy_cost, money_earned)
