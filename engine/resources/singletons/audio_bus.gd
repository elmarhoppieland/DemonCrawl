extends Node
class_name AudioBus

# ==============================================================================
static var _instance: AudioBus

static var master_volume: float = Eternal.create(1.0, "settings") :
	set(value):
		master_volume = value
		AudioServer.set_bus_volume_linear(0, value)
static var music_volume: float = Eternal.create(1.0, "settings") :
	set(value):
		music_volume = value
		AudioServer.set_bus_volume_linear(1, value)
static var effect_volume: float = Eternal.create(1.0, "settings") :
	set(value):
		effect_volume = value
		AudioServer.set_bus_volume_linear(2, value)
static var ambience_volume: float = Eternal.create(1.0, "settings") :
	set(value):
		ambience_volume = value
		AudioServer.set_bus_volume_linear(3, value)
# ==============================================================================
@onready var _music_player: AudioStreamPlayer = %MusicPlayer
@onready var _ambience_a_player: AudioStreamPlayer = %AmbienceAPlayer
@onready var _ambience_b_player: AudioStreamPlayer = %AmbienceBPlayer
# ==============================================================================

func _ready() -> void:
	_instance = self


static func play_music(stream: AudioStream) -> void:
	_instance._music_player.stream = stream
	_instance._music_player.play()


static func stop_music() -> void:
	_instance._music_player.stop()


static func play_effect(stream: AudioStream) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = "EffectPlayer"
	_instance.add_child(player)
	player.bus = &"SoundEffects"
	player.stream = stream
	player.play()
	player.finished.connect(player.queue_free)
	return player


static func play_ambience(stream_a: AudioStream, stream_b: AudioStream) -> void:
	_instance._ambience_a_player.stream = stream_a
	_instance._ambience_a_player.play()
	_instance._ambience_b_player.stream = stream_b
	_instance._ambience_b_player.play()


static func stop_ambience() -> void:
	_instance._ambience_a_player.stop()
	_instance._ambience_b_player.stop()
