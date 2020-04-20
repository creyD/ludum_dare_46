extends "res://Boss/SlimeBoss/States/BossState.gd"

func enter():
	SoundControler.pub_play_effect("res://Player/Sounds/hero_laugh1.ogg",10)
	animation_player.play("Die")

func _on_animation_finished(anim_name):	
	emit_signal("finished")

