extends Node2D

export(String, FILE, "*.tscn,*.scn") var scene_to_load = ""
onready var animation_player = $AnimationPlayer

func _process(delta):
	if Input.is_action_pressed("skip"):
		animation_player.playback_speed = 8.0
	else:
		animation_player.playback_speed = 1.0
		

func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene(scene_to_load)
