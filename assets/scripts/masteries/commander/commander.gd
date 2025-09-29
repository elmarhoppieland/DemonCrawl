@tool
extends Mastery
class_name Commander

# ==============================================================================
const RECRUIT_COIN_COST := 3
const INSTANT_FAMILIAR := preload("res://assets/items/instant_familiar.tres")
# ==============================================================================

func _enable() -> void:
	get_quest().get_action_manager().register(_get_actions)
	(get_quest().get_event_bus(Familiar.FamiliarEffects) as Familiar.FamiliarEffects).loot_collected.connect(_familiar_collected_loot)


func _disable() -> void:
	get_quest().get_action_manager().unregister(_get_actions)
	(get_quest().get_event_bus(Familiar.FamiliarEffects) as Familiar.FamiliarEffects).loot_collected.disconnect(_familiar_collected_loot)


func _get_actions(object: Object) -> Array[Callable]:
	if level < 1:
		return []
	if object is not CellData:
		return []
	
	if not object.is_flagged():
		return []
	
	return [recruit_familiar.bind(object)]


func _familiar_collected_loot(familiar: Familiar, loot: Loot) -> void:
	match loot.get_script():
		Coin:
			get_quest().get_current_stage().solve_cell()
		Diamond:
			for i in 5:
				get_quest().get_current_stage().solve_cell()
		Heart:
			familiar.strong = true
		#Token:
			#loot.get_cell().spawn(Familiar)
		#Artifact:
			#get_quest().get_current_stage().get_stage().max_power -= 1
		#Emblem:
			#get_inventory().mana_gain(100, self)


func _can_use_ability() -> bool:
	return get_quest().has_current_stage()


func _ability() -> void:
	for cell in get_quest().get_current_stage().get_cells():
		var familiar := cell.get_object() as Familiar
		if not familiar:
			continue
		
		familiar.clear()
		get_inventory().item_gain(INSTANT_FAMILIAR.create())


func recruit_familiar(cell: CellData) -> void:
	if get_stats().coins < RECRUIT_COIN_COST:
		return
	get_stats().spend_coins(RECRUIT_COIN_COST, self)
	cell.spawn(Familiar)
