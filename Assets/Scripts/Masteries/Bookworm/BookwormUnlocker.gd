extends MasteryUnlocker

# ==============================================================================
@export var activated_book_effects := 0 :
	set(value):
		activated_book_effects = value
		if value >= 10:
			unlock(1)
		if value >= 30:
			unlock(2)
		if value >= 100:
			unlock(3)
# ==============================================================================

func _enter_tree() -> void:
	get_quest().get_stage_effects().item_activated.connect(_item_activated)


func _exit_tree() -> void:
	get_quest().get_stage_effects().item_activated.disconnect(_item_activated)


func _item_activated(item: Item) -> void:
	if item is Book:
		activated_book_effects += 1
