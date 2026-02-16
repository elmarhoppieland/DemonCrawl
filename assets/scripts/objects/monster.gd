@tool
extends CellObject
class_name Monster

## A monster that attacks the player when revealed.

# ==============================================================================
@export var monster_name := ""

@export var _primary := true
# ==============================================================================

func _get_name_id() -> String:
	return "object.monster"


func _spawn() -> void:
	self.randomize()


## Randomizes the type and name of this [Monster], depending on its origin stage.
func randomize() -> void:
	if get_origin_stage().file is CombinedStageFile:
		_primary = randi() % 2
	
	if _primary:
		monster_name = get_origin_stage().get_primary_file().generate_monster_name()
	else:
		monster_name = get_origin_stage().get_secondary_file().generate_monster_name()
	
	clear_texture_cache()
	emit_changed()


func _get_texture() -> Texture2D:
	var texture := AnimatedTextureSequence.new()
	
	if _primary:
		texture.atlas = get_origin_stage().get_primary_file().monster_texture
	else:
		texture.atlas = get_origin_stage().get_secondary_file().monster_texture
	
	return texture


func _reveal_active() -> void:
	EffectManager.propagate(get_stage_instance().get_cell_effects().mistake_made, get_cell())
	Quest.get_current().get_stats().damage(get_origin_stage().roll_power(), self)


func _get_annotation_title() -> String:
	return monster_name


func _aura_apply() -> void:
	if get_cell().get_aura() is Burning:
		kill()


func _contribute_value() -> int:
	return 1


func _validate_property(property: Dictionary) -> void:
	if property.name == &"_primary" and get_origin_stage().file is not CombinedStageFile:
		property.usage &= ~PROPERTY_USAGE_STORAGE
