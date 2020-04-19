extends "res://Boss/SlimeBoss/States/Motion/MotionState.gd"

func enter():
	owner.get_node("AnimationPlayer").play("MoveDown") # TODO: Replace animation

func handle_input(event):
	return .handle_input(event)

func update(delta):
	var input_direction = get_input_direction()
	if input_direction:
		emit_signal("finished", "move")
