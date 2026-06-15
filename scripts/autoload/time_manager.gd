## TimeManager — Hệ thống thời gian tối quan trọng của game.
extends Node
class_name TimeManagerClass

enum Season { SPRING, SUMMER, AUTUMN, WINTER }

# --- Cấu hình (tuỳ chỉnh qua Inspector) ---
@export var seconds_per_ingame_hour: float = 60.0   # 1 giờ game = 60 giây thực
@export var start_hour: int = 6                      # Bắt đầu ngày lúc 6h sáng
@export var start_day: int = 1
@export var start_season: Season = Season.SPRING
@export var days_per_season: int = 28               # Plan says 28 days/season

# --- State (chỉ đọc từ bên ngoài) ---
var current_hour: int = 6
var current_minute: int = 0
var current_day: int = 1
var current_season: Season = Season.SPRING
var total_days_elapsed: int = 0

# --- Nội bộ ---
var _time_accumulator: float = 0.0
var _is_paused: bool = false

func _ready() -> void:
	current_hour = start_hour
	current_day = start_day
	current_season = start_season
	EventBus.save_requested.connect(_on_save_requested)
	EventBus.load_completed.connect(_on_load_completed)

func _on_save_requested(save_data: Dictionary) -> void:
	save_data["time"] = {
		"hour": current_hour,
		"minute": current_minute,
		"day": current_day,
		"season": current_season,
		"total_days": total_days_elapsed
	}

func _on_load_completed(load_data: Dictionary) -> void:
	if load_data.has("time"):
		var t: Dictionary = load_data["time"] as Dictionary
		current_hour = int(t["hour"])
		current_minute = int(t["minute"])
		current_day = int(t["day"])
		current_season = int(t["season"])
		total_days_elapsed = int(t["total_days"])
		EventBus.time_hour_changed.emit(current_hour)
		EventBus.time_tick.emit(current_hour, current_minute)

func _process(delta: float) -> void:
	if _is_paused:
		return
	_time_accumulator += delta
	var seconds_per_minute: float = seconds_per_ingame_hour / 60.0
	while _time_accumulator >= seconds_per_minute:
		_time_accumulator -= seconds_per_minute
		_advance_minute()

func _advance_minute() -> void:
	current_minute += 1
	if current_minute >= 60:
		current_minute = 0
		_advance_hour()
	EventBus.time_tick.emit(current_hour, current_minute)

func _advance_hour() -> void:
	current_hour += 1
	if current_hour >= 24:
		current_hour = 0
		_advance_day()
	EventBus.time_hour_changed.emit(current_hour)

func _advance_day() -> void:
	current_day += 1
	total_days_elapsed += 1
	if current_day > days_per_season:
		current_day = 1
		_advance_season()
	EventBus.time_day_changed.emit(current_day)

func _advance_season() -> void:
	match current_season:
		Season.SPRING:
			current_season = Season.SUMMER
		Season.SUMMER:
			current_season = Season.AUTUMN
		Season.AUTUMN:
			current_season = Season.WINTER
		Season.WINTER:
			current_season = Season.SPRING
	EventBus.time_season_changed.emit(current_season as int)

func pause_time() -> void:
	_is_paused = true

func resume_time() -> void:
	_is_paused = false

func skip_time(hours: int) -> void:
	for i in range(hours):
		_advance_hour()
