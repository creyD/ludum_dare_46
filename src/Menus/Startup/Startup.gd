extends AnimatedSprite

func _ready():
	play("begin")


func _animation_finished():
	play("loop")
