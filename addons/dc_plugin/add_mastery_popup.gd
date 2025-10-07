@tool
extends PopupPanel
class_name AddMasteryPopup

# ==============================================================================
const SETTINGS_FILE_PATH := "user://dev/settings.ini"
# ==============================================================================
var data_win_extraction_location := ""

var data_win_icon_cache: Array[Image] = []
# ==============================================================================
@onready var name_edit: LineEdit = %NameEdit
@onready var name_edit_timer: Timer = %NameEditTimer
@onready var disable_translation_strings_button: Button = %DisableTranslationStringsButton
@onready var description_container: VBoxContainer = %DescriptionContainer
@onready var description_edits_container: VBoxContainer = %DescriptionEditsContainer
@onready var unlock_text_container: VBoxContainer = %UnlockTextContainer
@onready var unlock_text_edits_container: VBoxContainer = %UnlockTextEditsContainer
@onready var enable_data_win_button: Button = %EnableDataWinButton
@onready var data_win_icons_container: VBoxContainer = %DataWinIconsContainer
@onready var data_win_enabled_check_box: CheckBox = %DataWinEnabledCheckBox
@onready var data_win_icon_rects_container: HBoxContainer = %DataWinIconRectsContainer
@onready var levels_edit: SpinBox = %LevelsEdit
@onready var charges_edit: SpinBox = %ChargesEdit
@onready var cost_edits_container: HBoxContainer = %CostEditsContainer
@onready var registry_check_box: CheckBox = %RegistryCheckBox
@onready var data_win_config_popup: __DataWinConfigPopup = %DataWinConfigPopup
# ==============================================================================

func _ready() -> void:
	if FileAccess.file_exists("user://dev/settings.ini"):
		var cfg := ConfigFile.new()
		cfg.load(SETTINGS_FILE_PATH)
		if cfg.has_section_key("DataWin", "location"):
			data_win_extraction_location = cfg.get_value("DataWin", "location")
	
	if data_win_extraction_location.is_empty():
		data_win_icons_container.hide()
		enable_data_win_button.show()
	else:
		data_win_icons_container.show()
		enable_data_win_button.hide()
	
	name_edit.grab_focus()
	
	_set_level_count(roundi(levels_edit.value))


func _reload_icons_from_data_win() -> void:
	if data_win_extraction_location.is_empty():
		return
	
	var mastery_name := name_edit.text
	var dir := data_win_extraction_location.path_join("spr_mastery_" + mastery_name)
	if not DirAccess.dir_exists_absolute(dir):
		return
	
	data_win_icon_cache.clear()
	for file in DirAccess.get_files_at(dir):
		var image := Image.load_from_file(dir.path_join(file))
		data_win_icon_cache.append(image)
	
	for i in maxi(data_win_icon_rects_container.get_child_count(), data_win_icon_cache.size()):
		var rect: TextureRect
		
		if i < data_win_icon_rects_container.get_child_count():
			rect = data_win_icon_rects_container.get_child(i)
		else:
			rect = TextureRect.new()
			rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			data_win_icon_rects_container.add_child(rect)
		
		if i < data_win_icon_cache.size():
			rect.texture = ImageTexture.create_from_image(data_win_icon_cache[i])
		else:
			rect.queue_free()
	
	levels_edit.value = data_win_icon_cache.size()


func _set_level_count(count: int) -> void:
	for i in range(count, cost_edits_container.get_child_count()):
		cost_edits_container.get_child(i).queue_free()
	
	for i in range(cost_edits_container.get_child_count(), count):
		var spin_box := SpinBox.new()
		spin_box.allow_greater = true
		spin_box.select_all_on_focus = true
		spin_box.value = 10 * (i + 1)
		cost_edits_container.add_child(spin_box)
	
	for i in range(count, description_edits_container.get_child_count()):
		description_edits_container.get_child(i).queue_free()
	
	for i in range(description_edits_container.get_child_count(), count):
		var text_edit := TextEdit.new()
		text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
		text_edit.custom_minimum_size.y = 128
		description_edits_container.add_child(text_edit)
	
	for i in range(count, unlock_text_edits_container.get_child_count()):
		unlock_text_edits_container.get_child(i).queue_free()
	
	for i in range(unlock_text_edits_container.get_child_count(), count):
		var text_edit := TextEdit.new()
		text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
		text_edit.custom_minimum_size.y = 128
		unlock_text_edits_container.add_child(text_edit)


func _on_under_tale_mod_tool_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))


func _on_enable_data_win_button_pressed() -> void:
	data_win_config_popup.popup_centered(Vector2(512, 0))


func _on_locate_button_pressed() -> void:
	data_win_config_popup.popup_centered(Vector2(512, 0))


func _on_cancel_button_pressed() -> void:
	close_requested.emit()


func _on_file_dialog_dir_selected(dir: String) -> void:
	data_win_extraction_location = dir
	
	if not DirAccess.dir_exists_absolute(SETTINGS_FILE_PATH.get_base_dir()):
		DirAccess.make_dir_recursive_absolute(SETTINGS_FILE_PATH.get_base_dir())
	
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_FILE_PATH)
	cfg.set_value("DataWin", "location", dir)
	var err := cfg.save(SETTINGS_FILE_PATH)
	if err:
		print("Could not save settings. Error: ", error_string(err))
	else:
		data_win_icons_container.show()
		enable_data_win_button.hide()
	
	_reload_icons_from_data_win()


func _on_name_edit_text_changed(_new_text: String) -> void:
	name_edit_timer.start()


func _on_name_edit_timer_timeout() -> void:
	_reload_icons_from_data_win()


func _on_levels_edit_value_changed(value: float) -> void:
	_set_level_count(roundi(value))


func _on_disable_translation_strings_button_pressed() -> void:
	disable_translation_strings_button.hide()
	description_container.show()
	unlock_text_container.show()


func _on_create_button_pressed() -> void:
	hide()
	
	var mastery_name := name_edit.text
	var mastery_id := mastery_name.to_snake_case()
	
	var dir := "res://assets/scripts/masteries/" + mastery_id
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_absolute(dir)
	
	var mastery_path := dir.path_join(mastery_id + ".tres")
	
	var data: MasteryData
	if ResourceLoader.exists(mastery_path):
		data = load(mastery_path)
	else:
		data = MasteryData.new()
	
	var script_path := dir.path_join(mastery_id + ".gd")
	if ResourceLoader.exists(script_path):
		data.mastery_script = load(script_path)
	else:
		var script := GDScript.new()
		script.source_code = "@tool
extends Mastery
class_name %s

# ==============================================================================
" % mastery_name.to_pascal_case()
		script.reload()
		ResourceSaver.save(script, script_path, ResourceSaver.FLAG_CHANGE_PATH)
	
	var unlocker_path := dir.path_join(mastery_id + "_unlocker.tres")
	var unlocker_data: MasteryUnlockerData
	if ResourceLoader.exists(unlocker_path):
		unlocker_data = load(unlocker_path)
	else:
		unlocker_data = MasteryUnlockerData.new()
	
	var unlocker_script_path := dir.path_join(mastery_id + "_unlocker.gd")
	if ResourceLoader.exists(unlocker_script_path):
		unlocker_data.unlocker_script = load(unlocker_script_path)
	else:
		var unlocker_script := GDScript.new()
		unlocker_script.source_code = "extends MasteryUnlocker

# ==============================================================================
"
		unlocker_script.reload()
		ResourceSaver.save(unlocker_script, unlocker_script_path, ResourceSaver.FLAG_CHANGE_PATH)
	
	var level_count := roundi(levels_edit.value)
	
	if data_win_enabled_check_box.button_pressed:
		for i in level_count:
			data_win_icon_cache[i].save_png(dir.path_join(mastery_id + "_" + str(i) + ".png"))
		
		var filesystem := EditorInterface.get_resource_filesystem()
		
		while filesystem.is_scanning():
			await get_tree().process_frame
		
		filesystem.scan_sources()
		
		while filesystem.is_scanning():
			await get_tree().process_frame
	
	data.name = "mastery." + mastery_id.replace("_", "-")
	data.ability_charges = roundi(charges_edit.value)
	data.mastery_script = load(dir.path_join(mastery_id + ".gd"))
	
	data.description.resize(level_count)
	data.unlock_text.resize(level_count)
	data.icon.resize(level_count)
	data.cost.resize(level_count)
	
	for i in level_count:
		if description_container.visible:
			data.description[i] = description_edits_container.get_child(i).text
		else:
			data.description[i] = data.name + ".description." + str(i + 1)
		
		if unlock_text_container.visible:
			data.unlock_text[i] = description_edits_container.get_child(i).text
		else:
			data.unlock_text[i] = data.name + ".unlock." + str(i + 1)
		
		if data_win_enabled_check_box.button_pressed:
			data.icon[i] = load(dir.path_join(mastery_id + "_" + str(i) + ".png"))
		
		data.cost[i] = roundi(cost_edits_container.get_child(i).value)
	
	ResourceSaver.save(data, mastery_path, ResourceSaver.FLAG_CHANGE_PATH)
	
	unlocker_data.data = data
	unlocker_data.unlocker_script = load(dir.path_join(mastery_id + "_unlocker.gd"))
	
	ResourceSaver.save(unlocker_data, unlocker_path, ResourceSaver.FLAG_CHANGE_PATH)
	
	if registry_check_box.button_pressed:
		var registry := DemonCrawl.get_full_registry()
		if not registry.masteries.any(func(mastery: MasteryData) -> bool: return mastery.resource_path == mastery_path):
			registry.masteries.append(load(mastery_path))
			ResourceSaver.save(registry)
	
	EditorInterface.edit_script(data.mastery_script)
	EditorInterface.edit_resource(load(dir.path_join(mastery_id + ".tres")))
	
	close_requested.emit()


func _on_enable_translation_strings_button_pressed() -> void:
	description_container.hide()
	unlock_text_container.hide()
	disable_translation_strings_button.show()


func _on_data_win_config_popup_dir_selected(dir: String) -> void:
	show.call_deferred()
	
	data_win_extraction_location = dir
	
	_reload_icons_from_data_win()


func _on_data_win_config_popup_canceled() -> void:
	show.call_deferred()
