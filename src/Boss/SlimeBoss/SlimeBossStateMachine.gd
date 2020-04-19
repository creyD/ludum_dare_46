extends "res://Overlap/StateMachine/StateMachine.gd"

func _ready():
	states_map = {
		"idle": $Idle,
		"wander": $Wander,
		"split_up": $SplitUp,
		"stagger": $Stagger
	}
