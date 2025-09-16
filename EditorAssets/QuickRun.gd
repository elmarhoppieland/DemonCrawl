@tool
extends EditorScript


func _run() -> void:
	var errors := get_tree().root.find_child("Errors*", true, false)
	var errors_tree := errors.get_child(1) as Tree
	var tab_container := errors.get_parent() as TabContainer
	
	var removed_item_count := 0
	var removed_all := true
	for item in errors_tree.get_root().get_children():
		if item.get_text(1).match("*Parameter \"SceneTree::get_singleton()\" is null.*"):
			errors_tree.get_root().remove_child(item)
			removed_item_count += 1
		else:
			removed_all = false
	
	var debugger: Button = null
	var queue: Array[Node] = [get_tree().root]
	while not queue.is_empty():
		var node := queue.pop_back() as Node
		if node is Button and node.text.match("Debugger*"):
			debugger = node
		
		queue.append_array(node.get_children())
	
	if removed_all:
		errors.name = "Errors"
		tab_container.set_tab_icon(errors.get_index(), null)
		debugger.text = "Debugger"
		debugger.icon = null
		debugger.add_theme_color_override("font_color", tab_container.get_theme_color("font_selected_color"))
	else:
		errors.name = "Errors (%d)" % (errors.name.to_int() - removed_item_count)
		debugger.text = "Debugger (%d)" % (debugger.text.to_int() - removed_item_count)


func call_on_root() -> void:
	var root := get_tree().edited_scene_root
	var function := "_run_" + UserClassDB.script_get_class(root.get_script()).to_snake_case().to_lower()
	if has_method(function):
		call(function, root)


class T extends Object:
	func function(callable: Callable) -> void:
		print(self)
		print(is_instance_valid(self))
		callable.call()
		print(self)
		print(is_instance_valid(self))


static func get_tree() -> SceneTree:
	return Engine.get_main_loop()


static func reload_item_translations() -> void:
	var items: Dictionary[String, String] = {}
	
	var client := HTTPClient.new()
	client.connect_to_host("https://demoncrawl.com")
	while true:
		await get_tree().create_timer(0.1).timeout
		
		var err := client.poll()
		var status := client.get_status()
		print(status)
		if status == HTTPClient.STATUS_CONNECTED:
			break
		
		if status != HTTPClient.STATUS_CONNECTING:
			print("Failed to connect to host.")
			print("Status: ", status)
			print("Error code: ", error_string(err))
			client.close()
			return
		
		print(status)
	
	print("Connected to host!")
	
	const PAGES: PackedStringArray = [
		"/wiki/index.php/Consumable_Items",
		"/wiki/index.php/Passive_Items",
		"/wiki/index.php/Magic_Items",
		"/wiki/index.php/Omen_Items",
		"/wiki/index.php/Legendary_Items",
	]
	
	for url in PAGES:
		print("Requesting page \"%s\"" % url)
		client.request(HTTPClient.METHOD_GET, url, [])
		
		while true:
			await get_tree().create_timer(0.1).timeout
			
			var err := client.poll()
			var status := client.get_status()
			print(status)
			if status == HTTPClient.STATUS_BODY:
				break
			
			if status != HTTPClient.STATUS_REQUESTING:
				print("Request failed.")
				print("Status: ", status)
				print("Error code: ", error_string(err))
				client.close()
				return
			
			print(status)
		
		print("Request succeeded.")
		
		var response_code := client.get_response_code()
		print("Response code: ", response_code)
		
		var headers := client.get_response_headers()
		print("Headers: ", headers)
		
		var body_length := client.get_response_body_length()
		print("Body length: ", body_length)
		
		var is_chunked := client.is_response_chunked()
		print("Is chunked: ", is_chunked)
		
		var body := PackedByteArray()
		while client.get_status() == HTTPClient.Status.STATUS_BODY:
			client.poll()
			
			var chunk := client.read_response_body_chunk()
			if chunk.is_empty():
				await get_tree().create_timer(0.1).timeout
			else:
				body.append_array(chunk)
		
		print("Body size: ", body.size())
		
		var text := body.get_string_from_utf8()
		var start := text.find("</th></tr>") + 2
		var end := text.find("</tbody></table>") - 1
		text = text.substr(start, end - start)
		
		text = text\
			.replace("&quot;", "\"")
		
		var i := 0
		while true:
			i = text.find(">", text.find("title=", i)) + 1
			var item_name := text.substr(i, text.find("<", i) - i)
			print("Found item: ", item_name)
			i = text.find("<td>", i) + 4
			var description := text.substr(i, text.find("</td>", i) - i).strip_edges()
			if description.match("[* Mana] *"):
				description = description.substr(description.find("]") + 1).strip_edges()
			print("Description: ", description)
			
			items[item_name] = description
			
			i = text.find("<tr>", i)
			
			if i < 0:
				break
	
	client.close()
	
	var file := FileAccess.open("res://Assets/Localization/localization-items.csv", FileAccess.WRITE)
	file.store_line("key;en\n")
	
	var item_list: Array[String] = []
	item_list.assign(items.keys())
	item_list.sort_custom(func(a: String, b: String) -> bool:
		if a.begins_with("Divine "):
			a = a.trim_prefix("Divine ")
		if b.begins_with("Divine "):
			b = b.trim_prefix("Divine ")
		return a < b
	)
	
	for item in item_list:
		if item.begins_with("Divine "):
			file.store_line("item.%s.divine;%s" % [item.trim_prefix("Divine ").to_snake_case().replace("_", "-"), item])
			file.store_line("item.%s.divine.description;%s" % [item.trim_prefix("Divine ").to_snake_case().replace("_", "-"), items[item]])
		else:
			file.store_line("item.%s;%s" % [item.to_snake_case().replace("_", "-"), item])
			file.store_line("item.%s.description;%s" % [item.to_snake_case().replace("_", "-"), items[item]])
	
	print("Client closed.")


static func reload_stage_translations() -> void:
	var stages: Dictionary[String, String] = {}
	var stage_signs: Dictionary[String, String] = {}
	
	var client := HTTPClient.new()
	client.connect_to_host("https://demoncrawl.com")
	while true:
		await get_tree().create_timer(0.1).timeout
		
		var err := client.poll()
		var status := client.get_status()
		print(status)
		if status == HTTPClient.STATUS_CONNECTED:
			break
		
		if status != HTTPClient.STATUS_CONNECTING and status != HTTPClient.STATUS_RESOLVING:
			print("Failed to connect to host.")
			print("Status: ", status)
			print("Error code: ", error_string(err))
			client.close()
			return
		
		print(status)
	
	print("Connected to host!")
	
	var url := "/wiki/index.php/Stage_Descriptions"
	print("Requesting page \"%s\"" % url)
	client.request(HTTPClient.METHOD_GET, url, [])
	
	while true:
		await get_tree().create_timer(0.1).timeout
		
		var err := client.poll()
		var status := client.get_status()
		print(status)
		if status == HTTPClient.STATUS_BODY:
			break
		
		if status != HTTPClient.STATUS_REQUESTING:
			print("Request failed.")
			print("Status: ", status)
			print("Error code: ", error_string(err))
			client.close()
			return
		
		print(status)
	
	print("Request succeeded.")
	
	var response_code := client.get_response_code()
	print("Response code: ", response_code)
	
	var headers := client.get_response_headers()
	print("Headers: ", headers)
	
	var body_length := client.get_response_body_length()
	print("Body length: ", body_length)
	
	var is_chunked := client.is_response_chunked()
	print("Is chunked: ", is_chunked)
	
	var body := PackedByteArray()
	while client.get_status() == HTTPClient.Status.STATUS_BODY:
		client.poll()
		
		var chunk := client.read_response_body_chunk()
		if chunk.is_empty():
			await get_tree().create_timer(0.1).timeout
		else:
			body.append_array(chunk)
	
	print("Body size: ", body.size())
	
	var text := body.get_string_from_utf8()
	
	text = text\
		.replace("&quot;", "\"")\
		.replace("&lt;", "<")
	
	var _file := FileAccess.open("user://temp.txt", FileAccess.WRITE)
	_file.store_string(text)
	_file.close()
	
	var i := text.find("<tr>")
	var c := 0
	while c < 128:
		c += 1
		
		i = text.find("<td>", i) + 4
		var stage_name := text.substr(i, text.find("\n", i) - i)
		i = text.find("<td>", i) + 4
		var description := text.substr(i, text.find("\n", i) - i)
		var next_td = text.find("<td>", i)
		var next_tr := text.find("<tr>", i)
		var stage_sign: String
		if next_tr <= next_td:
			stage_sign = description
			description = ""
		else:
			i = next_td + 4
			stage_sign = text.substr(i, text.find("\n", i) - i)
		
		stage_name = stage_name.replace(",", "")
		if ";" in description:
			description = "\"" + description + "\""
		if ";" in stage_sign:
			stage_sign = "\"" + stage_sign + "\""
		
		print("Found stage: ", stage_name)
		print("Description: ", description)
		print("Sign text: ", stage_sign)
		
		stages[stage_name] = description
		stage_signs[stage_name] = stage_sign
		
		i = next_tr
		
		if i < 0:
			break
	
	client.close()
	
	var file := FileAccess.open("res://Assets/Localization/localization-stages.csv", FileAccess.WRITE)
	file.store_line("key;en\n")
	
	var stage_list: Array[String] = []
	stage_list.assign(stages.keys())
	stage_list.sort_custom(func(a: String, b: String) -> bool:
		if a.begins_with("Divine "):
			a = a.trim_prefix("Divine ")
		if b.begins_with("Divine "):
			b = b.trim_prefix("Divine ")
		return a < b
	)
	
	for stage in stage_list:
		file.store_line("stage.%s;%s" % [stage.to_snake_case().replace("_", "-"), stage])
		if not stages[stage].is_empty():
			file.store_line("stage.%s.description;%s" % [stage.to_snake_case().replace("_", "-"), stages[stage]])
		file.store_line("stage.%s.sign;%s" % [stage.to_snake_case().replace("_", "-"), stage_signs[stage]])
	
	print("Client closed.")


static func reload_mastery_translations() -> void:
	var masteries: Dictionary[String, PackedStringArray] = {}
	var mastery_unlocks: Dictionary[String, PackedStringArray] = {}
	
	var client := HTTPClient.new()
	client.connect_to_host("https://demoncrawl.com")
	while true:
		await get_tree().create_timer(0.1).timeout
		
		var err := client.poll()
		var status := client.get_status()
		print(status)
		if status == HTTPClient.STATUS_CONNECTED:
			break
		
		if status != HTTPClient.STATUS_CONNECTING and status != HTTPClient.STATUS_RESOLVING:
			print("Failed to connect to host.")
			print("Status: ", status)
			print("Error code: ", error_string(err))
			client.close()
			return
		
		print(status)
	
	print("Connected to host!")
	
	var text := await get_url_text(client, "/wiki/index.php/Masteries")
	
	text = text\
		.replace("&quot;", "\"")\
		.replace("&lt;", "<")
	
	var start := text.find("<tbody>") + 7
	var end := text.find("</tbody>")
	
	text = text.substr(start, end - start)
	
	var _file := FileAccess.open("user://temp.txt", FileAccess.WRITE)
	_file.store_string(text)
	_file.close()
	
	var i := text.find("<tr>")
	while i >= 0:
		i = text.find("<td class=\"field__pageName\">", i)
		i = text.find(">", i)
		i = text.find("href=\"", i) + 6
		var mastery_url := text.substr(i, text.find("\"", i) - i)
		i = text.find(">", i) + 1
		var name := text.substr(i, text.find("</a>", i) - i).trim_suffix(" Mastery")
		masteries[name] = PackedStringArray()
		mastery_unlocks[name] = PackedStringArray()
		print("Found mastery: ", name)
		
		for field in ["field_Tier_I", "field_Tier_II", "field_Tier_III"]:
			var field_start_text := "<td class=\"%s\">" % field
			i = text.find(field_start_text, i) + field_start_text.length()
			var description := text.substr(i, text.find("</td>", i) - i)
			if description.match("[* Charge*] *"):
				description = description.substr(description.find("] ") + 2)
			description = remove_tags(description)
			masteries[name].append(description)
			
			print("Description: ", description)
		
		var mastery_page_text := await get_url_text(client, mastery_url)
	
		var infobox_start := mastery_page_text.find("<tbody>") + 7
		var infobox_end := mastery_page_text.find("</tbody>")
		
		mastery_page_text = mastery_page_text.substr(infobox_start, infobox_end - infobox_start)
		
		var j := mastery_page_text.find("<th>Unlock I</th>")
		
		for s in 3:
			j = mastery_page_text.find("<td>", j) + 4
			var unlock_text := mastery_page_text.substr(j, mastery_page_text.find("</td>", j) - j)
			unlock_text = remove_tags(unlock_text)
			mastery_unlocks[name].append(unlock_text)
			print("Unlock: ", unlock_text)
		
		i = text.find("<tr>", i)
	
	var added_translations: Dictionary[String, PackedStringArray] = {}
	
	var read_file := FileAccess.open("res://Assets/Localization/localization-masteries.csv", FileAccess.READ)
	read_file.get_line() # skip first line
	while not read_file.eof_reached():
		var line := read_file.get_line()
		if line.is_empty():
			continue
		
		if not line.match("mastery.*.*;*"):
			if line == "mastery.novice.ability.fail;You must make a guess to proceed.":
				OS.alert("Nononono")
			continue
		
		var mastery_id := line.get_slice(".", 1)
		if mastery_id not in added_translations:
			added_translations[mastery_id] = PackedStringArray()
		added_translations[mastery_id].append(line)
	
	var file := FileAccess.open("res://Assets/Localization/localization-masteries.csv", FileAccess.WRITE)
	file.store_line("key;en\n")
	
	var mastery_list: Array[String] = []
	mastery_list.assign(masteries.keys())
	mastery_list.sort()
	
	for mastery in mastery_list:
		var processed_keys := PackedStringArray()
		var mastery_id := mastery.to_snake_case().replace("_", "-")
		processed_keys.append("mastery.%s" % mastery_id)
		file.store_line("mastery.%s;%s" % [mastery_id, mastery])
		for j in masteries[mastery].size():
			processed_keys.append("mastery.%s.description.%d" % [mastery_id, j + 1])
			file.store_line("mastery.%s.description.%d;%s" % [mastery_id, j + 1, masteries[mastery][j]])
		for j in mastery_unlocks[mastery].size():
			processed_keys.append("mastery.%s.unlock.%d" % [mastery_id, j + 1])
			file.store_line("mastery.%s.unlock.%d;%s" % [mastery_id, j + 1, mastery_unlocks[mastery][j]])
		
		if mastery_id in added_translations:
			for added_translation in added_translations[mastery_id]:
				if added_translation.get_slice(";", 0) in processed_keys:
					continue
				print("Reused added translation with key '%s'" % added_translation.get_slice(";", 0))
				file.store_line(added_translation)
		
		file.store_line("")


static func get_url_text(client: HTTPClient, url: String) -> String:
	print("Requesting page \"%s\"" % url)
	client.request(HTTPClient.METHOD_GET, url, [])
	
	while true:
		await get_tree().create_timer(0.1).timeout
		
		var err := client.poll()
		var status := client.get_status()
		print(status)
		if status == HTTPClient.STATUS_BODY:
			break
		
		if status != HTTPClient.STATUS_REQUESTING:
			print("Request failed.")
			print("Status: ", status)
			print("Error code: ", error_string(err))
			client.close()
			return ""
		
		print(status)
	
	print("Request succeeded.")
	
	var response_code := client.get_response_code()
	print("Response code: ", response_code)
	
	var headers := client.get_response_headers()
	print("Headers: ", headers)
	
	var body_length := client.get_response_body_length()
	print("Body length: ", body_length)
	
	var is_chunked := client.is_response_chunked()
	print("Is chunked: ", is_chunked)
	
	var body := PackedByteArray()
	while client.get_status() == HTTPClient.Status.STATUS_BODY:
		client.poll()
		
		var chunk := client.read_response_body_chunk()
		if chunk.is_empty():
			await get_tree().create_timer(0.1).timeout
		else:
			body.append_array(chunk)
	
	print("Body size: ", body.size())
	
	var text := body.get_string_from_utf8()
	return text\
		.replace("&quot;", "\"")\
		.replace("&lt;", "<")\
		.replace("&#160;", "") # this is technically a no-break space but we ignore it


static func remove_tags(text: String) -> String:
	while text.match("*<*>*"):
		var begin := text.substr(0, text.find("<"))
		var end := text.substr(text.find(">") + 1)
		text = begin + end
	return text
