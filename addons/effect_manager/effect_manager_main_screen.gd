@tool
extends Control
class_name __EffectManagerMainScreen

# ==============================================================================
@onready var effects_container: VBoxContainer = %EffectsContainer
@onready var user_class_selector: __UserClassSelector = %UserClassSelector
@onready var priority_groups_editor: __PriorityGroupsManager = %PriorityGroupsEditor
# ==============================================================================

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		__EffectManagerPlugin.main_screen = self


func _exit_tree() -> void:
	if not Engine.is_editor_hint() and __EffectManagerPlugin.main_screen == self:
		__EffectManagerPlugin.main_screen = null


func select_user_class(allow_paths: bool = false) -> StringName:
	user_class_selector.allow_paths = allow_paths
	user_class_selector.popup_centered.call_deferred()
	
	return await Promise.new({
		__UserClassSelector.classes_tree.item_activated: func() -> StringName:
			user_class_selector.hide()
			return __UserClassSelector.classes_tree.get_selected().get_text(0),
		user_class_selector.popup_hide: func() -> StringName:
			return &""
	}).map()


func _ready() -> void:
	EffectManager.reload_priority_tree()
	
	_init_effect_list()
	
	reload_classes()


func _init_effect_list() -> void:
	for function_name in __EffectsFileManager.get_function_list():
		var function := __EffectsFileManager.get_function(function_name)
		assert(function != null, "__EffectsFileManager.get_function_list() returned an invalid value: " + function_name + ".")
		
		var editor: __EffectManagerEffectEditor = load("res://addons/effect_manager/effect_manager_effect_editor.tscn").instantiate()
		editor.function = function
		
		effects_container.add_child(editor)


#func _init_user_class_selector() -> void:
	#if classes_load_thread.is_alive():
		#await classes_load_thread.finished
	#
	#if is_instance_valid(user_class_tree) and user_class_tree.get_root() != null:
		#if not is_ancestor_of(user_class_tree):
			#if user_class_tree.is_inside_tree():
				#user_class_tree.reparent(self)
			#else:
				#user_class_selector.get_child(0).add_child(user_class_tree)
		#
		#waiting_container.hide()
		#
		#return
	#
	#if is_instance_valid(user_class_tree):
		#user_class_tree.clear()
	#else:
		#user_class_tree = Tree.new()
	#
	#if user_class_tree.is_inside_tree():
		#user_class_tree.get_parent().remove_child(user_class_tree)
	#
	#var root := user_class_tree.create_item()
	#root.set_text(0, "Object")
	#
	#waiting_container.show()
	#classes_load_thread.start(_populate_user_class_tree_from_base.bind("Object", root))
	#
	#await classes_load_thread.finished
	#
	#waiting_container.hide()
	#
	#if not is_instance_valid(user_class_selector):
		## we have left the screen and no longer exist
		#return
	#
	#user_class_selector.get_child(0).add_child(user_class_tree)
	#user_class_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL


#static func _populate_user_class_tree_from_base(base_class: String, root: TreeItem) -> void:
	#for c in ClassDB.get_inheriters_from_class(base_class):
		#if ClassDB.get_parent_class(c) != base_class:
			#continue
		#
		#var item := root.create_child()
		#item.set_text(0, c)
		#item.set_tooltip_text(0, " ")
		#_populate_user_class_tree_from_base(c, item)
	#
	#for c in UserClassDB.get_inheriters_from_class(base_class):
		#if UserClassDB.get_parent_class(c) != base_class:
			#continue
		#
		#c = UserClassDB.class_get_name(c)
		#if c.is_absolute_path():
			#continue
		#var item := root.create_child()
		#item.set_text(0, c)
		#item.set_tooltip_text(0, " ")
		#_populate_user_class_tree_from_base(c, item)


static func _update_treeitem_visibility(item: TreeItem, search: String, current_selection_priority: int = 0) -> int:
	const PRIORITY_VAGUE_MATCH := 1
	const PRIORITY_START_MATCH := 2
	const PRIORITY_EXACT_MATCH := 3
	
	var visibility := true
	
	if search.is_empty():
		current_selection_priority = PRIORITY_EXACT_MATCH # this will select 'Object' (the root)
	elif item.get_text(0).to_lower() == search.to_lower():
		if current_selection_priority < PRIORITY_EXACT_MATCH:
			item.select(0)
			item.get_tree().scroll_to_item(item)
			current_selection_priority = PRIORITY_EXACT_MATCH
	elif item.get_text(0).to_lower().begins_with(search.to_lower()):
		if current_selection_priority < PRIORITY_START_MATCH:
			item.select(0)
			item.get_tree().scroll_to_item(item)
			current_selection_priority = PRIORITY_START_MATCH
	elif search.to_lower() in item.get_text(0).to_lower():
		if current_selection_priority < PRIORITY_VAGUE_MATCH:
			item.select(0)
			item.get_tree().scroll_to_item(item)
			current_selection_priority = PRIORITY_VAGUE_MATCH
	else:
		visibility = false
	
	for child in item.get_children():
		current_selection_priority = _update_treeitem_visibility(child, search, current_selection_priority)
		if current_selection_priority:
			visibility = true
	
	item.visible = visibility
	return current_selection_priority


func reload_classes() -> void:
	user_class_selector.reload_classes()


func _on_add_effect_button_pressed() -> void:
	var function := __EffectsFileManager.get_function("new_effect", true)
	function.save()
	
	var editor: __EffectManagerEffectEditor = load("res://addons/effect_manager/effect_manager_effect_editor.tscn").instantiate()
	editor.function = function
	effects_container.add_child(editor)


func _on_reload_user_classes_button_pressed() -> void:
	reload_classes()


func _on_edit_priority_groups_button_pressed() -> void:
	priority_groups_editor.popup_centered()
