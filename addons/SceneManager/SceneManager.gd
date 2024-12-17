extends StaticClass
class_name SceneManager

# ==============================================================================

## Changes the current scene to the specified [code]file[/code]. Returns the created
## [Node] after instantiating it.
## [br][br][b]Note:[/b] The scene will be instantiated at the end of the current frame.
## therefore, this is a coroutine and should be called with [code]await[/code] if
## the return value is needed.
static func change_scene_to_file(file: String) -> Node:
	return await change_scene_to_packed(load(file))


## Changes the current scene to the specified [code]packed_scene[/code]. Returns the
## created [Node] after instantiating it.
## [br][br][b]Note:[/b] The scene will be instantiated at the end of the current frame.
## therefore, this is a coroutine and should be called with [code]await[/code] if
## the return value is needed.
static func change_scene_to_packed(packed_scene: PackedScene) -> Node:
	if Engine.is_editor_hint():
		return null
	
	var tree := Engine.get_main_loop() as SceneTree
	tree.current_scene.queue_free()
	tree.root.remove_child(tree.current_scene) # this sets tree.current_scene to null
	
	await Promise.defer()
	
	var scene := packed_scene.instantiate()
	tree.root.add_child(scene)
	tree.current_scene = scene
	return scene


## Reloads the current scene.
## [br][br][b]Note:[/b] This is the same as [method SceneTree.reload_current_scene].
static func reload_current_scene() -> Error:
	var tree := Engine.get_main_loop() as SceneTree
	return tree.reload_current_scene()


## Unloads the current scene.
## [br][br][b]Note:[/b] This is the same as [method SceneTree.unload_current_scene].
static func unload_current_scene() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	tree.unload_current_scene()
