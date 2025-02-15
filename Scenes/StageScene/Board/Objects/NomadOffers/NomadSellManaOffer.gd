extends NomadSellOffer
class_name NomadSellManaOffer

# ==============================================================================
@export var mana := -1
# ==============================================================================

func _spawn() -> void:
	mana = absi(roundi(randfn(0, 50))) + 1
	cost = roundi(randf_range(0.8, 1.2) * sqrt(mana))


func _perform() -> void:
	super()
	
	Quest.get_current().get_inventory().mana_gain(mana, self) # TODO: maybe have the source be the Nomad?
