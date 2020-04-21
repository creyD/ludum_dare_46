extends 'State.gd'

var state_active = null


func _ready():
	SoundControler.pub_play_effect("res://Boss/SlimeBoss/Music/SchleimSplit3.wav",10)
	for child in get_children():
		child.connect('finished', self, '_on_state_active_finished')


func enter():
	state_active = get_child(0)
	state_active.enter()


func exit():
	state_active = null


func update(delta):
	state_active.update(delta)


func _on_animation_finished(anim_name):
	state_active._on_animation_finished(anim_name)


func _on_state_active_finished():
	go_to_next_state_in_sequence()


func go_to_next_state_in_sequence():
	state_active.exit()
	var new_state_index = (state_active.get_index() + 1) % get_child_count()
	if new_state_index == 0:
		emit_signal('finished')
		return
	state_active = get_child(new_state_index)

	state_active.enter()
