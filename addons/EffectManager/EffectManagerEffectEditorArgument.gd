@tool
extends HBoxContainer
class_name __EffectManagerEffectEditorArgument

# ==============================================================================
@onready var index_label: Label = %IndexLabel
@onready var name_editor: LineEdit = %NameEditor
@onready var type_button: MenuButton = %TypeButton
@onready var add_default_button: Button = %AddDefaultButton
@onready var default_container: HBoxContainer = %DefaultContainer
@onready var default_label: RichTextLabel = %DefaultLabel
@onready var change_default_button: MenuButton = %ChangeDefaultButton
# ==============================================================================
var argument: __EffectsFileManager.Function.Argument :
	set(value):
		argument = value
		
		argument_changed.emit(value)
		
		if not argument:
			return
		
		_update_name(argument.name)
		_update_type(argument.type)
		_update_type_name(argument.type_name)
		_update_default()
		
		argument.name_changed.connect(_update_name)
		argument.type_changed.connect(_update_type)
		argument.type_name_changed.connect(_update_type_name)
		argument.has_default_changed.connect(_update_default.unbind(1))
		argument.default_changed.connect(_update_default.unbind(1))
		
		_update_index()
		argument.get_function().return_type_changed.connect(_update_index.unbind(1))
		
		while true:
			var next := await argument.get_next_argument()
			_update_default()
			next.has_default_changed.connect(func(new_has_default: bool) -> void:
				if not new_has_default:
					argument.has_default = false
				_update_default()
			)
			await next.deleted
			_update_default()

var builtin_class_tree: Tree
var user_class_tree: Tree
# ==============================================================================
signal modified()
signal argument_changed(argument: __EffectsFileManager.Function.Argument)
#signal deleted()
# ==============================================================================

func _ready() -> void:
	_init_change_type_menu()


func _init_change_type_menu() -> void:
	var popup := type_button.get_popup()
	
	popup.clear()
	
	popup.add_radio_check_item("Variant")
	
	var builtin_type_select := PopupMenu.new()
	
	builtin_type_select.name = "BuiltinTypeSelect"
	
	popup.add_child(builtin_type_select)
	
	const VARIANT_INDEX := 0
	const BUILTIN_TYPE_SELECT_INDEX := 1
	const CLASS_INDEX := 2
	popup.add_submenu_item("Built-in type", "BuiltinTypeSelect")
	popup.set_item_as_radio_checkable(BUILTIN_TYPE_SELECT_INDEX, true)
	
	#popup.add_radio_check_item("Built-in class...")
	popup.add_radio_check_item("Object Class...")
	
	for t in TYPE_MAX:
		if t in [TYPE_NIL, TYPE_OBJECT]:
			continue
		
		builtin_type_select.add_radio_check_item(type_string(t), t)
	
	if not argument:
		await argument_changed
	
	if argument.type == TYPE_NIL:
		popup.set_item_checked(VARIANT_INDEX, true)
	elif argument.type == TYPE_OBJECT:
		popup.set_item_checked(CLASS_INDEX, true)
	else:
		popup.set_item_checked(BUILTIN_TYPE_SELECT_INDEX, true)
		builtin_type_select.set_item_checked(builtin_type_select.get_item_index(argument.type), true)
	
	builtin_type_select.id_pressed.connect(func(t: Variant.Type) -> void:
		if argument.type == TYPE_NIL:
			popup.set_item_checked(0, false)
		elif argument.type == TYPE_OBJECT:
			popup.set_item_checked(2, false)
			popup.set_item_checked(3, false)
		else:
			builtin_type_select.set_item_checked(builtin_type_select.get_item_index(argument.type), false)
		
		builtin_type_select.set_item_checked(builtin_type_select.get_item_index(t), true)
		popup.set_item_checked(BUILTIN_TYPE_SELECT_INDEX, true)
		
		argument.type = t
		
		argument.save()
	)
	
	popup.index_pressed.connect(func(index: int) -> void:
		match index:
			0:
				argument.type = TYPE_NIL
				argument.save()
				
				popup.set_item_checked(VARIANT_INDEX, true)
				popup.set_item_checked(BUILTIN_TYPE_SELECT_INDEX, false)
				popup.set_item_checked(CLASS_INDEX, false)
			2:
				var type_name := await __EffectManagerPlugin.main_screen.select_user_class()
				if type_name.is_empty():
					return
				
				argument.type_name = type_name
				argument.type = TYPE_OBJECT
				
				argument.save()
				
				popup.set_item_checked(VARIANT_INDEX, false)
				popup.set_item_checked(BUILTIN_TYPE_SELECT_INDEX, false)
				popup.set_item_checked(CLASS_INDEX, true)
	)


func _update_index() -> void:
	if not is_node_ready():
		await ready
	
	index_label.text = "#" + str(get_index() + 1)
	
	if argument.get_function().return_type == -1 or get_index() != 0:
		index_label.label_settings.font_color = Color(0.745, 0.745, 0.745)
	else:
		index_label.label_settings.font_color = __EffectManagerPlugin.get_type_color("function_color")


func _update_name(value: String) -> void:
	if not is_node_ready():
		await ready
	
	name_editor.text = value


func _update_type(value: Variant.Type) -> void:
	if not is_node_ready():
		await ready
	
	if value == TYPE_NIL:
		type_button.text = "Variant"
		type_button.add_theme_color_override("font_color", __EffectManagerPlugin.get_type_color("base_type_color"))
	elif value == TYPE_OBJECT:
		type_button.text = argument.type_name
		if ClassDB.class_exists(argument.type_name):
			type_button.add_theme_color_override("font_color", __EffectManagerPlugin.get_type_color("engine_type_color"))
		else:
			type_button.add_theme_color_override("font_color", __EffectManagerPlugin.get_type_color("user_type_color"))
	else:
		type_button.text = type_string(value)
		type_button.add_theme_color_override("font_color", __EffectManagerPlugin.get_type_color("base_type_color"))


func _update_type_name(value: String) -> void:
	if not is_node_ready():
		await ready
	
	if argument.type == TYPE_OBJECT:
		type_button.text = value
		if ClassDB.class_exists(value):
			type_button.add_theme_color_override("font_color", __EffectManagerPlugin.get_type_color("engine_type_color"))
		else:
			for class_data in ProjectSettings.get_global_class_list():
				if class_data.class == value:
					type_button.add_theme_color_override("font_color", __EffectManagerPlugin.get_type_color("user_type_color"))
					return
			
			type_button.add_theme_color_override("font_color", EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/comment_markers/warning_color"))


func _update_default() -> void:
	if not is_node_ready():
		await ready
	
	add_default_button.visible = not argument.has_default and argument.allows_default()
	default_container.visible = argument.has_default
	if argument.default in [null, false, true]:
		default_label.text = "[color=#%s]%s[/color]" % [__EffectManagerPlugin.get_type_color("keyword_color").to_html(), argument.get_default_string()]
		return
	
	default_label.text = argument.get_default_string()
	
	for t in range(TYPE_MAX - 1, -1, -1):
		if t == TYPE_OBJECT:
			continue
		if type_string(t) in default_label.text:
			default_label.text = default_label.text.replace(type_string(t), "[color=#%s]%s[/color]" % [__EffectManagerPlugin.get_type_color("base_type_color").to_html(), type_string(t)])


func _on_add_default_button_pressed() -> void:
	argument.has_default = true
	argument.reset_default()
	
	argument.save()


func _on_remove_default_button_pressed() -> void:
	argument.has_default = false
	argument.save()


func _on_change_default_button_about_to_popup() -> void:
	var popup := change_default_button.get_popup()
	
	popup.clear()
	
	if argument.type == TYPE_NIL:
		return # TODO: special case
	elif argument.type == TYPE_OBJECT:
		popup.add_radio_check_item("null")
		if argument.default == null:
			popup.set_item_checked(-1, true)
	else:
		popup.add_radio_check_item(get_value_string(argument.get_base_value()))
		if argument.default == argument.get_base_value():
			popup.set_item_checked(-1, true)
	
	match argument.type:
		TYPE_BOOL:
			popup.add_radio_check_item("true")
			popup.set_item_checked(argument.default == true, true)
			
			popup.index_pressed.connect(func(index: int) -> void:
				argument.default = bool(index)
				argument.save()
			, CONNECT_ONE_SHOT)
			
			return # no custom option
		TYPE_INT:
			const ITEMS: PackedInt32Array = [0, 1, -1]
			
			for i in ITEMS.slice(1):
				popup.add_radio_check_item(str(i))
			
			if argument.default in ITEMS:
				popup.set_item_checked(ITEMS.find(argument.default), true)
			
			popup.index_pressed.connect(func(index: int) -> void:
				if index < ITEMS.size():
					argument.default = ITEMS[index]
				argument.save()
			, CONNECT_ONE_SHOT)
		TYPE_FLOAT:
			const ITEMS: PackedFloat32Array = [0.0, 1.0, -1.0, NAN, INF, -INF]
			
			popup.set_item_text(0, "0.0") # otherwise it will be "0"
			for i in ITEMS.slice(1):
				popup.add_radio_check_item(get_value_string(i))
			
			if argument.default in ITEMS:
				popup.set_item_checked(ITEMS.find(argument.default), true)
			
			popup.index_pressed.connect(func(index: int) -> void:
				if index < ITEMS.size():
					argument.default = ITEMS[index]
				argument.save()
			, CONNECT_ONE_SHOT)
		_:
			popup.index_pressed.connect(func(index: int) -> void:
				if index == 0:
					argument.reset_default()
					argument.save()
				elif index == popup.item_count - 1:
					pass # TODO: ask for custom value
			, CONNECT_ONE_SHOT)
	
	popup.add_radio_check_item("Custom...")
	popup.set_item_disabled(-1, true)


func _on_name_editor_text_submitted(new_text: String) -> void:
	if new_text.is_valid_identifier():
		argument.set_name(new_text).save()
	
	name_editor.release_focus()


func get_value_string(value: Variant = type_convert(null, argument.type)) -> String:
	if typeof(value) == TYPE_NIL:
		return "null"
	
	match typeof(value):
		TYPE_BOOL:
			return str(value)
		TYPE_INT:
			return str(value)
		TYPE_FLOAT:
			var string := str(value)
			if not "." in string:
				string += ".0"
			return string
	
	if value == type_convert(null, typeof(value)):
		if typeof(value) == TYPE_OBJECT:
			return "null"
		return type_string(typeof(value)) + "()"
	
	match typeof(value):
		TYPE_OBJECT:
			if is_instance_valid(value):
				push_error("Cannot convert non-null Object to String.")
				return ""
			return "null"
		TYPE_TRANSFORM2D:
			return "Transform2D(Vector2(%s, %s), Vector2(%s, %s), Vector2(%s, %s))" % [
				value.x.x, value.x.y, value.y.x, value.y.y, value.origin.x, value.origin.y
			]
	
	return var_to_str(value)


func _on_remove_argument_button_pressed() -> void:
	argument.delete()
	argument.save()
	queue_free()
	#deleted.emit()
