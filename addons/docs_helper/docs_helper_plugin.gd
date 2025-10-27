@tool
extends EditorPlugin


func _enter_tree() -> void:
	await get_tree().process_frame
	
	var queue: Array[String] = ["res://"]
	
	while not queue.is_empty():
		var base := queue.pop_back() as String
		
		for file in DirAccess.get_files_at(base):
			var path := base.path_join(file)
			if path == (get_script() as Script).resource_path:
				continue
			if file.get_extension() == "gd" and ResourceLoader.exists(path, "Script"):
				ResourceSaver.save.call_deferred(load(path))
		
		for dir in DirAccess.get_directories_at(base):
			queue.append(base.path_join(dir))
