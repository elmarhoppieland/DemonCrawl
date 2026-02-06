@tool
@abstract
class_name Codex

## Stores global player data.

# ==============================================================================
static var _heirlooms: Array[Heirloom] = Eternal.create([] as Array[Heirloom]) :
	set(value):
		_heirlooms = value
		for i in value.size():
			if value[i]:
				value[i].emptied.connect(clear_heirloom.bind(i))
				value[i].changed.connect(func() -> void: heirlooms_changed.emit())
		heirlooms_changed.emit()

## Emitted when the player's Heirlooms have changed.
static var heirlooms_changed := Signal() :
	get:
		if heirlooms_changed.is_null():
			(Codex as GDScript).add_user_signal("heirlooms_changed")
			heirlooms_changed = Signal(Codex, "heirlooms_changed")
		return heirlooms_changed

## The items that the player has Favored.
static var favored_items: Array[Favor] = Eternal.create([] as Array[Favor])

## The currently selected mastery.
static var selected_mastery: MasteryData = Eternal.create(null) :
	set(value):
		selected_mastery = value
		selected_mastery_changed.emit()
static var _selectable_masteries: Array[MasteryInstanceData] = Eternal.create([] as Array[MasteryInstanceData])
static var _unlocked_masteries: Array[MasteryInstanceData] = Eternal.create([] as Array[MasteryInstanceData])

## Emitted when the player selects a new mastery.
## [br][br][b]Note:[/b] This is [b]not[/b] emitted when a [Quest]'s mastery changes.
static var selected_mastery_changed := Signal() :
	get:
		if selected_mastery_changed.is_null():
			(Codex as GDScript).add_user_signal("_selected_mastery_changed")
			selected_mastery_changed = Signal(Codex, "_selected_mastery_changed")
		return selected_mastery_changed

## The number of tokens the player has.
static var tokens: int = Eternal.create(0) :
	set(new_token_count):
		tokens = new_token_count
		
		token_count_changed.emit()

static var token_count_changed := Signal() :
	get:
		if token_count_changed.is_null():
			(Codex as GDScript).add_user_signal("token_count_changed")
			token_count_changed = Signal(Codex, "token_count_changed")
		return token_count_changed

static var _artifacts: Dictionary[StageFile, int] = Eternal.create({} as Dictionary[StageFile, int])

static var _emblems: Dictionary[EmblemData, int] = Eternal.create({} as Dictionary[EmblemData, int])
## Emitted when the player's emblem inventory changes.
static var emblems_changed := Signal() :
	get:
		if emblems_changed.is_null():
			(Codex as GDScript).add_user_signal("_emblems_changed")
			emblems_changed = Signal(Codex, "_emblems_changed")
		return emblems_changed

static var _glints: Dictionary[GlintData, int] = Eternal.create({} as Dictionary[GlintData, int])
## Emitted when the player's glint inventory changes.
static var glints_changed := Signal() :
	get:
		if glints_changed.is_null():
			(Codex as GDScript).add_user_signal("_glints_changed")
			glints_changed = Signal(Codex, "_glints_changed")
		return glints_changed

## The player's current xp. Setting this property to a value greater than [method get_next_level_xp]
## will automatically level up the player.
static var xp: int = Eternal.create(0) :
	set(new_xp):
		xp = new_xp
		
		while xp > get_next_level_xp():
			xp -= get_next_level_xp()
			level += 1
		xp_changed.emit()

## The player's current level.
static var level: int = Eternal.create(1)

## Emitted when the player's amount of xp changes (i.e. when [member xp] changes).
static var xp_changed := Signal() :
	get:
		if xp_changed.is_null():
			(Codex as GDScript).add_user_signal("xp_changed")
			xp_changed = Signal(Codex, "xp_changed")
		return xp_changed

## The [Codex.CodexProfile]s the player has.
static var profiles: Array[CodexProfile] = Eternal.create([] as Array[CodexProfile])
# ==============================================================================

## Adds a new empty Heirloom slot.
static func add_heirloom_slot() -> void:
	_heirlooms.append(null)
	heirlooms_changed.emit()


## Returns the number of Heirloom slots the player has.
static func get_heirloom_slots() -> int:
	return _heirlooms.size()


## Sets the item of the Heirloom at the given [param index] to [param item].
## Sets the item count of the Heirloom to [param count].
static func set_heirloom(index: int, item: ItemData, count: int = 1) -> void:
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


## Removes the Heirloom at the given [param index]. This method allows for negative indices.
static func clear_heirloom(index: int) -> void:
	if _heirlooms[index] and _heirlooms[index].changed.is_connected(notify_heirlooms_changed):
		_heirlooms[index].changed.disconnect(notify_heirlooms_changed)
	
	_heirlooms[index] = null
	
	heirlooms_changed.emit()


## Uses the Heirloom at the given [param index] and returns its [Item] instance.
## Does nothing if the player does not have an Heirloom at the given [param index].
## This method allows for negative indices.
static func use_heirloom(index: int) -> Item:
	if not has_heirloom(index):
		return null
	
	var item := _heirlooms[index].use()
	return item


## Returns the [ItemData] of the Heirloom at the given [param index]. This method
## allows for negative indices.
static func get_heirloom(index: int) -> ItemData:
	if not has_heirloom(index):
		return null
	
	return _heirlooms[index].item


## Returns the [Codex.Heirloom] data at the given [param index]. This method
## allows for negative indices.
static func get_heirloom_data(index: int) -> Heirloom:
	if not has_heirloom(index):
		return null
	
	return _heirlooms[index]


## Returns the number of items the Heirloom at the given [param index] holds.
## This method allows for negative indices.
static func get_heirloom_count(index: int) -> int:
	if not has_heirloom(index):
		return 0
	
	return _heirlooms[index].count


## Returns whether the player has an Heirloom at the given [param index]. This
## method allows for negative indices.
static func has_heirloom(index: int) -> bool:
	if index >= _heirlooms.size() or index < -_heirlooms.size():
		return false
	if _heirlooms[index] == null:
		return false
	return true


## Notifies the [Codex] that the heirlooms changed.
static func notify_heirlooms_changed() -> void:
	heirlooms_changed.emit()


## Adds an empty [Codex.CodexProfile] slot.
static func add_profile_slot() -> void:
	profiles.append(CodexProfile.new())


## Returns the amount of xp the player has to gain to level up.
## [br][br][b]TODO:[/b] This method does not return 100% accurately yet.
static func get_next_level_xp() -> int:
	if level < 23:
		return (level + 13) * level / 2 + 93
	
	return (level + 80) * 5


## Returns the [MasteryInstanceData] representing the [param mastery] that the player
## may select. The mastery will be unlocked up to the level of the returned
## [MasteryInstanceData], and possibly higher. See also [method get_unlocked_mastery].
## [br][br][b]Note:[/b] The returned [MasteryInstanceData] will not have its
## [member MasteryInstanceData.charges] member set. Using it may result in unexpected
## behavior.
static func get_selectable_mastery(mastery: Variant) -> MasteryInstanceData:
	return _get_mastery_from_list(mastery, _selectable_masteries)


## Returns the level of the given [param mastery] the player may select. The mastery
## will be unlocked up to the returned level, and possibly higher. See also
## [method get_unlocked_mastery_level].
static func get_selectable_mastery_level(mastery: Variant) -> int:
	var selectable := get_selectable_mastery(mastery)
	if selectable:
		return selectable.level
	return 0


## Makes the given [param mastery] selectable at the given [param level]. If the
## mastery was not unlocked to this level, logs a warning and unlocks it at this level.
@warning_ignore("shadowed_variable")
static func add_selectable_mastery(mastery: MasteryData, level: int) -> void:
	if get_unlocked_mastery_level(mastery) < level:
		Debug.log_warning("Attempted to add selectable mastery '%s' at level %d, but this mastery was only unlocked at level %d. Unlocking the mastery..." % [TranslationServer.tr(mastery.name), level, get_unlocked_mastery_level(mastery)])
		unlock_mastery(mastery, level)
	
	var instance := get_selectable_mastery(mastery)
	if instance:
		if instance.level >= level:
			Debug.log_warning("Attempted to add selectable mastery '%s' at level %d, but it was already selectable at level %d." % [TranslationServer.tr(mastery.name), level, instance.level])
			return
		instance.level = level
	else:
		instance = mastery.instantiate(level)
		_selectable_masteries.append(instance)


## Returns the [MasteryInstanceData] representing the [param mastery] that the player
## has unlocked. The mastery may or may not be selectable up to the level of the
## returned [MasteryInstanceData]. See also [method get_selectable_mastery].
## [br][br][b]Note:[/b] The returned [MasteryInstanceData] will not have its
## [member MasteryInstanceData.charges] member set. Using it may result in unexpected
## behavior.
static func get_unlocked_mastery(mastery: Variant) -> MasteryInstanceData:
	return _get_mastery_from_list(mastery, _unlocked_masteries)


## Returns the level of the given [param mastery] the player has unlocked. The
## mastery may or may not be selectable up to the returned level. See also
## [method get_selectable_mastery_level].
static func get_unlocked_mastery_level(mastery: Variant) -> int:
	var unlocked := get_unlocked_mastery(mastery)
	if unlocked:
		return unlocked.level
	return 0


## Unlocks the given [param mastery] at the given [param level].
@warning_ignore("shadowed_variable")
static func unlock_mastery(mastery: MasteryData, level: int) -> void:
	var instance := get_unlocked_mastery(mastery)
	if instance:
		if instance.level >= level:
			Debug.log_warning("Attempted to unlock mastery '%s' at level %d, but it was already unlocked at level %d." % [TranslationServer.tr(mastery.name), level, instance.level])
			return
		instance.level = level
	else:
		instance = mastery.instantiate(level)
		_unlocked_masteries.append(instance)


static func _get_mastery_from_list(mastery: Variant, list: Array[MasteryInstanceData]) -> MasteryInstanceData:
	for i in list:
		if mastery is Script:
			if i.mastery_script == mastery:
				return i
		elif mastery is Mastery:
			if i.data.mastery_script.instance_has(mastery):
				return i
		elif mastery is MasteryData:
			if i.data == mastery:
				return i
		elif mastery is MasteryInstanceData:
			if i.data == mastery.data:
				return i
		else:
			Debug.log_error("Cannot find mastery in list: Invalid type '%s'." % Stringifier.get_type_string(mastery))
			return null
	
	return null


## Returns the number of _artifacts of the given [param stage] the player has.
static func get_artifacts(stage: StageFile) -> int:
	return _artifacts.get(stage, 0)


## Increases the number of _artifacts of the given [param stage] the player has by [param artifact_count].
static func gain_artifact(stage: StageFile, artifact_count: int = 1) -> void:
	_artifacts[stage] = get_artifacts(stage) + artifact_count


## Decreases the number of _artifacts of the given [param stage] the player has by [param artifact_count].
static func lose_artifact(stage: StageFile, artifact_count: int = 1) -> void:
	_artifacts[stage] = get_artifacts(stage) - artifact_count
	if get_artifacts(stage) <= 0:
		_artifacts.erase(stage)


## Returns the total number of _artifacts the player has, across all stages.
static func get_total_artifact_count() -> int:
	var total_count := 0
	for stage in _artifacts:
		total_count += _artifacts[stage]
	return total_count


## Returns the number of copies of the given [param emblem] the player has.
static func get_emblems(emblem: EmblemData) -> int:
	return _emblems.get(emblem, 0)


## Increases the number of copies of the given [param emblem] the player has by [param emblem_count].
static func gain_emblem(emblem: EmblemData, emblem_count: int = 1) -> void:
	_emblems[emblem] = get_emblems(emblem) + emblem_count
	emblems_changed.emit()


## Decreases the number of copies of the given [param emblem] the player has by [param emblem_count].
static func lose_emblem(emblem: EmblemData, emblem_count: int = 1) -> void:
	_emblems[emblem] = get_emblems(emblem) - emblem_count
	if get_emblems(emblem) <= 0:
		_emblems.erase(emblem)


## Returns the total number of _emblems the player has.
static func get_total_emblem_count() -> int:
	var total_count := 0
	for emblem in _emblems:
		total_count += _emblems[emblem]
	return total_count


## Returns the number of copies of the given [param emblem] the player has.
static func get_glints(glint: GlintData) -> int:
	return _glints.get(glint, 0)


## Increases the number of copies of the given [param emblem] the player has by [param emblem_count].
static func gain_glint(glint: GlintData, glint_count: int = 1) -> void:
	_glints[glint] = get_glints(glint) + glint_count
	glints_changed.emit()


## Decreases the number of copies of the given [param glint] the player has by [param glint_count].
static func lose_glint(glint: GlintData, glint_count: int = 1) -> void:
	_glints[glint] = get_glints(glint) - glint_count
	if get_glints(glint) <= 0:
		_glints.erase(glint)


## Returns the total number of _glints the player has.
static func get_total_glint_count() -> int:
	var total_count := 0
	for glint in _glints:
		total_count += _glints[glint]
	return total_count


## Stores information about an Heirloom.
class Heirloom extends Resource:
	## The item that exists in the Heirloom.
	@export var item: ItemData = null :
		set(value):
			if value and value.resource_path.is_empty():
				value = load(value.get_origin_path())
			item = value
			emit_changed()
	## The number of items that exist in the Heirloom.
	@export var count := 1 :
		set(value):
			count = value
			if value <= 0:
				emptied.emit()
			emit_changed()
	# ==========================================================================
	signal emptied() ## Emitted when the number of items in the Heirloom reaches zero or when it is manually emptied in the Codex.
	# ==========================================================================
	
	@warning_ignore("shadowed_variable")
	func _init(item: ItemData = null, count: int = 1) -> void:
		self.item = item
		self.count = count
	
	## Uses this Heirloom and returns an instance of this Heirloom's [member item].
	func use() -> Item:
		if count <= 0:
			Debug.log_error("Attempted to use an empty heirloom (of item '%s')." % item.resource_path)
			return item.create()
		
		count -= 1
		return item.create()


## Stores information about a Favored item.
class Favor extends Resource:
	## The item that is Favored or Unfavored.
	@export var item: ItemData = null :
		set(value):
			if value and value.resource_path.is_empty():
				value = load(value.get_origin_path())
			item = value
			emit_changed()
	## If [code]true[/code], the [member item] will appear less often than usual.
	## If [code]false[/code], the [member item] will appear more often than usual.
	@export var inverted := false


## Stores information about a Profile in the Codex.
class CodexProfile extends Resource:
	## The items that are Favored or Unfavored in the Profile.
	@export var favored_items: Array[Favor] = []
