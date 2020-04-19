extends "res://Player/States/PlayerAnimationState.gd"

func enter():
	animation_playback.travel("run")

func update(delta):
	var input_vector = get_input_direction()
	animation_tree.set("parameters/run/blend_position", input_vector)
