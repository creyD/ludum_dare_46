extends "res://Player/States/PlayerAnimationState.gd"

#the channel on which the sound is played
const CHANNEL=1

#one sound will be chosen at random
export var SoundLibary :PoolStringArray=[]
#the delay between 2 sounds being played, a new sound will only start if the old one is finished
export(float,0,5) var Delay = 0.2

var is_playing_sound:bool =false
var delay_passed:bool=true
var timer:Timer

func _ready():
	timer=Timer.new()
	self.add_child(timer)
	timer.connect("timeout",self,"sig_timer_timeout")
	SoundControler._effect[CHANNEL].connect("finished", self, "sig_walk_sound_finished")

func enter():
	animation_playback.travel("run")

func update(delta):
	var input_vector = get_input_direction()
	animation_tree.set("parameters/run/blend_position", input_vector)
	_play_random_sound()

func _play_random_sound():
	if delay_passed and is_playing_sound==false:
		var sound = SoundLibary[rand_range(0,SoundLibary.size())]
		SoundControler.pub_play_effect(sound,CHANNEL)
		
		is_playing_sound = true
		delay_passed=false
		#timer.start(Delay)


func sig_timer_timeout ():
	delay_passed=true

func sig_walk_sound_finished():
	is_playing_sound = false
	timer.start(Delay)
