extends "../BossState.gd"

export(float) var ARRIVE_DISTANCE = 6.0
export(float) var SLOW_RADIUS = 200.0
export(float) var MASS = 5.0
export(float) var MAX_SPEED = 300.0
export(float) var ROAM_RADIUS = 100.0

var time_since_start = 0

var target_position = Vector2()
var start_position = Vector2()
var velocity = Vector2()
var last_vel = Vector2()

func enter():
	start_position = get_parent().start_position
	target_position = calculate_new_target_position()
	$Timer.start()

func exit():
	owner.last_look = last_vel
	$Timer.stop()


func update(delta):
	# Set animation
	velocity = Steering.arrive_to(velocity, owner.global_position, target_position, MASS, SLOW_RADIUS, MAX_SPEED)
	last_vel = owner.move_and_slide(velocity)
	
	play_directional_animation("Move", last_vel)

	if owner.global_position.distance_to(target_position) < ARRIVE_DISTANCE or $Timer.time_left <= 0.0:
		emit_signal('finished')


func calculate_new_target_position():
	randomize()
	var random_angle = randf() * 2 * PI
	randomize()
	var random_radius = (randf() * ROAM_RADIUS) / 2 + ROAM_RADIUS / 2
	return start_position + Vector2(cos(random_angle) * random_radius, sin(random_angle) * random_radius)
