extends Hero
class_name Player
"""
This is an example player controller script created by Paul
"""
var velocity := Vector2.ZERO
var rollvector := Vector2.ZERO

# This is how you export variables with ranges to the editor window
export(bool) var debug := false
export(int, 0, 500) var ROLL_SPEED := 150
export(int, 0, 500) var FRICTION := 200 # Speed at which the player deaccelarates
export(int, 0, 500) var ACCELERATION := 450

# Reference for the current player
onready var player_stats := $Stats
onready var debug_label := $DebugLabel
onready var animation_state := $AnimationStates

# Variables for sound selection
var _rng = RandomNumberGenerator.new()
var is_playing_sound = false


export(String, FILE, "*.tscn,*.scn") var title_scene = ""

enum moveState{
	MOVE,
	ROLL,
	HIT,
	IDLE
}

var movementState = moveState.MOVE

var damage_per_second := 0.0
var heal_per_second := 0.0
var totaldamage := 0.0

var currency := 0
var experience := 0.0

func _debug_update():
	debug_label.text = str(player_stats.health) + "/" + str(player_stats.max_health) + " HP\n" + str(currency) + " €"


func _ready():
	grid = get_tree().current_scene.get_node("Grid")


func _physics_process(delta):
	totaldamage += (damage_per_second - heal_per_second) * delta
	player_stats.speed += 10 * delta
	while totaldamage > 1:
		totaldamage -= 1
		player_stats.health-=1
	while totaldamage < -1:
		totaldamage += 1
		player_stats.health += 1
	adjustPrio(player_stats.health, player_stats.max_health)
	_debug_update()
	if debug:
		match movementState:
			moveState.MOVE:
				movement_move(delta)
			moveState.IDLE:
				movement_move(delta)
			moveState.ROLL:
				movement_roll()
			moveState.HIT:
				movement_hit()
	else:
		if movementState == moveState.ROLL:
			movement_roll()
		elif movementState == moveState.HIT:
			movement_hit()
		elif movementState == moveState.IDLE:
			movement_idle()
		else:
			movement_run(Vector2(0,0), delta)
		makeMove(delta)
	move()
	$"Effects/HealEffect".emitting = heal_per_second > 0


# IMPORTANT: If you are using move_and_slide don't multiply by delta
# Godots physics system does that internally
# In move_and_collide(...) you have to multiply by delta.	
func move():
	move_and_slide(velocity)


# API Interface for ai_hero
func attac(direction, delta):
	direction = direction.normalized()
	rollvector = direction
	movementState = moveState.HIT


# API Interface for ai_hero
func roll(direction, delta):
	direction = direction.normalized()
	rollvector = direction
	movementState = moveState.ROLL


# API Interface for ai_hero
func run(direction, delta):
	direction = direction.normalized()
	rollvector = direction
	movementState = moveState.MOVE
	velocity = velocity.move_toward(player_stats.speed * rollvector, ACCELERATION * delta)
	
	if direction == Vector2.ZERO:
		animation_state.change_state("idle")
	else:
		animation_state.change_state("run")


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
		animation_state.change_state("idle")
		velocity = Vector2.ZERO
	else:
		rollvector = input_vector
		animation_state.change_state("run")	
		velocity = velocity.move_toward(player_stats.speed * input_vector, ACCELERATION * delta)
	if Input.is_action_just_pressed("roll"):
		movementState = moveState.ROLL
	elif Input.is_action_just_pressed("attack"):
		movementState = moveState.HIT


func movement_hit():
	velocity = Vector2.ZERO
	animation_state.change_state("attack")


func hit_finished():
	movementState = moveState.IDLE
	ai_movement_state = STEP
	ExecutionState = EXECUTING


func movement_roll():
	velocity = rollvector * ROLL_SPEED
	animation_state.change_state("roll")
	
	"""
	# Roll.gd
	func enter():
		owner.animation_state.travel("roll")
	
	func update():
		owner.velocity = rollvector * ROLL_SPEED
	"""
	ExecutionState = EXECUTING


func roll_finished():
	movementState = moveState.IDLE
	ai_movement_state = STEP
	ExecutionState = EXECUTING


func _on_Hurtbox_area_entered(area):
	player_stats.health -= area.damage
	
	if area.damage > 0:
		damage_per_second += area.damage
	else:
		heal_per_second += abs(area.damage)


func _on_Hurtbox_area_exited(area):
	if area.damage > 0:
		damage_per_second -= area.damage
	else:
		heal_per_second -= abs(area.damage)


func _on_Stats_no_health():
	queue_free()
	get_tree().change_scene("res://Menus/TitleScreen/TitleScreen.tscn")
	

func _on_Hitbox_area_entered(area):
	currency += area.currency_value
	player_stats.health += area.health_value
	player_stats.speed -= area.slowdown_value


func movement_run(direction, delta):
	run(direction, delta)


func movement_idle():
	movementState = moveState.IDLE
	velocity = Vector2.ZERO
	animation_state.change_state("idle")


func _on_SwordRange_area_entered(area):
	if(area.is_in_group("HittableByPlayer")):
		areaRefList.push_back(area.get_instance_id())


func _on_SwordRange_area_exited(area):
	if(area.is_in_group("HittableByPlayer")):
		areaRefList.erase(area.get_instance_id())
