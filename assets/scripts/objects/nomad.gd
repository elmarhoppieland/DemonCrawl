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
	var script: Script = null
	while not script or not NomadOffer.is_enabled(script):
		script = load("res://assets/loot_tables/nomad_offer.tres").generate()
	
	offer = script.new(self)
	offer.notify_spawned()


func _interact() -> void:
	if not offer.can_afford():
		var handled := handle_fail()
		if not handled:
			Toasts.add_toast(offer.get_fail_message(), get_source())
		return
	
	offer.pay()
	activate()


func _activate() -> void:
	if not offer.can_perform():
		Toasts.add_toast(offer.get_fail_message(), get_source())
		return
	
	offer.perform()


func _get_annotation_title() -> String:
	return tr("stranger.nomad").to_upper()


func _get_annotation_subtext() -> String:
	return offer.get_description()


func _can_afford() -> bool:
	return offer.can_afford()
