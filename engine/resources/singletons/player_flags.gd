extends Object
class_name PlayerFlags

# ==============================================================================
static var flags: PackedStringArray = Eternal.create(PackedStringArray())
# ==============================================================================

static func has_flag(flag: String) -> bool:
	return flag in flags


static func add_flag(flag: String) -> void:
	if not has_flag(flag):
		flags.append(flag)


static func remove_flag(flag: String) -> void:
	if has_flag(flag):
		flags.remove_at(flags.find(flag))
