extends "../BossState.gd"

export(float) var ARRIVE_DISTANCE = 6.0
export(float) var SLOW_RADIUS = 200.0
export(float) var MASS = 5.0
export(float) var MAX_SPEED = 300.0
export(float) var ROAM_RADIUS = 200.0

var time_since_start = 0

var target_position = Vector2()
var start_position = Vector2()
var velocity = Vector2()
var last_vel = Vector2()

func enter():
	# Set animation
	set_animation_type(ANIMATION_TYPE.TREE)
	animation_playback.start("move")
	
	time_since_start = 0
	start_position = get_parent().start_position
	target_position = calculate_new_target_position()


func update(delta):
	velocity = Steering.arrive_to(velocity, owner.global_position, target_position, MASS, SLOW_RADIUS, MAX_SPEED)
	time_since_start += delta
	last_vel = owner.move_and_slide(velocity)
	animation_tree.set("parameters/move/blend_position", last_vel)
	
	if owner.global_position.distance_to(target_position) < ARRIVE_DISTANCE or time_since_start > 2.0:
		emit_signal('finished')


func calculate_new_target_position():
	randomize()
	var random_angle = randf() * 2 * PI
	randomize()
	var random_radius = (randf() * ROAM_RADIUS) / 2 + ROAM_RADIUS / 2
	return start_position + Vector2(cos(random_angle) * random_radius, sin(random_angle) * random_radius)
