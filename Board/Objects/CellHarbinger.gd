extends CellObject
class_name CellHarbinger

# ==============================================================================
var effect: Effect
var cost := 0
# ==============================================================================

func spawn() -> void:
	cost = RNG.randi_range(5, 50)
	
	var options: Array[Script] = [
		MaxLifeEffect,
		CankerEffect,
		MonsterEffect,
		PassiveItemEffect,
		ConsumableItemEffect,
		MagicItemEffect,
		OmenItemEffect,
		SealEffect
	]
	options = EffectManager.propagate_value("get_harbinger_effect_options", options, [self])
	
	effect = options[RNG.randi() % options.size()].new()
	effect.generate()


func interact() -> void:
	if Stats.coins < cost:
		return
	
	Stats.spend_coins(cost, self)
	
	clear()


func get_texture() -> TextureSequence:
	var texture := TextureSequence.new()
	texture.texture_size = Board.CELL_SIZE
	texture.atlas = preload("res://Assets/sprites/harbinger.png")
	return texture


func get_animation_delta() -> float:
	return 0.52


func get_tooltip_text() -> String:
	return tr("STRANGER_HARBINGER").to_upper()


func get_tooltip_subtext() -> String:
	return "\"" + str(effect) + "\"\n" + tr("STRANGER_HARBINGER_BRIBE_COST").format({
		"cost": cost
	})


class Effect:
	func generate() -> void:
		pass
	
	func apply() -> void:
		pass
	
	func _to_string() -> String:
		if get_script() == Effect:
			return tr("STRANGER_HARBINGER_NULL")
		
		return tr("STRANGER_HARBINGER_" + UserClassDB.get_class_from_script(get_script(), true).trim_suffix("Effect").to_snake_case().to_upper()).format(
			get_property_list()\
				.filter(func(prop: Dictionary) -> bool:
					return prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE\
				)\
				.map(func(prop: Dictionary) -> Dictionary:
					return {prop.name: get(prop.name)}\
				)\
				.reduce(func(dict: Dictionary, this: Dictionary) -> Dictionary:
					dict.merge(this)
					return dict\
				)
		)


class MaxLifeEffect extends Effect:
	var lives := 0
	
	func generate() -> void:
		lives = RNG.randi_range(4, 10)
	
	func apply() -> void:
		Stats.max_life -= lives
	
	#func _to_string() -> String:
		#return super().format({
			#"lives": lives
		#})


class CankerEffect extends Effect:
	var cankers := 0
	
	func generate() -> void:
		cankers = RNG.randi_range(6, 15)
	
	func apply() -> void:
		pass # TODO: spawn {cankers} cankers (needs orb functionality)
	
	func _to_string() -> String:
		return super().format({
			"cankers": cankers
		})


class MonsterEffect extends Effect:
	var monsters := 0
	
	func generate() -> void:
		monsters = RNG.randi_range(10, 25)
	
	func apply() -> void:
		for stage in Quest.stages:
			if stage is SpecialStage:
				continue
			if stage == StagesOverview.selected_stage:
				continue
			
			stage.monsters += monsters
	
	func _to_string() -> String:
		return super().format({
			"monsters": monsters
		})


class PassiveItemEffect extends Effect:
	var items := 0
	
	func generate() -> void:
		items = RNG.randi_range(3, 12)
	
	func apply() -> void:
		var options := Inventory.items.filter(func(item: Item): return item.type == Item.Type.PASSIVE)
		for i in items:
			var index := RNG.randi() % options.size()
			Inventory.remove_item(options[index])
			options.remove_at(index)
	
	func _to_string() -> String:
		return super().format({
			"items": items
		})


class ConsumableItemEffect extends Effect:
	var items := 0
	
	func generate() -> void:
		items = RNG.randi_range(3, 12)
	
	func apply() -> void:
		var options := Inventory.items.filter(func(item: Item): return item.type == Item.Type.CONSUMABLE)
		for i in items:
			var index := RNG.randi() % options.size()
			Inventory.remove_item(options[index])
			options.remove_at(index)
	
	func _to_string() -> String:
		return super().format({
			"items": items
		})


class MagicItemEffect extends Effect:
	var items := 0
	
	func generate() -> void:
		items = RNG.randi_range(3, 12)
	
	func apply() -> void:
		var options := Inventory.items.filter(func(item: Item): return item.type == Item.Type.MAGIC)
		for i in items:
			var index := RNG.randi() % options.size()
			Inventory.remove_item(options[index])
			options.remove_at(index)
	
	func _to_string() -> String:
		return super().format({
			"items": items
		})


class OmenItemEffect extends Effect:
	var omen: ItemData
	
	func generate() -> void:
		omen = ItemDB.create_filter().disallow_all_types().allow_type(Item.Type.OMEN).get_random_item_data()
	
	func apply() -> void:
		Inventory.gain_item(omen.create())
	
	func _to_string() -> String:
		return super().format({
			"omen": omen.name
		})


class SealEffect extends Effect:
	var seal_count := 0
	
	func generate() -> void:
		seal_count = RNG.randi_range(2, 5)
	
	func apply() -> void:
		pass # TODO: seal inventory slots (not implemented)
	
	func _to_string() -> String:
		return super().format({
			"seal_count": seal_count
		})
