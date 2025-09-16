@tool
@abstract
extends AnnotatedTextureNode
class_name Collectible

## An abstract object that can be collected by the player.

# ==============================================================================
var _use_success := true
# ==============================================================================
signal predelete()
# ==============================================================================

## Creates a new [StatusEffect] for this [Collectible].
func create_status(status_script: Script = null) -> StatusEffect.Initializer:
	return StatusEffect.create(status_script).set_source(self).set_quest(get_quest())

#region internals

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		predelete.emit()

#endregion

#region getters

## Returns this collectible's background [Color].
func get_texture_bg_color() -> Color:
	return _get_texture_bg_color()


## Virtual method to override this texture's background color. Will default to a
## transparent background if not overridden.
func _get_texture_bg_color() -> Color:
	return Color.TRANSPARENT

#endregion

func _ready() -> void:
	if is_active():
		var base := get_parent()
		while base != null:
			if not base.is_node_ready():
				await base.ready
			base = base.get_parent()
		
		_enable()


func _exit_tree() -> void:
	if is_active():
		_disable()


func enable() -> void:
	_enable()


func _enable() -> void:
	pass


func disable() -> void:
	_disable()


func _disable() -> void:
	pass


## Uses this [Collectible], if possible. First calls [method _use], and then [method _post].
func use() -> void:
	if can_use():
		_use_success = true
		@warning_ignore("redundant_await")
		await _use()
		if _use_success:
			post()


## Virtual method to add an effect for when the [Collectible] is used. Note that, by default,
## nothing prevents the player from using the collectible again afterwards. To prevent this,
## add a cost in [method _post].
## [br][br][b]Note:[/b] If using the [Collectible] requires player input, [method _invoke]
## should also be overridden to allow non-player game effects to invoke the [Collectible].
## If using the [Collectible] does not require player input, this is not needed and
## [method _use] is called when the [Collectible] is invoked.
func _use() -> void:
	pass


## Cancels the [method _use] action. This effectively lets the engine know that
## the use action was unsuccessful and that [method post] should not be called.
## [br][br][b]Note:[/b] when called outside of a [Callable]'s [method _use] function,
## this has no effect.
func cancel_use() -> void:
	_use_success = false


## Returns whether the current use action has been cancelled using [method cancel_use].
func is_use_cancelled() -> bool:
	return not _use_success


## Posts this [Collectible]. This usally means performing its cost, like losing it.
func post() -> void:
	_post()


## Virtual method. Called after this [Collectible] is used. Should perform the [Collectible]'s
## cost, e.g. losing it. Not called if the [Collectible] is invoked.
func _post() -> void:
	pass


## Invokes the [Collectible], if possible. This means that the [Collectible] will be used
## without player input, often by randomly selecting a player's choice, e.g. picking
## the targeted [Cell] randomly.
func invoke() -> void:
	_invoke()


## Virtual method. Usually called when the [Collectible] is used by a game effect
## that is not the player. Should use the [Collectible] without requiring player
## input. If the [Collectible] requires a target [Cell], should target it on a
## random [Cell].
func _invoke() -> void:
	_use()


## Returns whether this collectible can be used. If this returns [code]true[/code],
## and the collectible is interacted with, [method _use] will be called.
func can_use() -> bool:
	return is_active() and _can_use()


## Virtual method to override the return value of [method can_use].
func _can_use() -> bool:
	return false


## Returns whether this [Collectible] is active, i.e. it can be interacted with
## in its current state.
func is_active() -> bool:
	return _is_active()


## Virtual method to override the return value of [method is_active].
func _is_active() -> bool:
	return false


## Returns whether this [Collectible] is currently blinking.
func is_blinking() -> bool:
	return _is_blinking()


## Virtual method to override the return value of [method is_blinking].
func _is_blinking() -> bool:
	return false


## Returns whether this [Collectible] has a progress bar.
func has_progress_bar() -> bool:
	return _has_progress_bar()


## Virtual method to override the return value of [method has_progress_bar].
func _has_progress_bar() -> bool:
	return false


## Returns this [Collectible]'s progress bar's progress value. [method has_progress_bar]
## must return true for this to be called, and [method get_max_progress] should return
## a non-zero value.
func get_progress() -> int:
	return _get_progress()


## Virtual method to override the return value of [method get_progress].
func _get_progress() -> int:
	return 0

## Returns this [Collectible]'s progress bar's maximum progress value. [method has_progress_bar]
## must return true for this to be called.
func get_max_progress() -> int:
	return _get_max_progress()


func _get_max_progress() -> int:
	return 0


func get_quest() -> Quest:
	var base := get_parent()
	while base != null and base is not Quest:
		base = base.get_parent()
	return base
