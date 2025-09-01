@tool
extends EditorScript


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


func _run() -> void:
	call_on_root()


func call_on_root() -> void:
	var root := get_tree().edited_scene_root
	var function := "_run_" + UserClassDB.script_get_class(root.get_script()).to_snake_case().to_lower()
	if has_method(function):
		call(function, root)


static func get_tree() -> SceneTree:
	return Engine.get_main_loop()
