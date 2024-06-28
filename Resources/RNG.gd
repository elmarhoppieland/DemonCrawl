extends StaticClass
class_name RNG

## Generates pseudo-random numbers.

# ==============================================================================
static var global_rng: RandomNumberGenerator
# ==============================================================================

## Calls [method @GlobalScope.randf] on [code]rng[/code] if possible, or on [@GlobalScope] if not.
static func randf(rng: RandomNumberGenerator = null) -> float:
	if rng:
		return rng.randf()
	if global_rng:
		return global_rng.randf()
	return randf()


## Calls [method @GlobalScope.randf_range] on [code]rng[/code] if possible, or on [@GlobalScope] if not.
static func randf_range(from: float, to: float, rng: RandomNumberGenerator = null) -> float:
	if rng:
		return rng.randf_range(from, to)
	if global_rng:
		return global_rng.randf_range(from, to)
	return randf_range(from, to)


## Calls [method @GlobalScope.randfn] on [code]rng[/code] if possible, or on [@GlobalScope] if not.
static func randfn(mean: float = 0.0, deviation: float = 1.0, rng: RandomNumberGenerator = null) -> float:
	if rng:
		return rng.randfn(mean, deviation)
	if global_rng:
		return global_rng.randfn(mean, deviation)
	return randfn(mean, deviation)


## Calls [method @GlobalScope.randi] on [code]rng[/code] if possible, or on [@GlobalScope] if not.
static func randi(rng: RandomNumberGenerator = null) -> int:
	if rng:
		return rng.randi()
	if global_rng:
		return global_rng.randi()
	return randi()


## Calls [method @GlobalScope.randi_range] on [code]rng[/code] if possible, or on [@GlobalScope] if not.
static func randi_range(from: int, to: int, rng: RandomNumberGenerator = null) -> int:
	if rng:
		return rng.randi_range(from, to)
	if global_rng:
		return global_rng.randi_range(from, to)
	return randi_range(from, to)
