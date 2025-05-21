@tool
extends TextureRect
class_name StageModIcon

# ==============================================================================
@export var data: StageModData :
	set(value):
		if data == value:
			return
		
		data = value
		
		if Engine.is_editor_hint():
			mod = value.get_mod_script().new()
# ==============================================================================
var mod: StageMod :
	set(value):
		mod = value
		
		if not is_node_ready():
			await ready
		
		if not value:
			data = null
			texture_rect.atlas = null
			return
		
		data = value.data
		
		value.icon = texture_rect
		
		texture_rect.texture.atlas = value.data.atlas
		texture_rect.texture.region = value.data.atlas_region
	get:
		if not mod:
			mod = data.get_mod_script().new()
		return mod
# ==============================================================================
@onready var texture_rect: TextureRect = %TextureRect
@onready var tooltip_grabber: TooltipGrabber = %TooltipGrabber
# ==============================================================================

static func create(_mod: StageMod) -> StageModIcon:
	var instance: StageModIcon = load("res://Engine/Resources/Scenes/StageModIcon.tscn").instantiate()
	instance.mod = _mod
	return instance


func _on_tooltip_grabber_about_to_show() -> void:
	tooltip_grabber.text = mod.data.name
	tooltip_grabber.subtext = mod.data.description
