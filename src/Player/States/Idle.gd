extends "res://Player/States/PlayerAnimationState.gd"

func enter():
	animation_playback.travel("idle")

func update(delta):
	var input_vector = get_input_direction()
	animation_tree.set("parameters/idle/blend_position", input_vector)
