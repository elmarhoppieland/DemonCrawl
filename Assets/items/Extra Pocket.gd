@tool
extends Item

# ==============================================================================

# the 'you may find duplicate items' effect is hardcoded
# see the ItemDB.ItemFilter._ignore_items_in_inventory getter

func stage_enter() -> void:
	var highest_count := 0
	var count := 0
	var item_match: Item = null
	for i in Quest.get_current().get_instance().get_item_count():
		var item := Quest.get_current().get_instance().get_item(i)
		if item == item_match:
			count += 1
		else:
			item_match = item
			count = 1
		
		if count > highest_count:
			highest_count = count
	
	Quest.get_current().get_selected_stage().min_power -= highest_count
