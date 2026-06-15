extends Node
class_name SaveManagerClass

const SAVE_PATH: String = "user://savegame.json"

func _ready() -> void:
	pass

func save_game() -> void:
	var save_data: Dictionary = {}
	EventBus.save_requested.emit(save_data)
	
	var json_string: String = JSON.stringify(save_data, "\t")
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		EventBus.save_completed.emit(true)
		print("Lưu game thành công: ", SAVE_PATH)
	else:
		EventBus.save_completed.emit(false)
		print("Lỗi lưu game!")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Không tìm thấy file save!")
		return
		
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string: String = file.get_as_text()
		file.close()
		
		var json: JSON = JSON.new()
		var error: Error = json.parse(json_string)
		if error == OK:
			var save_data: Dictionary = json.data as Dictionary
			EventBus.load_completed.emit(save_data)
			print("Tải game thành công!")
		else:
			print("Lỗi parse JSON!")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_F5:
			save_game()
		elif event.physical_keycode == KEY_F9:
			load_game()
