extends "res://Boss/SlimeBoss/States/BossState.gd"

onready var stomp_hitbox = owner.get_node("StompHitbox/CollisionShape2D")

func enter():
	stomp_hitbox.disabled = false

func exit():
	stomp_hitbox.disabled = true

func update(delta):
	play_directional_animation("Charge", owner.last_look)
	
func _on_animation_finished(anim_name):
	anim_name = get_base_anim_name(anim_name)
	assert(anim_name == "Charge")
	
	emit_signal("finished")
