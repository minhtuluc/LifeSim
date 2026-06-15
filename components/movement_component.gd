## MovementComponent — Handles physics movement for CharacterBody2D.
## Tách biệt logic di chuyển để có thể tái sử dụng cho Player và NPC.
extends Node
class_name MovementComponent

@export var speed: float = 120.0

var _body: CharacterBody2D

func _ready() -> void:
	_body = get_parent() as CharacterBody2D
	assert(_body != null, "[MovementComponent] Parent must be a CharacterBody2D!")

## Nhận input vector (có thể từ player controller hoặc AI pathfinding).
## Áp dụng velocity và gọi move_and_slide().
func move(direction: Vector2) -> void:
	if direction.length_squared() > 1.0:
		direction = direction.normalized()
		
	_body.velocity = direction * speed
	_body.move_and_slide()
