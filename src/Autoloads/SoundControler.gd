extends Node

const EFFECT_LAYERS:int = 20
var _effect: Array = []
var _music: AudioStreamPlayer

#Playback Options
var _loop: bool = true

#Settings that should be put into an Options script
var _music_volume:int = -12
var _effects_volume:int = -12


func _ready() -> void:
	_music = AudioStreamPlayer.new()
	_music.bus = "BGM"
	_music.volume_db= _music_volume
	_music.connect("finished",self,"sig_music_finished")
	add_child(_music)
	
	for i in range(0,EFFECT_LAYERS):
		_effect.append(AudioStreamPlayer.new())
		_effect[i].volume_db= _effects_volume
		_effect[i].bus = str("Effects",i)
		_effect[i].connect("finished", self, "sig_effect_finished")
		add_child(_effect[i])

func pub_play_music(path:String,should_loop:bool=true)-> void:
	var stream = load(path)
	#AudioServer.set_bus_mute(1, true)
	_music.stop()
	_music.stream = stream
	_music.play()
	_loop=should_loop

func pub_play_effect(path:String,channel:int=0)-> void:
	var stream = load(path)
	#AudioServer.set_bus_mute(1, true)
	_effect[channel].stop()
	_effect[channel].stream = stream
	_effect[channel].play()

func pub_stop_music()-> void:
	_music.stop()

func pub_stop_effect(channel:int)-> void:
	_effect[channel].stop()

func pub_stop_effects()-> void:
	for i in range(0,EFFECT_LAYERS):
		_effect[i].stop()

func pub_stop_all() -> void:
	pub_stop_music()
	pub_stop_effects()

func sig_music_finished() -> void:
	#AudioServer.set_bus_mute(1, false)
	if _loop :
		_music.stop()
		_music.play()
	pass

func sig_effect_finished() -> void:
	#AudioServer.set_bus_mute(1, false)
	pass


