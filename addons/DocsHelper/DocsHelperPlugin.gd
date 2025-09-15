@tool
extends EditorPlugin


func _enter_tree() -> void:
	await get_tree().process_frame
	
	var queue := PackedStringArray(["res://"])
	
	while not queue.is_empty():
		var base := queue[-1]
		queue.resize(queue.size() - 1)
		
		for file in DirAccess.get_files_at(base):
			var path := base.path_join(file)
			if file.get_extension() == "gd" and ResourceLoader.exists(path, "Script"):
				ResourceSaver.save.call_deferred(load(path))
		
		for dir in DirAccess.get_directories_at(base):
			queue.append(base.path_join(dir))
