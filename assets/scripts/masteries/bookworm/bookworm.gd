@tool
extends Mastery
class_name Bookworm

# ==============================================================================
const RESEARCH_SUBJECTS: Dictionary[ItemData, String] = {
	preload("res://assets/items/book_of_combat.tres"): "kill",
	preload("res://assets/items/book_of_defense.tres"): "defense",
	preload("res://assets/items/book_of_espionage.tres"): "glean",
	preload("res://assets/items/book_of_faith.tres"): "omen",
	preload("res://assets/items/book_of_gold.tres"): "coin",
	preload("res://assets/items/book_of_love.tres"): "life",
	preload("res://assets/items/book_of_maps.tres"): "pathfinding",
	preload("res://assets/items/book_of_mastery.tres"): "book",
	preload("res://assets/items/book_of_maths.tres"): "number",
	preload("res://assets/items/book_of_necromancy.tres"): "bone",
	preload("res://assets/items/book_of_rage.tres"): "powerchord",
	preload("res://assets/items/book_of_spells.tres"): "magic",
	preload("res://assets/items/book_of_truth.tres"): "solve",
}
# ==============================================================================

func _enable() -> void:
	get_quest().get_stage_effects().entered.connect(_stage_enter)
	get_quest().get_action_manager().register(_get_actions)
	get_quest().get_object_effects().used.connect(_object_use)


func _disable() -> void:
	get_quest().get_stage_effects().entered.disconnect(_stage_enter)
	get_quest().get_action_manager().unregister(_get_actions)
	get_quest().get_object_effects().used.disconnect(_object_use)


func _stage_enter() -> void:
	if level < 1:
		return
	
	if get_quest().get_current_stage().get_stage() is SpecialStage:
		get_inventory().item_gain(get_books().pick_random().create())


func _get_actions(object: Object) -> Array[Callable]:
	if object is not Book:
		return []
	return [_book_interact.bind(object)]


func _book_interact(book: Book) -> void:
	if book.data not in RESEARCH_SUBJECTS:
		return
	get_attributes().research_subject = RESEARCH_SUBJECTS[book.data]


func _object_use(object: CellObject) -> void:
	if level < 2:
		return
	
	if object is Heart:
		for item in get_inventory().get_items():
			if item is Book:
				item.activate()


func _ability() -> void:
	var item := get_quest().get_item_pool().create_filter().filter_custom(get_attributes().item_matches_research).get_random_item()
	get_inventory().item_gain(item.create())


func _get_max_charges() -> int:
	return 3


func get_books() -> Array[ItemData]:
	return get_quest().get_item_pool().create_filter().filter_tag("book").get_items()
