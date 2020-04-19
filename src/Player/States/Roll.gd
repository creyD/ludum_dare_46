extends "res://Player/States/PlayerAnimationState.gd"

func enter():
	animation_playback.travel("roll")

func update(delta):
	var input_vector = get_input_direction()
	animation_tree.set("parameters/roll/blend_position", owner.rollvector)
