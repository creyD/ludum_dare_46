extends Node2D

export(float,0.1,10.0) var burning_time = 2.0
var timer = Timer.new()


func on_timer_timeout():
	timer.stop()
	queue_free()

func _ready():
	$Sprite.play("burn")
	add_child(timer)
	timer.connect("timeout", self, "on_timer_timeout")
	timer.set_wait_time(burning_time)
	timer.start()
	



func _on_Hitbox_body_entered(body):
	if(body.get_name() == "Player"):
		body.velocity*=-3

