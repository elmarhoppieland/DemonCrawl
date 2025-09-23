@tool
extends Resource
class_name StageBase

# ==============================================================================
@export var name := ""

@export_group("Min Power", "min_power_")
@export var min_power_minimum := 0
@export var min_power_maximum := 0

@export_group("Max Power", "max_power_")
@export var max_power_minimum := 0
@export var max_power_maximum := 0

@export_group("Density", "density_")
@export var density_minimum := 0.0
@export var density_maximum := 0.0

@export_group("Size", "size_")
@export var size_minimum := 0
@export var size_maximum := 0

@export_group("Mod Difficulty", "mod_difficulty_")
@export var mod_difficulty_minimum := 0
@export var mod_difficulty_maximum := 0
# ==============================================================================

func generate() -> Stage:
	var stage := Stage.new(name)
	
	stage.size.x = randi_range(size_minimum, size_maximum)
	stage.size.y = randi_range(size_minimum, size_maximum)
	
	stage.min_power = randi_range(min_power_minimum, min_power_maximum)
	stage.max_power = randi_range(max_power_minimum, max_power_maximum)
	
	stage.monsters = roundi(stage.area() * randf_range(density_minimum, density_maximum))
	
	var total_difficulty := randi_range(mod_difficulty_minimum, mod_difficulty_maximum)
	while total_difficulty > 0:
		var mod := StageModDB.create_filter().get_random_mod()
		stage.mods.append(mod)
		total_difficulty -= mod.data.difficulty
	
	return stage
