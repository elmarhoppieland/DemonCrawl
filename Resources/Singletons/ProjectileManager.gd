@tool
extends Resource
class_name ProjectileManager

# ==============================================================================
@export var speed := 96.0

@export var _projectiles: Array[Projectile] = [] : get = get_projectiles
# ==============================================================================

func register_projectile(projectile: Projectile) -> void:
	if projectile in get_projectiles():
		Debug.log_error("Attempted to register an already-registered projectile.")
		return
	
	_projectiles.append(projectile)


func clear_projectile(projectile: Projectile) -> void:
	_projectiles.erase(projectile)


func get_projectiles() -> Array[Projectile]:
	return _projectiles
