extends Object
class_name RNG

## Generates pseudo-random numbers.

# ==============================================================================

func _init() -> void:
	assert(false, "Instantiating RNG is not allowed.")


## Calls [method @GlobalScope.randf] on [code]rng[/code] if possible, or on [@GlobalScope] if not.
static func getf(rng: RandomNumberGenerator = null) -> float:
	if rng:
		return rng.randf()
	return randf()


## Calls [method @GlobalScope.randf_range] on [code]rng[/code] if possible, or on [@GlobalScope] if not.
static func getf_range(from: float, to: float, rng: RandomNumberGenerator = null) -> float:
	if rng:
		return rng.randf_range(from, to)
	return randf_range(from, to)


## Calls [method @GlobalScope.randfn] on [code]rng[/code] if possible, or on [@GlobalScope] if not.
static func getfn(mean: float = 0.0, deviation: float = 1.0, rng: RandomNumberGenerator = null) -> float:
	if rng:
		return rng.randfn(mean, deviation)
	return randfn(mean, deviation)


## Calls [method @GlobalScope.randi] on [code]rng[/code] if possible, or on [@GlobalScope] if not.
static func geti(rng: RandomNumberGenerator = null) -> int:
	if rng:
		return rng.randi()
	return randi()


## Calls [method @GlobalScope.randi_range] on [code]rng[/code] if possible, or on [@GlobalScope] if not.
static func geti_range(from: int, to: int, rng: RandomNumberGenerator = null) -> int:
	if rng:
		return rng.randi_range(from, to)
	return randi_range(from, to)
