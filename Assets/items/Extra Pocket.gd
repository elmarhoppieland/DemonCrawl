extends Item

# ==============================================================================

# the 'you may find duplicate items' effect is hardcoded
# see the ItemDB.ItemFilter._ignore_items_in_inventory getter

func stage_enter() -> void:
	var highest_count := 0
	var count := 0
	var item_data: ItemData
	for item in Inventory.items:
		if item.data == item_data:
			count += 1
		else:
			item_data = item.data
			count = 1
		
		if count > highest_count:
			highest_count = count
	
	StagesOverview.selected_stage.min_power -= highest_count
