@abstract
class_name DemonCrawl

# ==============================================================================
static var _initialized := false
# ==============================================================================

static func _static_init() -> void:
	if _initialized:
		return
	
	await Promise.defer()
	if OS.is_debug_build():
		(Engine.get_main_loop() as SceneTree).node_added.connect(func(node: Node) -> void:
			if "@" not in node.name:
				return
			var script := node.get_script() as Script
			if not script:
				return
			var c := UserClassDB.script_get_class(script)
			if c.is_empty():
				return
			if "::" in c:
				c = c.substr(c.rfind("::") + 2)
			node.name = c
		)
	
	_initialized = true


static func get_full_registry() -> Registry:
	return load("res://assets/registry.tres")
