extends Panel

func _on_SlimeBoss_state_changed(new_state_name):
	$VBoxContainer/State.text = new_state_name


func _on_SlimeBoss_phase_changed(new_phase_name):
	$VBoxContainer/Phase.text = "Phase: " + new_phase_name
