@tool
extends Control
class_name __IconManagerMainScreen

# ==============================================================================
@onready var editors_container: VBoxContainer = %EditorsContainer
@onready var file_dialog: FileDialog = %FileDialog
# ==============================================================================

func _ready() -> void:
	var json := parse_json(open_data_file())
	if json.is_empty():
		return
	
	for atlas_name: String in json:
		const ICON_MANAGER_ICONS_FILE_EDITOR := preload("res://addons/icon_manager/icon_manager_icons_file_editor.tscn")
		
		var editor := ICON_MANAGER_ICONS_FILE_EDITOR.instantiate() as __IconManagerIconsFileEditor
		var data: Array[Dictionary] = []
		data.assign(json[atlas_name].icons)
		editor.load_data(atlas_name, json[atlas_name].atlas, data)
		editors_container.add_child(editor)
		
		editor.data_changed.connect(func(new_data: Array[Dictionary]) -> void:
			var new_json := parse_json(open_data_file())
			new_json[editor.atlas_name].icons = new_data
			save_json(new_json)
		)
		editor.deleted.connect(func() -> void:
			var new_json := parse_json(open_data_file())
			new_json.erase(editor.atlas_name)
			save_json(new_json)
			editor.queue_free()
		)
		
		(func() -> void:
			var old_name := atlas_name
			while true:
				await editor.name_changed
				
				var new_json := parse_json(open_data_file())
				new_json[editor.atlas_name] = new_json[old_name]
				new_json.erase(old_name)
				save_json(new_json)
				
				old_name = editor.atlas_name
		).call()


func open_data_file(flags: FileAccess.ModeFlags = FileAccess.READ) -> FileAccess:
	if not DirAccess.dir_exists_absolute(__IconManagerPlugin.ICONS_FILE.get_base_dir()):
		DirAccess.make_dir_absolute(__IconManagerPlugin.ICONS_FILE.get_base_dir())
	
	if not FileAccess.file_exists(__IconManagerPlugin.ICONS_FILE):
		FileAccess.open(__IconManagerPlugin.ICONS_FILE, FileAccess.WRITE)
	
	var file := FileAccess.open(__IconManagerPlugin.ICONS_FILE, flags)
	if not file:
		push_error("Could not open file '%s': %s" % [__IconManagerPlugin.ICONS_FILE, error_string(FileAccess.get_open_error())])
		return null
	
	return file


func parse_json(file: FileAccess) -> Dictionary:
	if not file:
		return {}
	if file.get_length() == 0:
		return {}
	
	var text := file.get_as_text()
	var json = JSON.parse_string(text)
	if not json is Dictionary:
		push_error("The JSON data at '%s' could not be parsed as a Dictionary." % __IconManagerPlugin.ICONS_FILE)
		return {}
	
	return json


func save_json(json: Dictionary, file: FileAccess = null) -> void:
	(file if file else open_data_file(FileAccess.WRITE)).store_line(JSON.stringify(json, "\t"))


func _on_add_atlas_button_pressed() -> void:
	file_dialog.popup_centered()


func _on_file_dialog_file_selected(path: String) -> void:
	const ICON_MANAGER_ICONS_FILE_EDITOR := preload("res://addons/icon_manager/icon_manager_icons_file_editor.tscn")
	
	var atlas_name := path.get_file().get_basename()
	var json := parse_json(open_data_file())
	
	if atlas_name in json:
		var index := 0
		if atlas_name[-1].is_valid_int():
			for i in range(atlas_name.length() - 1, -1, -1):
				var c := atlas_name[i]
				if not c.is_valid_int():
					atlas_name = atlas_name.substr(0, i + 1)
					break
				index = index * 10 + c.to_int()
		else:
			index = 2
		
		while atlas_name + str(index) in json:
			index += 1
		atlas_name += str(index)
	
	json[atlas_name] = {
		"atlas": path,
		"icons": []
	}
	save_json(json)
	
	var editor := ICON_MANAGER_ICONS_FILE_EDITOR.instantiate() as __IconManagerIconsFileEditor
	editor.load_data(atlas_name, path, [])
	editors_container.add_child(editor)
	
	editor.data_changed.connect(func(new_data: Array[Dictionary]) -> void:
		var new_json := parse_json(open_data_file())
		new_json[editor.atlas_name].icons = new_data
		save_json(new_json)
	)
	editor.deleted.connect(func() -> void:
		var new_json := parse_json(open_data_file())
		new_json.erase(editor.atlas_name)
		save_json(new_json)
		editor.queue_free()
	)
	
	(func() -> void:
		var old_name := atlas_name
		while true:
			await editor.name_changed
			
			var new_json := parse_json(open_data_file())
			new_json[editor.atlas_name] = new_json[old_name]
			new_json.erase(old_name)
			save_json(new_json)
			
			old_name = editor.atlas_name
	).call()
