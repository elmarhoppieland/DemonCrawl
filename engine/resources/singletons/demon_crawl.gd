@tool
@abstract
class_name DemonCrawl

# ==============================================================================
static var _initialized := false

static var _full_registry: Registry : get = get_full_registry
# ==============================================================================

static func _static_init() -> void:
	if _initialized:
		return
	
	_initialized = true
	
	await Promise.defer()
	if OS.is_debug_build():
		get_tree().node_added.connect(func(node: Node) -> void:
			if "@" not in node.name:
				return
			var script := node.get_script() as Script
			if not script:
				return
			
			var base := script
			var cls := &""
			while cls.is_empty():
				if base == null:
					return
				
				cls = UserClassDB.script_get_class(base)
				base = base.get_base_script()
			
			if "::" in cls:
				cls = cls.substr(cls.rfind("::") + 2)
			node.name = cls
		)
	
	get_tree().root.close_requested.connect(Eternity.save)


static func get_full_registry() -> Registry:
	if not _full_registry:
		_full_registry = load("res://assets/registry.tres")
	return _full_registry


static func get_tree() -> SceneTree:
	return Engine.get_main_loop()
