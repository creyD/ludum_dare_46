extends KinematicBody2D
class_name Player
"""
This is an example player controller script created by Paul
"""
var velocity := Vector2.ZERO
# This is how you export variables with ranges to the editor window
export(int, 0, 500) var MAX_SPEED = 125
export(int, 0, 500) var FRICTION = 200 # Speed at which the player deaccelarates
export(int, 0, 500) var ACCELERATION = 450

func _physics_process(delta):
	"""
	Run approximately every 1/60th of a second by default.
	@param delta, so the time since lastt frame, should be pretty constant at 1/60 by default.
	"""
	# If a constant is applicable, use it instead of creating the object yourself
	var input_vector := Vector2.ZERO
	# This is a clever way to handle directional input
	# Input.get_action_strength(...) returns a value between 0 and 1 depending
	# on how strong the controller direction is pressed
	# For keyboards it always returns 1 if pressed and 0 if not
	# The actions are custom and defined in the project settings
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y =  Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	
	if input_vector == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	else:
		velocity = velocity.move_toward(MAX_SPEED * input_vector, ACCELERATION * delta)
	
	# IMPORTANT: If you are using move_and_slide don't multiply by delta
	# Godots physics system does that internally
	# In move_and_collide(...) you have to multiply by delta.
	move_and_slide(velocity)
