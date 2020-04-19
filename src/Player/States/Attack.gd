extends "res://Player/States/PlayerAnimationState.gd"

func enter():
	animation_playback.travel("hit")

func update(delta):
	animation_tree.set("parameters/hit/blend_position", owner.rollvector)
