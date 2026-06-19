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
signal npc_dialogue_started(dialogue_data: Resource)
signal npc_dialogue_ended()

signal npc_friendship_changed(npc_id: StringName, new_amount: int, delta: int)
signal npc_gift_received(npc_id: StringName, item_data: Resource)
signal npc_schedule_target_changed(npc_id: StringName, target_position: Vector2, activity: StringName)
signal ui_npc_interaction_requested(npc_id: StringName, dialogue_data: Resource)
signal ui_npc_interaction_selected(npc_id: StringName, action_id: StringName)
signal ui_gift_item_selected(npc_id: StringName, item_index: int)
signal npc_schedule_registered(npc_id: StringName, entries: Array)

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
signal ui_phone_opened()
signal ui_phone_closed()
signal phone_contacts_updated(contacts_data: Dictionary)

# --- NEEDS ---
signal needs_updated(need_type: int, new_value: float)
signal needs_all_updated(hunger: float, energy: float, mood: float, hygiene: float, social: float)
