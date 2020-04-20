extends KinematicBody2D

signal target_position_changed
signal state_changed(new_state_name)
signal phase_changed(new_phase_name)

export(float) var MASS = 8.0
onready var start_global_position = global_position

var last_look = Vector2()

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
		# target_position = player_node.global_position

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

func _on_Stats_health_changed(new_health):
	if _phase == PHASES.PHASE_ONE and new_health == 2:
		_change_phase(PHASES.PHASE_TWO)
	elif _phase == PHASES.PHASE_TWO and new_health == 1:
		_change_phase(PHASES.PHASE_THREE)
	elif _phase == PHASES.PHASE_THREE and new_health < 1:
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

func _change_phase(new_phase):
	set_invincible(true)
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


var angry_phases_done = 0

func _decide_on_next_state():
	# Battle start
	if state_active == null:
		set_invincible(true)
		return $States/FightStart
	if state_active == $States/FightStart:
		return $States/ChargeSequence
	# Death
	if state_active == $States/Die:
		queue_free()
		# return $States/Dead
	
	if _phase == PHASES.PHASE_ONE:
		if angry_phases_done < 1:
			set_invincible(true)
			sequence_cycles += 1
			if sequence_cycles < 2:
				return $States/ChargeSequence
			else:
				angry_phases_done = 1
				sequence_cycles = 0
				return $States/ReturnToCenter
		else:
			if state_active == $States/ReturnToCenter:
				return $States/Stomp # TODO: Maybe Stomp.
			if state_active == $States/Stomp:
				set_invincible(false)
				return $States/RoamSequence
			if state_active == $States/RoamSequence:
				return $States/ChargeSequence
			if state_active == $States/ChargeSequence:
				return $States/Stomp
	
	if _phase == PHASES.PHASE_TWO:
		if angry_phases_done < 2:
			set_invincible(true)
			if sequence_cycles < 4:
				if state_active == $States/ChargeSequence:
					return $States/Stomp
				if state_active == $States/Stomp:
					sequence_cycles += 1
					return $States/ChargeSequence
				return $States/ChargeSequence
			else:
				angry_phases_done = 2
				sequence_cycles = 0
				return $States/ReturnToCenter
		else:
			if state_active == $States/ReturnToCenter:
				return $States/Stomp # TODO: Maybe Stomp.
			if state_active == $States/Stomp:
				set_invincible(false)
				return $States/RoamSequence
			if state_active == $States/RoamSequence:
				return $States/ChargeSequence
			if state_active == $States/ChargeSequence:
				return $States/Stomp
	
	if _phase == PHASES.PHASE_THREE:
		if angry_phases_done < 3:
			set_invincible(true)
			if sequence_cycles < 6:
				if state_active == $States/ChargeSequence:
					return $States/Stomp
				if state_active == $States/Stomp:
					sequence_cycles += 1
					return $States/ChargeSequence
				return $States/ChargeSequence
			else:
				angry_phases_done = 3
				sequence_cycles = 0
				return $States/ReturnToCenter
		else:
			if state_active == $States/ReturnToCenter:
				return $States/Stomp # TODO: Maybe Stomp.
			if state_active == $States/Stomp:
				set_invincible(false)
				return $States/RoamSequence
			if state_active == $States/RoamSequence:
				return $States/ChargeSequence
			if state_active == $States/ChargeSequence:
				return $States/Stomp

	



func set_invincible(value):
	# $CollisionShape2D.disabled = value
	# $Hitbox/CollisionShape2D.disabled = value
	$Hurtbox/CollisionShape2D.disabled = value

func _on_Hurtbox_area_entered(area):
	$Stats.health -= area.damage

