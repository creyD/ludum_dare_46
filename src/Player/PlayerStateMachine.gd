extends "res://Overlap/StateMachine/StateMachine.gd"


func _ready():
	states_map = {
		"idle": $Idle,
		"run": $Run,
		"attack": $Attack,
		"roll": $Roll
	}
