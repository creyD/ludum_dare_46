extends KinematicBody2D
class_name Player
"""
This is an example player controller script created by Paul
"""
var velocity := Vector2.ZERO
var rollvector := Vector2.ZERO
# This is how you export variables with ranges to the editor window
export(int, 0, 500) var ROLL_SPEED := 150
export(int, 0, 500) var FRICTION := 200 # Speed at which the player deaccelarates
export(int, 0, 500) var ACCELERATION := 450
# Reference for the current player

onready var player_stats := $Stats
onready var debug_label := $DebugLabel
onready var animation_player := $AnimationPlayer
onready var animation_tree := $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")

enum moveState{
	MOVE,
	ROLL,
	HIT
}

var movementState = moveState.MOVE

var damage_per_second := 0.0
var totaldamage := 0.0

var currency := 0
var experience := 0.0

func _debug_update():
	debug_label.text = str(player_stats.health) + "/" + str(player_stats.max_health) + " HP\n" + str(currency) + " €"
	

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
	match movementState:
		moveState.MOVE:
			movement_move(delta)
		moveState.ROLL:
			movement_roll()
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
		animation_state.travel("idle")
		velocity = Vector2.ZERO
	else:
		rollvector = input_vector
		animation_tree.set("parameters/idle/blend_position", input_vector)
		animation_tree.set("parameters/hit/blend_position", input_vector)
		animation_tree.set("parameters/roll/blend_position", input_vector)
		animation_tree.set("parameters/run/blend_position", input_vector)
		animation_state.travel("run")	
		velocity = velocity.move_toward(player_stats.speed * input_vector, ACCELERATION * delta)
	if Input.is_action_just_pressed("roll"):
		movementState = moveState.ROLL
	elif Input.is_action_just_pressed("attack"):
		movementState = moveState.HIT
	
func movement_hit():
	velocity = Vector2.ZERO
	animation_state.travel("hit")
	
func hit_finished():
	movementState = moveState.MOVE
	
func movement_roll():
	velocity = rollvector * ROLL_SPEED
	animation_state.travel("roll")
	
func roll_finished():
	movementState = moveState.MOVE


func _on_Hurtbox_area_entered(area):
	player_stats.health-=area.damage
	damage_per_second = damage_per_second + area.damage

func _on_Hurtbox_area_exited(area):
	damage_per_second = damage_per_second - area.damage


func _on_Stats_no_health():
	queue_free()
	get_tree().change_scene("res://Menus/TitleScreen/TitleScreen.tscn")
	



func _on_Hitbox_area_entered(area):
	currency += area.currency_value
	player_stats.health = player_stats.health+area.health_value
	player_stats.speed -= area.slowdown_value
