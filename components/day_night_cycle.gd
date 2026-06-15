extends CanvasModulate
class_name DayNightCycle

@export var gradient: Gradient

func _ready() -> void:
	if not gradient:
		gradient = Gradient.new()
		# Gradient mặc định có sẵn 2 điểm ở 0.0 và 1.0
		gradient.set_color(0, Color(0.1, 0.1, 0.3, 1.0)) # Nửa đêm 0:00
		gradient.set_color(1, Color(0.1, 0.1, 0.3, 1.0)) # Nửa đêm 24:00
		gradient.add_point(0.25, Color(0.9, 0.7, 0.6, 1.0)) # Bình minh 6:00
		gradient.add_point(0.5, Color(1.0, 1.0, 1.0, 1.0))  # Trưa 12:00
		gradient.add_point(0.75, Color(0.9, 0.4, 0.2, 1.0)) # Hoàng hôn 18:00
		
	EventBus.time_tick.connect(_on_time_tick)
	_on_time_tick(TimeManager.current_hour, TimeManager.current_minute)

func _on_time_tick(hour: int, minute: int) -> void:
	var float_hour: float = hour + (minute / 60.0)
	var time_ratio: float = float_hour / 24.0
	color = gradient.sample(time_ratio)
