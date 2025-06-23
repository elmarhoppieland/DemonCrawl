@tool
extends StaticClass
class_name Codex

# ==============================================================================
static var _heirlooms: Array[Heirloom] = Eternal.create([] as Array[Heirloom]) :
	set(value):
		_heirlooms = value
		for i in value.size():
			if value[i]:
				value[i].emptied.connect(clear_heirloom.bind(i))
				value[i].changed.connect(func() -> void: heirlooms_changed.emit())
		heirlooms_changed.emit()

static var heirlooms_changed := Signal() :
	get:
		if heirlooms_changed.is_null():
			(Codex as GDScript).add_user_signal("heirlooms_changed")
			heirlooms_changed = Signal(Codex, "heirlooms_changed")
		return heirlooms_changed

static var favored_items: Array[Favor] = Eternal.create([] as Array[Favor])

static var selected_mastery: Mastery = Eternal.create(null) :
	set(value):
		selected_mastery = value
		selected_mastery_changed.emit()
	get:
		if selected_mastery and selected_mastery.level != get_selectable_mastery_level(selected_mastery):
			selected_mastery.level = get_selectable_mastery_level(selected_mastery)
		return selected_mastery
static var selectable_masteries: Array[Mastery] = Eternal.create([] as Array[Mastery])
static var unlocked_masteries: Array[Mastery] = Eternal.create([] as Array[Mastery])

static var selected_mastery_changed := Signal() :
	get:
		if selected_mastery_changed.is_null():
			(Codex as GDScript).add_user_signal("selected_mastery_changed")
			selected_mastery_changed = Signal(Codex, "selected_mastery_changed")
		return selected_mastery_changed

static var tokens: int = Eternal.create(0)

static var profiles: Array[CodexProfile] = Eternal.create([] as Array[CodexProfile])
# ==============================================================================

static func add_heirloom_slot() -> void:
	_heirlooms.append(null)
	heirlooms_changed.emit()


static func get_heirloom_slots() -> int:
	return _heirlooms.size()


static func set_heirloom(index: int, item: Item, count: int = 1) -> void:
	if index >= _heirlooms.size():
		Debug.log_error("Attempted to set an heirloom to '%s' at locked or nonexistent slot #%d." % [item, index])
		return
	if index < -_heirlooms.size():
		Debug.log_error("Attempted to set an heirloom to '%s' at locked or nonexistent slot #%d." % [item, index + _heirlooms.size()])
		return
	
	if not item:
		clear_heirloom(index)
		return
	
	if _heirlooms[index] and _heirlooms[index].changed.is_connected(notify_heirlooms_changed):
		_heirlooms[index].changed.disconnect(notify_heirlooms_changed)
	
	var heirloom := Heirloom.new(item, count)
	heirloom.emptied.connect(func() -> void:
		if Codex._heirlooms[index] == heirloom:
			clear_heirloom(index)
	, CONNECT_ONE_SHOT)
	heirloom.changed.connect(notify_heirlooms_changed)
	
	_heirlooms[index] = heirloom
	
	heirlooms_changed.emit()


static func clear_heirloom(index: int) -> void:
	if _heirlooms[index] and _heirlooms[index].changed.is_connected(notify_heirlooms_changed):
		_heirlooms[index].changed.disconnect(notify_heirlooms_changed)
	
	_heirlooms[index] = null
	
	heirlooms_changed.emit()


static func use_heirloom(index: int) -> Item:
	if not has_heirloom(index):
		return null
	
	var item := _heirlooms[index].use()
	return item


static func get_heirloom(index: int) -> Item:
	if not has_heirloom(index):
		return null
	
	return _heirlooms[index].item


static func get_heirloom_data(index: int) -> Heirloom:
	if not has_heirloom(index):
		return null
	
	return _heirlooms[index]


static func get_heirloom_count(index: int) -> int:
	if not has_heirloom(index):
		return 0
	
	return _heirlooms[index].count


static func has_heirloom(index: int) -> bool:
	if index >= _heirlooms.size() or index < -_heirlooms.size():
		return false
	if _heirlooms[index] == null:
		return false
	return true


static func notify_heirlooms_changed() -> void:
	heirlooms_changed.emit()


static func add_profile_slot() -> void:
	profiles.append(CodexProfile.new())


static func get_selectable_mastery(mastery: Variant) -> Mastery:
	return _get_mastery_from_list(mastery, selectable_masteries)


static func get_selectable_mastery_level(mastery: Variant) -> int:
	var selectable := get_selectable_mastery(mastery)
	if selectable:
		return selectable.level
	return 0


static func get_unlocked_mastery(mastery: Variant) -> Mastery:
	return _get_mastery_from_list(mastery, unlocked_masteries)


static func get_unlocked_mastery_level(mastery: Variant) -> int:
	var unlocked := get_unlocked_mastery(mastery)
	if unlocked:
		return unlocked.level
	return 0


static func _get_mastery_from_list(mastery: Variant, list: Array) -> Mastery:
	assert(mastery is Mastery or mastery is String or mastery is StringName or mastery is Script, "The parameter must be a Mastery, a Mastery id, or a Mastery Script, but '%s' was found." % type_string(typeof(mastery)))
	
	for i in list:
		if mastery is String or mastery is StringName:
			if mastery in [i._get_identifier(), UserClassDB.class_get_name(i.get_script())]:
				return i
		elif mastery is Script:
			if i.get_script() == mastery:
				return i
		elif mastery is Mastery:
			if i.get_script() == mastery.get_script():
				return i
	
	return null


class Heirloom extends Resource:
	# ==========================================================================
	@export var item: Item = null :
		set(value):
			if value and value.resource_path.is_empty():
				value = load(value.get_origin_path())
			item = value
			emit_changed()
	@export var count := 1 :
		set(value):
			count = value
			if value <= 0:
				emptied.emit()
			emit_changed()
	# ==========================================================================
	signal emptied()
	# ==========================================================================
	
	@warning_ignore("shadowed_variable")
	func _init(item: Item = null, count: int = 1) -> void:
		self.item = item
		self.count = count
	
	func use() -> Item:
		if count <= 0:
			Debug.log_error("Attempted to use an empty heirloom (of item '%s')." % item.resource_path)
			return item
		
		count -= 1
		return item


class Favor extends Resource:
	@export var item: Item = null :
		set(value):
			if value and value.resource_path.is_empty():
				value = load(value.get_origin_path())
			item = value
			emit_changed()
	@export var inverted := false


class CodexProfile extends Resource:
	@export var favored_items: Array[Favor] = []
