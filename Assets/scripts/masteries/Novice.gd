extends Mastery

# ==============================================================================

func change_score(value: int) -> int:
	if level < 1:
		return value
	
	if value <= PlayerStats.score:
		return value
	
	# simplified version of: PlayerStats.score + (value - PlayerStats.score) / 2
	return (PlayerStats.score + value) / 2


func damage(amount: int, source: Object) -> int:
	if level < 1:
		return amount
	if amount < 1:
		return 0
	if not source is CellMonster:
		return amount
	
	if Board.needs_guess():
		Toasts.add_toast(tr("NOVICE_UNLUCKY_GUESS"), AssetManager.get_icon("mastery0/novice"))
		return 1
	
	return amount


func death(_source: Object) -> void:
	if level < 2:
		return
	
	if PlayerStats.score >= 300:
		PlayerStats.score = 0
		Stats.revive()


func ability() -> void:
	StageCamera.focus_progress()
