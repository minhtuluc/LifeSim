## Main — Root scene của game.
## Sẽ được mở rộng khi có thêm hệ thống (UI layer, World layer, v.v.).
extends Node2D

func _ready() -> void:
	print("[Main] LifeSim started. EventBus: OK, GameManager: OK")
	print("[Main] Starting money: %d" % GameManager.money)
