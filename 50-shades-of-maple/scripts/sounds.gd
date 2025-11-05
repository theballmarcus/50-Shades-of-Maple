extends Node

const MAX_PLAYERS = 16

var sounds = {
	"ButtonClicked": preload("res://sounds/ButtonClickSound.mp3"),
}

var players: Array
var backgroundMusic

func _ready():
	for i in MAX_PLAYERS:
		var player = AudioStreamPlayer.new()
		add_child(player)
		players.append(player)
	backgroundMusic = AudioStreamPlayer.new()
	add_child(backgroundMusic)
	
func play_sound(sound_name: String):
	if not sounds.has(sound_name):
		push_warning("Sound not found: %s" % sound_name)
		return
	var sound = sounds[sound_name]

	for player in players:
		if not player.playing:
			player.stream = sound
			player.volume_db = linear_to_db(Gamestate.soundEffectLevel)
			player.play()
			return player
	push_warning("All audio players busy, couldn't play: %s" % sound_name)

#func play_music(sound_name: String="MusicMenu"):
	#backgroundMusic.stream = backgroundSounds[sound_name]
	#backgroundMusic.play()
	
#func _process(delta: float) -> void:
	#backgroundMusic.volume_db = linear_to_db(Gamestate.musicLevel)
	
func linear_to_db(value):
	if value <= 0:
		return -80  
	return 20 * log(value)
