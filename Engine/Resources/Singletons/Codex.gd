@tool
extends StaticClass
class_name Codex

# ==============================================================================
static var _heirlooms: Array[Heirloom] = Eternal.create([Heirloom.new("res://Assets/items/Apple.tres"), null] as Array[Heirloom]) :
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

static var selected_mastery: Mastery = Eternal.create(null)
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
	
	var heirloom := Heirloom.new(item.get_origin_path(), count)
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
	
	return load(_heirlooms[index].item_path)


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


class Heirloom extends Resource:
	# ==========================================================================
	@export var item_path := "" :
		set(value):
			item_path = value
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
	func _init(item_path: String = "", count: int = 1) -> void:
		self.item_path = item_path
		self.count = count
	
	func use() -> Item:
		if count <= 0:
			Debug.log_error("Attempted to use an empty heirloom (of item '%s')." % item_path)
			return load(item_path)
		
		count -= 1
		return load(item_path)
