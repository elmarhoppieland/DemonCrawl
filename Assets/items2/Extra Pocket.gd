@tool
extends Item

# ==============================================================================

# the 'you may find duplicate items' effect is hardcoded
# see the ItemDB.ItemFilter._ignore_items_in_inventory getter

func stage_enter() -> void:
	var highest_count := 0
	var count := 0
	var item_match: Item = null
	for i in get_quest().get_inventory().get_item_count():
		var item := get_quest().get_inventory().get_item(i)
		if item == item_match:
			count += 1
		else:
			item_match = item
			count = 1
		
		if count > highest_count:
			highest_count = count
	
	get_quest().get_selected_stage().min_power -= highest_count
