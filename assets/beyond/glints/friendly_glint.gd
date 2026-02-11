extends Glint

# ==============================================================================
const STRANGER_TABLE := preload("res://assets/loot_tables/stranger.tres")
# ==============================================================================

func _quest_start() -> void:
	const ITER_MAX := 256
	
	for s in 5:
		var stranger: CellObjectBase = null
		var i := 0
		while i < ITER_MAX and (stranger == null or not stranger.can_spawn_in_quest(get_quest())):
			stranger = STRANGER_TABLE.generate()
			i += 1
		
		assert(stranger != null, "Could not find a valid Stranger to spawn.")
		
		var bubble := Bubble.new(stranger.create())
		get_quest().get_orb_manager().register_orb(bubble)
