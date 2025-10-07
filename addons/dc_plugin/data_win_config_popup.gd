@tool
extends PopupPanel
class_name __DataWinConfigPopup

# ==============================================================================
const SETTINGS_FILE_PATH := "user://dev/settings.ini"
# ==============================================================================
@export var save_location := true
# ==============================================================================
@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var file_dialog: FileDialog = %FileDialog
# ==============================================================================
signal dir_selected(dir: String)
signal canceled()
# ==============================================================================

func _ready() -> void:
	var text := rich_text_label.text
	rich_text_label.text = ""
	
	var was_visible := visible
	if not was_visible:
		await visibility_changed
	
	await Promise.defer()
	
	rich_text_label.text = text
	
	await Promise.defer()
	
	if not was_visible:
		position.y -= size.y / 2


func _on_locate_button_pressed() -> void:
	file_dialog.popup_centered()


func _on_file_dialog_dir_selected(dir: String) -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_FILE_PATH)
	cfg.set_value("DataWin", "location", dir)
	
	dir_selected.emit(dir)


func _on_cancel_button_pressed() -> void:
	hide()
	canceled.emit()


func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))


func _on_file_dialog_canceled() -> void:
	canceled.emit()
