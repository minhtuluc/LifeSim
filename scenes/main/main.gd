## Main — Root scene của game.
## Sẽ được mở rộng khi có thêm hệ thống (UI layer, World layer, v.v.).
extends Node2D

func _ready() -> void:
	print("[Main] LifeSim started. EventBus: OK, GameManager: OK")
	print("[Main] Starting money: %d" % GameManager.money)
	
	# Test connections for TimeManager & NeedsManager
	TimeManager.seconds_per_ingame_hour = 1.0 # 1 real sec = 1 game hour for fast test
	EventBus.time_hour_changed.connect(_on_time_hour_changed)
	EventBus.needs_all_updated.connect(_on_needs_all_updated)

func _on_time_hour_changed(new_hour: int) -> void:
	print("[Main] Time is now %d:00 (Day %d, Season %d)" % [new_hour, TimeManager.current_day, TimeManager.current_season])

func _on_needs_all_updated(hunger: float, energy: float, mood: float, hygiene: float, social: float) -> void:
	print("[Main] Needs Updated - H: %.1f | E: %.1f | M: %.1f | Hy: %.1f | S: %.1f" % [hunger, energy, mood, hygiene, social])
