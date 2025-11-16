@tool
@abstract
extends ResourceNode
class_name StageInstanceBase

# ==============================================================================
var _scene: Node : get = get_scene

var _reloaded := false : get = was_reloaded
# ==============================================================================
signal finished()
# ==============================================================================

func _init() -> void:
	_reloaded = Eternity.get_processing_file() != null
	
	tree_exited.connect(Eternity.save, CONNECT_DEFERRED)


## Notifies this stage that the player has entered this stage, or that the player
## continues this stage.
func play() -> void:
	_play()


## Virtual method. Called when the player enters this stage, and when the player
## continues this stage.
func _play() -> void:
	pass


## Returns [code]true[/code] if this stage was reloaded from disk.
## [br][br]This is most useful in the [code]_ready()[/code] function, to check
## if initialization is still needed.
func was_reloaded() -> bool:
	return _reloaded


## Returns the stage this object is an instance of.
func get_stage() -> StageBase:
	var stage := get_parent()
	while stage != null and stage is not StageBase:
		stage = stage.get_parent()
	return stage


## Returns the quest this object is in.
func get_quest() -> Quest:
	var base := get_parent()
	while base != null and base is not Quest:
		base = base.get_parent()
	return base


## Returns this instance's scene, if it exists.
func get_scene() -> Node:
	return _scene


## Returns whether the stage currently has an active scene.
func has_scene() -> bool:
	return get_scene() != null


## Creates and returns a new scene.
func create_scene() -> Node:
	assert(_scene == null, "Cannot create a scene when one is already active.")
	
	_scene = _create_scene()
	return _scene


## Virtual method. Should create the scene for this stage, and return its root node.
@abstract func _create_scene() -> Node


## Finishes this stage.
func finish() -> void:
	get_stage().completed = true
	finished.emit()
	EffectManager.propagate(get_effects().finished, self)


## Returns the [EventBus] that holds stage's effects.
func get_effects() -> StageBaseEffects:
	return get_event_bus(_get_effects())


## Virtual method. Should return the [Script] (or class) of this stage's [EventBus].
## The returned [Script] must extend [StageInstanceBase.StageBaseEffects].
## [br][br][b]Note:[/b] If you override this method, you may also want to override
## [method get_effects] (simply calling [code]super()[/code]) for easy typing.
func _get_effects() -> Script:
	return StageBaseEffects


## Returns this stage's [EventBusManager]. Creates one if it doesn't exist yet.
func get_event_bus_manager() -> EventBusManager:
	return get_component(EventBusManager, self, func() -> EventBusManager:
		var instance: EventBusManager = add_component(EventBusManager)
		instance.event_owner = self
		instance.event_owner_parent = get_quest()
		return instance
	)


## Returns the [EventBus] with the given [Script]. Creates it if it doesn't exist yet.
func get_event_bus(script: Script) -> EventBus:
	return get_event_bus_manager().get_event_bus(script)


## Returns the component with the given [param component_script], under the given
## [param parent]. Creates it if it doesn't exist yet.
func get_component(component_script: Script, parent: Node = self, add_method: Callable = add_component.bind(component_script, parent)) -> Node:
	for child in parent.get_children():
		if component_script.instance_has(child):
			return child
	
	return add_method.call()


## Creates and returns a component with the given [param component_script],
## as a child of [param parent]. See also [method get_component].
func add_component(component_script: Script, parent: Node = self) -> Node:
	var instance: Node = component_script.new()
	parent.add_child(instance)
	return instance

@warning_ignore_start("unused_signal")

class StageBaseEffects extends EventBus:
	signal entered(stage: StageInstanceBase)
	signal finished(stage: StageInstanceBase)
	signal exited(stage: StageInstanceBase)

@warning_ignore_restore("unused_signal")
