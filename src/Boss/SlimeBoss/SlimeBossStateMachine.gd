extends "res://Overlap/StateMachine/StateMachine.gd"

onready var hero_close_zone = $HeroCloseZone
onready var debug_label = $DebugLabel

func _ready():
	states_map = {
		"idle": $States/Idle,
		"wander": $States/Wander,
		"pursue": $States/Pursue,
		"split_up": $States/SplitUp,
		"stagger": $States/Stagger,
		"jump_teleport": $States/JumpTeleport,
		"dead": $States/Dead
	}
	
	debug_label.text = "IDLE"

func change_state(state_name):
	current_state.exit()
	debug_label.text = state_name.to_upper()

	if state_name == "previous":
		states_stack.pop_front()
	elif state_name in ["stagger"]:
		states_stack.push_front(states_map[state_name])
	elif state_name == "dead":
		queue_free()
		return
	else:
		var new_state = states_map[state_name]
		states_stack[0] = new_state
	
	current_state = states_stack[0]
	if state_name != "previous":
		# We don"t want to reinitialize the state if we"re going back to the previous state
		current_state.enter()
	emit_signal("state_changed", states_stack)
