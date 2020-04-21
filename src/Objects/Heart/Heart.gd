extends Node2D

var CHANNEL = 2
export var SoundLibary :PoolStringArray=[]


# One walk sound will be chosen at random
func _on_Hurtbox_area_entered(area):
	var sound = SoundLibary[rand_range(0,SoundLibary.size())]
	SoundControler.pub_play_effect(sound,CHANNEL)

	queue_free()
