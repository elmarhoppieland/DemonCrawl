@tool
extends Window

# ==============================================================================
const LOCALIZATION_ITEMS_EN = preload("uid://c5c25072ykxhg")

const STATUS_TEXT_FETCHING := "Fetching..."
const STATUS_TEXT_UNAVAILABLE := "Icon could not be found."

const ITEMS_BASE_DIR := "res://assets/items/"
# ==============================================================================
var _base_classes_cache := PackedStringArray()

var _data_win_extraction_location := ""

var _icon_image_cache: Image
# ==============================================================================
@onready var name_edit: LineEdit = %NameEdit
@onready var name_edit_timer: Timer = %NameEditTimer
@onready var disable_translation_strings_button: Button = %DisableTranslationStringsButton
@onready var description_edit_container: VBoxContainer = %DescriptionEditContainer
@onready var description_edit: TextEdit = %DescriptionEdit
@onready var add_mana_button: Button = %AddManaButton
@onready var mana_edit_container: HBoxContainer = %ManaEditContainer
@onready var mana_edit: SpinBox = %ManaEdit
@onready var cost_edit: SpinBox = %CostEdit
@onready var use_data_win_button: Button = %UseDataWinButton
@onready var data_win_container: HBoxContainer = %DataWinContainer
@onready var data_win_check_box: CheckBox = %DataWinCheckBox
@onready var data_win_texture_rect: TextureRect = %DataWinTextureRect
@onready var type_option_button: OptionButton = %TypeOptionButton
@onready var registry_check_box: CheckBox = %RegistryCheckBox
@onready var data_win_config_popup: __DataWinConfigPopup = %DataWinConfigPopup
# ==============================================================================

func _ready() -> void:
	if FileAccess.file_exists(__DataWinConfigPopup.SETTINGS_FILE_PATH):
		var cfg := ConfigFile.new()
		cfg.load(__DataWinConfigPopup.SETTINGS_FILE_PATH)
		if cfg.has_section_key("DataWin", "location"):
			_data_win_extraction_location = str(cfg.get_value("DataWin", "location"))
			use_data_win_button.hide()
			data_win_container.show()
	
	name_edit.grab_focus()
	
	_base_classes_cache.clear()
	type_option_button.clear()
	for cls in UserClassDB.get_inheriters_from_class("Item"):
		cls = UserClassDB.class_get_name(cls)
		if cls.is_absolute_path():
			continue
		
		var script := UserClassDB.class_get_script(cls)
		if script and not script.is_abstract():
			continue
		
		type_option_button.add_item(cls.trim_suffix("Item"))
		_base_classes_cache.append(cls)
		if cls == "ConsumableItem":
			type_option_button.selected = type_option_button.item_count - 1


func _on_cancel_button_pressed() -> void:
	close_requested.emit()


func _on_create_button_pressed() -> void:
	hide()
	
	var item_name := name_edit.text
	
	var item_path := ITEMS_BASE_DIR.path_join(item_name.to_snake_case() + ".tres")
	
	var data: ItemData
	if ResourceLoader.exists(item_path):
		data = load(item_path)
	else:
		data = ItemData.new()
	
	if description_edit_container.visible:
		data.name = item_name
		data.description = description_edit.text
	else:
		data.name = "item." + item_name.to_snake_case().replace("_", "-")
		data.description = data.name + ".description"
	
	data.mana = int(mana_edit.value)
	data.cost = int(cost_edit.value)
	
	if not _icon_image_cache and data_win_check_box.button_pressed and data.icon:
		_icon_image_cache = data.icon.get_image()
	
	if _icon_image_cache:
		var icon_path := ITEMS_BASE_DIR.path_join(item_name.to_snake_case() + ".png")
		_icon_image_cache.save_png(icon_path)
		
		var filesystem := EditorInterface.get_resource_filesystem()
		
		while filesystem.is_scanning():
			await get_tree().process_frame
		
		filesystem.scan_sources()
		
		while filesystem.is_scanning():
			await get_tree().process_frame
		
		data.icon = load(icon_path)
	
	var script_path := ITEMS_BASE_DIR.path_join(item_name.to_snake_case() + ".gd")
	if ResourceLoader.exists(script_path):
		data.item_script = load(script_path)
	else:
		var script := GDScript.new()
		script.source_code = "@tool
extends %s

# ==============================================================================
" % _base_classes_cache[type_option_button.selected]
		ResourceSaver.save(script, script_path, ResourceSaver.FLAG_CHANGE_PATH)
		
		data.item_script = load(script_path)
	
	ResourceSaver.save(data, item_path, ResourceSaver.FLAG_CHANGE_PATH)
	
	if registry_check_box.button_pressed:
		var registry := DemonCrawl.get_full_registry()
		if not registry.items.any(func(item: ItemData) -> bool: return item.resource_path == item_path):
			registry.items.append(load(item_path))
			ResourceSaver.save(registry)
	
	EditorInterface.edit_script(data.item_script)
	EditorInterface.edit_resource(load(item_path))
	
	close_requested.emit()


func _on_name_edit_text_changed(_new_text: String) -> void:
	name_edit_timer.start()


func _on_name_edit_timer_timeout() -> void:
	_load_icon_from_data_win()
	
	#var item_name := name_edit.text
	#var tr_name := "item." + item_name.to_snake_case().replace("_", "-")
	#var file_name := "spr_" + LOCALIZATION_ITEMS_EN.get_message(tr_name).to_snake_case()
	#if url_name.is_empty():
		#wiki_sprite_status_label.text = STATUS_TEXT_UNAVAILABLE
		#wiki_texture_rect.texture = null
		#return
	#
	#wiki_sprite_status_label.text = STATUS_TEXT_FETCHING
	#wiki_texture_rect.texture = null
	#item_page_http_request.request("https://demoncrawl.com/wiki/index.php/" + url_name, [], HTTPClient.METHOD_GET)


#func _on_item_page_http_request_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	#if result != HTTPRequest.RESULT_SUCCESS or response_code != HTTPClient.RESPONSE_OK:
		#print("Request to item page failed.")
		#wiki_sprite_status_label.text = STATUS_TEXT_UNAVAILABLE
		#wiki_texture_rect.texture = null
		#return
	#
	#var text := body.get_string_from_utf8()
	#var i := text.find("<img src=") + 10
	#var new_url := "https://demoncrawl.com" + text.substr(i, text.find("\"", i) - i)
	#
	#wiki_sprite_status_label.text = STATUS_TEXT_FETCHING
	#wiki_texture_rect.texture = null
	#sprite_http_request.request(new_url)


#func _on_sprite_http_request_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	#if result != HTTPRequest.RESULT_SUCCESS or response_code != HTTPClient.RESPONSE_OK:
		#print("Request to sprite page failed.")
		#wiki_sprite_status_label.text = STATUS_TEXT_UNAVAILABLE
		#wiki_texture_rect.texture = null
		#return
	#
	#_icon_image_cache = Image.new()
	#_icon_image_cache.load_png_from_buffer(body)
	#
	#var texture := ImageTexture.create_from_image(_icon_image_cache)
	#wiki_texture_rect.texture = texture
	#wiki_sprite_status_label.text = ""


func _on_disable_translation_strings_button_pressed() -> void:
	disable_translation_strings_button.hide()
	description_edit_container.show()


func _on_add_mana_button_pressed() -> void:
	add_mana_button.hide()
	mana_edit_container.show()


func _on_enable_translation_strings_button_pressed() -> void:
	description_edit_container.hide()
	disable_translation_strings_button.show()


func _on_use_data_win_button_pressed() -> void:
	data_win_config_popup.popup_centered(Vector2(512, 0))


func _on_data_win_config_popup_canceled() -> void:
	show.call_deferred()


func _on_data_win_config_popup_dir_selected(dir: String) -> void:
	show.call_deferred()
	
	_data_win_extraction_location = dir
	
	_load_icon_from_data_win()


func _load_icon_from_data_win() -> void:
	if _data_win_extraction_location.is_empty():
		data_win_texture_rect.texture = null
		use_data_win_button.show()
		data_win_container.hide()
		return
	
	use_data_win_button.hide()
	data_win_container.show()
	
	var item_name := name_edit.text
	var item_dir := _data_win_extraction_location.path_join("spr_" + item_name.to_snake_case())
	if not DirAccess.dir_exists_absolute(item_dir):
		data_win_texture_rect.texture = null
		return
	
	var files := DirAccess.get_files_at(item_dir)
	if files.size() != 1:
		printerr("Attempted to get an item icon at '%s', but this directory contains more than one file. Only the first file will be used." % item_dir)
	
	var file := files[0]
	var path := item_dir.path_join(file)
	var image := Image.load_from_file(path)
	
	if image.get_width() > 16 or image.get_height() > 16:
		printerr("Item icon at path '%s' is invalid, since its size is greater than 16x16. Aborting..." % path)
		data_win_texture_rect.texture = null
		return
	elif image.get_size() != Vector2i(16, 16):
		var new_image := Image.create_empty(16, 16, image.has_mipmaps(), image.get_format())
		var topleft := (new_image.get_size() - image.get_size()) / 2
		for x: int in range(topleft.x, topleft.x + image.get_width()):
			for y: int in range(topleft.y, topleft.y + image.get_height()):
				new_image.set_pixel(x, y, image.get_pixel(x, y))
		image = new_image
	
	_icon_image_cache = image
	
	data_win_texture_rect.texture = ImageTexture.create_from_image(image)


func _on_locate_data_win_button_pressed() -> void:
	_on_use_data_win_button_pressed()
