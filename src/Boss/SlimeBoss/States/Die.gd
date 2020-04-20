extends "res://Boss/SlimeBoss/States/BossState.gd"

func enter():
	animation_player.play("Die")

func _on_animation_finished(anim_name):
	emit_signal("finished")
