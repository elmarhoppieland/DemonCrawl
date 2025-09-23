@tool
extends PopupPanel
class_name __UserClassSelector

# ==============================================================================
static var classes_tree: Tree
static var classes_load_thread := AutoThread.new()
# ==============================================================================
var load_progress: Progress

var allow_paths := false
# ==============================================================================
@onready var user_class_search: LineEdit = %UserClassSearch
@onready var waiting_container: MarginContainer = %WaitingContainer
@onready var waiting_progress_bar: ProgressBar = %WaitingProgressBar
# ==============================================================================

func _ready() -> void:
	classes_tree = Tree.new()
	classes_load_thread = AutoThread.new()
	
	reload_classes()


func _on_about_to_popup() -> void:
	user_class_search.grab_focus()
	user_class_search.clear()


func reload_classes() -> void:
	if is_instance_valid(classes_tree) and classes_tree.is_inside_tree():
		classes_tree.get_parent().remove_child(classes_tree)
		classes_tree.clear()
	
	if classes_load_thread.is_alive():
		await classes_load_thread.finished
	
	if is_instance_valid(classes_tree) and classes_tree.get_root() != null:
		if not is_ancestor_of(classes_tree):
			if classes_tree.is_inside_tree():
				classes_tree.reparent(get_child(0))
			else:
				_add_classes_tree_to_tree()
		
		waiting_container.hide()
		
		return
	
	if is_instance_valid(classes_tree):
		classes_tree.clear()
	else:
		classes_tree = Tree.new()
	
	if classes_tree.is_inside_tree():
		classes_tree.get_parent().remove_child(classes_tree)
	
	load_progress = Progress.new(waiting_progress_bar)
	
	load_progress.max_value = ClassDB.get_class_list().size() + UserClassDB.get_class_list().size()
	
	var root := classes_tree.create_item()
	root.set_text(0, "Object")
	root.set_tooltip_text(0, " ")
	
	load_progress.current_value = 1  # we have already done Object
	
	waiting_container.show()
	classes_load_thread.start(_populate_classes_tree_from_base.bind("Object", root))
	
	var thread_id := classes_load_thread.get_id().to_int()
	UserClassDB.freeze_class_list_on_thread(thread_id)
	classes_load_thread.finished.connect(UserClassDB.unfreeze_class_list_on_thread.bind(thread_id).unbind(1), CONNECT_ONE_SHOT)
	
	await classes_load_thread.finished
	
	waiting_container.hide()
	
	_add_classes_tree_to_tree()
	classes_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL


func _add_classes_tree_to_tree() -> void:
	if classes_tree.is_inside_tree():
		return
	get_child(0).add_child(classes_tree)


func _populate_classes_tree_from_base(base_class: String, root: TreeItem) -> void:
	for c in ClassDB.get_inheriters_from_class(base_class):
		if ClassDB.get_parent_class(c) != base_class:
			continue
		
		var item := root.create_child()
		item.set_text(0, c)
		item.set_tooltip_text(0, " ")
		
		if is_instance_valid(load_progress):
			load_progress.current_value += 1
		
		if not is_instance_valid(self):
			return
		
		_populate_classes_tree_from_base(c, item)
	
	for c in UserClassDB.get_inheriters_from_class(base_class):
		if UserClassDB.get_parent_class(c) != base_class:
			continue
		
		c = UserClassDB.class_get_name(c)
		if not allow_paths and c.is_absolute_path():
			continue  # this script does not have a class name
		
		var item := root.create_child()
		item.set_text(0, c)
		item.set_tooltip_text(0, " ")
		
		if is_instance_valid(load_progress):
			load_progress.current_value += 1
		
		if not is_instance_valid(self):
			return
		
		_populate_classes_tree_from_base(c, item)


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


func _on_user_class_search_text_changed(new_text: String) -> void:
	__UserClassSelector._update_treeitem_visibility(classes_tree.get_root(), new_text)


func _on_user_class_search_text_submitted(_new_text: String) -> void:
	# we are emitting a built-in signal here which should work but may cause issues
	classes_tree.item_activated.emit()


func _exit_tree() -> void:
	if is_instance_valid(classes_tree) and classes_tree.is_inside_tree():
		# keep the tree alive
		classes_tree.get_parent().remove_child(classes_tree)


class Progress:
	var current_value := 0 :
		set(value):
			current_value = value
			if is_instance_valid(progress_bar):
				progress_bar.set_deferred("value", value)
	var max_value := 0 :
		set(value):
			max_value = value
			if is_instance_valid(progress_bar):
				progress_bar.set_deferred("max_value", max_value)
	var progress_bar: ProgressBar
	
	func _init(bar: ProgressBar) -> void:
		progress_bar = bar


func _on_reload_user_classes_button_pressed() -> void:
	classes_tree.clear()
	reload_classes()
