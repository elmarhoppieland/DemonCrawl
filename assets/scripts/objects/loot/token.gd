@tool
extends Loot
class_name Token

# ==============================================================================
const GLOW_MATERIAL := preload("res://assets/scripts/objects/loot/magic_glow.tres")
const ANIM_DURATION := 0.8
# ==============================================================================

func _get_texture() -> AnimatedTextureSequence:
	var texture = AnimatedTextureSequence.new()
	texture.atlas = preload("res://assets/sprites/token.png")
	texture.duration = ANIM_DURATION
	return texture


func _get_material() -> Material:
	return GLOW_MATERIAL


func _reveal() -> void:
	Toasts.add_toast(tr("object.token.spawned"), get_texture(), "gold")


func _collect() -> bool:
	Codex.tokens += 1
	
	tween_texture_to(GuiLayer.get_statbar().position + Vector2(0.0, 16.0))
	
	Toasts.add_toast(str(Codex.tokens), get_texture(), "gold")
	
	return true


func _get_charitable_amount() -> int:
	return 5


func _is_charitable() -> bool:
	return true


func _can_interact() -> bool:
	return true
