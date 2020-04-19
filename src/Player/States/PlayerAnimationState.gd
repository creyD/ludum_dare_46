extends "res://Overlap/StateMachine/MotionState.gd"

onready var animation_player := get_node("../../AnimationPlayer")
onready var animation_tree := get_node("../../AnimationTree")
onready var animation_playback = animation_tree.get("parameters/playback")
