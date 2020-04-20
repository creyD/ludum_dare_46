extends "res://Boss/SlimeBoss/States/BossState.gd"

onready var stomp_hitbox = owner.get_node("StompHitbox/CollisionShape2D")
onready var stomp_effect = owner.get_node("Effects/StompEffect")

func enter():
	stomp_hitbox.disabled = false
	stomp_effect.stomp()
	SoundControler.pub_play_effect("res://Boss/SlimeBoss/Music/SchleimSplit.wav",10)

func exit():
	stomp_hitbox.disabled = true

func update(delta):
	play_directional_animation("Charge", owner.last_look)
	
func _on_StompEffect_animation_finished():
	emit_signal("finished")

