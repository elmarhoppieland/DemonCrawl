@abstract
class_name SceneManager

## Manages the current scene.

# ==============================================================================

## Changes the current scene to the given [param node].
static func change_scene_to_node(node: Node) -> void:
	await change_scene_to_custom(func() -> Node: return node)


## Changes the current scene to the specified [code]file[/code]. Returns the created
## [Node] after instantiating it.
## [br][br][b]Note:[/b] The scene will be instantiated at the end of the current frame.
## Therefore, this is a coroutine and should be called with [code]await[/code] if
## the return value is needed.
static func change_scene_to_file(file: String) -> Node:
	return await change_scene_to_custom(func() -> Node: return load(file).instantiate())


## Changes the current scene to the specified [code]packed_scene[/code]. Returns the
## created [Node] after instantiating it.
## [br][br][b]Note:[/b] The scene will be instantiated at the end of the current frame.
## therefore, this is a coroutine and should be called with [code]await[/code] if
## the return value is needed.
static func change_scene_to_packed(packed_scene: PackedScene) -> Node:
	return await change_scene_to_custom(packed_scene.instantiate)


## Changes the current scene a new [Node], in the following way:
## [br][br]First, the current scene is removed from the scene tree.
## [br][br]At the end of the current frame (see [method Promsise.defer]), the
## [param instantiator] is called. Its return value is then added to the scene tree.
## [br][br][b]Note:[/b] The instantiator is called at the end of the current frame.
## Therefore, this is a coroutine and should be called with [code]await[/code] if
## the return value is needed.
static func change_scene_to_custom(instantiator: Callable) -> Node:
	if Engine.is_editor_hint():
		return null
	
	var tree := Engine.get_main_loop() as SceneTree
	tree.current_scene.queue_free()
	tree.root.remove_child(tree.current_scene) # this sets tree.current_scene to null
	
	await Promise.defer()
	
	var scene := instantiator.call() as Node
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
