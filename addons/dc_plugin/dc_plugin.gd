@tool
extends EditorPlugin

#region error supressor

var errors: VBoxContainer :
	get:
		if not errors and self.is_inside_tree():
			errors = get_tree().root.find_child("Errors*", true, false)
		return errors
var errors_tree: Tree :
	get:
		if not errors_tree and self.is_inside_tree():
			errors_tree = errors.get_child(1)
		return errors_tree
var tab_container: TabContainer :
	get:
		if not tab_container and self.is_inside_tree():
			tab_container = errors.get_parent()
		return tab_container
var debugger: Button :
	get:
		if not debugger and self.is_inside_tree():
			var queue: Array[Node] = [get_tree().root]
			while not queue.is_empty():
				var node := queue.pop_back() as Node
				if node is Button and node.text.match("Debugger*"):
					debugger = node
				
				queue.append_array(node.get_children())
		return debugger
var saved_error_count := -1


func _process(_delta: float) -> void:
	var root := errors_tree.get_root()
	if root == null:
		return
	
	var old_error_count := root.get_child_count()
	if saved_error_count < 0:
		saved_error_count = old_error_count
	var new_error_count := old_error_count
	var found_warning := false
	var found_error := false
	for item in root.get_children():
		if item.get_text(1).match("*Parameter \"SceneTree::get_singleton()\" is null.*"):
			root.remove_child(item)
			new_error_count -= 1
		elif item.get_custom_color(1) == errors_tree.get_theme_color("warning_color", "Editor"):
			found_warning = true
		elif item.get_custom_color(1) == errors_tree.get_theme_color("error_color", "Editor"):
			found_error = true
	
	if saved_error_count == new_error_count and new_error_count == old_error_count:
		return
	
	if new_error_count == 0:
		get_tree().process_frame.connect(get_tree().process_frame.connect.bind(func() -> void:
			errors.name = "Errors"
			tab_container.set_tab_icon(errors.get_index(), null)
			debugger.text = "Debugger"
			debugger.icon = null
			debugger.remove_theme_color_override("font_color")
		, CONNECT_DEFERRED | CONNECT_ONE_SHOT), CONNECT_ONE_SHOT)
	else:
		get_tree().process_frame.connect(get_tree().process_frame.connect.bind(func() -> void:
			errors.name = "Errors (%d)" % new_error_count
			var icon: Texture2D
			var color: Color
			match [found_error, found_warning]:
				[true, false]:
					icon = errors_tree.get_theme_icon("Error", "EditorIcons")
					color = errors_tree.get_theme_color("error_color", "Editor")
				[false, true]:
					icon = errors_tree.get_theme_icon("Warning", "EditorIcons")
					color = errors_tree.get_theme_color("warning_color", "Editor")
				[true, true]:
					icon = errors_tree.get_theme_icon("ErrorWarning", "EditorIcons")
					color = errors_tree.get_theme_color("error_color", "Editor")
			tab_container.set_tab_icon(errors.get_index(), icon)
			debugger.text = "Debugger (%d)" % new_error_count
			debugger.icon = icon
			debugger.add_theme_color_override("font_color", color)
		, CONNECT_DEFERRED | CONNECT_ONE_SHOT), CONNECT_ONE_SHOT)
	
	if old_error_count > new_error_count:
		print_rich("[color=web_gray]DCPlugin: Suppressed %d errors. See [url=https://github.com/godotengine/godot/issues/110548]this GitHub issue[/url] for more info.[/color]" % (old_error_count - new_error_count))
	saved_error_count = new_error_count

#endregion


const COMMANDS_GROUP_NAME := "DemonCrawl Helper Commands"
const COMMAND_ADD_ITEM := "Add Item"
const COMMAND_ADD_ITEM_KEY := COMMANDS_GROUP_NAME + "/dc.add-item"
const COMMAND_ADD_MASTERY := "Add Mastery"
const COMMAND_ADD_MASTERY_KEY := COMMANDS_GROUP_NAME + "/dc.add-mastery"
const ADD_ITEM_SCENE := preload("res://addons/dc_plugin/add_item.tscn")
const ADD_MASTERY_SCENE := preload("res://addons/dc_plugin/add_mastery_popup.tscn")


func _enter_tree() -> void:
	EditorInterface.get_command_palette().add_command(COMMAND_ADD_ITEM, COMMAND_ADD_ITEM_KEY, add_item)
	EditorInterface.get_command_palette().add_command(COMMAND_ADD_MASTERY, COMMAND_ADD_MASTERY_KEY, add_mastery)


func _exit_tree() -> void:
	EditorInterface.get_command_palette().remove_command(COMMAND_ADD_ITEM_KEY)
	EditorInterface.get_command_palette().remove_command(COMMAND_ADD_MASTERY_KEY)


func add_item() -> void:
	var window := ADD_ITEM_SCENE.instantiate() as Window
	EditorInterface.popup_dialog_centered(window, Vector2(512, 384))
	
	window.close_requested.connect(window.queue_free)


func add_mastery() -> void:
	var window := ADD_MASTERY_SCENE.instantiate() as Window
	EditorInterface.popup_dialog_centered(window, Vector2(512, 384))
	
	window.close_requested.connect(window.queue_free)
