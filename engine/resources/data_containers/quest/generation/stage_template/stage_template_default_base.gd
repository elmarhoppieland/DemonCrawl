@abstract
extends StageTemplateBase
class_name StageTemplateDefaultBase

## Base class for normal [Stage] templates.

# ==============================================================================
@export_group("Min Power", "min_power_")
@export var min_power_minimum := 0 ## The minimum value that the stage's minimum power can be.
@export var min_power_maximum := 0 ## The maximum value that the stage's minimum power can be.

@export_group("Max Power", "max_power_")
@export var max_power_minimum := 0 ## The minimum value that the stage's maximum power can be.
@export var max_power_maximum := 0 ## The maximum value that the stage's maximum power can be.

@export_group("Density", "density_")
@export_range(0.0, 1.0, 0.001) var density_minimum := 0.0 ## The minimum density that the stage can have.
@export_range(0.0, 1.0, 0.001) var density_maximum := 0.0 ## The maximum density that the stage can have.

@export_group("Size", "size_")
@export var size_minimum := 0 ## The minimum size that the stage can have, both horizontally and vertically.
@export var size_maximum := 0 ## The maximum size that the stage can have, both horizontally and vertically.
# ==============================================================================

func generate() -> Stage:
	var stage := _generate()
	
	stage.size.x = randi_range(size_minimum, size_maximum)
	stage.size.y = randi_range(size_minimum, size_maximum)
	
	stage.min_power = randi_range(min_power_minimum, min_power_maximum)
	stage.max_power = randi_range(max_power_minimum, max_power_maximum)
	
	stage.monsters = roundi(stage.area() * randf_range(density_minimum, density_maximum))
	
	return stage


@abstract func _generate() -> Stage
