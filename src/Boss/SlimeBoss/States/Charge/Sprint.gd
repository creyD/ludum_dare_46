extends "res://Boss/SlimeBoss/States/BossState.gd"

export(float) var SPEED = 1000.0

var player_pos = owner.get_parent().get_node("Player").global_position
var direction = Vector2()

func enter():
	# Set animation
	set_animation_type(ANIMATION_TYPE.TREE)
	animation_playback.play("move")
	
	direction = (player_pos - owner.global_position).normalized()
	owner.set_particles_active(true)

func exit():
	owner.set_particles_active(false)

func update(delta):
	owner.move_and_slide(SPEED * direction)

	if owner.get_slide_count() > 0 or owner.position.x > 1800:
		emit_signal('finished')
