@tool
extends Stranger
class_name Nomad

# ==============================================================================
@export var offer: NomadOffer :
	set(value):
		offer = value
		if Engine.is_editor_hint() and value:
			value._nomad = self
# ==============================================================================

func _spawn() -> void:
	var script: Script
	while not script or not NomadOffer.is_enabled(script):
		script = preload("res://Assets/loot_tables/NomadOffer.tres").generate()
	
	offer = script.new(self)
	offer.notify_spawned()


func _interact() -> void:
	if not offer.can_perform():
		Toasts.add_toast(offer.get_fail_message(), IconManager.get_icon_data("Nomad/Frame0").create_texture())
		return
	
	offer.perform()


func _get_texture() -> TextureSequence:
	var texture := TextureSequence.new()
	texture.atlas = get_theme_icon("stranger_nomad")
	texture.size = Cell.CELL_SIZE
	return texture


func _get_annotation_title() -> String:
	return tr("STRANGER_NOMAD").to_upper()


func _get_annotation_subtext() -> String:
	return offer.get_description()


func _animate(time: float) -> void:
	get_texture().animate(1.0, time)
