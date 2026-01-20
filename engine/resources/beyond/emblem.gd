@abstract
extends Node
class_name Emblem

## An object that modifies a Beyond quest.

# ==============================================================================
@export var data: EmblemData ## The [EmblemData] of this [Emblem].
# ==============================================================================

@warning_ignore("shadowed_variable")
func _init(data: EmblemData) -> void:
	self.data = data


## Parses the given [param stage_list], possibly modifying it for this [Emblem].
func parse_stage_list(artifacts: Array[StageFile], stage_list: Array[StageTemplateBase]) -> Array[StageTemplateBase]:
	return _parse_stage_list(artifacts, stage_list)


## Virtual method. If implemented, should parse and modify the given [param stage_list].
## If not implemented, the [param stage_list] remains unmodified.
@warning_ignore("unused_parameter")
func _parse_stage_list(artifacts: Array[StageFile], stage_list: Array[StageTemplateBase]) -> Array[StageTemplateBase]:
	return stage_list


func _enter_tree() -> void:
	get_quest().started.connect(_quest_start)
	
	var base := self
	while base != null:
		if not base.is_node_ready():
			await base.ready
		base = get_parent()
	
	_enable()


func _exit_tree() -> void:
	get_quest().started.disconnect(_quest_start)
	
	_disable()


## Returns the [Quest] this [Emblem] is in.
func get_quest() -> Quest:
	var base := get_parent()
	while base != null and base is not Quest:
		base = base.get_parent()
	return base


## Virtual method. Called every time this [Emblem] is enabled, usually when it
## enters the scene tree, after its entire ancestry is ready.
func _enable() -> void:
	pass


## Virtual method. Called every time this [Emblem] is disabled, usually when it
## exits the scene tree.
func _disable() -> void:
	pass


## Virtual method. Called (once) when the [Quest] starts.
func _quest_start() -> void:
	pass
