extends StaticBody2D

# This is the decay script for the barrier

# TODO: please adjust it for actual gameplay
export (float, 0.5, 10.0) var decay_time = 1.5

func on_timer_timeout():
	queue_free()


func _ready():
	var time = Timer.new()
	add_child(time)
	time.connect("timeout", self, "on_timer_timeout")
	time.set_wait_time(decay_time)
	time.start()
