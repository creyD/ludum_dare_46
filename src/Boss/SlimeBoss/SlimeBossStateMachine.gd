extends KinematicBody2D

onready var animation_playback = $AnimationTree.get("parameters/playback")
signal target_position_changed
signal state_changed(new_state_name)
signal phase_changed(new_phase_name)

export(float) var MASS = 8.0
onready var start_global_position = global_position

var target_position = Vector2()

var state_active = null
var sequence_cycles = 0

enum PHASES {PHASE_ONE, PHASE_TWO, PHASE_THREE}
export(PHASES) var _phase = PHASES.PHASE_ONE

func _ready():
	print("Hey.")
	_change_phase(_phase)
	$AnimationPlayer.play("__INIT__")

	# We check if the Player node is a sibling so that we don't get errors
	# playing the WildBoar scene
	if get_parent().has_node('Player'):
		var player_node = get_parent().get_node('Player')
		player_node.connect('position_changed', self, '_on_target_position_changed')
		target_position = player_node.global_position

	for state_node in $States.get_children():
		state_node.connect('finished', self, '_on_active_state_finished')
	go_to_next_state()


func _physics_process(delta):
	state_active.update(delta)


func _on_animation_finished(anim_name):
	state_active._on_animation_finished(anim_name)


func _on_active_state_finished():
	go_to_next_state()


# Well.. guess I'll die.
func _on_Stats_no_health():
	print("dead")
	set_invincible(true)
	go_to_next_state($States/Die)


func go_to_next_state(state_override=null):
	if state_active:
		state_active.exit()
		
	if state_override != null:
		state_active = state_override
	else:
		state_active = _decide_on_next_state()
	emit_signal("state_changed", state_active.name)
	state_active.enter()


func _on_Health_health_changed(new_health):
	$Tween.interpolate_property($Pivot, 'scale', Vector2(0.92, 1.12), Vector2(1.0, 1.0), 0.3, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Pivot/Body, 'modulate', Color('#ff48de'), Color('#ffffff'), 0.2, Tween.TRANS_QUINT, Tween.EASE_IN)
	$Tween.start()
	
	if _phase == PHASES.PHASE_ONE and new_health < 100:
		_change_phase(PHASES.PHASE_TWO)
	if _phase == PHASES.PHASE_TWO and new_health < 50:
		_change_phase(PHASES.PHASE_THREE)


func _change_phase(new_phase):
	var phase_name = ""
	match new_phase:
		PHASES.PHASE_ONE:
			$AnimationPlayer.playback_speed = 1.0
			phase_name = "One"
		PHASES.PHASE_TWO:
			$AnimationPlayer.playback_speed = 1.4
			phase_name = "Two"
		PHASES.PHASE_THREE:
			$AnimationPlayer.playback_speed = 1.8
			phase_name = "Three"
	
	emit_signal("phase_changed", phase_name)
	_phase = new_phase


# The AI's brain. This function defines the flow of states
# That's a big advantage of the state pattern
# If it grows too big you can swap it with a node
# Or move the flow of states to a data file, like JSON or a text file
func _decide_on_next_state():
	# Battle start
	if state_active == null:
		set_invincible(true)
		return $States/FightStart
	if state_active == $States/FightStart:
		set_invincible(false)
		return $States/RoamSequence
	if state_active == $States/RoamSequence:
		return $States/FightStart
	
#	# Death
#	if state_active == $States/Die:
#		queue_free()
#		return $States/Dead
#
#	# PHASE ONE
#	if _phase == PHASES.PHASE_ONE:
#		if state_active == $States/RoamSequence:
#			sequence_cycles += 1
#			if sequence_cycles < 2:
#				return $States/RoamSequence
#			else:
#				sequence_cycles = 0
#				return $States/Stomp
#		if state_active == $States/Stomp:
#			return $States/RoamSequence
#
#	# PHASE TWO
#	elif _phase == PHASES.PHASE_TWO:
#		if state_active == $States/RoamSequence:
#			return $States/Stomp
#		if state_active == $States/Stomp:
#			if sequence_cycles < 2:
#				sequence_cycles += 1
#				return $States/Stomp
#			else:
#				sequence_cycles = 0
#				return $States/ChargeSequence
#		if state_active == $States/ChargeSequence:
#			return $States/RoamSequence
#
#
#	# PHASE THREE
#	elif _phase == PHASES.PHASE_THREE:
#		if state_active == $States/RoamSequence:
#			return $States/Stomp
#		if state_active == $States/Stomp:
#			if sequence_cycles < 2:
#				sequence_cycles += 1
#				return $States/Stomp
#			else:
#				sequence_cycles = 0
#				return $States/ChargeSequence
#		if state_active == $States/ChargeSequence:
#			if sequence_cycles < 2:
#				sequence_cycles += 1
#				return $States/ChargeSequence
#			else:
#				sequence_cycles = 0
#				return $States/Stomp


# Using a public method makes it so we can change the entire particle setup anytime
func set_particles_active(value):
	$DustPuffsLarge.emitting = value


# Same thing here, we will likely need more collision shapes in the final version
# So using a function we can group these disabled toggles together
func set_invincible(value):
	$CollisionShape2D.disabled = value
	$Hitbox/CollisionShape2D.disabled = value
	$Hurtbox/CollisionShape2D.disabled = value


func _on_target_position_changed(new_position):
	target_position = new_position


func _on_Hurtbox_area_entered(area):
	$Stats.health -= area.damage

