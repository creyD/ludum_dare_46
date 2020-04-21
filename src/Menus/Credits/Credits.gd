extends Node2D

export(String, FILE, "*.tscn,*.scn") var scene_to_load = ""
onready var animation_player = $AnimationPlayer


func _process(delta):
	if Input.is_action_pressed("skip"):
		animation_player.playback_speed = 8.0
	else:
		animation_player.playback_speed = 1.0


func _ready():
	SoundControler.pub_play_music("res://Menus/Credits/Chad_Crouch_-_Algorithms.ogg", false)


func _on_AnimationPlayer_animation_finished(anim_name):
	SoundControler.pub_stop_music()
	get_tree().change_scene(scene_to_load)
