extends Node

# ==============================================================================
var _save_queued := false
# ==============================================================================

func _ready() -> void:
	queue_save()
	
	if not OS.is_debug_build():
		Eternity._defaults_cfg.load(Eternity.DEFAULTS_FILE_PATH)


func queue_save() -> void:
	if _save_queued:
		return
	
	_save_queued = true
	
	(func():
		Eternity._defaults_cfg.save(Eternity.DEFAULTS_FILE_PATH)
		self._save_queued = false
	).call_deferred()
