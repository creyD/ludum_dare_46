extends AnimatedSprite

func stomp():
	visible = true
	frame = 0
	play("stomp")

func _animation_finished():
	visible = false
