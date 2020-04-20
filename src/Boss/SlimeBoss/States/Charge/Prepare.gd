extends "res://Boss/SlimeBoss/States/BossState.gd"

onready var charge_effect = owner.get_node("Effects/ChargeEffect")

func enter():
	charge_effect.emitting = true
	animation_player.play('Charging')
	$Timer.start()

func exit():
	charge_effect.emitting = false
	$Timer.stop()

func update(delta):
	if $Timer.time_left <= 0.0:
		emit_signal('finished')
