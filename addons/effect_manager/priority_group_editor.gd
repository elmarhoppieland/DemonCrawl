@tool
extends PopupPanel
class_name __PriorityGroupEditor

# ==============================================================================
#var node: EffectManager.PriorityGroup

var group_name := ""
var type := EffectManager.PriorityGroup.Type.SCRIPT_INSTANCES
var data := ""
# ==============================================================================
@onready var name_edit: LineEdit = %NameEdit
@onready var type_button: OptionButton = %TypeButton
@onready var extra_settings: Array[VBoxContainer] = [
	%ScriptInstancesSettingsContainer,
	%NodeChildrenSettingsContainer,
	%ScriptInstancesSettingsContainer
]
@onready var select_script_button: Button = %SelectScriptButton
@onready var node_path_edit: LineEdit = %NodePathEdit
# ==============================================================================
signal confirmed()
signal canceled()
signal applied()
# ==============================================================================

func _ready() -> void:
	popup_window = true
	transient = true


func _on_about_to_popup() -> void:
	assert(data != null, "No data selected when editing the priority group.")
	
	name_edit.text = group_name
	type_button.select(type)
	
	for i in extra_settings:
		i.hide()
	
	extra_settings[type].show()
	
	match type:
		EffectManager.PriorityGroup.Type.SCRIPT_INSTANCES, EffectManager.PriorityGroup.Type.SCRIPT_SINGLETON:
			if data.is_empty():
				select_script_button.text = "Select Script..."
			else:
				select_script_button.text = data + " (Click to change...)"
		EffectManager.PriorityGroup.Type.NODE_CHILDREN:
			node_path_edit.text = data


func _on_name_edit_text_submitted() -> void:
	name_edit.release_focus()


func _on_type_button_item_selected(index: int) -> void:
	type = index as EffectManager.PriorityGroup.Type
	
	for i in extra_settings:
		i.hide()
	
	extra_settings[index].show()


func _on_name_edit_text_changed(new_text: String) -> void:
	group_name = new_text


func _on_select_script_button_pressed() -> void:
	__EffectManagerPlugin.main_screen.user_class_selector.reparent(self)
	var script_name := await __EffectManagerPlugin.main_screen.select_user_class(true)
	__EffectManagerPlugin.main_screen.user_class_selector.reparent(__EffectManagerPlugin.main_screen)
	if script_name.is_empty():
		return
	
	data = script_name
	select_script_button.text = data + " (Click to change...)"


func _on_node_path_edit_text_changed(new_text: String) -> void:
	data = new_text


func _on_node_path_edit_text_submitted(_new_text: String) -> void:
	node_path_edit.release_focus()


func _on_confirm_button_pressed() -> void:
	hide()
	confirmed.emit()


func _on_cancel_button_pressed() -> void:
	hide()
	canceled.emit()


func _on_apply_button_pressed() -> void:
	applied.emit()


func _on_close_requested() -> void:
	hide()
	canceled.emit()
