extends Node2D


func _on_Hurtbox_area_entered(area):
	SoundControler.pub_play_effect("res://Objects/Rubies/emerald3.wav",8)
	queue_free()
