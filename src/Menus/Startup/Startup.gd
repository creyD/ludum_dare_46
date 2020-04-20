extends AnimatedSprite

onready var timer = $Timer

func _ready():
	timer.connect("timeout", self, "_timeout")

func start():
	timer.set_wait_time(0.25)
	timer.start()

func _timeout():
	play("begin")

func _animation_finished():
	play("loop")
