extends Node


signal finished(next_state_name)

func enter():
	"""Initialize the state. E.g. change the animation"""
	return

func exit():
	"""Clean up the state. Reinitialize values like a timer"""
	return

func handle_input(event):
	return

func update(delta):
	return

func _on_animation_finished(anim_name):
	return
