extends Node2D

var CHANNEL = 2
#one sound will be chosen at random
export var SoundLibary :PoolStringArray=[]

func _on_Hurtbox_area_entered(area):
	var sound = SoundLibary[rand_range(0,SoundLibary.size())]
	SoundControler.pub_play_effect(sound,CHANNEL)
	
	queue_free()
