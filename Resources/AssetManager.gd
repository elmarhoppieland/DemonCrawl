extends StaticClass
class_name AssetManager

# ==============================================================================
const ICONS := {
	"monster5": Rect2(0, 0, 5, 5),
	"power5": Rect2(5, 0, 5, 5),
	"size5": Rect2(10, 0, 5, 5),
	"token_small": Rect2(20, 0, 6, 6),
	"statbar_coin": Rect2(59, 0, 8, 7),
	"statbar_heart": Rect2(67, 0, 8, 7),
	"statbar_shield": Rect2(75, 0, 8, 7),
	"checkmark": Rect2(59, 7, 8, 9),
	"scroll_grabber": Rect2(67, 7, 8, 8),
	"scroll_grabber_highlight": Rect2(75, 7, 8, 8),
	"time8": Rect2(0, 7, 8, 9),
	"monster8": Rect2(8, 7, 8, 9),
	"power8": Rect2(16, 7, 8, 9),
	"inbox": Rect2(24, 7, 12, 9),
	"customize": Rect2(36, 4, 10, 12),
	"achievements": Rect2(46, 6, 13, 10),
	"inventory": Rect2(0, 16, 16, 16),
	"inventory_hover": Rect2(16, 16, 16, 16),
	"dictionary": Rect2(32, 16, 16, 16),
	"none": Rect2(48, 16, 16, 16),
	"change": Rect2(64, 16, 16, 16),
	"button_arrow": Rect2(80, 16, 16, 16),
	"button_masteries": Rect2(96, 16, 16, 16),
	"button_chests": Rect2(112, 16, 16, 16),
	"button_sigils": Rect2(128, 16, 16, 16),
	"twitter": Rect2(0, 32, 12, 12),
	"patreon": Rect2(12, 32, 12, 12),
	"discord": Rect2(24, 32, 12, 12),
	"settings": Rect2(0, 44, 13, 14),
	"patch_notes": Rect2(13, 44, 9, 12),
	"button_back": Rect2(22, 44, 12, 8),
	"button_back_hover": Rect2(34, 44, 12, 8),
	"button_quests": Rect2(0, 58, 12, 12),
	"button_classic": Rect2(12, 58, 10, 12),
	"button_arena": Rect2(22, 58, 12, 12),
	"button_token_shop": Rect2(34, 59, 12, 11),
	"button_codex": Rect2(46, 58, 12, 12),
	"button_quit": Rect2(58, 59, 11, 11),
	"icon_blank": Rect2(0, 70, 16, 16),
	"icon_locked": Rect2(16, 70, 16, 16),
	"icon_questionmark": Rect2(32, 70, 16, 16),
	"icon_quest1": Rect2(48, 70, 16, 16),
	"icon_quest2": Rect2(64, 70, 16, 16),
	"icon_quest3": Rect2(80, 70, 16, 16),
	"icon_quest4": Rect2(0, 86, 16, 16),
	"icon_quest5": Rect2(16, 86, 16, 16),
	"icon_quest_em": Rect2(32, 86, 16, 16),
	"icon_quest_ht": Rect2(48, 86, 16, 16),
	"icon_locked_flat": Rect2(64, 86, 16, 16),
	"category_upgrades": Rect2(0, 102, 16, 16),
	"category_masteries": Rect2(16, 102, 16, 16),
	"category_items": Rect2(32, 102, 16, 16),
	"category_avatars": Rect2(48, 102, 16, 16),
	"category_inventories": Rect2(64, 102, 16, 16),
	"category_holographs": Rect2(80, 102, 16, 16),
	"stage_reward_victory": Rect2(0, 118, 16, 16),
	"stage_reward_flagless": Rect2(16, 118, 16, 16),
	"stage_reward_untouchable": Rect2(32, 118, 16, 16),
	"stage_reward_fast": Rect2(48, 118, 16, 16),
	"stage_reward_thrifty": Rect2(64, 118, 16, 16),
	"stage_reward_charitable": Rect2(80, 118, 16, 16),
	"stage_reward_heartless": Rect2(96, 118, 16, 16),
	"stage_reward_quest_complete": Rect2(112, 118, 16, 16),
	"stage_reward_boost": Rect2(128, 118, 16, 16),
	"stage_reward_achievement": Rect2(144, 118, 16, 16),
	"token_shop_upgrade_token": Rect2(0, 134, 16, 16),
	"token_shop_upgrade_heart": Rect2(16, 134, 16, 16),
	"token_shop_upgrade_artifact": Rect2(32, 134, 16, 16),
	"token_shop_upgrade_tools": Rect2(48, 134, 16, 16),
	"token_shop_upgrade_xpboost": Rect2(64, 134, 16, 16),
	"token_shop_upgrade_quest": Rect2(80, 134, 16, 16),
	"token_shop_hover_plus": Rect2(0, 150, 16, 16),
	"difficulty_casual": Rect2(0, 166, 16, 16),
	"difficulty_normal": Rect2(16, 166, 16, 16),
	"difficulty_hard": Rect2(32, 166, 16, 16),
	"difficulty_beyond": Rect2(48, 166, 16, 16),
}
const MASTERIES := {
	"auramancer": Rect2(0, 0, 16, 16),
	"banker": Rect2(16, 0, 16, 16),
	"barbarian": Rect2(32, 0, 16, 16),
	"bookworm": Rect2(48, 0, 16, 16),
	"bubbler": Rect2(64, 0, 16, 16),
	"commander": Rect2(80, 0, 16, 16),
	"demolitionist": Rect2(0, 16, 16, 16),
	"detective": Rect2(16, 16, 16, 16),
	"exorcist": Rect2(32, 16, 16, 16),
	"firefly": Rect2(48, 16, 16, 16),
	"ghost": Rect2(64, 16, 16, 16),
	"guardian": Rect2(80, 16, 16, 16),
	"human": Rect2(0, 32, 16, 16),
	"hunter": Rect2(16, 32, 16, 16),
	"hypnotist": Rect2(32, 32, 16, 16),
	"immortal": Rect2(48, 32, 16, 16),
	"knight": Rect2(64, 32, 16, 16),
	"lumberjack": Rect2(80, 32, 16, 16),
	"marksman": Rect2(0, 48, 16, 16),
	"mutant": Rect2(16, 48, 16, 16),
	"ninja": Rect2(32, 48, 16, 16),
	"novice": Rect2(48, 48, 16, 16),
	"poisoner": Rect2(64, 48, 16, 16),
	"prophet": Rect2(80, 48, 16, 16),
	"protagonist": Rect2(0, 64, 16, 16),
	"scholar": Rect2(16, 64, 16, 16),
	"scout": Rect2(32, 64, 16, 16),
	"snowflake": Rect2(48, 64, 16, 16),
	"spark": Rect2(64, 64, 16, 16),
	"spy": Rect2(80, 64, 16, 16),
	"survivor": Rect2(0, 80, 16, 16),
	"undertaker": Rect2(16, 80, 16, 16),
	"warlock": Rect2(32, 80, 16, 16),
	"witch": Rect2(48, 80, 16, 16),
	"wizard": Rect2(64, 80, 16, 16),
	"none": Rect2(80, 80, 16, 16),
}
# ==============================================================================
static var theme := ""

static var _skin_assets_worker_thread_ids := {}

static var _preloaded_icons := {}
# ==============================================================================

## Creates a new [AtlasTexture] that contains the icon with the given [code]name[/code]. Uses one from the cache if available, or adds one to the cache if not.
static func get_icon(name: String) -> Icon:
	if not name in _preloaded_icons:
		_preloaded_icons[name] = Icon.new()
		_preloaded_icons[name].name = name
	
	return _preloaded_icons[name]


## Returns whether an icon with the given [code]name[/code] exists.
static func has_icon(name: String) -> bool:
	return Icon.has_icon(name)


## Returns the region of the icon with the given [code]name[/code].
static func get_icon_region(name: String) -> Rect2:
	return ICONS[name]


## Returns whether an icon with the given [code]name[/code] exists.
static func icon_exists(name: String) -> bool:
	return name in ICONS


static func has_skin_asset(file: String) -> bool:
	return FileAccess.file_exists(get_skin_dir().path_join(file))


static func get_skin_asset(file: String) -> Resource:
	if get_skin_dir().path_join(file) in _skin_assets_worker_thread_ids:
		WorkerThreadPool.wait_for_task_completion(_skin_assets_worker_thread_ids[get_skin_dir().path_join(file)])
	
	if file == "monster.png" and not has_skin_asset("monster.png"):
		return generate_monster_atlas_from_gif()
	
	if not has_skin_asset(file):
		push_error("Skin asset '%s' does not exist on theme '%s'." % [file, theme])
		return null
	
	if ResourceLoader.load_threaded_get_status(get_skin_dir().path_join(file)) in [ResourceLoader.THREAD_LOAD_LOADED, ResourceLoader.THREAD_LOAD_IN_PROGRESS]:
		return ResourceLoader.load_threaded_get(get_skin_dir().path_join(file))
	
	return ResourceLoader.load(get_skin_dir().path_join(file))


static func load_theme(theme_resource: Theme) -> Theme:
	theme_resource.set_icon("board_bg", "Board", get_skin_asset("bg.png"))
	
	theme_resource.set_icon("background", "Cell", get_skin_asset("empty.png"))
	theme_resource.set_icon("checking", "Cell", get_skin_asset("checking.png"))
	theme_resource.set_icon("flag", "Cell", get_skin_asset("flag.png"))
	theme_resource.set_icon("flag_bg", "Cell", get_skin_asset("flag_bg.png"))
	theme_resource.set_icon("hidden", "Cell", get_skin_asset("full.png"))
	theme_resource.set_icon("monster_atlas", "Cell", get_skin_asset("monster.png"))
	
	if has_skin_asset("coin.png"):
		theme_resource.set_icon("coin_palette", "Cell", get_skin_asset("coin.png"))
	
	# TODO: load number outline colors
	
	return theme_resource


static func preload_skin_asset(file: String) -> void:
	if file == "monster.png" and not has_skin_asset("monster.png"):
		var task_id := WorkerThreadPool.add_task(generate_monster_atlas_from_gif)
		_skin_assets_worker_thread_ids[file] = task_id
	
	if not has_skin_asset(file):
		return
	
	ResourceLoader.load_threaded_request(get_skin_dir().path_join(file))


static func preload_skin_asset_pack(theme_name: String) -> void:
	var dir := "res://Assets/skins/".path_join(theme_name)
	for file in DirAccess.get_files_at(dir):
		if ResourceLoader.load_threaded_get_status(dir.path_join(file)) in [ResourceLoader.THREAD_LOAD_IN_PROGRESS, ResourceLoader.THREAD_LOAD_LOADED]:
			continue
		if ResourceLoader.exists(dir.path_join(file), "Resource"):
			ResourceLoader.load_threaded_request(dir.path_join(file))


static func get_skin_dir() -> String:
	return "res://Assets/skins/%s/" % theme


static func generate_monster_atlas_from_gif() -> ImageTexture:
	print("monster.png was not found on theme '%s'. Generating monster.png from monster.gif..." % theme)
	
	var gif := GifManager.sprite_frames_from_file(get_skin_dir().path_join("monster.gif"))
	var textures: Array[Texture2D] = [gif.get_frame_texture("gif", 0), gif.get_frame_texture("gif", 1)]
	
	var total_size := Vector2i.ZERO
	for texture in textures:
		total_size += Vector2i(texture.get_width(), maxi(0, texture.get_height() - total_size.y))
	
	var images: Array[Image] = []
	images.assign(textures.map(func(texture: Texture2D): return texture.get_image()))
	
	var out_image := Image.create(total_size.x, total_size.y, false, Image.FORMAT_RGBA8)
	out_image.fill(Color.TRANSPARENT)
	
	var index := 0
	var image := images[0]
	var painted_width := 0
	for x in out_image.get_width():
		if painted_width >= image.get_width():
			index += 1
			image = images[index]
			painted_width = 0
		
		for y in image.get_height():
			out_image.set_pixel(x, y, image.get_pixel(painted_width, y))
		
		painted_width += 1
	
	out_image.save_png(get_skin_dir().path_join("monster.png"))
	
	return ImageTexture.create_from_image(out_image)
