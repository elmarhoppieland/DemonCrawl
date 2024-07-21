extends CellObject
class_name CellNomad

# ==============================================================================
var offer: Offer
# ==============================================================================

func spawn() -> void:
	generate_offer()


func get_texture() -> TextureSequence:
	var texture := TextureSequence.new()
	texture.texture_size = Board.CELL_SIZE
	texture.atlas = preload("res://Assets/sprites/nomad.png")
	return texture


func get_animation_delta() -> float:
	return 0.5


func get_tooltip_text() -> String:
	return str(offer)


func interact() -> void:
	super()
	if Stats.coins < offer.price:
		return
	offer.apply()


func generate_offer() -> void:
	var options: Array[Script] = [
		ItemTradeOffer,
		ItemBuyOffer,
		ManaSellOffer,
		ChestSellOffer,
		DollSellOffer,
		ConsumableSellOffer,
		MagicSellOffer,
		LegendarySellOffer,
		WeaponSellOffer,
		AppleSellOffer
	]
	options = EffectManager.propagate_value("get_nomad_offer_options", options, [self])
	
	offer = options[RNG.randi() % options.size()].new(self)
	
	offer.generate()


class Offer:
	var _nomad: CellNomad
	
	func _init(nomad: CellNomad) -> void:
		_nomad = nomad
	
	func generate() -> void:
		pass
	
	func apply() -> void:
		pass
	
	func _to_string() -> String:
		return TooltipText.new("STRANGER_NOMAD").to_upper().add_line("STRANGER_NOMAD_NULL").as_subtext().to_string()


class SellOffer extends Offer:
	var price := 0
	
	func apply() -> void:
		Stats.spend_coins(price, _nomad)
		price += 1
	
	func _to_string() -> String:
		return TooltipText.new("STRANGER_NOMAD").to_upper().add_line("\"" + tr("STRANGER_NOMAD_SELL") + "\"").set_translate(false).as_subtext().add_line("STRANGER_NOMAD_SELL_PRICE").as_subtext().to_string()


class TradeOffer extends Offer:
	func _to_string() -> String:
		return TooltipText.new("STRANGER_NOMAD").to_upper().add_line("\"" + tr("STRANGER_NOMAD_TRADE") + "\"").set_translate(false).as_subtext().to_string()


class BuyOffer extends Offer:
	var price := 0
	
	func apply() -> void:
		Stats.coins += price
		price -= 1
	
	func _to_string() -> String:
		return TooltipText.new("STRANGER_NOMAD").to_upper().add_line("\"" + tr("STRANGER_NOMAD_BUY") + "\"").set_translate(false).as_subtext().to_string()


class ItemTradeOffer extends TradeOffer:
	var give_item: ItemData
	var take_item: ItemData
	
	func generate() -> void:
		give_item = ItemDB.create_filter().disallow_type(Item.Type.OMEN).set_min_cost(1).get_random_item_data()
		take_item = Inventory.items[RNG.randi() % Inventory.items.size()].data
	
	func apply() -> void:
		for item in Inventory.items:
			if item.data == take_item:
				Inventory.remove_item(item)
				Inventory.gain_item(give_item.create())
				return
	
	func _to_string() -> String:
		return super().format({
			"offer": tr(give_item.name),
			"price": tr(take_item.name)
		})


class ItemBuyOffer extends BuyOffer:
	var item: ItemData
	
	func generate() -> void:
		item = Inventory.items[RNG.randi() % Inventory.items.size()].data
		price = int(RNG.randf_range(0.7, 1) * item.cost)
	
	func apply() -> void:
		for inventory_item in Inventory.items:
			if inventory_item.data == item:
				Inventory.remove_item(inventory_item)
				super()
				return
	
	func _to_string() -> String:
		return super().format({
			"offer": tr(item.name),
			"price": price
		})


class ManaSellOffer extends SellOffer:
	var mana := 0
	
	func generate() -> void:
		# TODO: research ranges
		mana = RNG.randi_range(1, 100)
		price = int(RNG.randf_range(0.7, 1.3) * mana)
	
	func apply() -> void:
		Inventory.gain_mana(mana)
		super()
	
	func _to_string() -> String:
		return super().format({
			"offer": str(mana) + " " + tr("MANA"),
			"price": price
		})


class ChestSellOffer extends SellOffer:
	func generate() -> void:
		price = RNG.randi_range(7, 13) # TODO: research price range
	
	func apply() -> void:
		_nomad.cell.spawn_nearby(CellChest)
		super()
	
	func _to_string() -> String:
		return super().format({
			"offer": tr("STRANGER_NOMAD_SELL_TREASURE_CHESTS"),
			"price": price
		})


class DollSellOffer extends SellOffer:
	func generate() -> void:
		price = RNG.randi_range(20, 40) # TODO: research price range
	
	func apply() -> void:
		# TODO: gain a doll item
		Debug.log_warning("Doll nomads are not yet implemented since Dolls are not implemented.")
		super()
	
	func _to_string() -> String:
		return super().format({
			"offer": tr("STRANGER_NOMAD_SELL_DOLLS"),
			"price": price
		})


class ConsumableSellOffer extends SellOffer:
	var item: ItemData
	
	func generate() -> void:
		item = ItemDB.create_filter().disallow_all_types().allow_type(Item.Type.CONSUMABLE).get_random_item_data()
		price = int(RNG.randf_range(0.7, 1.3) * item.cost) # TODO: research price range
	
	func apply() -> void:
		Inventory.gain_item(item.create())
		super()
	
	func _to_string() -> String:
		return super().format({
			"offer": tr(item.name),
			"price": price
		})


class MagicSellOffer extends SellOffer:
	func generate() -> void:
		price = RNG.randi_range(10, 30) # TODO: research price range
	
	func apply() -> void:
		Inventory.gain_item(ItemDB.create_filter().disallow_all_types().allow_type(Item.Type.MAGIC).get_random_item())
		super()
	
	func _to_string() -> String:
		return super().format({
			"offer": tr("STRANGER_NOMAD_SELL_MAGIC_ITEMS"),
			"price": price
		})


class LegendarySellOffer extends SellOffer:
	func generate() -> void:
		price = RNG.randi_range(25, 50) # TODO: research price range
	
	func apply() -> void:
		Inventory.gain_item(ItemDB.create_filter().disallow_all_types().allow_type(Item.Type.LEGENDARY).get_random_item())
		super()
	
	func _to_string() -> String:
		return super().format({
			"offer": tr("STRANGER_NOMAD_SELL_LEGENDARY_ITEMS"),
			"price": price
		})


class KeySellOffer extends SellOffer:
	func generate() -> void:
		price = RNG.randi_range(7, 15) # TODO: research price range
	
	func apply() -> void:
		Inventory.gain_item(ItemDB.create_filter().filter_category("key").get_random_item())
		super()
	
	func _to_string() -> String:
		return super().format({
			"offer": tr("STRANGER_NOMAD_SELL_KEYS"),
			"price": price
		})


class WeaponSellOffer extends SellOffer:
	func generate() -> void:
		price = RNG.randi_range(10, 20) # TODO: research price range
	
	func apply() -> void:
		Inventory.gain_item(ItemDB.create_filter().filter_category("weapon").get_random_item())
		super()
	
	func _to_string() -> String:
		return super().format({
			"offer": tr("STRANGER_NOMAD_SELL_WEAPONS"),
			"price": price
		})


class AppleSellOffer extends SellOffer:
	const APPLE := preload("res://Assets/items/Apple.tres")
	
	var amount := 0
	
	func generate() -> void:
		# TODO: research ranges
		amount = RNG.randi_range(1, 5)
		price = RNG.randi_range(3, 8) * amount
	
	func apply() -> void:
		for i in amount:
			Inventory.gain_item(APPLE.create())
		
		super()
	
	func _to_string() -> String:
		return super().format({
			"offer": tr("STRANGER_NOMAD_SELL_WEAPONS").format({
				"amount": amount
			}),
			"price": price
		})
