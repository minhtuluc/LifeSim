extends Area2D
class_name InteractableArea

## Tín hiệu phát ra khi có người tương tác
signal interacted(user: Node)

## Câu nhắc sẽ hiển thị cho người chơi (VD: "Ngủ", "Làm việc", "Nói chuyện")
@export var prompt_text: String = "Tương tác"

func _ready() -> void:
	# Đảm bảo Area này thuộc collision layer dành cho tương tác (giả sử là layer 2)
	collision_layer = 2
	collision_mask = 0

## Hàm được gọi từ InteractionScanner
func interact(user: Node) -> void:
	interacted.emit(user)
