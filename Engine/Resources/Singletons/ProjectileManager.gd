@tool
extends Node
class_name ProjectileManager

# ==============================================================================
@export var speed := 96.0
# ==============================================================================

func _init() -> void:
	name = "ProjectileManager"


func register_projectile(projectile: Projectile) -> void:
	if projectile in get_projectiles():
		Debug.log_error("Attempted to register an already-registered projectile.")
		return
	
	add_child(projectile)


func clear_projectile(projectile: Projectile) -> void:
	projectile.queue_free()


func get_projectiles() -> Array[Projectile]:
	var projectiles: Array[Projectile] = []
	projectiles.assign(get_children())
	return projectiles
