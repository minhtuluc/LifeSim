extends Resource
class_name ItemData

@export var item_id: StringName
@export var display_name: String
@export_multiline var description: String
@export var base_price: int = 10
@export var icon: Texture2D

@export_group("Consumable Stats")
@export var is_consumable: bool = false
@export var hunger_restore: float = 0.0
@export var energy_restore: float = 0.0
@export var mood_restore: float = 0.0
@export var hygiene_restore: float = 0.0
@export var social_restore: float = 0.0
