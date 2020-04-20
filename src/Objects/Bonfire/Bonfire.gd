extends StaticBody2D

func _sound_finished():
	SoundControler.pub_play_effect("res://Objects/Bonfire/Bonfire.wav",3)

func _ready():
	SoundControler.pub_play_effect("res://Objects/Bonfire/Bonfire.wav",3)
	SoundControler._effect[3].volume_db = -20
	SoundControler._effect[3].connect("finished",self,"_sound_finished")

func _on_Hurtbox_area_entered(area):
	queue_free()
