extends "res://Boss/SlimeBoss/States/BossState.gd"

func enter():
	$Timer.start()

func update(delta):
	if $Timer.time_left <= 0.0:
		emit_signal('finished')

func exit():
	$Timer.stop()
