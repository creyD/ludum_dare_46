extends KinematicBody2D
class_name Boss
"""
This is an example player controller script created by Paul
"""
var velocity := Vector2.ZERO
# This is how you export variables with ranges to the editor window
export(bool) var debug := false
export(int, 0, 500) var ACCELERATION := 450
# Reference for the current player

onready var player_stats := $Stats
onready var debug_label := $DebugLabel
#onready var animation_player := $AnimationPlayer
#var animation_tree := $AnimationTree
#onready var animation_state = animation_tree.get("parameters/playback")

enum moveState{
	MOVE,
	HIT
}

var movementState = moveState.MOVE

var damage_per_second := 0.0
var totaldamage := 0.0

func _debug_update():
	debug_label.text = str(player_stats.health) + "/" + str(player_stats.max_health) + " HP\n"
	

func _physics_process(delta):
	totaldamage+=damage_per_second*delta
	player_stats.speed+=10*delta
	while(totaldamage>1):
		totaldamage-=1
		player_stats.health-=1
	while(totaldamage<-1):
		totaldamage+=1
		player_stats.health+=1
	_debug_update()
	if debug == true:
		match movementState:
			moveState.MOVE:
				movement_move(delta)
			moveState.HIT:
				movement_hit()
	
	move()

# IMPORTANT: If you are using move_and_slide don't multiply by delta
# Godots physics system does that internally
# In move_and_collide(...) you have to multiply by delta.	
func move():
	move_and_slide(velocity)
	
func movement_move(delta):
	var input_vector = Vector2.ZERO
	# This is a clever way to handle directional input
	# Input.get_action_strength(...) returns a value between 0 and 1 depending
	# on how strong the controller direction is pressed
	# For keyboards it always returns 1 if pressed and 0 if not
	# The actions are custom and defined in the project settings
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y =  Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	
	if input_vector == Vector2.ZERO:
		#animation_state.travel("idle")
		velocity = Vector2.ZERO
	else:
		velocity = velocity.move_toward(player_stats.speed * input_vector, ACCELERATION * delta)
	if Input.is_action_just_pressed("roll"):
		pass
	elif Input.is_action_just_pressed("attack"):
		pass
	
func movement_hit():
	velocity = Vector2.ZERO
	
func hit_finished():
	movementState = moveState.MOVE

func _on_Stats_no_health():
	queue_free()


func _on_Hurtbox_area_entered(area):
	player_stats.health-=area.damage
	damage_per_second = damage_per_second + area.damage


func _on_Hurtbox_area_exited(area):
	damage_per_second = damage_per_second - area.damage
