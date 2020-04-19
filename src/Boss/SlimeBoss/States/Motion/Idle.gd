extends "res://Overlap/StateMachine/State.gd"

func enter():
	owner.get_node("AnimationPlayer").play("MoveDown")
 
func hero_close(area):
	emit_signal("finished", "pursue")
