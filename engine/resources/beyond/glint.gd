extends Node
class_name Glint

## An object that adds a positive effect to a Beyond quest.

# ==============================================================================
@export var data: GlintData ## The [GlintData] of this [Glint].
# ==============================================================================

@warning_ignore("shadowed_variable")
func _init(data: GlintData = null) -> void:
	self.data = data


func _enter_tree() -> void:
	get_quest().started.connect(_quest_start)
	
	if Eternity.get_current_loader() != null:
		return
	
	var base: Node = self
	while base != null:
		if not base.is_node_ready():
			await base.ready
		base = base.get_parent()
	
	_enable()


func _exit_tree() -> void:
	get_quest().started.disconnect(_quest_start)
	
	_disable()


## Returns the [Quest] this [Glint] is in.
func get_quest() -> Quest:
	var base := get_parent()
	while base != null and base is not Quest:
		base = base.get_parent()
	return base


## Virtual method. Called every time this [Glint] is enabled, usually when it
## enters the scene tree, after its entire ancestry is ready.
func _enable() -> void:
	pass


## Virtual method. Called every time this [Glint] is disabled, usually when it
## exits the scene tree.
func _disable() -> void:
	pass


## Virtual method. Called (once) when the [Quest] starts.
func _quest_start() -> void:
	pass
