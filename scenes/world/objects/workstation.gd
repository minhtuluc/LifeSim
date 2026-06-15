extends Node2D

@onready var interactable_area: InteractableArea = $InteractableArea

func _ready() -> void:
	interactable_area.interacted.connect(_on_interacted)

func _on_interacted(_user: Node) -> void:
	# Nếu Energy quá thấp thì không cho làm việc
	if NeedsManager.energy < 20.0:
		print("Quá mệt, không thể làm việc!")
		return
		
	var hours = 2
	var energy_cost = 25.0
	var money_earned = 80
	
	TimeManager.skip_time(hours)
	EventBus.player_worked.emit(hours, energy_cost, money_earned)
