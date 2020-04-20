extends "res://Boss/SlimeBoss/States/BossState.gd"

export(float) var SPEED = 800.0

var direction = Vector2()

func enter():
	var player_pos = owner.get_parent().get_node("Player").global_position
	direction = (player_pos - owner.global_position).normalized()

func exit():
	owner.last_look = direction

func update(delta):
	var last_vel = owner.move_and_slide(SPEED * direction)
	play_directional_animation("Move", last_vel)

	if owner.get_slide_count() > 0 or owner.position.x > 1800:
		emit_signal('finished')
