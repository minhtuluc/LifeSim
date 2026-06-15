## HUD — Giao diện hiển thị thông tin người chơi (Thời gian, Tiền, Nhu cầu).
## Tuân thủ Rule 2: Reactive UI (Chỉ lắng nghe EventBus, không thay đổi data).
extends CanvasLayer
class_name HUD

@onready var time_label: Label = $MarginContainer/VBoxContainer/TopBar/TimeLabel
@onready var money_label: Label = $MarginContainer/VBoxContainer/TopBar/MoneyLabel
@onready var hunger_bar: ProgressBar = $MarginContainer/VBoxContainer/Needs/HungerBar
@onready var energy_bar: ProgressBar = $MarginContainer/VBoxContainer/Needs/EnergyBar
@onready var mood_bar: ProgressBar = $MarginContainer/VBoxContainer/Needs/MoodBar
@onready var hygiene_bar: ProgressBar = $MarginContainer/VBoxContainer/Needs/HygieneBar
@onready var social_bar: ProgressBar = $MarginContainer/VBoxContainer/Needs/SocialBar

func _ready() -> void:
	# Kết nối signal
	EventBus.time_tick.connect(_on_time_tick)
	EventBus.time_day_changed.connect(_on_time_day_changed)
	EventBus.time_season_changed.connect(_on_time_season_changed)
	EventBus.player_money_changed.connect(_on_money_changed)
	EventBus.needs_all_updated.connect(_on_needs_all_updated)
	EventBus.needs_updated.connect(_on_needs_updated)
	
	# Khởi tạo giá trị ban đầu
	_update_time_display(TimeManager.current_hour, TimeManager.current_minute)
	_update_money_display(GameManager.money)

func _on_time_tick(hour: int, minute: int) -> void:
	_update_time_display(hour, minute)

func _on_time_day_changed(_day: int) -> void:
	_update_time_display(TimeManager.current_hour, TimeManager.current_minute)

func _on_time_season_changed(_season: int) -> void:
	_update_time_display(TimeManager.current_hour, TimeManager.current_minute)

func _update_time_display(hour: int, minute: int) -> void:
	var season_key := "SEASON_" + str(TimeManager.current_season)
	var day_text := tr("DAY") + " " + str(TimeManager.current_day)
	var time_text := "%02d:%02d" % [hour, minute]
	time_label.text = "%s - %s | %s" % [tr(season_key), day_text, time_text]

func _on_money_changed(amount: int, _delta: int) -> void:
	_update_money_display(amount)

func _update_money_display(amount: int) -> void:
	money_label.text = str(amount) + " " + tr("MONEY")

func _on_needs_all_updated(hunger: float, energy: float, mood: float, hygiene: float, social: float) -> void:
	hunger_bar.value = hunger
	energy_bar.value = energy
	mood_bar.value = mood
	hygiene_bar.value = hygiene
	social_bar.value = social

func _on_needs_updated(need_type: int, value: float) -> void:
	match need_type:
		0: hunger_bar.value = value
		1: energy_bar.value = value
		2: mood_bar.value = value
		3: hygiene_bar.value = value
		4: social_bar.value = value
