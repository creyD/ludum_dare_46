extends "BossState.gd"

func enter():
	animation_tree.active = false
	animation_player.playback_active = true
	animation_player.play('FightStart')

func _on_animation_finished(anim_name):
	assert(anim_name == 'FightStart')
	emit_signal('finished')
