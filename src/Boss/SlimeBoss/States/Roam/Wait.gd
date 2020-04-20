extends "res://Boss/SlimeBoss/States/BossState.gd"

func enter():
	set_animation_type(ANIMATION_TYPE.PLAYER)
	# owner.get_node('AnimationPlayer').play('idle')
	$Timer.start()

func update(delta):
	if $Timer.time_left <= 0.0:
		emit_signal('finished')

func exit():
	$Timer.stop()
