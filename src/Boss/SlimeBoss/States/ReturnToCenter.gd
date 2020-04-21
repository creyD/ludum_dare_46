extends "res://Boss/SlimeBoss/States/BossState.gd"

export(float) var MASS = 4.0
export(float) var SLOW_RADIUS = 200.0
export(float) var MAX_SPEED = 300.0
export(float) var ARRIVE_DISTANCE = 6.0

var velocity = Vector2.ZERO



func update(delta):
	velocity = Steering.arrive_to(velocity, 
								  owner.global_position, 
								  owner.start_global_position,
								  MASS,
								  SLOW_RADIUS, 
								  MAX_SPEED)
	play_directional_animation("Move", velocity)
	SoundControler.pub_play_effect("res://Boss/SlimeBoss/Music/slimy.wav",10)
	owner.move_and_slide(velocity)
	if owner.global_position.distance_to(owner.start_global_position) < ARRIVE_DISTANCE:
		emit_signal('finished')
