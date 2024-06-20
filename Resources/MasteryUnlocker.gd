extends RefCounted
class_name MasteryUnlocker

# ==============================================================================
static var unlockers: Array[MasteryUnlocker] = []
# ==============================================================================
var mastery := ""
# ==============================================================================

func unlock(level: int) -> void:
	var flag := mastery + "_condition_" + str(level)
	
	if PlayerFlags.has_flag(flag):
		return
	
	PlayerFlags.add_flag(flag)
	
	MasteryUnlockPopup.show_unlock(mastery, level)


static func register_effects() -> void:
	const DIR := "res://Assets/scripts/mastery_unlocks/"
	for file in DirAccess.get_files_at(DIR):
		var path := DIR.path_join(file)
		var script := ResourceLoader.load(path)
		if not script is Script:
			Debug.log_error("The file at '%s' was attempted to be loaded as a MasteryUnlocker script, but it is either not a Script or not loadable." % path)
			continue
		
		var unlocker = script.new()
		if not unlocker is MasteryUnlocker:
			Debug.log_error("The script file at '%s' does not extend 'MasteryUnlocker'. This is required for mastery unlockers." % path)
			continue
		
		EffectManager.register_object(unlocker)
		unlockers.append(unlocker)
	
	await EffectManager.await_call("quest_finish")
	
	for unlocker in unlockers:
		EffectManager.unregister_object(unlocker)
	
	unlockers.clear()
