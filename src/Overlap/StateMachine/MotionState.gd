extends "res://Overlap/StateMachine/State.gd"

func get_input_direction():
	var input_direction = Vector2()
	input_direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	input_direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	input_direction = input_direction.normalized()
	return input_direction
