@tool
extends Mastery
class_name Bookworm

# ==============================================================================
const RESEARCH_SUBJECTS: Dictionary[ItemData, String] = {
	preload("res://Assets/Items/Book of Combat.tres"): "kill",
	preload("res://Assets/Items/Book of Defense.tres"): "defense",
	preload("res://Assets/Items/Book of Espionage.tres"): "glean",
	preload("res://Assets/Items/Book of Faith.tres"): "omen",
	preload("res://Assets/Items/Book of Gold.tres"): "coin",
	preload("res://Assets/Items/Book of Love.tres"): "life",
	preload("res://Assets/Items/Book of Maps.tres"): "pathfinding",
	preload("res://Assets/Items/Book of Mastery.tres"): "book",
	preload("res://Assets/Items/Book of Maths.tres"): "number",
	preload("res://Assets/Items/Book of Necromancy.tres"): "bone",
	preload("res://Assets/Items/Book of Rage.tres"): "powerchord",
	preload("res://Assets/Items/Book of Spells.tres"): "magic",
	preload("res://Assets/Items/Book of Truth.tres"): "solve",
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
