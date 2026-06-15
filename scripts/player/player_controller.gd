## PlayerController — Đọc input từ người chơi và điều khiển MovementComponent.
extends CharacterBody2D
class_name PlayerController

@onready var _movement: MovementComponent = $MovementComponent

var _is_in_dialogue: bool = false

func _ready() -> void:
	EventBus.npc_dialogue_started.connect(_on_dialogue_started)
	EventBus.npc_dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_started(_data: Resource) -> void:
	_is_in_dialogue = true

func _on_dialogue_ended() -> void:
	_is_in_dialogue = false

func _physics_process(_delta: float) -> void:
	if GameManager.is_game_paused or _is_in_dialogue:
		return
		
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	_movement.move(direction)
	
	# Emit signal khi player di chuyển
	if direction != Vector2.ZERO:
		EventBus.player_moved.emit(global_position)
