extends Node2D


func _on_Hurtbox_area_entered(area):
	SoundControler.pub_play_effect("res://Objects/Slime/Schleim.wav",3)	
