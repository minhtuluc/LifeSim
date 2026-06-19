extends Node2D

@onready var interactable_area: InteractableArea = $InteractableArea

func _ready() -> void:
	interactable_area.interacted.connect(_on_interacted)

func _on_interacted(_user: Node) -> void:
	print("Stargazing Transition Triggered -> Hồi tưởng về tuổi thơ")
	EventBus.scene_transition_requested.emit(&"home_village")
