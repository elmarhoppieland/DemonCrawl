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

func _enable() -> void:
	get_quest().get_item_effects().used.connect(_item_activated)


func _disable() -> void:
	get_quest().get_item_effects().used.disconnect(_item_activated)


func _item_activated(item: Item) -> void:
	if item is Book:
		activated_book_effects += 1
