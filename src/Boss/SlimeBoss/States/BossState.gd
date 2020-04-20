extends "res://Overlap/StateMachine/State.gd"

onready var animation_player = owner.get_node("AnimationPlayer")
onready var animation_tree = owner.get_node("AnimationTree")
onready var animation_playback = animation_tree.get("parameters/playback")

var _animation_type = ANIMATION_TYPE.TREE

enum ANIMATION_TYPE {
	PLAYER,
	TREE
}

func set_animation_type(val):
	print("wow")
	_animation_type = val
	animation_player.playback_active = _animation_type == ANIMATION_TYPE.PLAYER
	animation_tree.active = _animation_type == ANIMATION_TYPE.TREE
	

