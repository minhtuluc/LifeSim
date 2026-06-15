## EventBus — Kênh giao tiếp trung tâm (Signal Hub).
## Tất cả module giao tiếp với nhau thông qua file này.
## RULE: Chỉ APPEND signal mới — KHÔNG được xóa hoặc đổi tên signal cũ.
extends Node

# --- TIME ---
signal time_tick(current_hour: int, current_minute: int)
signal time_hour_changed(new_hour: int)
signal time_day_changed(new_day: int)
signal time_season_changed(new_season: int)

# --- PLAYER ---
signal player_moved(new_position: Vector2)
signal player_ate_food(food_data: Resource)
signal player_money_changed(new_amount: int, delta: int)
signal player_need_critical(need_type: int)
signal player_slept(hours: int)
signal player_worked(hours: int, energy_cost: float, money_earned: int)

# --- NPC ---
signal npc_spawned(npc_id: StringName, npc_ref: Node)
signal npc_despawned(npc_id: StringName)
signal npc_schedule_changed(npc_id: StringName, new_activity: StringName)
signal npc_path_failed(npc_id: StringName)
signal npc_path_ready(npc_id: StringName, path: PackedVector2Array)
signal npc_dialogue_started(npc_id: StringName)
signal npc_dialogue_ended(npc_id: StringName, outcome: Dictionary)

# --- SCENE / DISTRICT ---
signal scene_transition_requested(target_district: StringName)
signal scene_transition_started(from_district: StringName, to_district: StringName)
signal scene_transition_completed(district_name: StringName)
signal scene_load_progress(progress: float)

# --- QUEST ---
signal quest_started(quest_id: StringName)
signal quest_objective_updated(quest_id: StringName, objective_id: StringName, progress: int)
signal quest_completed(quest_id: StringName)
signal quest_failed(quest_id: StringName)

# --- SAVE ---
signal save_requested(save_data: Dictionary)
signal save_completed(success: bool)
signal load_completed(load_data: Dictionary)

# --- UI (từ UI lên backend) ---
signal ui_purchase_requested(item_data: Resource)
signal ui_dialogue_choice_selected(choice_index: int)
signal ui_menu_opened(menu_id: StringName)
signal ui_menu_closed(menu_id: StringName)

# --- NEEDS ---
signal needs_updated(need_type: int, new_value: float)
signal needs_all_updated(hunger: float, energy: float, mood: float, hygiene: float, social: float)
