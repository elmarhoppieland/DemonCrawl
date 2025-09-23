@tool
extends MarginContainer
class_name __EffectManagerEffectEditor

# ==============================================================================
var function: __EffectsFileManager.Function :
	set(value):
		function = value
		
		_update_name()
		_update_return_type()
		function.return_type_changed.connect(_update_return_type.unbind(1))
		function.return_type_name_changed.connect(_update_return_type.unbind(1))
		
		_update_arguments()
		
		_update_description()
		
		while true:
			var first := function.get_argument(0)
			if not first:
				function.return_type = -1
				first = await Promise.capture(function.argument_added)
			
			first.type_changed.connect(func(new_type: Variant.Type) -> void:
				if function.return_type != -1:
					function.return_type = new_type
			)
			first.type_name_changed.connect(func(new_type_name: String) -> void:
				if function.return_type != -1:
					function.return_type_name = new_type_name
			)
			
			await first.deleted
# ==============================================================================
var function_save_queued := false
# ==============================================================================
@onready var return_type_button: MenuButton = %ReturnTypeButton
@onready var name_label: RichTextLabel = %NameLabel
@onready var name_editor: LineEdit = %NameEditor
@onready var arg_editors_container: VBoxContainer = %ArgEditorsContainer
@onready var description_edit: TextEdit = %DescriptionEdit
# ==============================================================================

func _ready() -> void:
	name_editor.add_theme_color_override("font_color", __EffectManagerPlugin.get_function_definition_color())


func _update_name() -> void:
	if not is_node_ready():
		await ready
	
	name_editor.text = function.name


func _update_return_type() -> void:
	if not is_node_ready():
		await ready
	
	return_type_button.text = function.get_return_string()
	
	match function.return_type:
		TYPE_OBJECT:
			if UserClassDB.class_exists(function.return_type_name):
				return_type_button.add_theme_color_override("font_color", __EffectManagerPlugin.get_type_color("user_type_color"))
			elif ClassDB.class_exists(function.return_type_name):
				return_type_button.add_theme_color_override("font_color", __EffectManagerPlugin.get_type_color("engine_type_color"))
			else:
				return_type_button.add_theme_color_override("font_color", EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/comment_markers/warning_color"))
		_:
			return_type_button.add_theme_color_override("font_color", __EffectManagerPlugin.get_type_color("base_type_color"))


func _update_arguments() -> void:
	if not is_node_ready():
		await ready
	
	for child in arg_editors_container.get_children():
		arg_editors_container.remove_child(child)
		child.queue_free()
	
	for i in function.arguments.size():
		_add_arg_editor(function.get_argument(i))


func _update_description() -> void:
	if not is_node_ready():
		await ready
	
	description_edit.text = function.description


static func get_type(string: String) -> Variant.Type:
	if string == "Variant":
		return TYPE_NIL
	
	for t in TYPE_MAX:
		if type_string(t) == string:
			return t as Variant.Type
	
	return TYPE_OBJECT


func _on_name_editor_text_submitted(new_text: String) -> void:
	function.set_name(new_text).save()
	
	name_editor.release_focus()


func _on_add_arg_button_pressed() -> void:
	var argument := function.add_argument("new_argument")
	
	if function.arguments.size() > 1 and function.get_argument(-2).has_default:
		argument.has_default = true
	
	function.save()
	var arg_editor := _add_arg_editor(argument)
	arg_editor.name_editor.grab_focus()
	arg_editor.name_editor.select_all()


func _add_arg_editor(argument: __EffectsFileManager.Function.Argument) -> __EffectManagerEffectEditorArgument:
	const EFFECT_MANAGER_EFFECT_EDITOR_ARGUMENT: PackedScene = preload("res://addons/effect_manager/effect_manager_effect_editor_argument.tscn")
	
	var arg_editor: __EffectManagerEffectEditorArgument = EFFECT_MANAGER_EFFECT_EDITOR_ARGUMENT.instantiate()
	
	arg_editor.argument = argument
	
	#arg_editor.arg_index = arg_index
	#arg_editor.arg_name = argument.name
	#arg_editor.type = argument.type
	#arg_editor.type_name = argument.type_name
	#arg_editor.has_default = argument.has_default
	#arg_editor.allow_default = allow_default
	#arg_editor.default = argument.get_default_string()
	
	arg_editors_container.add_child(arg_editor)
	
	#arg_editor.deleted.connect(func():
		#arg_editors_container.remove_child(arg_editor)
		#arg_editor.queue_free()
		#
		#function.arguments.erase(argument)
		#
		#function.save()
	#)
	
	return arg_editor


func _on_description_edit_text_changed() -> void:
	function.description = description_edit.text
	
	if not function_save_queued:
		function_save_queued = true
		await get_tree().create_timer(1).timeout
		function_save_queued = false
		function.save()


func _on_return_type_button_about_to_popup() -> void:
	var popup := return_type_button.get_popup()
	popup.clear()
	
	popup.add_radio_check_item("void")
	if function.return_type == -1:
		popup.set_item_checked(-1, true)
	
	if not function.arguments.is_empty():
		popup.add_radio_check_item(function.get_argument(0).get_type_string())
		if function.get_return_string() == function.get_argument(0).get_type_string():
			popup.set_item_checked(-1, true)
	
	match await Promise.capture(popup.index_pressed):
		0:
			function.return_type = -1
		1:
			function.return_type = function.get_argument(0).type
			function.return_type_name = function.get_argument(0).type_name
	
	function.save()
