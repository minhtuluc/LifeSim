## PlayerController — Đọc input từ người chơi và điều khiển MovementComponent.
extends CharacterBody2D
class_name PlayerController

@onready var _movement: MovementComponent = $MovementComponent

func _physics_process(_delta: float) -> void:
	if GameManager.is_game_paused:
		return
		
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	_movement.move(direction)
	
	# Emit signal khi player di chuyển
	if direction != Vector2.ZERO:
		EventBus.player_moved.emit(global_position)
