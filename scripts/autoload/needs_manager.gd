## NeedsManager — Quản lý các nhu cầu sinh lý của người chơi (hunger, energy, mood, hygiene, social).
## Lắng nghe EventBus để decay theo thời gian và phát signal khi thay đổi.
extends Node
class_name NeedsManagerClass

enum NeedType { HUNGER, ENERGY, MOOD, HYGIENE, SOCIAL }

const MAX_NEED: float = 100.0
const CRITICAL_THRESHOLD: float = 20.0

# State
var hunger: float = 100.0
var energy: float = 100.0
var mood: float = 100.0
var hygiene: float = 100.0
var social: float = 100.0

func _ready() -> void:
	EventBus.time_hour_changed.connect(_on_time_hour_changed)
	EventBus.player_slept.connect(_on_player_slept)
	EventBus.player_worked.connect(_on_player_worked)
	EventBus.player_ate_food.connect(_on_player_ate_food)

func _on_player_ate_food(food: Resource) -> void:
	var item = food as ItemData
	if not item: return
	
	_add_to_need(NeedType.HUNGER, item.hunger_restore)
	_add_to_need(NeedType.ENERGY, item.energy_restore)
	_add_to_need(NeedType.MOOD, item.mood_restore)
	_add_to_need(NeedType.HYGIENE, item.hygiene_restore)
	_add_to_need(NeedType.SOCIAL, item.social_restore)
	EventBus.needs_all_updated.emit(hunger, energy, mood, hygiene, social)

func _on_player_slept(_hours: int) -> void:
	_add_to_need(NeedType.ENERGY, 100.0)
	_add_to_need(NeedType.MOOD, 50.0)
	EventBus.needs_all_updated.emit(hunger, energy, mood, hygiene, social)

func _on_player_worked(_hours: int, energy_cost: float, _money_earned: int) -> void:
	_add_to_need(NeedType.ENERGY, -energy_cost)
	EventBus.needs_all_updated.emit(hunger, energy, mood, hygiene, social)

func _on_time_hour_changed(_new_hour: int) -> void:
	_decay_needs()

func _decay_needs() -> void:
	# Mức giảm trung bình mỗi giờ (tạm thời)
	_add_to_need(NeedType.HUNGER, -2.5)
	_add_to_need(NeedType.ENERGY, -1.5)
	_add_to_need(NeedType.HYGIENE, -1.0)
	_add_to_need(NeedType.SOCIAL, -1.5)
	
	# Mood giảm nhanh hơn nếu các need khác ở mức critical
	var mood_decay: float = -0.5
	if hunger <= CRITICAL_THRESHOLD: mood_decay -= 2.0
	if energy <= CRITICAL_THRESHOLD: mood_decay -= 1.0
	if hygiene <= CRITICAL_THRESHOLD: mood_decay -= 1.0
	if social <= CRITICAL_THRESHOLD: mood_decay -= 1.5
	_add_to_need(NeedType.MOOD, mood_decay)
	
	EventBus.needs_all_updated.emit(hunger, energy, mood, hygiene, social)

func _add_to_need(need_type: NeedType, amount: float) -> void:
	var new_value: float = 0.0
	match need_type:
		NeedType.HUNGER:
			hunger = clampf(hunger + amount, 0.0, MAX_NEED)
			new_value = hunger
		NeedType.ENERGY:
			energy = clampf(energy + amount, 0.0, MAX_NEED)
			new_value = energy
		NeedType.MOOD:
			mood = clampf(mood + amount, 0.0, MAX_NEED)
			new_value = mood
		NeedType.HYGIENE:
			hygiene = clampf(hygiene + amount, 0.0, MAX_NEED)
			new_value = hygiene
		NeedType.SOCIAL:
			social = clampf(social + amount, 0.0, MAX_NEED)
			new_value = social
			
	EventBus.needs_updated.emit(need_type as int, new_value)
	
	if new_value <= CRITICAL_THRESHOLD:
		EventBus.player_need_critical.emit(need_type as int)
